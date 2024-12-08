import formz
import formz/field
import formz_nakai/widget
import formz_nakai/widgets
import formz_string/widget as string_widget
import formz_string/widgets as string_widgets
import gleam/string
import gleeunit
import gleeunit/should
import nakai

pub fn main() {
  gleeunit.main()
}

pub fn to_string_args(args: widget.Args) {
  let labelled_by = case args.labelled_by {
    widget.LabelledByFieldValue -> string_widget.LabelledByFieldValue
    widget.LabelledByElementsWithIds(ids) ->
      string_widget.LabelledByElementsWithIds(ids)
    widget.LabelledByLabelFor -> string_widget.LabelledByLabelFor
  }

  let described_by = case args.described_by {
    widget.DescribedByNone -> string_widget.DescribedByNone
    widget.DescribedByElementsWithIds(ids) ->
      string_widget.DescribedByElementsWithIds(ids)
  }

  string_widget.Args(args.id, labelled_by, described_by)
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
  name name: String,
  label label: String,
  help help_text: String,
  hidden hidden: Bool,
  disabled disabled: Bool,
  required required: Bool,
  value value: String,
  args args: widget.Args,
  string string_widget: string_widget.Widget,
  widget widget: widget.Widget,
) {
  let string_field = field.Field(name:, label:, help_text:, hidden:, disabled:)
  let field = field.Field(name:, label:, help_text:, hidden:, disabled:)

  let requirement = case required {
    True -> formz.Required
    False -> formz.Optional
  }
  let state = formz.Valid(value, requirement)

  widget(field, state, args)
  |> convert_to_string
  |> should.equal(string_widget(string_field, state, args |> to_string_args))
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
