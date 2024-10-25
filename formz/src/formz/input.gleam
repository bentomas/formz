pub type Input(format) {
  Valid(
    name: String,
    label: String,
    help_text: String,
    disabled: Bool,
    required: Bool,
    widget: Widget(format),
    hidden: Bool,
    value: String,
  )
  Invalid(
    name: String,
    label: String,
    help_text: String,
    disabled: Bool,
    required: Bool,
    widget: Widget(format),
    hidden: Bool,
    value: String,
    error: String,
  )
}

pub type Widget(format) =
  fn(Input(format), WidgetArgs) -> format

pub type WidgetArgs {
  WidgetArgs(id: String, labelled_by: InputLabelled)
}

pub type InputLabelled {
  Element
  Value
  Id(element_id: String)
}

pub fn set_name(field: Input(format), name: String) -> Input(format) {
  case field {
    Valid(
      _name,
      label:,
      help_text:,
      widget:,
      hidden:,
      value:,
      disabled:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _name,
      label:,
      help_text:,
      widget:,
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
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_label(field: Input(format), label: String) -> Input(format) {
  case field {
    Valid(
      _label,
      name:,
      help_text:,
      widget:,
      hidden:,
      value:,
      disabled:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _label,
      name:,
      help_text:,
      widget:,
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
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_help_text(field: Input(format), help_text: String) -> Input(format) {
  case field {
    Valid(
      _help_text,
      name:,
      label:,
      widget:,
      hidden:,
      value:,
      disabled:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _help_text,
      name:,
      label:,
      widget:,
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
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_widget(field: Input(format), widget: Widget(format)) -> Input(format) {
  case field {
    Valid(
      _widget,
      name:,
      label:,
      help_text:,
      hidden:,
      value:,
      disabled:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _widget,
      name:,
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
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_hidden(field: Input(format), hidden: Bool) -> Input(format) {
  case field {
    Valid(
      _hidden,
      name:,
      label:,
      help_text:,
      widget:,
      value:,
      disabled:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _hidden,
      name:,
      label:,
      help_text:,
      widget:,
      disabled:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_disabled(field: Input(format), disabled: Bool) -> Input(format) {
  case field {
    Valid(
      _disabled,
      name:,
      label:,
      help_text:,
      widget:,
      value:,
      hidden:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _disabled,
      name:,
      label:,
      help_text:,
      widget:,
      hidden:,
      required:,
      value:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_value(field: Input(format), value: String) -> Input(format) {
  case field {
    Valid(
      _value,
      name:,
      label:,
      help_text:,
      widget:,
      hidden:,
      disabled:,
      required:,
    ) ->
      Valid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        disabled:,
        required:,
      )
    Invalid(
      _value,
      name:,
      label:,
      help_text:,
      widget:,
      hidden:,
      disabled:,
      required:,
      error:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}

pub fn set_error(field: Input(format), error: String) -> Input(format) {
  case field {
    Valid(
      name:,
      label:,
      help_text:,
      widget:,
      hidden:,
      value:,
      disabled:,
      required:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        widget:,
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
      widget:,
      hidden:,
      disabled:,
      required:,
      value:,
    ) ->
      Invalid(
        name:,
        label:,
        help_text:,
        widget:,
        hidden:,
        value:,
        error:,
        disabled:,
        required:,
      )
  }
}
