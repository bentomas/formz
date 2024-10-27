import formz/field
import formz/widget
import gleam/string
import gleeunit
import gleeunit/should
import nakai

import formz_nakai/widgets
import formz_string/widgets as string_widgets

pub fn main() {
  gleeunit.main()
}

fn remove_self_closing_slash(str: String) -> String {
  string.replace(str, " />", ">")
}

fn remove_checked_true(str: String) -> String {
  string.replace(str, "checked=\"true\"", "checked")
}

fn remove_empty_attributes(str: String) -> String {
  string.replace(str, "=\"\"", "")
}

fn convert_to_string(input) {
  input
  |> nakai.to_inline_string
  |> remove_self_closing_slash
  |> remove_checked_true
  |> remove_empty_attributes
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
  let string_field =
    field.Valid(
      name:,
      label:,
      help_text:,
      hidden:,
      value:,
      disabled:,
      required:,
    )
  let field =
    field.Valid(
      name:,
      label:,
      help_text:,
      hidden:,
      value:,
      disabled:,
      required:,
    )

  widget(field, args)
  |> convert_to_string
  |> should.equal(string_widget(string_field, args))
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByFieldValue),
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
    args: widget.Args("id", labelled_by: widget.LabelledByElementWithId("div")),
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
    args: widget.Args("id", labelled_by: widget.LabelledByFieldValue),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByElementWithId("div")),
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
    args: widget.Args("id", labelled_by: widget.LabelledByFieldValue),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByElementWithId("div")),
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
    args: widget.Args("id", labelled_by: widget.LabelledByFieldValue),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByElementWithId("div")),
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
    args: widget.Args("id", labelled_by: widget.LabelledByFieldValue),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
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
    args: widget.Args("id", labelled_by: widget.LabelledByElementWithId("div")),
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
    args: widget.Args("id", labelled_by: widget.LabelledByFieldValue),
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
    args: widget.Args("id", labelled_by: widget.LabelledByLabelFor),
  )
}
