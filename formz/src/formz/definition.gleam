import formz/widget

pub type Definition(format, output) {
  Definition(
    widget: widget.Widget(format),
    transform: fn(String) -> Result(output, String),
    placeholder: output,
  )
}

pub fn validates(
  kind: Definition(format, output),
  next: fn(output) -> Result(output, String),
) -> Definition(format, output) {
  let Definition(widget, previous_transform, placeholder) = kind

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
  kind: Definition(format, a),
  placeholder: b,
  next: fn(a) -> Result(b, String),
) -> Definition(format, b) {
  let Definition(widget, previous_transform, _) = kind

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
  kind: Definition(format, a),
  widget: widget.Widget(format),
) -> Definition(format, a) {
  Definition(..kind, widget:)
}
