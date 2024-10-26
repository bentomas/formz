import justin

pub type Field(format) {
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

pub type Definition(format, output) {
  Definition(
    widget: Widget(format),
    transform: fn(String) -> Result(output, String),
    placeholder: output,
  )
}

pub opaque type Widget(format) {
  Widget(fn(Field(format), WidgetArgs) -> format)
}

pub type WidgetArgs {
  WidgetArgs(id: String, labelled_by: InputLabelled)
}

pub type InputLabelled {
  Element
  Value
  Id(element_id: String)
}

pub fn field(named name: String) -> Field(format) {
  Valid(
    name: name,
    label: justin.sentence_case(name),
    help_text: "",
    disabled: False,
    required: False,
    widget: Widget(fn(_, _) { panic }),
    hidden: False,
    value: "",
  )
}

pub fn widget(fun: fn(Field(format), WidgetArgs) -> format) -> Widget(format) {
  Widget(fun)
}

pub fn set_name(field: Field(format), name: String) -> Field(format) {
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

pub fn set_label(field: Field(format), label: String) -> Field(format) {
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

pub fn set_help_text(field: Field(format), help_text: String) -> Field(format) {
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

pub fn set_widget(field: Field(format), widget: Widget(format)) -> Field(format) {
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

pub fn set_visibility(field: Field(format), hidden: Bool) -> Field(format) {
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

pub fn make_hidden(field: Field(format)) -> Field(format) {
  set_visibility(field, True)
}

pub fn make_visible(field: Field(format)) -> Field(format) {
  set_visibility(field, False)
}

pub fn set_disabled(field: Field(format), disabled: Bool) -> Field(format) {
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

pub fn set_value(field: Field(format), value: String) -> Field(format) {
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

pub fn set_error(field: Field(format), error: String) -> Field(format) {
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

pub fn run_widget(f: Field(format), args: WidgetArgs) -> format {
  let Widget(fun) = f.widget

  fun(f, args)
}
