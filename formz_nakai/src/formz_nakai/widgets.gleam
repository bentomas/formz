import formz/input.{type Input}
import nakai/attr
import nakai/html

pub fn checkbox_widget(input: Input(html.Node, Nil), _) -> html.Node {
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

pub fn password_widget(input: Input(html.Node, Nil), _) -> html.Node {
  html.input([
    attr.type_("password"),
    attr.name(input.name),
    attr.value(input.value),
  ])
}

pub fn text_widget(input: Input(html.Node, Nil), _) -> html.Node {
  let placeholder = ""

  html.input([
    attr.type_("text"),
    attr.name(input.name),
    attr.value(input.value),
    attr.placeholder(placeholder),
  ])
}

pub fn textarea_widget(input: Input(html.Node, Nil), _) -> html.Node {
  html.textarea([attr.name(input.name)], [])
}

pub fn hidden_widget(input: Input(html.Node, Nil), _) -> html.Node {
  html.input([
    attr.type_("hidden"),
    attr.name(input.name),
    attr.value(input.value),
  ])
}
