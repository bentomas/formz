import formz/input.{type Input, type WidgetArgs}
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
  labelled_by: input.InputLabelled,
  label: String,
) -> List(attr.Attr) {
  case labelled_by {
    input.Element -> []
    input.Id(id) -> [attr.aria_labelledby(id)]
    input.Value ->
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
  fn(input: Input(html.Node), args: input.WidgetArgs) -> html.Node {
    let checked_attr = case input.value {
      "on" -> [attr.checked()]
      _ -> []
    }

    html.input(
      list.flatten([
        type_attr("checkbox"),
        name_attr(input.name),
        id_attr(args.id),
        checked_attr,
        aria_label_attr(args.labelled_by, input.label),
      ]),
    )
  }
}

pub fn password_widget() {
  fn(input: Input(html.Node), args: WidgetArgs) -> html.Node {
    html.input(
      list.flatten([
        type_attr("password"),
        name_attr(input.name),
        id_attr(args.id),
        // value_attr(input.value),
        aria_label_attr(args.labelled_by, input.label),
      ]),
    )
  }
}

pub fn text_like_widget(type_: String) {
  fn(input: Input(html.Node), args: WidgetArgs) -> html.Node {
    html.input(
      list.flatten([
        type_attr(type_),
        name_attr(input.name),
        id_attr(args.id),
        value_attr(input.value),
        aria_label_attr(args.labelled_by, input.label),
      ]),
    )
  }
}

pub fn textarea_widget() {
  fn(input: Input(html.Node), args: WidgetArgs) -> html.Node {
    html.textarea(
      list.flatten([
        name_attr(input.name),
        id_attr(args.id),
        aria_label_attr(args.labelled_by, input.label),
      ]),
      [html.Text(input.value)],
    )
  }
}

pub fn hidden_widget() {
  fn(input: Input(html.Node), _) -> html.Node {
    html.input(
      list.flatten([
        type_attr("hidden"),
        name_attr(input.name),
        value_attr(input.value),
      ]),
    )
  }
}

pub fn select_widget(variants: List(#(String, value))) {
  fn(input: Input(html.Node), args: WidgetArgs) -> html.Node {
    html.select(
      list.flatten([
        name_attr(input.name),
        id_attr(args.id),
        aria_label_attr(args.labelled_by, input.label),
      ]),
      list.map(variants, fn(variant) {
        let val = string.inspect(variant.1)
        let selected_attr = case input.value == val {
          True -> [attr.selected()]
          _ -> []
        }
        html.option(list.flatten([value_attr(val), selected_attr]), [
          html.Text(variant.0),
        ])
      }),
    )
  }
}
