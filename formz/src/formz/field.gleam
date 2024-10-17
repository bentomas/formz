import formz/input.{type Input, Input}
import formz/validation
import gleam/option
import gleam/result
import gleam/string
import justin

pub fn text_field(
  widget: fn(Input(format, widget_args), widget_args) -> format,
) -> Field(format, widget_args, String) {
  Field(input.empty_field(widget), "", validation.string)
}

pub fn email_field(
  widget: fn(Input(format, widget_args), widget_args) -> format,
) -> Field(format, widget_args, String) {
  Field(input.empty_field(widget), "", validation.email)
}

pub fn integer_field(
  widget: fn(Input(format, widget_args), widget_args) -> format,
) -> Field(format, widget_args, Int) {
  let transform = validation.int
  Field(input.empty_field(widget), 0, transform)
}

pub fn number_field(
  widget: fn(Input(format, widget_args), widget_args) -> format,
) -> Field(format, widget_args, Float) {
  let transform = validation.number
  Field(input.empty_field(widget), 0.0, transform)
}

pub fn boolean_field(
  widget: fn(Input(format, widget_args), widget_args) -> format,
) -> Field(format, widget_args, Bool) {
  let transform = validation.boolean
  Field(input.empty_field(widget), False, transform)
}

pub type Field(format, widget_args, output) {
  Field(
    input: Input(format, widget_args),
    default: output,
    transform: fn(String) -> Result(output, String),
  )
}

pub fn field(
  name: String,
  field: Field(format, widget_args, output),
) -> Field(format, widget_args, output) {
  Field(
    Input(name, justin.sentence_case(name), "", field.input.render, False, ""),
    field.default,
    field.transform,
  )
}

pub fn hidden(
  name: String,
  field: Field(format, widget_args, output),
) -> Field(format, widget_args, output) {
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
  field: Field(format, widget_args, output),
) -> Field(format, widget_args, output) {
  Field(
    Input(name, label, help_text, field.input.render, False, ""),
    field.default,
    field.transform,
  )
}

pub fn set_name(
  field: Field(format, widget_args, b),
  name: String,
) -> Field(format, widget_args, b) {
  Field(..field, input: input.set_name(field.input, name))
}

pub fn set_label(
  field: Field(format, widget_args, b),
  label: String,
) -> Field(format, widget_args, b) {
  Field(..field, input: input.set_label(field.input, label))
}

pub fn set_help_text(
  field: Field(format, widget_args, b),
  help_text: String,
) -> Field(format, widget_args, b) {
  Field(..field, input: input.set_help_text(field.input, help_text))
}

pub fn set_value(
  field: Field(format, widget_args, b),
  value: String,
) -> Field(format, widget_args, b) {
  Field(..field, input: input.set_value(field.input, value))
}

pub fn set_hidden(
  field: Field(format, widget_args, b),
  hidden: Bool,
) -> Field(format, widget_args, b) {
  Field(..field, input: input.set_hidden(field.input, hidden))
}

pub fn set_optional(
  field: Field(format, widget_args, b),
) -> Field(format, widget_args, option.Option(b)) {
  Field(input: field.input, default: option.None, transform: fn(str) {
    case string.trim(str) {
      "" -> Ok(option.None)
      _ -> result.map(field.transform(str), option.Some)
    }
  })
}

pub fn validates(
  field: Field(format, widget_args, b),
  next: fn(b) -> Result(b, String),
) -> Field(format, widget_args, b) {
  let Field(field, default, previous_transform) = field

  Field(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}

pub fn transforms(
  field: Field(format, widget_args, b),
  next: fn(b) -> Result(c, String),
  default: c,
) -> Field(format, widget_args, c) {
  let Field(field, _, previous_transform) = field

  Field(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}
