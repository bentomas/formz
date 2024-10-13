// https://docs.djangoproject.com/en/5.0/topics/forms/
// https://github.com/nakaixo/nakai
// date time handling https://hexdocs.pm/birl/index.html

// TODO
// - list fields
// - form sets
// - decoders/toy.decoder
// - csrf token
// - overwrite error messages

import formz/field.{type Field}
import formz/input.{type Input, Input}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type HasDecoder

pub type NoDecoder

pub opaque type Form(format, output, decoder, has_decoder) {
  Form(
    fields: List(Input(format)),
    parse_with: fn(List(Input(format)), decoder) ->
      Result(output, List(Input(format))),
    decoder: Option(decoder),
  )
}

pub fn new() -> Form(format, a, a, NoDecoder) {
  Form([], fn(_, output) { Ok(output) }, None)
}

pub fn add(
  form: Form(
    format,
    fn(decoder_step_input) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  definition: Field(format, decoder_step_input),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
  let Form(inputs, parse_with, decoder) = form

  // create new form with the new field and update the parse
  // function to handle the new details from the type of the
  // field
  Form(
    fields: [definition.input, ..inputs],
    parse_with: fn(inputs, decoder: form_output) {
      // can do let assert because we know there's at least one field since
      // we just added one
      let assert [input, ..rest] = inputs
      case parse_with(rest, decoder), definition.transform(input.value) {
        // the form we've already parsed has no errors and the field
        // we just parsed has no errors.  so we can move on to the next
        Ok(next), Ok(value) -> Ok(next(value))

        // the form already has errors even though this one succeeded.
        // so add this to the list and stop anymore parsing
        Error(inputs), Ok(_value) -> Error([input, ..inputs])

        // form was good so far, but this field errored, so need to
        // mark this field as invalid and return all the fields we've got
        // so far
        Ok(_), Error(error) -> Error([input.set_error(input, error), ..rest])

        // form already has errors and this field errored, so add this field
        // to the list
        Error(fields), Error(error) ->
          Error([input.set_error(input, error), ..fields])
      }
    },
    decoder:,
  )
}

pub fn data(
  form: Form(a, b, format, has_decoder),
  field: List(#(String, String)),
) -> Form(a, b, format, has_decoder) {
  case form {
    Form(fields, parse_with, decoder) -> {
      fields
      // we always prepend fields, so reverse to get correct order
      // TODO I think we're going to make it so order doesn't matter
      |> list.reverse
      |> do_add_input_data(field, [])
      |> Form(parse_with, decoder)
    }
    // FormWithErrors(..) -> form
  }
}

fn do_add_input_data(
  fields: List(Input(format)),
  data: List(#(String, String)),
  acc: List(Input(format)),
) {
  case fields, data {
    // no more fields, we've return all the fields with data we have accumulated
    [], _ -> acc
    // no more data!  return all the fields we have left plus the ones we accumulated
    _, [] -> list.append(fields, acc)
    // we have a field and data, and the names match. update field to have data
    [Input(name: field_name, ..) as field, ..fields_rest],
      [#(data_name, value), ..data_rest]
      if field_name == data_name
    ->
      do_add_input_data(fields_rest, data_rest, [
        input.set_value(field, value),
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
  let Form(fields, parse_with, _) = form
  Form(fields, parse_with, Some(decoder))
}

pub fn parse(
  form: Form(format, output, decoder, HasDecoder),
) -> Result(output, Form(format, output, decoder, HasDecoder)) {
  // we've tagged that we have a decoder with out has_decoder phantom type
  // so we can get away with let assert here
  let assert Form(fields, parse_with, Some(decoder)) = form
  case parse_with(fields, decoder) {
    Ok(output) -> Ok(output)
    Error(fields) -> Error(Form(fields, parse_with, Some(decoder)))
  }
}

pub fn parse_and_try(
  form: Form(format, output, decoder, HasDecoder),
  apply fun: fn(output, Form(format, output, decoder, HasDecoder)) ->
    Result(c, Form(format, output, decoder, HasDecoder)),
) -> Result(c, Form(format, output, decoder, HasDecoder)) {
  parse(form) |> result.try(fun(_, form))
}

pub fn get_inputs(form: Form(format, a, b, has_decoder)) -> List(Input(format)) {
  form.fields |> list.reverse
}

pub fn update_input(
  form: Form(format, output, decoder, has_decoder),
  name: String,
  fun: fn(Input(format)) -> Input(format),
) -> Form(format, output, decoder, has_decoder) {
  form.fields
  |> list.map(fn(field) {
    case field.name == name {
      True -> fun(field)
      False -> field
    }
  })
  |> Form(form.parse_with, form.decoder)
}
