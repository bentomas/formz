import birdie
import formz
import formz_string/widget
import gleeunit

pub fn main() {
  gleeunit.main()
}

fn get_make_fun(
  widget: widget.Widget,
) -> fn(formz.Config, formz.InputState, widget.Args) -> String {
  let assert widget.Widget(fun) = widget
  fun
}

pub fn input_labelled_by_field_value_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello", formz.Optional),
    widget.Args("", widget.LabelledByConfigValue, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input labelled by field value")
}

pub fn input_labelled_by_element_with_id_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello", formz.Optional),
    widget.Args(
      "",
      widget.LabelledByElementsWithIds(["id"]),
      widget.DescribedByNone,
    ),
  )
  |> birdie.snap(title: "input labelled by element with id")
}

pub fn input_labelled_by_label_for_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input labelled by label/for")
}

pub fn input_described_by_elements_with_ids_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello", formz.Optional),
    widget.Args(
      "",
      widget.LabelledByLabelElement,
      widget.DescribedByElementsWithIds(["id1", "id2"]),
    ),
  )
  |> birdie.snap(title: "input described by elements with ids")
}

pub fn input_described_by_elements_with_ids_all_empty_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello", formz.Optional),
    widget.Args(
      "",
      widget.LabelledByLabelElement,
      widget.DescribedByElementsWithIds(["", ""]),
    ),
  )
  |> birdie.snap(title: "input described by elements with ids all empty")
}

pub fn input_required_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello", formz.Required),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input required")
}

pub fn input_disabled_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: True),
    formz.Valid("hello", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input disabled")
}

pub fn input_sanitized_value_test() {
  get_make_fun(widget.input_widget("text"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("hello\"<-_=>", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "input sanitized value")
}

pub fn checkbox_checked_test() {
  get_make_fun(widget.checkbox_widget())(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("on", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "checkbox checked")
}

pub fn checkbox_unchecked_test() {
  get_make_fun(widget.checkbox_widget())(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "checkbox unchecked")
}

pub fn password_test() {
  get_make_fun(widget.password_widget())(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("pass", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "password ignores input")
}

pub fn numeric_no_step_test() {
  get_make_fun(widget.number_widget(""))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("1", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "number input with no step")
}

pub fn numeric_step_test() {
  get_make_fun(widget.number_widget("0.1"))(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("1.0", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "number input with step")
}

pub fn select_test() {
  get_make_fun(
    widget.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")]),
  )(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "basic select")
}

pub fn select_selected_test() {
  get_make_fun(
    widget.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")]),
  )(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("1", formz.Optional),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "select selected")
}

pub fn select_required_test() {
  get_make_fun(
    widget.select_widget([#("One", "0"), #("Two", "1"), #("Three", "2")]),
  )(
    formz.Config(name: "name", label: "Label", help_text: "", disabled: False),
    formz.Valid("", formz.Required),
    widget.Args("", widget.LabelledByLabelElement, widget.DescribedByNone),
  )
  |> birdie.snap(title: "required select")
}
