pub type Input(format) {
  Input(
    name: String,
    label: String,
    help_text: String,
    widget: fn(Input(format), WidgetArgs) -> format,
    hidden: Bool,
    value: String,
  )
  InvalidInput(
    name: String,
    label: String,
    help_text: String,
    widget: fn(Input(format), WidgetArgs) -> format,
    hidden: Bool,
    value: String,
    error: String,
  )
}

pub type WidgetArgs {
  WidgetArgs(id: String, labelled_by: InputLabelled)
}

pub type InputLabelled {
  Element
  Value
  Id(element_id: String)
}

pub fn empty_field(widget: fn(Input(format), _) -> format) -> Input(format) {
  Input("", "", "", widget, False, "")
}

pub fn set_name(field: Input(format), name: String) -> Input(format) {
  case field {
    Input(_, label, help_text, widget, hidden, value) ->
      Input(name, label, help_text, widget, hidden, value)
    InvalidInput(_, label, help_text, widget, hidden, value, error) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}

pub fn set_label(field: Input(format), label: String) -> Input(format) {
  case field {
    Input(name, _, help_text, widget, hidden, value) ->
      Input(name, label, help_text, widget, hidden, value)
    InvalidInput(name, _, help_text, widget, hidden, value, error) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}

pub fn set_help_text(field: Input(format), help_text: String) -> Input(format) {
  case field {
    Input(name, label, _, widget, hidden, value) ->
      Input(name, label, help_text, widget, hidden, value)
    InvalidInput(name, label, _, widget, hidden, value, error) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}

pub fn set_widget(
  field: Input(format),
  widget: fn(Input(format), WidgetArgs) -> format,
) -> Input(format) {
  case field {
    Input(name, label, help_text, _, hidden, value) ->
      Input(name, label, help_text, widget, hidden, value)
    InvalidInput(name, label, help_text, _, hidden, value, error) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}

pub fn set_hidden(field: Input(format), hidden: Bool) -> Input(format) {
  case field {
    Input(name, label, help_text, widget, _, value) ->
      Input(name, label, help_text, widget, hidden, value)
    InvalidInput(name, label, help_text, widget, _, value, error) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}

pub fn set_value(field: Input(format), value: String) -> Input(format) {
  case field {
    Input(name, label, help_text, widget, hidden, _) ->
      Input(name, label, help_text, widget, hidden, value)
    InvalidInput(name, label, help_text, widget, hidden, _, error) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}

pub fn set_error(field: Input(format), error: String) -> Input(format) {
  case field {
    Input(name, label, help_text, widget, hidden, value) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
    InvalidInput(name, label, help_text, widget, hidden, value, _) ->
      InvalidInput(name, label, help_text, widget, hidden, value, error)
  }
}
