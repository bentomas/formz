import birdie
import formz/field
import formz/widget
import formz_string/widgets
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn text_like_labelled_by_field_value_test() {
  widgets.input_widget("text")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "hello",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByFieldValue, widget.DescribedByNone),
  )
  |> birdie.snap(title: "text like labelled by field value")
}

pub fn text_like_labelled_by_element_with_id_test() {
  widgets.input_widget("text")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "hello",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args(
      "",
      widget.LabelledByElementsWithIds(["id"]),
      widget.DescribedByNone,
    ),
  )
  |> birdie.snap(title: "text like labelled by element with id")
}

pub fn text_like_labelled_by_label_for_test() {
  widgets.input_widget("text")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "hello",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "text like labelled by label/for")
}

pub fn text_like_required_test() {
  widgets.input_widget("text")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "hello",
      disabled: False,
      required: True,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "text like required")
}

pub fn text_like_disabled_test() {
  widgets.input_widget("text")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "hello",
      disabled: True,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "text like disabled")
}

pub fn checkbox_checked_test() {
  widgets.checkbox_widget()(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "on",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "checkbox checked")
}

pub fn checkbox_unchecked_test() {
  widgets.checkbox_widget()(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "checkbox unchecked")
}

pub fn password_test() {
  widgets.password_widget()(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "pass",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "password ignores input")
}

pub fn numeric_no_step_test() {
  widgets.number_widget("")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "1",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "number input with no step")
}

pub fn numeric_step_test() {
  widgets.number_widget("0.1")(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "1.0",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "number input with step")
}

pub fn select_test() {
  widgets.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")])(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "basic select")
}

pub fn select_selected_test() {
  widgets.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")])(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "1",
      disabled: False,
      required: False,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "select selected")
}

pub fn select_required_test() {
  widgets.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")])(
    field.Valid(
      name: "name",
      label: "Label",
      help_text: "",
      value: "",
      disabled: False,
      required: True,
      hidden: False,
    ),
    widget.Args("", widget.LabelledByLabelFor, widget.DescribedByNone),
  )
  |> birdie.snap(title: "required select")
}
