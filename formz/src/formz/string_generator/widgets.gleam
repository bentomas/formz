import formz/input.{type Input}

pub fn checkbox_widget(f: Input(String)) -> String {
  "<input type=\"checkbox\">"
}

pub fn password_widget(f: Input(String)) -> String {
  "<input type=\"password\">"
}

pub fn text_widget(f: Input(String)) -> String {
  let aria_label = case f.label {
    "" -> ""
    _ -> " aria-label=\"" <> f.label <> "\""
  }

  "<input "
  <> { " name=\"" <> f.name <> "\"" }
  <> { " type=\"text\"" }
  <> { " value=\"" <> f.value <> "\"" }
  <> { aria_label }
  <> ">"
}

pub fn textarea_widget(f: Input(String)) -> String {
  // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
  // https://til.simonwillison.net/css/resizing-textarea
  "<textarea></textarea>"
}
