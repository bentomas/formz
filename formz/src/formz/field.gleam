import formz/input.{type Input, Input}
import formz/validation
import gleam/option
import gleam/result
import gleam/string
import justin

pub fn text_field(widget: fn(Input(format)) -> format) -> Field(format, String) {
  Field(input.empty_field(widget), "", validation.string)
}

pub fn email_field(widget: fn(Input(format)) -> format) -> Field(format, String) {
  Field(input.empty_field(widget), "", validation.email)
}

pub fn integer_field(widget: fn(Input(format)) -> format) -> Field(format, Int) {
  let transform = validation.int
  Field(input.empty_field(widget), 0, transform)
}

pub fn number_field(widget: fn(Input(format)) -> format) -> Field(format, Float) {
  let transform = validation.number
  Field(input.empty_field(widget), 0.0, transform)
}

pub fn boolean_field(widget: fn(Input(format)) -> format) -> Field(format, Bool) {
  let transform = validation.boolean
  Field(input.empty_field(widget), False, transform)
}

pub type Field(format, output) {
  Field(
    input: Input(format),
    default: output,
    transform: fn(String) -> Result(output, String),
  )
}

pub fn field(
  name: String,
  field: Field(format, output),
) -> Field(format, output) {
  Field(
    Input(name, justin.sentence_case(name), "", field.input.render, False, ""),
    field.default,
    field.transform,
  )
}

pub fn hidden(
  name: String,
  field: Field(format, output),
) -> Field(format, output) {
  Field(
    Input(name, "", "", field.input.render, True, ""),
    field.default,
    field.transform,
  )
}

pub fn full(
  name: String,
  label: String,
  help_text: String,
  field: Field(format, output),
) -> Field(format, output) {
  Field(
    Input(name, label, help_text, field.input.render, False, ""),
    field.default,
    field.transform,
  )
}

pub fn set_name(field: Field(format, b), name: String) -> Field(format, b) {
  Field(..field, input: input.set_name(field.input, name))
}

pub fn set_label(field: Field(format, b), label: String) -> Field(format, b) {
  Field(..field, input: input.set_label(field.input, label))
}

pub fn set_help_text(
  field: Field(format, b),
  help_text: String,
) -> Field(format, b) {
  Field(..field, input: input.set_help_text(field.input, help_text))
}

pub fn set_value(field: Field(format, b), value: String) -> Field(format, b) {
  Field(..field, input: input.set_value(field.input, value))
}

pub fn set_hidden(field: Field(format, b), hidden: Bool) -> Field(format, b) {
  Field(..field, input: input.set_hidden(field.input, hidden))
}

pub fn set_optional(field: Field(format, b)) -> Field(format, option.Option(b)) {
  Field(input: field.input, default: option.None, transform: fn(str) {
    case string.trim(str) {
      "" -> Ok(option.None)
      _ -> result.map(field.transform(str), option.Some)
    }
  })
}

pub fn validates(
  field: Field(format, b),
  next: fn(b) -> Result(b, String),
) -> Field(format, b) {
  let Field(field, default, previous_transform) = field

  Field(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}

pub fn transforms(
  field: Field(format, b),
  next: fn(b) -> Result(c, String),
  default: c,
) -> Field(format, c) {
  let Field(field, _, previous_transform) = field

  Field(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}
