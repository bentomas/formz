import formz
import formz_string/widget
import gleam/list
import gleam/string

pub fn generate(form) -> String {
  "<div class=\"formz_items\">"
  <> {
    form
    |> formz.items
    |> list.map(generate_item)
    |> string.join("")
  }
  <> "</div>"
}

pub fn generate_item(item: formz.FormItem(widget.Widget)) -> String {
  case item {
    formz.Field(field, state, _) if field.hidden == True ->
      "<input"
      <> { " type=\"hidden\"" }
      <> { " name=\"" <> field.name <> "\"" }
      <> { " value=\"" <> state.value <> "\"" }
      <> ">"
    formz.Field(field, state, make_widget) -> {
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

      let #(errors_el, errors_id) = case state {
        formz.Invalid(error:, ..) -> {
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
        _ -> #("", "")
      }

      let widget_el =
        make_widget(
          field,
          state,
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
    formz.ListField(field, states, _, make_widget) -> {
      let id = field.name

      let #(legend_el, legend_id) = #(
        "<legend id=\"" <> id <> "_legend\">" <> field.label <> ": </legend>",
        id <> "_legend",
      )

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

      let widgets_el =
        states
        |> list.map(fn(state) {
          let #(errors_el, errors_id) = case state {
            formz.Invalid(error:, ..) -> {
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
            _ -> #("", "")
          }

          let widget_el =
            make_widget(
              field,
              state,
              widget.Args(
                id,
                widget.LabelledByElementsWithIds([legend_id]),
                widget.DescribedByElementsWithIds([help_text_id, errors_id]),
              ),
            )

          widget_el <> errors_el
        })
        |> string.join("</li><li>")
      let widgets_el = "<ol><li>" <> widgets_el <> "</ol>"

      "<fieldset class=\"formz_listfield\">"
      <> legend_el
      <> help_text_el
      <> widgets_el
      <> "</fieldset>"
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
