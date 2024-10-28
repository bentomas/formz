import formz/field
import formz/formz_use as formz
import formz/widget
import gleam/list
import gleam/string

pub fn generate_form(form) -> String {
  "<div class=\"formz_formitems\">"
  <> {
    form
    |> formz.items
    |> list.map(generate_item)
    |> string.join("\n")
  }
  <> "</div>"
}

pub fn generate_item(item: formz.FormItem(String)) -> String {
  case item {
    formz.Element(f, _) if f.hidden == True ->
      "<input"
      <> { " type=\"hidden\"" }
      <> { " name=\"" <> f.name <> "\"" }
      <> { " value\"" <> f.value <> "\"" }
      <> ">"
    formz.Element(f, widget) -> {
      let label_el =
        "<label for=\"" <> f.name <> "\">" <> f.label <> ": </label>"
      let description_el = case string.is_empty(f.help_text) {
        True -> ""
        False ->
          " <span class=\"formz_help_text\">" <> f.help_text <> " </span>"
      }
      let widget_el =
        " <span class=\"formz_widget\">"
        <> widget(
          f,
          widget.Args(
            id: f.name,
            labelled_by: widget.LabelledByLabelFor,
            described_by: widget.DescribedByNone,
          ),
        )
        <> "</span>"

      let errors_el = case f {
        field.Valid(..) -> ""
        field.Invalid(error:, ..) ->
          " <span class=\"formz_error\">" <> error <> "</span>"
      }

      "<div class=\"formz_field\">"
      <> label_el
      <> widget_el
      <> description_el
      <> errors_el
      <> "</div>"
    }
    formz.Set(s, items) -> {
      { "<fieldset><legend>" <> s.label <> "</legend>" }
      <> { "<div>" }
      <> {
        list.map(items, generate_item)
        |> string.join("\n")
      }
      <> "</div>"
      <> "</fieldset>"
    }
  }
}
