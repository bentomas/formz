import forma/field
import forma/input.{type Input}

pub fn checkbox_widget(_f) -> String {
  "<input type=\"checkbox\">"
}

pub fn password_widget(_f) -> String {
  "<input type=\"password\">"
}

pub fn text_widget(f: Input(String)) -> String {
  let placeholder = ""

  "<input name=\""
  <> f.name
  <> "\" placeholder=\""
  <> placeholder
  <> "\" type=\"text\" value=\""
  <> f.value
  <> "\">"
}

pub fn textarea_widget(_f) -> String {
  // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
  // https://til.simonwillison.net/css/resizing-textarea
  "<textarea></textarea>"
}

pub fn text_field() {
  field.text_field(text_widget)
}

pub fn email_field() {
  field.email_field(text_widget)
}

pub fn integer_field() {
  field.integer_field(text_widget)
}

pub fn number_field() {
  field.number_field(text_widget)
}

pub fn boolean_field() {
  field.boolean_field(checkbox_widget)
}
