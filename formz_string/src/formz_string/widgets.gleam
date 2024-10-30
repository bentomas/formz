import formz/field.{type Field}
import formz/widget
import gleam/list
import gleam/string

fn id_attr(id: String) -> String {
  case id {
    "" -> ""
    _ -> " id=\"" <> id <> "\""
  }
}

fn name_attr(name: String) -> String {
  case name {
    "" -> ""
    _ -> " name=\"" <> name <> "\""
  }
}

fn aria_label_attr(labelled_by: widget.LabelledBy, label: String) -> String {
  case labelled_by {
    // there should be a label with a for attribute pointing to this id
    widget.LabelledByLabelFor -> ""

    // we have the id of the element that labels this input
    widget.LabelledByElementsWithIds(ids) ->
      " aria-labelledby=\"" <> string.join(ids, " ") <> "\""

    // we'll use the label value as the aria-label
    widget.LabelledByFieldValue -> {
      let sanitized_label =
        label
        |> string.replace("\"", "&quot;")
        |> string.replace(">", "&gt;")
      case label {
        "" -> ""
        _ -> " aria-label=\"" <> sanitized_label <> "\""
      }
    }
  }
}

fn aria_describedby_attr(described_by: widget.DescribedBy) -> String {
  case described_by {
    // there should be a label with a for attribute pointing to this id
    widget.DescribedByNone -> ""

    // we have the id of the element that labels this input
    widget.DescribedByElementsWithIds(ids) ->
      " aria-describedby=\"" <> string.join(ids, " ") <> "\""
  }
}

fn step_size_attr(step_size: String) -> String {
  case step_size {
    "" -> ""
    _ -> " step=\"" <> step_size <> "\""
  }
}

fn type_attr(type_: String) -> String {
  " type=\"" <> type_ <> "\""
}

fn value_attr(value: String) -> String {
  let sanitized_value =
    value
    |> string.replace("\"", "&quot;")
    |> string.replace(">", "&gt;")
  case value {
    "" -> ""
    _ -> " value=\"" <> sanitized_value <> "\""
  }
}

fn disabled_attr(disabled: Bool) -> String {
  case disabled {
    True -> " disabled"
    False -> ""
  }
}

fn required_attr(required: Bool) -> String {
  case required {
    True -> " required"
    False -> ""
  }
}

fn checked_attr(value: String) -> String {
  case value {
    "on" -> " checked"
    _ -> ""
  }
}

// Create a checkbox widget (`<input type="checkbox">`). The checkbox is checked
// if the value is "on" (the browser default).
pub fn checkbox_widget() {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field |> field.set_raw_value(""), args, "checkbox", [
      checked_attr(field.value),
    ])
  }
}

pub fn number_widget(step_size: String) {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field, args, "number", [step_size_attr(step_size)])
  }
}

pub fn password_widget() {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field |> field.set_raw_value(""), args, "password", [])
  }
}

pub fn text_like_widget(type_: String) {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field, args, type_, [])
  }
}

fn do_input_widget(
  field: Field,
  args: widget.Args,
  type_: String,
  extra_attrs: List(String),
) {
  "<input"
  <> type_attr(type_)
  <> name_attr(field.name)
  <> id_attr(args.id)
  <> required_attr(field.required)
  <> disabled_attr(field.disabled)
  <> value_attr(field.value)
  <> aria_label_attr(args.labelled_by, field.label)
  <> aria_describedby_attr(args.described_by)
  <> extra_attrs |> string.join("")
  <> ">"
}

pub fn textarea_widget() {
  fn(field: Field, args: widget.Args) -> String {
    // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
    // https://til.simonwillison.net/css/resizing-textarea
    "<textarea"
    <> name_attr(field.name)
    <> id_attr(args.id)
    <> required_attr(field.required)
    <> disabled_attr(field.disabled)
    <> aria_label_attr(args.labelled_by, field.label)
    <> aria_describedby_attr(args.described_by)
    <> ">"
    <> field.value
    <> "</textarea>"
  }
}

pub fn hidden_widget() {
  fn(field: Field, _args: widget.Args) -> String {
    "<input"
    <> type_attr("hidden")
    <> name_attr(field.name)
    <> value_attr(field.value)
    <> ">"
  }
}

pub fn select_widget(variants: List(#(String, String))) {
  fn(field: Field, args: widget.Args) {
    let choices =
      list.map(variants, fn(variant) {
        let val = variant.1
        let selected_attr = case field.value == val {
          True -> " selected"
          _ -> ""
        }
        { "<option" <> value_attr(val) <> selected_attr <> ">" }
        <> variant.0
        <> "</option>"
      })
      |> string.join("")

    {
      "<select"
      <> name_attr(field.name)
      <> id_attr(args.id)
      <> required_attr(field.required)
      <> disabled_attr(field.disabled)
      <> aria_label_attr(args.labelled_by, field.label)
      <> aria_describedby_attr(args.described_by)
      <> ">"
    }
    // TODO make this placeholder option not selectable? with disabled selected attributes
    // https://stackoverflow.com/questions/5805059/how-do-i-make-a-placeholder-for-a-select-box
    <> { "<option value>Select...</option>" }
    <> { "<hr>" }
    <> choices
    <> { "</select>" }
  }
}
