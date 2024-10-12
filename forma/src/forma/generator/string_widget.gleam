import forma/field.{type Field}

pub fn checkbox_widget(_f, _env) -> String {
  "<input type=\"checkbox\">"
}

pub fn password_widget(_f, _env) -> String {
  "<input type=\"password\">"
}

pub fn text_widget(f: Field(String)) -> String {
  let placeholder = ""

  "<input name=\""
  <> f.name
  <> "\" placeholder=\""
  <> placeholder
  <> "\" type=\"text\" value=\""
  <> f.value
  <> "\">"
}

// https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
// https://til.simonwillison.net/css/resizing-textarea

pub fn textarea_widget(_f, _env) -> String {
  "<textarea></textarea>"
}
