import formz/field
import formz/string_generator/widgets

pub fn text_field() {
  field.text_field(widgets.text_widget)
}

pub fn email_field() {
  field.email_field(widgets.text_widget)
}

pub fn integer_field() {
  field.integer_field(widgets.text_widget)
}

pub fn number_field() {
  field.number_field(widgets.text_widget)
}

pub fn boolean_field() {
  field.boolean_field(widgets.checkbox_widget)
}
