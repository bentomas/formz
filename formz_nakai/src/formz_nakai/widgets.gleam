import formz/field.{type Field}
import formz/widget
import gleam/string

import gleam/list
import nakai/attr
import nakai/html

fn id_attr(id: String) -> List(attr.Attr) {
  case id {
    "" -> []
    _ -> [attr.id(id)]
  }
}

fn name_attr(name: String) -> List(attr.Attr) {
  case name {
    "" -> []
    _ -> [attr.name(name)]
  }
}

fn aria_label_attr(
  labelled_by: widget.LabelledBy,
  label: String,
) -> List(attr.Attr) {
  case labelled_by {
    widget.LabelledByLabelFor -> []
    widget.LabelledByElementsWithIds(ids) -> [
      attr.aria_labelledby(string.join(ids, " ")),
    ]
    widget.LabelledByFieldValue ->
      case label {
        "" -> []
        _ -> [attr.aria_label(label)]
      }
  }
}

fn aria_describedby_attr(described_by: widget.DescribedBy) -> List(attr.Attr) {
  case described_by {
    widget.DescribedByElementsWithIds(ids) -> [
      attr.Attr("aria-describedby", string.join(ids, " ")),
    ]
    widget.DescribedByNone -> []
  }
}

fn type_attr(type_: String) -> List(attr.Attr) {
  [attr.type_(type_)]
}

fn value_attr(value: String) -> List(attr.Attr) {
  case value {
    "" -> []
    _ -> [attr.value(value)]
  }
}

fn required_attr(required: Bool) -> List(attr.Attr) {
  case required {
    True -> [attr.required("")]
    False -> []
  }
}

fn checked_attr(value: String) -> List(attr.Attr) {
  case value {
    "on" -> [attr.checked()]
    _ -> []
  }
}

fn disabled_attr(disabled: Bool) -> List(attr.Attr) {
  case disabled {
    True -> [attr.disabled()]
    False -> []
  }
}

fn step_size_attr(step_size: String) -> List(attr.Attr) {
  case step_size {
    "" -> []
    _ -> [attr.Attr("step", step_size)]
  }
}

// Create a checkbox widget (`<input type="checkbox">`). The checkbox is checked
// if the value is "on" (the browser default).
pub fn checkbox_widget() {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field |> field.set_raw_value(""), args, "checkbox", [
      checked_attr(field.value),
    ])
  }
}

pub fn number_widget(step_size: String) {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field, args, "number", [step_size_attr(step_size)])
  }
}

pub fn password_widget() {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field |> field.set_raw_value(""), args, "password", [])
  }
}

pub fn text_like_widget(type_: String) {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field, args, type_, [])
  }
}

fn do_input_widget(
  field: Field,
  args: widget.Args,
  type_: String,
  extra_attrs: List(List(attr.Attr)),
) {
  html.input(
    list.flatten([
      type_attr(type_),
      name_attr(field.name),
      id_attr(args.id),
      required_attr(field.required),
      value_attr(field.value),
      disabled_attr(field.disabled),
      aria_describedby_attr(args.described_by),
      aria_label_attr(args.labelled_by, field.label),
      extra_attrs |> list.flatten,
    ]),
  )
}

pub fn textarea_widget() {
  fn(field: Field, args: widget.Args) -> html.Node {
    html.textarea(
      list.flatten([
        name_attr(field.name),
        id_attr(args.id),
        required_attr(field.required),
        aria_label_attr(args.labelled_by, field.label),
      ]),
      [html.Text(field.value)],
    )
  }
}

pub fn hidden_widget() {
  fn(field: Field, _) -> html.Node {
    html.input(
      list.flatten([
        type_attr("hidden"),
        name_attr(field.name),
        value_attr(field.value),
      ]),
    )
  }
}

pub fn select_widget(variants: List(#(String, String))) {
  fn(field: Field, args: widget.Args) -> html.Node {
    html.select(
      list.flatten([
        name_attr(field.name),
        id_attr(args.id),
        required_attr(field.required),
        aria_label_attr(args.labelled_by, field.label),
      ]),
      list.flatten([
        [html.option([attr.value("")], [html.Text("Select...")]), html.hr([])],
        list.map(variants, fn(variant) {
          let val = variant.1
          let selected_attr = case field.value == val {
            True -> [attr.selected()]
            _ -> []
          }
          html.option(list.flatten([value_attr(val), selected_attr]), [
            html.Text(variant.0),
          ])
        }),
      ]),
    )
  }
}
