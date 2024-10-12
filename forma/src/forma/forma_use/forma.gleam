///////   field related functions

import forma/field.{type Field}
import forma/input.{type Input, Input}
import gleam/dict
import gleam/list
import gleam/result

pub opaque type Form(format, output) {
  Form(
    inputs: List(Input(format)),
    parse: fn(List(Input(format))) -> Result(output, List(Input(format))),
  )
}

pub fn with(
  field: Field(format, input_output),
  fun: fn(input_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  // we pass in our default value, and we're going to throw away the
  // decoded result here, we just care about pulling out the fields
  // from the form.
  let next = fun(field.default)

  // prepend the new input to the inputs from the form we got in the
  // previous step.
  let updated_inputs = [field.input, ..next.inputs]

  // now create the parse function. parse function accepts most recent
  // version of input list, since data can be added to it.  the list
  // above we just needed for the initial setup.
  let parse = fn(inputs: List(Input(format))) {
    // pull out the latest version of this field to get latest input data
    let assert [input, ..next_inputs] = inputs

    // transform the input data using the transform/validate/decode/etc function
    let input_output = field.transform(input.value)

    // pass our transformed input data to the next function/form. if
    // we errored we still do this with our default so we can continue
    // processing all the fields in the form.  we will return a form
    // with an error, so if we're on the error track we'll throw away
    // the "output" made with this and just keep the errors.
    let next_form = fun(input_output |> result.unwrap(field.default))
    let form_output = next_form.parse(next_inputs)

    // ok, check which track we're on
    case form_output, input_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so add it to the list
      // of fields as is.
      Error(inputs), Ok(_value) -> Error([input, ..inputs])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        input
        |> input.set_error(error)
        |> list.prepend(next_inputs, _)
        |> Error

      // form already has errors and this field errored, so add this field
      // to the list of errors
      Error(fields), Error(error) ->
        input
        |> input.set_error(error)
        |> list.prepend(fields, _)
        |> Error
    }
  }
  Form(updated_inputs, parse: parse)
}

pub fn data(
  form: Form(format, output),
  input_data: List(#(String, String)),
) -> Form(format, output) {
  let data = dict.from_list(input_data)
  let Form(fields, parse) = form
  fields
  |> list.map(fn(field) {
    case dict.get(data, field.name) {
      Ok(value) ->
        Input(
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

pub fn get_inputs(form: Form(format, ouput)) -> List(Input(format)) {
  form.inputs
}

pub fn update_input(
  form: Form(format, output),
  name: String,
  fun: fn(Input(format)) -> Input(format),
) -> Form(format, output) {
  form.inputs
  |> list.map(fn(field) {
    case field.name == name {
      True -> fun(field)
      False -> field
    }
  })
  |> Form(form.parse)
}
