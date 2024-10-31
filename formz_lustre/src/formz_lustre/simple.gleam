import formz/field
import formz/formz_use as formz
import formz/widget
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html.{html}

pub fn generate_form(form) -> element.Element(msg) {
  form
  |> formz.items
  |> list.map(generate_item)
  |> element.fragment
}

pub fn generate_item(
  item: formz.FormItem(element.Element(msg)),
) -> element.Element(msg) {
  case item {
    formz.Field(field, _) if field.hidden == True ->
      html.input([
        attribute.type_("hidden"),
        attribute.name(field.name),
        attribute.value(field.value),
      ])

    formz.Field(field, make_widget) -> {
      let label_el = html.label([], [html.text(field.label), html.text(": ")])

      let description_el = case string.is_empty(field.help_text) {
        True -> element.none()
        False ->
          html.span([attribute.class("help_text")], [html.text(field.help_text)])
      }
      let described_by = case field, field.help_text {
        field.Valid(..), "" -> widget.DescribedByNone
        field.Valid(..), _ ->
          widget.DescribedByElementsWithIds([field.name <> "_help_text"])
        field.Invalid(..), "" ->
          widget.DescribedByElementsWithIds([field.name <> "_error"])
        field.Invalid(..), _ ->
          widget.DescribedByElementsWithIds([
            field.name <> "_help_text",
            field.name <> "_error",
          ])
      }
      let widget_el =
        html.span([attribute.class("widget")], [
          make_widget(
            field,
            widget.args(widget.LabelledByLabelFor)
              |> widget.id(field.name)
              |> widget.described_by(described_by),
          ),
        ])

      let errors_el = case field {
        field.Valid(..) -> element.none()
        field.Invalid(error:, ..) ->
          html.span([attribute.class("errors")], [html.text(error)])
      }

      html.p([attribute.class("simple_field")], [
        label_el,
        description_el,
        widget_el,
        errors_el,
      ])
    }
    formz.SubForm(s, items) -> {
      let legend = html.legend([], [html.text(s.label)])
      let children = items |> list.map(generate_item)
      html.fieldset([], [legend, ..children])
    }
  }
}
