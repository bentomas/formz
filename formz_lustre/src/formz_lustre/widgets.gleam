import formz/input.{type Input}
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn checkbox_widget() {
  fn(input: Input(element.Element(msg), Nil), _) -> element.Element(msg) {
    html.input([
      attribute.type_("checkbox"),
      attribute.name(input.name),
      attribute.value("1"),
      attribute.checked(input.value == "1"),
    ])
  }
}

pub fn password_widget() {
  fn(input: Input(element.Element(msg), Nil), _) -> element.Element(msg) {
    html.input([
      attribute.type_("password"),
      attribute.name(input.name),
      attribute.value(input.value),
    ])
  }
}

pub fn text_widget() {
  fn(input: Input(element.Element(msg), Nil), _) -> element.Element(msg) {
    let placeholder = ""

    html.input([
      attribute.type_("text"),
      attribute.name(input.name),
      attribute.value(input.value),
      attribute.placeholder(placeholder),
    ])
  }
}

pub fn textarea_widget() {
  fn(input: Input(element.Element(msg), _), _) -> element.Element(msg) {
    html.textarea([attribute.name(input.name)], "")
  }
}

pub fn hidden_widget() {
  fn(input: Input(element.Element(msg), Nil), _) -> element.Element(msg) {
    html.input([
      attribute.type_("hidden"),
      attribute.name(input.name),
      attribute.value(input.value),
    ])
  }
}

pub fn select_widget(variants: List(#(String, value))) {
  fn(input: Input(element.Element(msg), Nil), _) -> element.Element(msg) {
    html.select(
      [attribute.name(input.name)],
      list.map(variants, fn(variant) {
        let val = string.inspect(variant.1)
        html.option(
          [attribute.value(val), attribute.selected(input.value == val)],
          variant.0,
        )
      }),
    )
  }
}
