import formz/input.{type Input, Input}
import formz/validation
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import justin

pub fn text_field(
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, String) {
  Field(input.empty_field(widget), "", validation.string)
}

pub fn email_field(
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, String) {
  Field(input.empty_field(widget), "", validation.email)
}

pub fn integer_field(
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, Int) {
  let transform = validation.int
  Field(input.empty_field(widget), 0, transform)
}

pub fn number_field(
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, Float) {
  let transform = validation.number
  Field(input.empty_field(widget), 0.0, transform)
}

pub fn boolean_field(
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, Bool) {
  let transform = validation.boolean
  Field(input.empty_field(widget), False, transform)
}

pub fn enum_field(
  variants: List(#(String, enum)),
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, enum) {
  let transform = validation.enum(variants)
  // todo should i force this to be a non empty list?
  // https://github.com/giacomocavalieri/non_empty_list
  // on the one hand it needs to be non empty, on the other
  // hand it's an unfamiliar type to most gleam users
  let assert Ok(first) = list.first(variants)
  Field(input.empty_field(widget), pair.second(first), transform)
}

pub fn list_field(
  variants: List(#(String, enum)),
  widget: fn(Input(format), input.Args) -> format,
) -> Field(format, enum) {
  let transform = validation.list_item(variants)
  // todo should i force this to be a non empty list?
  // https://github.com/giacomocavalieri/non_empty_list
  // on the one hand it needs to be non empty, on the other
  // hand it's an unfamiliar type to most gleam users
  let assert Ok(first) = list.first(variants)
  Field(input.empty_field(widget), pair.second(first), transform)
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
  let label = case field.input.name {
    "" -> justin.sentence_case(name)
    _ -> field.input.name
  }
  field |> set_name(name) |> set_label(label)
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
  default: c,
  next: fn(b) -> Result(c, String),
) -> Field(format, c) {
  let Field(field, _, previous_transform) = field

  Field(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}
