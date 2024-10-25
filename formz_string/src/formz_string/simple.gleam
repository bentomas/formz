import formz/formz_use as formz
import formz/input
import formz_string/widgets
import gleam/list
import gleam/string

pub fn generate_form(form) -> String {
  {
    form
    |> formz.get_items
    |> list.map(generate_item)
    |> string.join("\n")
  }
}

pub fn generate_item(item: formz.FormItem(String)) -> String {
  case item {
    formz.Item(f) if f.hidden == True ->
      widgets.hidden_widget()(f, input.WidgetArgs("", input.Value))
    formz.Item(f) ->
      case f.hidden {
        True -> ""
        False -> {
          let label_el =
            "<label for=\"" <> f.name <> "\">" <> f.label <> ": </label>"
          let description_el = case string.is_empty(f.help_text) {
            True -> ""
            False -> "<span class=\"description\">" <> f.help_text <> "</span>"
          }
          let widget_el =
            "<span class=\"widget\">"
            <> f.widget(f, input.WidgetArgs(f.name, input.Element))
            <> "</span>"

          let errors_el = case f {
            input.Valid(..) -> "<span class=\"error-placeholder\"></span>"
            input.Invalid(error:, ..) ->
              "<span class=\"errors\">" <> error <> "</span>"
          }

          "<p class=\"simple_field\">"
          <> label_el
          <> widget_el
          <> description_el
          <> errors_el
          <> "</p>"
        }
      }
    formz.Set(s, items) -> {
      "<fieldset><legend>"
      <> s.label
      <> "</legend>"
      <> {
        list.map(items, generate_item)
        |> string.join("\n")
      }
      <> "</fieldset>"
    }
  }
}
