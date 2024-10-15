import formz/formz_use as formz
import formz/input.{type Input, Input, InvalidInput}
import gleam/list
import gleam/string

pub fn generate_form(form) -> String {
  {
    form
    |> formz.get_inputs
    |> list.filter(fn(f) { !f.hidden })
    |> list.map(generate_visible_field)
    |> string.join("\n")
  }
  <> {
    form
    |> formz.get_inputs
    |> list.filter(fn(f) { f.hidden })
    |> list.map(generate_hidden_field)
    |> string.join("\n")
  }
}

pub fn generate_visible_field(f: Input(String)) -> String {
  let label_el = "<label>" <> f.label <> ": </label>"
  let description_el = case string.is_empty(f.help_text) {
    True -> ""
    False -> "<span class=\"description\">" <> f.help_text <> "</span>"
  }
  let widget_el = "<span class=\"widget\">" <> f.render(f) <> "</span>"

  let errors_el = case f {
    Input(..) -> "<span class=\"error-placeholder\"></span>"
    InvalidInput(error:, ..) -> "<span class=\"errors\">" <> error <> "</span>"
  }

  "<p class=\"simple_field\">"
  <> label_el
  <> description_el
  <> widget_el
  <> errors_el
  <> "</p>"
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
