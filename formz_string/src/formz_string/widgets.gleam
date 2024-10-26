import formz/field.{type Field, type WidgetArgs}
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

fn aria_label_attr(labelled_by: field.InputLabelled, label: String) -> String {
  case labelled_by {
    // there should be a label with a for attribute pointing to this id
    field.Element -> ""

    // we have the id of the element that labels this input
    field.Id(id) -> " aria-labelledby=\"" <> id <> "\""

    // we'll use the label value as the aria-label
    field.Value -> {
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

pub fn checkbox_widget() {
  field.widget(fn(field: Field(String), args: WidgetArgs) -> String {
    let checked_attr = case field.value {
      "on" -> " checked"
      _ -> ""
    }

    "<input"
    <> type_attr("checkbox")
    <> name_attr(field.name)
    <> id_attr(args.id)
    <> checked_attr
    <> aria_label_attr(args.labelled_by, field.label)
    <> ">"
  })
}

pub fn password_widget() {
  field.widget(fn(field: Field(String), args: WidgetArgs) -> String {
    "<input"
    <> type_attr("password")
    <> name_attr(field.name)
    <> id_attr(args.id)
    // <> value_attr(field.value)
    <> aria_label_attr(args.labelled_by, field.label)
    <> ">"
  })
}

pub fn text_like_widget(type_: String) {
  field.widget(fn(field: Field(String), args: WidgetArgs) -> String {
    "<input"
    <> type_attr(type_)
    <> name_attr(field.name)
    <> id_attr(args.id)
    <> value_attr(field.value)
    <> aria_label_attr(args.labelled_by, field.label)
    <> ">"
  })
}

pub fn textarea_widget() {
  field.widget(fn(field: Field(String), args: WidgetArgs) -> String {
    // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
    // https://til.simonwillison.net/css/resizing-textarea
    "<textarea"
    <> name_attr(field.name)
    <> id_attr(args.id)
    <> aria_label_attr(args.labelled_by, field.label)
    <> ">"
    <> field.value
    <> "</textarea>"
  })
}

pub fn hidden_widget() {
  field.widget(fn(field: Field(String), _args: WidgetArgs) -> String {
    "<input"
    <> type_attr("hidden")
    <> name_attr(field.name)
    <> value_attr(field.value)
    <> ">"
  })
}

pub fn select_widget(variants: List(#(String, value))) {
  field.widget(fn(field: Field(String), args: WidgetArgs) {
    let choices =
      list.map(variants, fn(variant) {
        let val = string.inspect(variant.1)
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
      <> aria_label_attr(args.labelled_by, field.label)
      <> ">"
    }
    // TODO make this placeholder option not selectable? with disabled selected attributes
    // https://stackoverflow.com/questions/5805059/how-do-i-make-a-placeholder-for-a-select-box
    <> { "<option value>Select...</option>" }
    <> { "<hr>" }
    <> choices
    <> { "</select>" }
  })
}
