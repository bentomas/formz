import formz/field
import formz/formz_use as formz
import formz/widget
import gleam/list
import gleam/string

pub fn generate_form(form) -> String {
  {
    form
    |> formz.items
    |> list.map(generate_item)
    |> string.join("\n")
  }
}

pub fn generate_item(item: formz.FormItem(String)) -> String {
  case item {
    formz.Element(f, _) if f.hidden == True ->
      "<input"
      <> { " type=\"hidden\"" }
      <> { " name=\"" <> f.name <> "\"" }
      <> { " value\"" <> f.value <> "\"" }
      <> ">"
    formz.Element(f, widget) ->
      case f.hidden {
        True -> ""
        False -> {
          let label_el =
            "<label for=\"" <> f.name <> "\">" <> f.label <> ": </label>"
          let description_el = case string.is_empty(f.help_text) {
            True -> ""
            False -> "<span class=\"description\">" <> f.help_text <> " </span>"
          }
          let widget_el =
            "<span class=\"widget\">"
            <> widget(f, widget.Args(f.name, widget.LabelledByLabelFor))
            <> "</span>"

          let errors_el = case f {
            field.Valid(..) -> "<span class=\"error-placeholder\"></span>"
            field.Invalid(error:, ..) ->
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
