pub type Field(format) {
  Field(
    name: String,
    label: String,
    help_text: String,
    render: fn(Field(format)) -> format,
    value: String,
  )
  InvalidField(
    name: String,
    label: String,
    help_text: String,
    render: fn(Field(format)) -> format,
    value: String,
    error: String,
  )
}

pub fn empty_field(render: fn(Field(format)) -> format) -> Field(format) {
  Field("", "", "", render, "")
}

pub fn set_name(field: Field(format), name: String) -> Field(format) {
  case field {
    Field(_, label, help_text, render, value) ->
      Field(name, label, help_text, render, value)
    InvalidField(_, label, help_text, render, value, error) ->
      InvalidField(name, label, help_text, render, value, error)
  }
}

pub fn set_label(field: Field(format), label: String) -> Field(format) {
  case field {
    Field(name, _, help_text, render, value) ->
      Field(name, label, help_text, render, value)
    InvalidField(name, _, help_text, render, value, error) ->
      InvalidField(name, label, help_text, render, value, error)
  }
}

pub fn set_help_text(field: Field(format), help_text: String) -> Field(format) {
  case field {
    Field(name, label, _, render, value) ->
      Field(name, label, help_text, render, value)
    InvalidField(name, label, _, render, value, error) ->
      InvalidField(name, label, help_text, render, value, error)
  }
}

pub fn set_render(
  field: Field(format),
  render: fn(Field(format)) -> format,
) -> Field(format) {
  case field {
    Field(name, label, help_text, _, value) ->
      Field(name, label, help_text, render, value)
    InvalidField(name, label, help_text, _, value, error) ->
      InvalidField(name, label, help_text, render, value, error)
  }
}

pub fn set_value(field: Field(format), value: String) -> Field(format) {
  case field {
    Field(name, label, help_text, render, _) ->
      Field(name, label, help_text, render, value)
    InvalidField(name, label, help_text, render, _, error) ->
      InvalidField(name, label, help_text, render, value, error)
  }
}

pub fn set_error(field: Field(format), error: String) -> Field(format) {
  case field {
    Field(name, label, help_text, render, value) ->
      InvalidField(name, label, help_text, render, value, error)
    InvalidField(name, label, help_text, render, value, _) ->
      InvalidField(name, label, help_text, render, value, error)
  }
}
