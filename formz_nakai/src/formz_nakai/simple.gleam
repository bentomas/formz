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
    formz.Field(field, _) if field.hidden == True ->
      html.input([
        attr.type_("hidden"),
        attr.name(field.name),
        attr.value(field.value),
      ])
    formz.Field(field, make_widget) -> {
      let label_el =
        html.label([attr.for(field.name)], [
          html.Text(field.label),
          html.Text(": "),
        ])

      let description_el = case string.is_empty(field.help_text) {
        True -> html.Nothing
        False ->
          html.span([attr.class("help_text")], [html.Text(field.help_text)])
      }
      let widget_el =
        html.span([attr.class("widget")], [
          make_widget(
            field,
            widget.args(widget.LabelledByLabelFor) |> widget.id(field.name),
          ),
        ])

      let errors_el = case field {
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
    formz.SubForm(s, items) -> {
      let legend = html.legend([], [html.Text(s.label)])
      let children = items |> list.map(generate_visible_item)
      html.fieldset([], [legend, ..children])
    }
  }
}
