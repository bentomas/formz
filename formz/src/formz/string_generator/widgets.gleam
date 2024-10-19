import formz/input.{type Input}
import gleam/list
import gleam/string

pub fn checkbox_widget() {
  fn(input: Input(String, Nil), _) -> String {
    let aria_label_attr = case input.label {
      "" -> ""
      _ -> " aria-label=\"" <> input.label <> "\""
    }

    let checked_attr = case input.value {
      "1" -> " checked"
      _ -> ""
    }

    "<input "
    <> { " name=\"" <> input.name <> "\"" }
    <> { " type=\"checkbox\"" }
    <> { " value=\"1\"" }
    <> { aria_label_attr }
    <> { checked_attr }
    <> ">"
  }
}

pub fn password_widget() {
  fn(_input: Input(String, Nil), _) -> String { "<input type=\"password\">" }
}

pub fn text_widget() {
  fn(input: Input(String, Nil), _) -> String {
    let aria_label = case input.label {
      "" -> ""
      _ -> " aria-label=\"" <> input.label <> "\""
    }

    "<input "
    <> { " name=\"" <> input.name <> "\"" }
    <> { " type=\"text\"" }
    <> { " value=\"" <> input.value <> "\"" }
    <> { aria_label }
    <> ">"
  }
}

pub fn textarea_widget() {
  fn(_input: Input(String, Nil), _) -> String {
    // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
    // https://til.simonwillison.net/css/resizing-textarea
    "<textarea></textarea>"
  }
}

pub fn select_widget(
  variants: List(#(String, value)),
) -> fn(Input(String, Nil), _) -> String {
  fn(input: Input(String, Nil), _) {
    let choices =
      list.map(variants, fn(variant) {
        let val = string.inspect(variant.1)
        let selected = case input.value == val {
          True -> " selected"
          _ -> ""
        }
        { "<option value=\"" <> val <> "\"" <> selected <> ">" }
        <> variant.0
        <> "</option>"
      })
      |> string.join("")

    { "<select " <> { " name=\"" <> input.name <> "\"" } <> ">" }
    <> choices
    <> { "</select>" }
  }
}
