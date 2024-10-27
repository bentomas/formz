import formz/field.{type Field}
import formz/widget

import gleam/list
import gleam/string
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
    widget.LabelledByElementWithId(id) -> [attr.aria_labelledby(id)]
    widget.LabelledByFieldValue ->
      case label {
        "" -> []
        _ -> [attr.aria_label(label)]
      }
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

pub fn checkbox_widget() {
  fn(field: Field, args: widget.Args) -> html.Node {
    let checked_attr = case field.value {
      "on" -> [attr.checked()]
      _ -> []
    }

    html.input(
      list.flatten([
        type_attr("checkbox"),
        name_attr(field.name),
        id_attr(args.id),
        checked_attr,
        aria_label_attr(args.labelled_by, field.label),
      ]),
    )
  }
}

pub fn password_widget() {
  fn(field: Field, args: widget.Args) -> html.Node {
    html.input(
      list.flatten([
        type_attr("password"),
        name_attr(field.name),
        id_attr(args.id),
        // value_attr(field.value),
        aria_label_attr(args.labelled_by, field.label),
      ]),
    )
  }
}

pub fn text_like_widget(type_: String) {
  fn(field: Field, args: widget.Args) -> html.Node {
    html.input(
      list.flatten([
        type_attr(type_),
        name_attr(field.name),
        id_attr(args.id),
        value_attr(field.value),
        aria_label_attr(args.labelled_by, field.label),
      ]),
    )
  }
}

pub fn textarea_widget() {
  fn(field: Field, args: widget.Args) -> html.Node {
    html.textarea(
      list.flatten([
        name_attr(field.name),
        id_attr(args.id),
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

pub fn select_widget(variants: List(#(String, value))) {
  fn(field: Field, args: widget.Args) -> html.Node {
    html.select(
      list.flatten([
        name_attr(field.name),
        id_attr(args.id),
        aria_label_attr(args.labelled_by, field.label),
      ]),
      list.flatten([
        [html.option([attr.value("")], [html.Text("Select...")]), html.hr([])],
        list.map(variants, fn(variant) {
          let val = string.inspect(variant.1)
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
