import formz/formz_use as formz
import formz/input.{type Input, Input, InvalidInput}
import gleam/list
import gleam/string
import nakai/attr
import nakai/html

pub fn generate_form(form) -> html.Node {
  form
  |> formz.get_inputs
  |> list.filter(fn(f) { !f.hidden })
  |> list.map(generate_visible_field)
  |> html.Fragment
  // <> {
  //   form
  //   |> formz.get_inputs
  //   |> list.filter(fn(f) { f.hidden })
  //   |> list.map(generate_hidden_field)
  //   |> string.join("\n")
  // }
}

pub fn generate_visible_field(f: Input(html.Node)) -> html.Node {
  let label_el = html.label([], [html.Text(f.label), html.Text(": ")])

  let description_el = case string.is_empty(f.help_text) {
    True -> html.Nothing
    False -> html.span([attr.class("help_text")], [html.Text(f.help_text)])
  }
  let widget_el =
    html.span([attr.class("widget")], [f.render(f, input.Args(f.name))])

  let errors_el = case f {
    Input(..) -> html.Nothing
    InvalidInput(error:, ..) ->
      html.span([attr.class("errors")], [html.Text(error)])
  }

  html.p([attr.class("simple_field")], [
    label_el,
    description_el,
    widget_el,
    errors_el,
  ])
}

pub fn generate_hidden_field(f: Input(String)) -> String {
  case f.hidden {
    False -> ""
    True -> {
      "<input type=\"hidden\" name=\""
      <> f.name
      <> "\" value=\""
      <> f.value
      <> "\" />"
    }
  }
}
