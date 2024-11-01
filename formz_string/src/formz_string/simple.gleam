import formz
import formz/field
import formz/formz_builder
import formz/formz_use
import formz/widget
import gleam/list
import gleam/string

pub fn generate_form_builder(form) -> String {
  "<div class=\"formz_items\">"
  <> {
    form
    |> formz_builder.items
    |> list.map(generate_item)
    |> string.join("")
  }
  <> "</div>"
}

pub fn generate_form_use(form) -> String {
  "<div class=\"formz_items\">"
  <> {
    form
    |> formz_use.items
    |> list.map(generate_item)
    |> string.join("")
  }
  <> "</div>"
}

pub fn generate_item(item: formz.FormItem(String)) -> String {
  case item {
    formz.Field(field, _) if field.hidden == True ->
      "<input"
      <> { " type=\"hidden\"" }
      <> { " name=\"" <> field.name <> "\"" }
      <> { " value=\"" <> field.value <> "\"" }
      <> ">"
    formz.Field(field, make_widget) -> {
      let id = field.name

      let label_el =
        "<label for=\"" <> id <> "\">" <> field.label <> ": </label>"

      let #(help_text_el, help_text_id) = case field.help_text {
        "" -> #("", "")
        _ -> {
          #(
            "<span"
              <> { " id=\"" <> id <> "_help_text" <> "\"" }
              <> { " class=\"formz_help_text\"" }
              <> ">"
              <> field.help_text
              <> "</span>",
            id <> "_help_text",
          )
        }
      }

      let #(errors_el, errors_id) = case field {
        field.Valid(..) -> #("", "")
        field.Invalid(error:, ..) -> {
          #(
            "<span"
              <> { " id=\"" <> id <> "_error" <> "\"" }
              <> { " class=\"formz_error\"" }
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
    formz.SubForm(subform, items) -> {
      let #(help_text_el, help_text_id) = case subform.help_text {
        "" -> #("", "")
        _ -> {
          #(
            "<p"
              <> { " id=\"" <> subform.name <> "_help_text" <> "\"" }
              <> { " class=\"formz_help_text\"" }
              <> ">"
              <> subform.help_text
              <> "</p>",
            subform.name <> "_help_text",
          )
        }
      }

      let described_by_attr = case help_text_id {
        "" -> ""
        _ -> {
          " aria-describedby=\"" <> help_text_id <> "\""
        }
      }

      { "<fieldset" <> described_by_attr <> ">" }
      <> { "<legend>" <> subform.label <> "</legend>" }
      <> help_text_el
      <> { "<div>" }
      <> {
        list.map(items, generate_item)
        |> string.join("")
      }
      <> "</div>"
      <> "</fieldset>"
    }
  }
}
