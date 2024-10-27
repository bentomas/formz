import formz/field
import formz/formz_use as formz
import formz/widget
import gleam/list
import gleam/string
import nakai/attr
import nakai/html

pub fn generate_form(form) -> html.Node {
  form
  |> formz.items
  |> list.map(generate_visible_item)
  |> html.Fragment()
}

pub fn generate_visible_item(item: formz.FormItem(html.Node)) -> html.Node {
  case item {
    formz.Element(f, _) if f.hidden == True ->
      html.input([attr.type_("hidden"), attr.name(f.name), attr.value(f.value)])
    formz.Element(f, make_widget) -> {
      let label_el =
        html.label([attr.for(f.name)], [html.Text(f.label), html.Text(": ")])

      let description_el = case string.is_empty(f.help_text) {
        True -> html.Nothing
        False -> html.span([attr.class("help_text")], [html.Text(f.help_text)])
      }
      let widget_el =
        html.span([attr.class("widget")], [
          make_widget(
            f,
            widget.Args(id: f.name, labelled_by: widget.LabelledByLabelFor),
          ),
        ])

      let errors_el = case f {
        field.Valid(..) -> html.Nothing
        field.Invalid(error:, ..) ->
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
