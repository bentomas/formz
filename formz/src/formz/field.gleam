import formz/input.{type Input}
import gleam/option
import gleam/result
import gleam/string
import justin

pub type Field(format, output) {
  Field(
    input: Input(format),
    placeholder: output,
    transform: fn(String) -> Result(output, String),
  )
}

pub type Definition(format, output) {
  Definition(
    widget: input.Widget(format),
    transform: fn(String) -> Result(output, String),
    placeholder: output,
  )
}

pub fn field(
  name: String,
  definition: Definition(format, output),
) -> Field(format, output) {
  Field(
    input.Valid(
      name,
      justin.sentence_case(name),
      help_text: "",
      widget: definition.widget,
      hidden: False,
      value: "",
      disabled: False,
      required: True,
    ),
    definition.placeholder,
    definition.transform,
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

pub fn set_widget(
  field: Field(format, b),
  widget: fn(Input(format), input.WidgetArgs) -> format,
) -> Field(format, b) {
  Field(..field, input: input.set_widget(field.input, widget))
}

pub fn set_value(field: Field(format, b), value: String) -> Field(format, b) {
  Field(..field, input: input.set_value(field.input, value))
}

pub fn set_visibility(
  field: Field(format, b),
  visibility: Bool,
) -> Field(format, b) {
  Field(..field, input: input.set_hidden(field.input, visibility))
}

pub fn make_visible(field: Field(format, b)) -> Field(format, b) {
  set_visibility(field, True)
}

pub fn make_hidden(field: Field(format, b)) -> Field(format, b) {
  set_visibility(field, False)
}

pub fn set_optional(field: Field(format, b)) -> Field(format, option.Option(b)) {
  Field(input: field.input, placeholder: option.None, transform: fn(str) {
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
  let Field(field, placeholder, previous_transform) = field

  Field(field, placeholder, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}

pub fn transforms(
  field: Field(format, b),
  placeholder: c,
  next: fn(b) -> Result(c, String),
) -> Field(format, c) {
  let Field(field, _, previous_transform) = field

  Field(field, placeholder, fn(str) {
    case previous_transform(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}
