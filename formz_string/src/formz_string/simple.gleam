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
    formz.Field(field, _) if field.hidden == True ->
      "<input"
      <> { " type=\"hidden\"" }
      <> { " name=\"" <> field.name <> "\"" }
      <> { " value\"" <> field.value <> "\"" }
      <> ">"
    formz.Field(field, make_widget) -> {
      let id = field.name

      let label_el =
        "<label for=\"" <> id <> "\">" <> field.label <> ": </label>"

      let #(help_text_el, help_text_id) = case field.help_text {
        "" -> #("", "")
        _ -> {
          #(
            " <span"
              <> { " class=\"formz_help_text\"" }
              <> { " id=\"" <> id <> "_help_text" <> "\"" }
              <> ">"
              <> field.help_text
              <> " </span>",
            id <> "_help_text",
          )
        }
      }

      let #(errors_el, errors_id) = case field {
        field.Valid(..) -> #("", "")
        field.Invalid(error:, ..) -> {
          #(
            " <span"
              <> { " class=\"formz_error\"" }
              <> { " id=\"" <> id <> "_error" <> "\"" }
              <> ">"
              <> error
              <> "</span>",
            id <> "_error",
          )
        }
      }

      let widget_el =
        make_widget(
          field,
          widget.Args(
            id,
            widget.LabelledByLabelFor,
            widget.DescribedByElementsWithIds([help_text_id, errors_id]),
          ),
        )

      "<div class=\"formz_field\">"
      <> label_el
      <> widget_el
      <> help_text_el
      <> errors_el
      <> "</div>"
    }
    formz.SubForm(s, items) -> {
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
