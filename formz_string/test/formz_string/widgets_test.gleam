import birdie
import formz
import formz/field
import formz/widget
import formz_string/widgets
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn input_labelled_by_field_value_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args("", widget.LabelledByFieldValue, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input labelled by field value")
}

pub fn input_labelled_by_element_with_id_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args(
      "",
      widget.LabelledByElementsWithIds(["id"]),
      widget.DescribedByNone,
    ),
  )
  |> birdie.snap(title: "input labelled by element with id")
}

pub fn input_labelled_by_label_for_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input labelled by label/for")
}

pub fn input_described_by_elements_with_ids_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args(
      "",
      widget.LabelledByLabelFor,
      widget.DescribedByElementsWithIds(["id1", "id2"]),
    ),
  )
  |> birdie.snap(title: "input described by elements with ids")
}

pub fn input_described_by_elements_with_ids_all_empty_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args(
      "",
      widget.LabelledByLabelFor,
      widget.DescribedByElementsWithIds(["", ""]),
    ),
  )
  |> birdie.snap(title: "input described by elements with ids all empty")
}

pub fn input_required_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: True,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input required")
}

pub fn input_disabled_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: True,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input disabled")
}

pub fn input_sanitized_value_test() {
  widgets.input_widget("text")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("hello\"<-_=>"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input sanitized value")
}

pub fn checkbox_checked_test() {
  widgets.checkbox_widget()(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("on"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "checkbox checked")
}

pub fn checkbox_unchecked_test() {
  widgets.checkbox_widget()(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid(""),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "checkbox unchecked")
}

pub fn password_test() {
  widgets.password_widget()(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("pass"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "password ignores input")
}

pub fn numeric_no_step_test() {
  widgets.number_widget("")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("1"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "number input with no step")
}

pub fn numeric_step_test() {
  widgets.number_widget("0.1")(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("1.0"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "number input with step")
}

pub fn select_test() {
  widgets.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")])(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid(""),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "basic select")
}

pub fn select_selected_test() {
  widgets.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")])(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    formz.Valid("1"),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "select selected")
}

pub fn select_required_test() {
  widgets.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")])(
    field.Field(
      name: "name",
      label: "Label",
      help_text: "",
      disabled: False,
      required: True,
      hidden: False,
    ),
    formz.Valid(""),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "required select")
}
