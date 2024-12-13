import formz
import formz_lustre/widget
import gleam/int
import gleam/list
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
  item: formz.Item(widget.Widget(msg)),
) -> element.Element(msg) {
  case item {
    formz.Field(config, state, widget.Hidden) -> hidden_input(config, state)

    formz.ListField(config, states, _, widget.Hidden) ->
      states
      |> list.map(hidden_input(config, _))
      |> element.fragment

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

      html.div([attribute.class("formz_field")], [
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

      html.fieldset([attribute.class("formz_listfield")], [
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
      html.fieldset([described_by_attr(help_text.id)], [
        legend.element,
        help_text.element,
        html.div([], children),
      ])
    }
  }
}

fn described_by_attr(id) -> attribute.Attribute(msg) {
  case id {
    "" -> attribute.none()
    _ -> attribute.attribute("aria-describedby", id)
  }
}

pub type ElementAndId(msg) {
  ElementAndId(element: element.Element(msg), id: String)
}

pub fn label(id, label) -> ElementAndId(msg) {
  ElementAndId(
    html.label([attribute.for(id)], [html.text(label), html.text(": ")]),
    "",
  )
}

pub fn legend(id, label) -> ElementAndId(msg) {
  ElementAndId(
    html.legend([attribute.id(id <> "_legend")], [html.text(label <> ": ")]),
    id <> "_legend",
  )
}

fn hidden_input(
  config: formz.Config,
  state: formz.InputState,
) -> element.Element(msg) {
  html.input([
    attribute.type_("hidden"),
    attribute.name(config.name),
    attribute.value(state.value),
  ])
}

pub fn help_text(
  id: String,
  help_text: String,
  element: fn(List(attribute.Attribute(msg)), List(element.Element(msg))) ->
    element.Element(msg),
  class_name: String,
) -> ElementAndId(msg) {
  case help_text {
    "" -> ElementAndId(element.none(), "")
    _ ->
      ElementAndId(
        element(
          [attribute.id(id <> "_help_text"), attribute.class(class_name)],
          [html.text(help_text)],
        ),
        id <> "_help_text",
      )
  }
}

pub fn error(
  id: String,
  state: formz.InputState,
  element: fn(List(attribute.Attribute(msg)), List(element.Element(msg))) ->
    element.Element(msg),
  class_name: String,
) -> ElementAndId(msg) {
  case state {
    formz.Invalid(error:, ..) -> {
      ElementAndId(
        element([attribute.id(id <> "_error"), attribute.class(class_name)], [
          html.text(error),
        ]),
        id <> "_error",
      )
    }
    _ -> ElementAndId(element.none(), "")
  }
}
