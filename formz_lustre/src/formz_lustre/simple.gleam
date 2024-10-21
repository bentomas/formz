import formz/formz_use as formz
import formz/input.{type Input, Input, InvalidInput}
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html.{html}

pub fn generate_form(form) -> element.Element(msg) {
  form
  |> formz.get_inputs
  |> list.filter(fn(f) { !f.hidden })
  |> list.map(generate_visible_field)
  |> element.fragment
  // <> {
  //   form
  //   |> formz.get_inputs
  //   |> list.filter(fn(f) { f.hidden })
  //   |> list.map(generate_hidden_field)
  //   |> string.join("\n")
  // }
}

pub fn generate_visible_field(
  f: Input(element.Element(msg)),
) -> element.Element(msg) {
  let label_el = html.label([], [html.text(f.label), html.text(": ")])

  let description_el = case string.is_empty(f.help_text) {
    True -> element.none()
    False -> html.span([attribute.class("help_text")], [html.text(f.help_text)])
  }
  let widget_el =
    html.span([attribute.class("widget")], [f.render(f, input.Args(f.name))])

  let errors_el = case f {
    Input(..) -> element.none()
    InvalidInput(error:, ..) ->
      html.span([attribute.class("errors")], [html.text(error)])
  }

  html.p([attribute.class("simple_field")], [
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
