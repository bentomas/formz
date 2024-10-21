import formz/input.{type Input}
import gleam/list
import gleam/string
import nakai/attr
import nakai/html

pub fn checkbox_widget() {
  fn(input: Input(html.Node), _) -> html.Node {
    let checked_attr = case input.value {
      "" -> attr.Attr("x", "x")
      _ -> attr.checked()
    }
    html.input([
      attr.type_("checkbox"),
      attr.name(input.name),
      attr.value("1"),
      checked_attr,
    ])
  }
}

pub fn password_widget() {
  fn(input: Input(html.Node), _) -> html.Node {
    html.input([
      attr.type_("password"),
      attr.name(input.name),
      attr.value(input.value),
    ])
  }
}

pub fn text_widget() {
  fn(input: Input(html.Node), _) -> html.Node {
    let placeholder = ""

    html.input([
      attr.type_("text"),
      attr.name(input.name),
      attr.value(input.value),
      attr.placeholder(placeholder),
    ])
  }
}

pub fn textarea_widget() {
  fn(input: Input(html.Node), _) -> html.Node {
    html.textarea([attr.name(input.name)], [])
  }
}

pub fn hidden_widget() {
  fn(input: Input(html.Node), _) -> html.Node {
    html.input([
      attr.type_("hidden"),
      attr.name(input.name),
      attr.value(input.value),
    ])
  }
}

pub fn select_widget(variants: List(#(String, value))) {
  fn(input: Input(html.Node), _) -> html.Node {
    html.select(
      [attr.name(input.name)],
      list.map(variants, fn(variant) {
        let val = string.inspect(variant.1)
        let selected_attr = case input.value == val {
          True -> attr.selected()
          _ -> attr.Attr("x", "x")
        }
        html.option([attr.value(val), selected_attr], [html.Text(variant.0)])
      }),
    )
  }
}
