import forma/field.{type Field, Field}
import forma/validation
import justin

pub fn text_input(widget: fn(Field(format)) -> format) -> Input(format, String) {
  Input(field.empty_field(widget), "", validation.string)
}

pub fn email_input(widget: fn(Field(format)) -> format) -> Input(format, String) {
  Input(field.empty_field(widget), "", validation.email)
}

pub fn integer_input(widget: fn(Field(format)) -> format) -> Input(format, Int) {
  let transform = validation.trim |> validation.and(validation.int)
  Input(field.empty_field(widget), 0, transform)
}

pub fn number_input(widget: fn(Field(format)) -> format) -> Input(format, Float) {
  let transform = validation.trim |> validation.and(validation.number)
  Input(field.empty_field(widget), 0.0, transform)
}

pub type Input(format, output) {
  Input(
    field: Field(format),
    default: output,
    transform: fn(String) -> Result(output, String),
  )
}

pub fn input(
  name: String,
  input: Input(format, output),
) -> Input(format, output) {
  Input(
    Field(name, justin.sentence_case(name), "", input.field.render, ""),
    input.default,
    input.transform,
  )
}

pub fn full(
  name: String,
  label: String,
  help_text: String,
  input: Input(format, output),
) -> Input(format, output) {
  Input(
    Field(name, label, help_text, input.field.render, ""),
    input.default,
    input.transform,
  )
}

pub fn name(input: Input(format, b), name: String) -> Input(format, b) {
  Input(..input, field: field.set_name(input.field, name))
}

pub fn label(input: Input(format, b), label: String) -> Input(format, b) {
  Input(..input, field: field.set_label(input.field, label))
}

pub fn help_text(input: Input(format, b), help_text: String) -> Input(format, b) {
  Input(..input, field: field.set_help_text(input.field, help_text))
}

pub fn validate(
  input: Input(format, b),
  next: fn(b) -> Result(b, String),
) -> Input(format, b) {
  let Input(field, default, previous_transform) = input

  Input(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}

pub fn transform(
  input: Input(format, b),
  next: fn(b) -> Result(c, String),
  default: c,
) -> Input(format, c) {
  let Input(field, _, previous_transform) = input

  Input(field, default, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}
