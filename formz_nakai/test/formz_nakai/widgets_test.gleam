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

fn remove_trues(str: String) -> String {
  str
  |> string.replace("checked=\"true\"", "checked")
  |> string.replace("disabled=\"true\"", "disabled")
}

fn remove_empty_attributes(str: String) -> String {
  string.replace(str, "=\"\"", "")
}

fn convert_to_string(input) {
  input
  |> nakai.to_inline_string
  |> remove_self_closing_slash
  |> remove_trues
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
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: False,
    value: "",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
  )

  test_inputs(
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
  )

  test_inputs(
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "val",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
  )

  test_inputs(
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: True,
    value: "",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
  )

  test_inputs(
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: True,
    required: False,
    value: "",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
  )
}

pub fn described_by_ids_test() {
  test_inputs(
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: False,
    value: "",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByElementsWithIds(["id1", "id2"]),
    ),
  )
}

pub fn described_by_ids_all_empty_test() {
  test_inputs(
    string_widgets.input_widget("text"),
    widgets.input_widget("text"),
    name: "a",
    label: "A",
    help: "help",
    hidden: False,
    disabled: False,
    required: False,
    value: "",
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByElementsWithIds(["", ""]),
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByElementsWithIds(["div"]),
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByElementsWithIds(["div"]),
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByElementsWithIds(["div"]),
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByElementsWithIds(["div"]),
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByElementsWithIds(["div"]),
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByFieldValue,
      described_by: widget.DescribedByNone,
    ),
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
    args: widget.Args(
      "id",
      labelled_by: widget.LabelledByLabelFor,
      described_by: widget.DescribedByNone,
    ),
  )
}
