import formz/field.{type Definition, Definition}

pub fn validates(
  definition: Definition(format, output),
  next: fn(output) -> Result(output, String),
) -> Definition(format, output) {
  let Definition(widget, previous_transform, placeholder) = definition

  Definition(
    widget,
    fn(str) {
      case previous_transform(str) {
        Ok(value) -> next(value)
        Error(error) -> Error(error)
      }
    },
    placeholder,
  )
}

pub fn transforms(
  definition: Definition(format, a),
  placeholder: b,
  next: fn(a) -> Result(b, String),
) -> Definition(format, b) {
  let Definition(widget, previous_transform, _) = definition

  Definition(
    widget,
    fn(str) {
      case previous_transform(str) {
        Ok(value) -> next(value)
        Error(error) -> Error(error)
      }
    },
    placeholder,
  )
}

pub fn set_widget(
  definition: Definition(format, a),
  widget: field.Widget(format),
) -> Definition(format, a) {
  Definition(..definition, widget:)
}
