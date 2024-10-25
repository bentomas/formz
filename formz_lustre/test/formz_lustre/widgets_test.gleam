import formz/input.{WidgetArgs}
import gleeunit
import gleeunit/should
import lustre/element

import formz_lustre/widgets
import formz_string/widgets as string_widgets

pub fn main() {
  gleeunit.main()
}

fn convert_to_string(input) {
  input
  |> element.to_string
}

fn test_inputs(
  name name,
  label label,
  help help_text,
  hidden hidden,
  disabled disabled,
  required required,
  value value,
  args args,
  string string_widget,
  widget widget,
) {
  let string_input =
    input.Valid(
      name:,
      label:,
      help_text:,
      widget: string_widget,
      hidden:,
      value:,
      disabled:,
      required:,
    )
  let input =
    input.Valid(
      name:,
      label:,
      help_text:,
      widget: widget,
      hidden:,
      value:,
      disabled:,
      required:,
    )

  input.widget(input, args)
  |> convert_to_string
  |> should.equal(string_input.widget(string_input, args))
}

pub fn text_widget_test() {
  test_inputs(
    string_widgets.text_like_widget("text"),
    widgets.text_like_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Element),
  )

  test_inputs(
    string_widgets.text_like_widget("text"),
    widgets.text_like_widget("text"),
    name: "",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Element),
  )

  test_inputs(
    string_widgets.text_like_widget("text"),
    widgets.text_like_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "val",
    args: WidgetArgs("id", labelled_by: input.Element),
  )

  test_inputs(
    string_widgets.text_like_widget("text"),
    widgets.text_like_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Value),
  )
}

pub fn checkbox_widget_test() {
  test_inputs(
    string_widgets.checkbox_widget(),
    widgets.checkbox_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Id("div")),
  )
  test_inputs(
    string_widgets.checkbox_widget(),
    widgets.checkbox_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "on",
    args: WidgetArgs("id", labelled_by: input.Value),
  )

  test_inputs(
    string_widgets.checkbox_widget(),
    widgets.checkbox_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "on",
    args: WidgetArgs("id", labelled_by: input.Element),
  )
}

pub fn password_widget_test() {
  test_inputs(
    string_widgets.password_widget(),
    widgets.password_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Id("div")),
  )
  test_inputs(
    string_widgets.password_widget(),
    widgets.password_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "xxxx",
    args: WidgetArgs("id", labelled_by: input.Value),
  )

  test_inputs(
    string_widgets.password_widget(),
    widgets.password_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "xxxx",
    args: WidgetArgs("id", labelled_by: input.Element),
  )
}

pub fn textarea_widget_test() {
  test_inputs(
    string_widgets.textarea_widget(),
    widgets.textarea_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Id("div")),
  )
  test_inputs(
    string_widgets.textarea_widget(),
    widgets.textarea_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Value),
  )

  test_inputs(
    string_widgets.textarea_widget(),
    widgets.textarea_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Element),
  )
}

pub fn hidden_widget_test() {
  test_inputs(
    string_widgets.hidden_widget(),
    widgets.hidden_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Id("div")),
  )
  test_inputs(
    string_widgets.hidden_widget(),
    widgets.hidden_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Value),
  )

  test_inputs(
    string_widgets.hidden_widget(),
    widgets.hidden_widget(),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Element),
  )
}

pub fn select_widget_test() {
  let list = [#("One", "a"), #("Two", "b"), #("Three", "c")]
  test_inputs(
    string_widgets.select_widget(list),
    widgets.select_widget(list),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: WidgetArgs("id", labelled_by: input.Id("div")),
  )
  test_inputs(
    string_widgets.select_widget(list),
    widgets.select_widget(list),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Value),
  )

  test_inputs(
    string_widgets.select_widget(list),
    widgets.select_widget(list),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Element),
  )
}
