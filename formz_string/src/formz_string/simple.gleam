import formz
import formz_string/widget
import gleam/int
import gleam/list
import gleam/string

pub fn generate(form) -> String {
  formz.items(form)
  |> list.map(generate_item)
  |> string.join("")
  |> wrap("<div class=\"formz_items\">", _, "</div>")
}

pub fn generate_item(item: formz.Item(widget.Widget)) -> String {
  case item {
    formz.Field(config, state, widget.Hidden) -> hidden_input(config, state)

    formz.ListField(config, states, _, widget.Hidden) ->
      states |> list.map(hidden_input(config, _)) |> string.join("")

    formz.Field(config, state, widget.Widget(make_widget)) -> {
      let id = config.name

      let label = label(id, config.label)
      let help_text = help_text(id, config.help_text, "span", "formz_help_text")
      let error = error(id, state, "span", "formz_error")

      let args =
        widget.Args(
          id,
          widget.LabelledByLabelFor,
          widget.DescribedByElementsWithIds([help_text.id, error.id]),
        )
      let widget_el = make_widget(config, state, args)

      "<div class=\"formz_field\">"
      <> label.element
      <> help_text.element
      <> widget_el
      <> error.element
      <> "</div>"
    }

    formz.ListField(config, states, _, widget.Widget(make_widget)) -> {
      let id = config.name

      let legend = legend(id, config.label)
      let help_text = help_text(id, config.help_text, "span", "formz_help_text")

      let widgets_el =
        states
        |> list.index_map(fn(state, i) {
          let id = id <> "_" <> int.to_string(i)
          let error = error(id, state, "span", "formz_error")

          let args =
            widget.Args(
              id,
              widget.LabelledByElementsWithIds([legend.id]),
              widget.DescribedByElementsWithIds([help_text.id, error.id]),
            )

          make_widget(config, state, args) <> error.element
        })
        |> list.map(wrap("<li>", _, "</li>"))
        |> string.join("")
        |> wrap("<ol>", _, "</ol>")

      "<fieldset class=\"formz_listfield\">"
      <> legend.element
      <> help_text.element
      <> widgets_el
      <> "</fieldset>"
    }

    formz.SubForm(config, items) -> {
      let id = config.name

      let legend = legend(id, config.label)
      let help_text = help_text(id, config.help_text, "p", "formz_help_text")

      let items_el =
        "<div>" <> list.map(items, generate_item) |> string.join("") <> "</div>"

      { "<fieldset" <> described_by_attr(help_text.id) <> ">" }
      <> legend.element
      <> help_text.element
      <> items_el
      <> "</fieldset>"
    }
  }
}

fn wrap(start: String, inside: String, end: String) -> String {
  start <> inside <> end
}

fn described_by_attr(id) {
  case id {
    "" -> ""
    _ -> " aria-describedby=\"" <> id <> "\""
  }
}

pub type ElementAndId {
  ElementAndId(element: String, id: String)
}

pub fn label(id, label) -> ElementAndId {
  ElementAndId("<label for=\"" <> id <> "\">" <> label <> ": </label>", "")
}

pub fn legend(id, label) -> ElementAndId {
  ElementAndId(
    "<legend id=\"" <> id <> "_legend\">" <> label <> ": </legend>",
    id <> "_legend",
  )
}

fn hidden_input(config: formz.Config, state: formz.InputState) -> String {
  let value_attr = case state.value {
    "" -> " value"
    _ -> " value=\"" <> widget.sanitize_attr(state.value) <> "\""
  }
  "<input"
  <> { " type=\"hidden\"" }
  <> { " name=\"" <> config.name <> "\"" }
  <> value_attr
  <> ">"
}

pub fn help_text(
  id: String,
  help_text: String,
  element_name: String,
  class_name: String,
) -> ElementAndId {
  case help_text {
    "" -> ElementAndId("", "")
    _ ->
      ElementAndId(
        { "<" <> element_name }
          <> { " id=\"" <> id <> "_help_text" <> "\"" }
          <> { " class=\"" <> class_name <> "\"" }
          <> ">"
          <> help_text
          <> { "</" <> element_name <> ">" },
        id <> "_help_text",
      )
  }
}

pub fn error(
  id: String,
  state: formz.InputState,
  element_name: String,
  class_name: String,
) -> ElementAndId {
  case state {
    formz.Invalid(error:, ..) -> {
      ElementAndId(
        { "<" <> element_name }
          <> { " id=\"" <> id <> "_error" <> "\"" }
          <> { " class=\"" <> class_name <> "\"" }
          <> ">"
          <> error
          <> { "</" <> element_name <> ">" },
        id <> "_error",
      )
    }
    _ -> ElementAndId("", "")
  }
}
