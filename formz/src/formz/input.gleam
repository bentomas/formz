pub type Input(format) {
  Input(
    name: String,
    label: String,
    help_text: String,
    render: fn(Input(format)) -> format,
    value: String,
  )
  InvalidInput(
    name: String,
    label: String,
    help_text: String,
    render: fn(Input(format)) -> format,
    value: String,
    error: String,
  )
}

pub fn empty_field(render: fn(Input(format)) -> format) -> Input(format) {
  Input("", "", "", render, "")
}

pub fn set_name(field: Input(format), name: String) -> Input(format) {
  case field {
    Input(_, label, help_text, render, value) ->
      Input(name, label, help_text, render, value)
    InvalidInput(_, label, help_text, render, value, error) ->
      InvalidInput(name, label, help_text, render, value, error)
  }
}

pub fn set_label(field: Input(format), label: String) -> Input(format) {
  case field {
    Input(name, _, help_text, render, value) ->
      Input(name, label, help_text, render, value)
    InvalidInput(name, _, help_text, render, value, error) ->
      InvalidInput(name, label, help_text, render, value, error)
  }
}

pub fn set_help_text(field: Input(format), help_text: String) -> Input(format) {
  case field {
    Input(name, label, _, render, value) ->
      Input(name, label, help_text, render, value)
    InvalidInput(name, label, _, render, value, error) ->
      InvalidInput(name, label, help_text, render, value, error)
  }
}

pub fn set_render(
  field: Input(format),
  render: fn(Input(format)) -> format,
) -> Input(format) {
  case field {
    Input(name, label, help_text, _, value) ->
      Input(name, label, help_text, render, value)
    InvalidInput(name, label, help_text, _, value, error) ->
      InvalidInput(name, label, help_text, render, value, error)
  }
}

pub fn set_value(field: Input(format), value: String) -> Input(format) {
  case field {
    Input(name, label, help_text, render, _) ->
      Input(name, label, help_text, render, value)
    InvalidInput(name, label, help_text, render, _, error) ->
      InvalidInput(name, label, help_text, render, value, error)
  }
}

pub fn set_error(field: Input(format), error: String) -> Input(format) {
  case field {
    Input(name, label, help_text, render, value) ->
      InvalidInput(name, label, help_text, render, value, error)
    InvalidInput(name, label, help_text, render, value, _) ->
      InvalidInput(name, label, help_text, render, value, error)
  }
}
