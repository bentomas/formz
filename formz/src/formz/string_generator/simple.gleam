import formz/formz_use as formz
import formz/input.{type Input, Input, InvalidInput}
import formz/string_generator/widgets
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
  let label_el = "<label for=\"" <> f.name <> "\">" <> f.label <> ": </label>"
  let description_el = case string.is_empty(f.help_text) {
    True -> ""
    False -> "<span class=\"description\">" <> f.help_text <> "</span>"
  }
  let widget_el =
    "<span class=\"widget\">"
    <> f.widget(f, input.WidgetArgs(f.name, input.Element))
    <> "</span>"

  let errors_el = case f {
    Input(..) -> "<span class=\"error-placeholder\"></span>"
    InvalidInput(error:, ..) -> "<span class=\"errors\">" <> error <> "</span>"
  }

  "<p class=\"simple_field\">"
  <> label_el
  <> widget_el
  <> description_el
  <> errors_el
  <> "</p>"
}

pub fn generate_hidden_field(f: Input(String)) -> String {
  widgets.hidden_widget()(f, input.WidgetArgs("", input.Value))
}
