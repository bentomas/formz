pub type Input(format) {
  Input(
    name: String,
    label: String,
    help_text: String,
    render: fn(Input(format), Args) -> format,
    hidden: Bool,
    value: String,
  )
  InvalidInput(
    name: String,
    label: String,
    help_text: String,
    render: fn(Input(format), Args) -> format,
    hidden: Bool,
    value: String,
    error: String,
  )
}

pub type Args {
  Args(id: String)
}

pub fn empty_field(render: fn(Input(format), _) -> format) -> Input(format) {
  Input("", "", "", render, False, "")
}

pub fn set_name(field: Input(format), name: String) -> Input(format) {
  case field {
    Input(_, label, help_text, render, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(_, label, help_text, render, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_label(field: Input(format), label: String) -> Input(format) {
  case field {
    Input(name, _, help_text, render, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, _, help_text, render, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_help_text(field: Input(format), help_text: String) -> Input(format) {
  case field {
    Input(name, label, _, render, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, _, render, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_render(
  field: Input(format),
  render: fn(Input(format), Args) -> format,
) -> Input(format) {
  case field {
    Input(name, label, help_text, _, hidden, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, help_text, _, hidden, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_hidden(field: Input(format), hidden: Bool) -> Input(format) {
  case field {
    Input(name, label, help_text, render, _, value) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, help_text, render, _, value, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_value(field: Input(format), value: String) -> Input(format) {
  case field {
    Input(name, label, help_text, render, hidden, _) ->
      Input(name, label, help_text, render, hidden, value)
    InvalidInput(name, label, help_text, render, hidden, _, error) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}

pub fn set_error(field: Input(format), error: String) -> Input(format) {
  case field {
    Input(name, label, help_text, render, hidden, value) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
    InvalidInput(name, label, help_text, render, hidden, value, _) ->
      InvalidInput(name, label, help_text, render, hidden, value, error)
  }
}
