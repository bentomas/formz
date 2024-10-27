import justin

pub type Field {
  Valid(
    name: String,
    label: String,
    help_text: String,
    disabled: Bool,
    required: Bool,
    hidden: Bool,
    value: String,
  )
  Invalid(
    name: String,
    label: String,
    help_text: String,
    disabled: Bool,
    required: Bool,
    hidden: Bool,
    value: String,
    error: String,
  )
}

pub fn field(named name: String) -> Field {
  Valid(
    name: name,
    label: justin.sentence_case(name),
    help_text: "",
    disabled: False,
    required: False,
    hidden: False,
    value: "",
  )
}

pub fn set_name(field: Field, name: String) -> Field {
  case field {
    Valid(_name, label:, help_text:, hidden:, value:, disabled:, required:) ->
      Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:)
    Invalid(
      _name,
      label:,
      help_text:,
      hidden:,
      disabled:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_label(field: Field, label: String) -> Field {
  case field {
    Valid(_label, name:, help_text:, hidden:, value:, disabled:, required:) ->
      Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:)
    Invalid(
      _label,
      name:,
      help_text:,
      hidden:,
      disabled:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_help_text(field: Field, help_text: String) -> Field {
  case field {
    Valid(_help_text, name:, label:, hidden:, value:, disabled:, required:) ->
      Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:)
    Invalid(
      _help_text,
      name:,
      label:,
      hidden:,
      disabled:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

fn set_hidden(field: Field, hidden: Bool) -> Field {
  case field {
    Valid(_hidden, name:, label:, help_text:, value:, disabled:, required:) ->
      Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:)
    Invalid(
      _hidden,
      name:,
      label:,
      help_text:,
      disabled:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn make_hidden(field: Field) -> Field {
  set_hidden(field, True)
}

pub fn make_visible(field: Field) -> Field {
  set_hidden(field, False)
}

fn set_disabled(field: Field, disabled: Bool) -> Field {
  case field {
    Valid(_disabled, name:, label:, help_text:, value:, hidden:, required:) ->
      Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:)
    Invalid(
      _disabled,
      name:,
      label:,
      help_text:,
      hidden:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn make_disabled(field: Field) -> Field {
  set_disabled(field, True)
}

pub fn make_enabled(field: Field) -> Field {
  set_disabled(field, False)
}

pub fn set_string_value(field: Field, value: String) -> Field {
  case field {
    Valid(_value, name:, label:, help_text:, hidden:, disabled:, required:) ->
      Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:)
    Invalid(
      _value,
      name:,
      label:,
      help_text:,
      hidden:,
      disabled:,
      required:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_error(field: Field, error: String) -> Field {
  case field {
    Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        disabled:,
        required:,
        error:,
      )
    Invalid(
      _error,
      name:,
      label:,
      help_text:,
      hidden:,
      disabled:,
      required:,
      value:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}
