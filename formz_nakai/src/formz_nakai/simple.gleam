import formz/formz_use as formz
import formz/input.{WidgetArgs}
import gleam/list
import gleam/string
import nakai/attr
import nakai/html

pub fn generate_form(form) -> html.Node {
  form
  |> formz.get_items
  |> list.map(generate_visible_item)
  |> html.Fragment()
}

pub fn generate_visible_item(item: formz.FormItem(html.Node)) -> html.Node {
  case item {
    formz.Item(f) if f.hidden == True ->
      html.input([attr.type_("hidden"), attr.name(f.name), attr.value(f.value)])
    formz.Item(f) -> {
      let label_el =
        html.label([attr.for(f.name)], [html.Text(f.label), html.Text(": ")])

      let description_el = case string.is_empty(f.help_text) {
        True -> html.Nothing
        False -> html.span([attr.class("help_text")], [html.Text(f.help_text)])
      }
      let widget_el =
        html.span([attr.class("widget")], [
          f.widget(f, WidgetArgs(id: f.name, labelled_by: input.Element)),
        ])

      let errors_el = case f {
        input.Valid(..) -> html.Nothing
        input.Invalid(error:, ..) ->
          html.span([attr.class("errors")], [html.Text(error)])
      }

      html.p([attr.class("simple_field")], [
        label_el,
        description_el,
        widget_el,
        errors_el,
      ])
    }
    formz.Set(s, items) -> {
      let legend = html.legend([], [html.Text(s.label)])
      let children = items |> list.map(generate_visible_item)
      html.fieldset([], [legend, ..children])
    }
  }
}
