import formz/definition.{Definition}
import formz/validation
import formz_nakai/widgets
import gleam/list

pub fn text_field() {
  Definition(widgets.text_like_widget("text"), validation.string, "")
}

pub fn email_field() {
  Definition(widgets.text_like_widget("email"), validation.email, "")
}

pub fn integer_field() {
  Definition(widgets.text_like_widget("number"), validation.int, 0)
}

pub fn number_field() {
  Definition(widgets.text_like_widget("number"), validation.number, 0.0)
}

pub fn boolean_field() {
  Definition(widgets.checkbox_widget(), validation.boolean, False)
}

pub fn password_field() {
  Definition(widgets.password_widget(), validation.string, "")
}

pub fn enum_field(variants: List(#(String, enum))) {
  let assert Ok(#(_, first)) = list.first(variants)
  Definition(
    widgets.select_widget(variants),
    validation.enum(variants)
      |> validation.replace_error("Please select an option"),
    first,
  )
}

pub fn indexed_enum_field(variants: List(#(String, enum))) {
  let keys_indexed = list.index_map(variants, fn(t, i) { #(t.0, i) })
  let assert Ok(#(_, first)) = list.first(variants)
  Definition(
    widgets.select_widget(keys_indexed),
    validation.enum_by_index(variants)
      |> validation.replace_error("Please select an option"),
    first,
  )
}

pub fn list_field(variants: List(String)) {
  let tuple_list = list.map(variants, fn(s) { #(s, s) })
  indexed_enum_field(tuple_list)
}
