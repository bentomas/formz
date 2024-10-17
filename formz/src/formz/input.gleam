pub type Input(format, widget_args) {
  Input(
    name: String,
    label: String,
    help_text: String,
    render: fn(Input(format, widget_args), widget_args) -> format,
    hidden: Bool,
    value: String,
  )
  InvalidInput(
    name: String,
    label: String,
    help_text: String,
    render: fn(Input(format, widget_args), widget_args) -> format,
    hidden: Bool,
    value: String,
    error: String,
  )
}

pub fn empty_field(
  render: fn(Input(format, widget_args), widget_args) -> format,
) -> Input(format, widget_args) {
  Input("", "", "", render, False, "")
}

pub fn set_name(
  field: Input(format, widget_args),
  name: String,
) -> Input(format, widget_args) {
  case field {
    Input(_, label, help_text, render, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(_, label, help_text, render, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_label(
  field: Input(format, widget_args),
  label: String,
) -> Input(format, widget_args) {
  case field {
    Input(name, _, help_text, render, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, _, help_text, render, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_help_text(
  field: Input(format, widget_args),
  help_text: String,
) -> Input(format, widget_args) {
  case field {
    Input(name, label, _, render, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, _, render, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_render(
  field: Input(format, widget_args),
  render: fn(Input(format, widget_args), widget_args) -> format,
) -> Input(format, widget_args) {
  case field {
    Input(name, label, help_text, _, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, help_text, _, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_hidden(
  field: Input(format, widget_args),
  hidden: Bool,
) -> Input(format, widget_args) {
  case field {
    Input(name, label, help_text, render, _, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, help_text, render, _, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_value(
  field: Input(format, widget_args),
  value: String,
) -> Input(format, widget_args) {
  case field {
    Input(name, label, help_text, render, hidden, _) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, help_text, render, hidden, _, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_error(
  field: Input(format, widget_args),
  error: String,
) -> Input(format, widget_args) {
  case field {
    Input(name, label, help_text, render, hidden, value) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
    InvalidInput(name, label, help_text, render, hidden, value, _) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}
