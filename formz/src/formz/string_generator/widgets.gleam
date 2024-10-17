import formz/input.{type Input}

pub fn checkbox_widget(f: Input(String, Nil), _) -> String {
  let aria_label_attr = case f.label {
    "" -> ""
    _ -> " aria-label=\"" <> f.label <> "\""
  }

  let checked_attr = case f.value {
    "1" -> " checked"
    _ -> ""
  }

  "<input "
  <> { " name=\"" <> f.name <> "\"" }
  <> { " type=\"checkbox\"" }
  <> { " value=\"1\"" }
  <> { aria_label_attr }
  <> { checked_attr }
  <> ">"
}

pub fn password_widget(_f: Input(String, Nil), _) -> String {
  "<input type=\"password\">"
}

pub fn text_widget(f: Input(String, Nil), _) -> String {
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

pub fn textarea_widget(_f: Input(String, Nil), _) -> String {
  // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
  // https://til.simonwillison.net/css/resizing-textarea
  "<textarea></textarea>"
}
