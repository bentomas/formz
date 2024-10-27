import formz/definition
import gleeunit
import gleeunit/should

import formz_lustre/definitions
import formz_string/definitions as string_kinds

pub fn main() {
  gleeunit.main()
}

fn fields_should_be_equal_except_widget(
  field1: definition.Definition(format1, output),
  field2: definition.Definition(format2, output),
) {
  field1.placeholder |> should.equal(field2.placeholder)
  field1.transform |> should.equal(field2.transform)
}

pub fn text_field_test() {
  let string_field = string_kinds.text_field()
  let field = definitions.text_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn email_field_test() {
  let string_field = string_kinds.email_field()
  let field = definitions.email_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn number_field_test() {
  let string_field = string_kinds.number_field()
  let field = definitions.number_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn integer_field_test() {
  let string_field = string_kinds.integer_field()
  let field = definitions.integer_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn boolean_field_test() {
  let string_field = string_kinds.boolean_field()
  let field = definitions.boolean_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn enum_field_test() {
  let string_field = string_kinds.enum_field([#("a", "A"), #("b", "B")])
  let field = definitions.enum_field([#("a", "A"), #("b", "B")])

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn indexed_enum_field_test() {
  let string_field = string_kinds.indexed_enum_field([#("a", "A"), #("b", "B")])
  let field = definitions.indexed_enum_field([#("a", "A"), #("b", "B")])

  fields_should_be_equal_except_widget(field, string_field)
}
