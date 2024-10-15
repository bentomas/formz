import formz/input.{type Input}
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn checkbox_widget(
  input: Input(element.Element(msg)),
) -> element.Element(msg) {
  html.input([
    attribute.type_("checkbox"),
    attribute.name(input.name),
    attribute.value(input.value),
  ])
}

pub fn password_widget(
  input: Input(element.Element(msg)),
) -> element.Element(msg) {
  html.input([
    attribute.type_("password"),
    attribute.name(input.name),
    attribute.value(input.value),
  ])
}

pub fn text_widget(input: Input(element.Element(msg))) -> element.Element(msg) {
  let placeholder = ""

  html.input([
    attribute.type_("text"),
    attribute.name(input.name),
    attribute.value(input.value),
    attribute.placeholder(placeholder),
  ])
}

pub fn textarea_widget(
  input: Input(element.Element(msg)),
) -> element.Element(msg) {
  html.textarea([attribute.name(input.name)], "")
}

pub fn hidden_widget(input: Input(element.Element(msg))) -> element.Element(msg) {
  html.input([
    attribute.type_("hidden"),
    attribute.name(input.name),
    attribute.value(input.value),
  ])
}
