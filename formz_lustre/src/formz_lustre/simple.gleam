import formz
import formz_lustre/widget
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html.{html}

pub fn generate(form) -> element.Element(msg) {
  form
  |> formz.items
  |> list.map(generate_item)
  |> html.div([attribute.class("formz_items")], _)
}

pub fn generate_item(
  item: formz.FormItem(widget.Widget(msg)),
) -> element.Element(msg) {
  case item {
    formz.Field(field, state, _) if field.hidden == True ->
      html.input([
        attribute.type_("hidden"),
        attribute.name(field.name),
        attribute.value(state.value),
      ])

    formz.Field(field, state, make_widget) -> {
      let id = field.name

      let label_el =
        html.label([attribute.for(id)], [
          html.text(field.label),
          html.text(": "),
        ])

      let help_text = case string.is_empty(field.help_text) {
        True -> #(element.none(), "")
        False -> #(
          html.span(
            [
              attribute.id(id <> "_help_text"),
              attribute.class("formz_help_text"),
            ],
            [html.text(field.help_text)],
          ),
          id <> "_help_text",
        )
      }

      let error = case state {
        formz.Invalid(error:, ..) -> #(
          html.span(
            [attribute.id(id <> "_error"), attribute.class("formz_error")],
            [html.text(error)],
          ),
          id <> "_error",
        )
        _ -> #(element.none(), "")
      }

      let widget_el =
        make_widget(
          field,
          state,
          widget.Args(
            id: id,
            labelled_by: widget.LabelledByLabelFor,
            described_by: widget.DescribedByElementsWithIds([
              help_text.1,
              error.1,
            ]),
          ),
        )

      html.div([attribute.class("formz_field")], [
        label_el,
        widget_el,
        help_text.0,
        error.0,
      ])
    }
    formz.SubForm(s, items) -> {
      let legend = html.legend([], [html.text(s.label)])
      let children = items |> list.map(generate_item)
      html.fieldset([], [legend, html.div([], children)])
    }
    _ -> element.none()
  }
}
