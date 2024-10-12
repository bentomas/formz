///////   field related functions

import forma/field.{type Field, Field}
import forma/input.{type Input}
import gleam/dict
import gleam/list
import gleam/result

pub opaque type Form(format, output) {
  Form(
    fields: List(Field(format)),
    parse: fn(List(Field(format))) -> Result(output, List(Field(format))),
  )
}

pub fn with(
  definition: Input(format, input_output),
  fun: fn(input_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  let field = definition.field
  let next = fun(definition.default)
  Form([field, ..next.fields], parse: fn(fields) {
    // pull out the latest version of this field to get latest data
    let assert [field, ..next_fields] = fields

    let input_output = definition.transform(field.value)

    let next_form = fun(input_output |> result.unwrap(definition.default))
    let form_output = next_form.parse(next_fields)

    case form_output, input_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so add it to the list
      // of fields as is.
      Error(fields), Ok(_value) -> Error([field, ..fields])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        field |> field.set_error(error) |> list.prepend(next_fields, _) |> Error

      // form already has errors and this field errored, so add this field
      // to the list of errors
      Error(fields), Error(error) ->
        field |> field.set_error(error) |> list.prepend(fields, _) |> Error
    }
  })
}

pub fn data(
  form: Form(format, output),
  input: List(#(String, String)),
) -> Form(format, output) {
  let data = dict.from_list(input)
  let Form(fields, parse) = form
  fields
  |> list.map(fn(field) {
    case dict.get(data, field.name) {
      Ok(value) ->
        Field(
          name: field.name,
          label: field.label,
          help_text: field.help_text,
          render: field.render,
          value: value,
        )
      Error(_) -> field
    }
  })
  |> Form(parse)
}

pub fn create_form(thing: thing) -> Form(format, thing) {
  Form([], fn(_) { Ok(thing) })
}

pub fn parse(form: Form(format, output)) -> Result(output, Form(format, output)) {
  // we've tagged that we have a decoder with out has_decoder phantom type
  // so we can get away with let assert here
  let Form(fields, parse) = form
  case parse(fields) {
    Ok(output) -> Ok(output)
    Error(fields) -> Error(Form(fields, parse))
  }
}

pub fn parse_and_try(
  form: Form(format, output),
  apply fun: fn(output, Form(format, output)) -> Result(c, Form(format, output)),
) -> Result(c, Form(format, output)) {
  parse(form) |> result.try(fun(_, form))
}

pub fn get_fields(form: Form(format, ouput)) -> List(Field(format)) {
  form.fields
}

pub fn field_update(
  form: Form(format, output),
  name: String,
  fun: fn(Field(format)) -> Field(format),
) -> Form(format, output) {
  form.fields
  |> list.map(fn(field) {
    case field.name == name {
      True -> fun(field)
      False -> field
    }
  })
  |> Form(form.parse)
}
