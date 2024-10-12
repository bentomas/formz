import forma/generator/string_widget
import forma/input

pub fn text_input() {
  input.text_input(string_widget.text_widget)
}

pub fn email_input() {
  input.email_input(string_widget.text_widget)
}

pub fn integer_input() {
  input.integer_input(string_widget.text_widget)
}

pub fn number_input() {
  input.number_input(string_widget.text_widget)
}
