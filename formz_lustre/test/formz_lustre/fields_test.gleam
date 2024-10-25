import formz/field
import gleeunit
import gleeunit/should

import formz_lustre/fields
import formz_string/fields as string_fields

pub fn main() {
  gleeunit.main()
}

fn fields_should_be_equal_except_widget(
  field1: field.Definition(format1, output),
  field2: field.Definition(format2, output),
) {
  field1.placeholder |> should.equal(field2.placeholder)
  field1.transform |> should.equal(field2.transform)
}

pub fn text_field_test() {
  let string_field = string_fields.text_field()
  let field = fields.text_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn email_field_test() {
  let string_field = string_fields.email_field()
  let field = fields.email_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn number_field_test() {
  let string_field = string_fields.number_field()
  let field = fields.number_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn integer_field_test() {
  let string_field = string_fields.integer_field()
  let field = fields.integer_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn boolean_field_test() {
  let string_field = string_fields.boolean_field()
  let field = fields.boolean_field()

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn enum_field_test() {
  let string_field = string_fields.enum_field([#("a", "A"), #("b", "B")])
  let field = fields.enum_field([#("a", "A"), #("b", "B")])

  fields_should_be_equal_except_widget(field, string_field)
}

pub fn indexed_enum_field_test() {
  let string_field =
    string_fields.indexed_enum_field([#("a", "A"), #("b", "B")])
  let field = fields.indexed_enum_field([#("a", "A"), #("b", "B")])

  fields_should_be_equal_except_widget(field, string_field)
}
