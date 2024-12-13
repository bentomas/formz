import formz
import formz_nakai/widget
import gleam/int
import gleam/list
import nakai/attr
import nakai/html

pub fn generate(form: formz.Form(widget.Widget, a)) -> html.Node {
  form
  |> formz.items
  |> list.map(generate_item)
  |> html.div([attr.class("formz_items")], _)
}

pub fn generate_item(item: formz.Item(widget.Widget)) -> html.Node {
  case item {
    formz.Field(config, state, widget.Hidden) -> hidden_input(config, state)

    formz.ListField(config, states, _, widget.Hidden) ->
      states |> list.map(hidden_input(config, _)) |> html.Fragment

    formz.Field(config, state, widget.Widget(make_widget)) -> {
      let id = config.name

      let label = label(id, config.label)
      let help_text =
        help_text(id, config.help_text, html.span, "formz_help_text")
      let error = error(id, state, html.span, "formz_error")

      let widget_el =
        make_widget(
          config,
          state,
          widget.Args(
            id: id,
            labelled_by: widget.LabelledByLabelFor,
            described_by: widget.DescribedByElementsWithIds([
              help_text.id,
              error.id,
            ]),
          ),
        )

      html.div([attr.class("formz_field")], [
        label.element,
        help_text.element,
        widget_el,
        error.element,
      ])
    }

    formz.ListField(config, states, _, widget.Widget(make_widget)) -> {
      let id = config.name

      let legend = legend(id, config.label)
      let help_text =
        help_text(id, config.help_text, html.span, "formz_help_text")

      let widgets_el =
        states
        |> list.index_map(fn(state, i) {
          let id = id <> "_" <> int.to_string(i)
          let error = error(id, state, html.span, "formz_error")

          let args =
            widget.Args(
              id,
              widget.LabelledByElementsWithIds([legend.id]),
              widget.DescribedByElementsWithIds([help_text.id, error.id]),
            )

          html.li([], [make_widget(config, state, args), error.element])
        })
        |> html.ol([], _)

      html.fieldset([attr.class("formz_listfield")], [
        legend.element,
        help_text.element,
        widgets_el,
      ])
    }

    formz.SubForm(config, items) -> {
      let id = config.name
      let legend = legend(id, config.label)
      let help_text = help_text(id, config.help_text, html.p, "formz_help_text")
      let children = items |> list.map(generate_item)
      html.fieldset(list.flatten([described_by_attr(help_text.id)]), [
        legend.element,
        help_text.element,
        html.div([], children),
      ])
    }
  }
}

fn described_by_attr(id) -> List(attr.Attr) {
  case id {
    "" -> []
    _ -> [attr.Attr("aria-describedby", id)]
  }
}

pub type ElementAndId {
  ElementAndId(element: html.Node, id: String)
}

pub fn label(id, label) -> ElementAndId {
  ElementAndId(
    html.label([attr.for(id)], [html.Text(label), html.Text(": ")]),
    "",
  )
}

pub fn legend(id, label) -> ElementAndId {
  ElementAndId(
    html.legend([attr.id(id <> "_legend")], [html.Text(label <> ": ")]),
    id <> "_legend",
  )
}

fn hidden_input(config: formz.Config, state: formz.InputState) -> html.Node {
  html.input([
    attr.type_("hidden"),
    attr.name(config.name),
    attr.value(state.value),
  ])
}

pub fn help_text(
  id: String,
  help_text: String,
  element: fn(List(attr.Attr), List(html.Node)) -> html.Node,
  class_name: String,
) -> ElementAndId {
  case help_text {
    "" -> ElementAndId(html.Nothing, "")
    _ ->
      ElementAndId(
        element([attr.id(id <> "_help_text"), attr.class(class_name)], [
          html.Text(help_text),
        ]),
        id <> "_help_text",
      )
  }
}

pub fn error(
  id: String,
  state: formz.InputState,
  element: fn(List(attr.Attr), List(html.Node)) -> html.Node,
  class_name: String,
) -> ElementAndId {
  case state {
    formz.Invalid(error:, ..) -> {
      ElementAndId(
        element([attr.id(id <> "_error"), attr.class(class_name)], [
          html.Text(error),
        ]),
        id <> "_error",
      )
    }
    _ -> ElementAndId(html.Nothing, "")
  }
}
