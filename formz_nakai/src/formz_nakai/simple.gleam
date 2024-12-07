import formz
import formz_nakai/widget
import gleam/list
import nakai/attr
import nakai/html

pub fn generate(form) -> html.Node {
  form
  |> formz.items
  |> list.map(generate_visible_item)
  |> html.div([attr.class("formz_items")], _)
}

pub fn generate_visible_item(item: formz.FormItem(widget.Widget)) -> html.Node {
  case item {
    formz.Field(field, state, _) if field.hidden == True ->
      html.input([
        attr.type_("hidden"),
        attr.name(field.name),
        attr.value(state.value),
      ])
    formz.Field(field, state, make_widget) -> {
      let id = field.name

      let label_el =
        html.label([attr.for(id)], [html.Text(field.label), html.Text(": ")])

      let help_text = case field.help_text {
        "" -> #(html.Nothing, "")
        _ -> #(
          html.span(
            [attr.id(id <> "_help_text"), attr.class("formz_help_text")],
            [html.Text(field.help_text)],
          ),
          id <> "_help_text",
        )
      }
      let error = case state {
        formz.Invalid(error:, ..) -> #(
          html.span([attr.id(id <> "_error"), attr.class("formz_error")], [
            html.Text(error),
          ]),
          id <> "_error",
        )
        _ -> #(html.Nothing, "")
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

      html.div([attr.class("formz_field")], [
        label_el,
        widget_el,
        help_text.0,
        error.0,
      ])
    }
    formz.SubForm(s, items) -> {
      let legend = html.legend([], [html.Text(s.label)])
      let children = items |> list.map(generate_visible_item)
      html.fieldset([], [legend, html.div([], children)])
    }

    _ -> html.Nothing
  }
}
