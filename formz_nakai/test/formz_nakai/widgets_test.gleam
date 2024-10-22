import formz/input.{type Input, type WidgetArgs, Input, WidgetArgs}
import gleam/string
import gleeunit
import gleeunit/should
import nakai

import formz/string_generator/widgets as string_widgets
import formz_nakai/widgets

pub fn main() {
  gleeunit.main()
}

fn remove_self_closing_slash(str: String) -> String {
  string.replace(str, " />", ">")
}

fn remove_checked_true(str: String) -> String {
  string.replace(str, "checked=\"true\"", "checked")
}

fn convert_to_string(input) {
  input
  |> nakai.to_inline_string
  |> remove_self_closing_slash
  |> remove_checked_true
}

fn test_inputs(
  name name,
  label label,
  help help,
  hidden hidden,
  value value,
  args args,
  string string_widget,
  widget widget,
) {
  let string_input = Input(name, label, help, string_widget, hidden, value)
  let input = Input(name, label, help, widget, hidden, value)

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
    value: "1",
    args: WidgetArgs("id", labelled_by: input.Element),
  )
}
