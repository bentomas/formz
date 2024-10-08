// https://docs.djangoproject.com/en/5.0/topics/forms/
// https://github.com/nakaixo/nakai
// date time handling https://hexdocs.pm/birl/index.html

// TODO
// - list fields
// - form sets
// - csrf token
// - data order doesn't matter
// - required/option

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type HasDecoder

pub type NoDecoder

pub type FieldsWithErrors(format) =
  List(Field(format))

pub opaque type Form(format, output, decoder, has_decoder) {
  Form(
    fields: List(Field(format)),
    parse_with: fn(List(Field(format)), decoder) ->
      Result(output, FieldsWithErrors(format)),
    decoder: Option(decoder),
  )
}

pub type Field(format) {
  Field(
    name: String,
    label: String,
    help_text: String,
    render: fn(Field(format)) -> format,
    value: String,
  )
  InvalidField(
    name: String,
    label: String,
    help_text: String,
    render: fn(Field(format)) -> format,
    value: String,
    error: String,
  )
}

pub type Input(output, format) {
  Input(
    render: fn(Field(format)) -> format,
    validate: fn(String) -> Result(output, String),
  )
}

pub fn new() -> Form(format, a, a, NoDecoder) {
  Form([], fn(_, output) { Ok(output) }, None)
}

pub fn add(
  form: Form(format, fn(b) -> c, a, has_decoder),
  thing: #(Field(format), fn(String) -> Result(b, String)),
) -> Form(format, c, a, has_decoder) {
  let #(field, validate) = thing
  case form {
    Form(fields, parse_with, decoder) -> {
      // create new form with the new field and update the parse
      // function to handle the new details from the type of the
      // field
      Form(
        fields: [field, ..fields],
        parse_with: fn(fields, decoder: a) {
          let assert [field, ..rest] = fields
          case parse_with(rest, decoder), validate(field.value) {
            // the form we've already parsed has no errors and the field
            // we just parsed has no errors.  so we can move on to the next
            Ok(next), Ok(value) -> Ok(next(value))

            // the form already has errors even though this one succeeded.
            // so add this to the list and stop anymore parsing
            Error(fields), Ok(_value) -> Error([field, ..fields])

            // form was good so far, but this field errored, so need to
            // mark this field as invalid and return all the fields we've got
            // so far
            Ok(_), Error(error) ->
              Error([
                InvalidField(
                  name: field.name,
                  label: field.label,
                  help_text: field.help_text,
                  render: field.render,
                  value: field.value,
                  error: error,
                ),
                ..rest
              ])

            // form already has errors and this field errored, so add this field
            // to the list
            Error(fields), Error(error) ->
              Error([
                InvalidField(
                  name: field.name,
                  label: field.label,
                  help_text: field.help_text,
                  render: field.render,
                  value: field.value,
                  error: error,
                ),
                ..fields
              ])
          }
        },
        decoder:,
      )
    }
    // FormWithErrors(fields) -> FormWithErrors([field, ..fields])
  }
}

pub fn data(
  form: Form(a, b, format, has_decoder),
  input: List(#(String, String)),
) -> Form(a, b, format, has_decoder) {
  case form {
    Form(fields, parse_with, decoder) -> {
      fields
      // we always prepend fields, so reverse to get correct order
      // TODO I think we're going to make it so order doesn't matter
      |> list.reverse
      |> do_add_input_data(input, [])
      |> Form(parse_with, decoder)
    }
    // FormWithErrors(..) -> form
  }
}

fn do_add_input_data(
  fields: List(Field(format)),
  data: List(#(String, String)),
  acc: List(Field(format)),
) {
  case fields, data {
    // no more fields, we've return all the fields with data we have accumulated
    [], _ -> acc
    // no more data!  return all the fields we have left plus the ones we accumulated
    _, [] -> list.append(fields, acc)
    // we have a field and data, and the names match. update field to have data
    [Field(name: field_name, ..) as field, ..fields_rest],
      [#(data_name, value), ..data_rest]
      if field_name == data_name
    ->
      do_add_input_data(fields_rest, data_rest, [
        Field(
          name: field_name,
          label: field.label,
          help_text: field.help_text,
          render: field.render,
          value: value,
        ),
        ..acc
      ])
    // at this point we still have fields and data left, but the first
    // field and first data don't match. so we decide we've got no data
    // for the first field and move on to the next. but we need to add
    // this field without data to the accumulator
    [field, ..fields_rest], _ ->
      do_add_input_data(fields_rest, data, [field, ..acc])
  }
}

pub fn decodes(
  form: Form(format, output, decoder, has_decoder),
  decoder: decoder,
) -> Form(format, output, decoder, HasDecoder) {
  // can use let assert here because you can't have errors if you
  // haven't tried to parse and decode, which you can't do without
  // a decoder
  let Form(fields, parse_with, _) = form

  Form(fields, parse_with, Some(decoder))
}

pub fn decoded(
  form: Form(format, output, decoder, HasDecoder),
) -> Result(output, Form(format, output, decoder, HasDecoder)) {
  let assert Form(fields, parse_with, Some(decoder)) = form
  case parse_with(fields, decoder) {
    Ok(output) -> Ok(output)
    Error(fields) -> Error(Form(fields, parse_with, Some(decoder)))
  }
}

pub fn decode_and_try(
  form: Form(format, output, decoder, HasDecoder),
  apply fun: fn(output, Form(format, output, decoder, HasDecoder)) ->
    Result(c, Form(format, output, decoder, HasDecoder)),
) -> Result(c, Form(format, output, decoder, HasDecoder)) {
  decoded(form) |> result.try(fun(_, form))
}

pub fn get_fields(form: Form(format, a, b, has_decoder)) -> List(Field(format)) {
  form.fields |> list.reverse
}

pub fn set_field_error(
  form: Form(format, output, decoder, has_decoder),
  name: String,
  error: String,
) -> Form(format, output, decoder, has_decoder) {
  let updated =
    form.fields
    |> list.map(fn(field) {
      case field.name == name {
        True ->
          InvalidField(
            name: field.name,
            label: field.label,
            help_text: field.help_text,
            render: field.render,
            value: field.value,
            error: error,
          )
        False -> field
      }
    })
  Form(updated, form.parse_with, form.decoder)
}
