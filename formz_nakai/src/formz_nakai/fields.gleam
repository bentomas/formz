import formz/field
import formz_nakai/widgets
import gleam/list

pub fn text_field() {
  field.text_field(widgets.text_like_widget("text"))
}

pub fn email_field() {
  field.email_field(widgets.text_like_widget("email"))
}

pub fn integer_field() {
  field.integer_field(widgets.text_like_widget("number"))
}

pub fn number_field() {
  field.number_field(widgets.text_like_widget("number"))
}

pub fn boolean_field() {
  field.boolean_field(widgets.checkbox_widget())
}

pub fn enum_field(variants: List(#(String, enum))) {
  field.enum_field(variants, widgets.select_widget(variants))
}

pub fn indexed_enum_field(variants: List(#(String, enum))) {
  let keys_indexed = list.index_map(variants, fn(t, i) { #(t.0, i) })
  field.indexed_enum_field(variants, widgets.select_widget(keys_indexed))
}

pub fn list_field(variants: List(String)) {
  let tuple_list = list.map(variants, fn(s) { #(s, s) })
  indexed_enum_field(tuple_list)
}

pub fn hidden_field() {
  field.text_field(widgets.hidden_widget()) |> field.set_hidden(True)
}
