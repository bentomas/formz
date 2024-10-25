import formz/formz_use as formz
import formz/input.{WidgetArgs}
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html.{html}

pub fn generate_form(form) -> element.Element(msg) {
  form
  |> formz.get_items
  |> list.map(generate_item)
  |> element.fragment
}

pub fn generate_item(
  item: formz.FormItem(element.Element(msg)),
) -> element.Element(msg) {
  case item {
    formz.Item(f) if f.hidden == True ->
      html.input([
        attribute.type_("hidden"),
        attribute.name(f.name),
        attribute.value(f.value),
      ])
    formz.Item(f) -> {
      let label_el = html.label([], [html.text(f.label), html.text(": ")])

      let description_el = case string.is_empty(f.help_text) {
        True -> element.none()
        False ->
          html.span([attribute.class("help_text")], [html.text(f.help_text)])
      }
      let widget_el =
        html.span([attribute.class("widget")], [
          f.widget(f, WidgetArgs(id: f.name, labelled_by: input.Element)),
        ])

      let errors_el = case f {
        input.Valid(..) -> element.none()
        input.Invalid(error:, ..) ->
          html.span([attribute.class("errors")], [html.text(error)])
      }

      html.p([attribute.class("simple_field")], [
        label_el,
        description_el,
        widget_el,
        errors_el,
      ])
    }
    formz.Set(s, items) -> {
      let legend = html.legend([], [html.text(s.label)])
      let children = items |> list.map(generate_item)
      html.fieldset([], [legend, ..children])
    }
  }
}
