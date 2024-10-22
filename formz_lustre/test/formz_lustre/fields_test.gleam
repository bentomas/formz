import formz/field
import gleeunit
import gleeunit/should

import formz/string_generator/fields as string_fields
import formz_lustre/fields as lustre_fields

pub fn main() {
  gleeunit.main()
}

fn fields_should_be_equal_except_widget(
  field1: field.Field(format1, output),
  field2: field.Field(format2, output),
) {
  field1.default |> should.equal(field2.default)

  field1.input.name |> should.equal(field2.input.name)
  field1.input.label |> should.equal(field2.input.label)
  field1.input.help_text |> should.equal(field2.input.help_text)
  field1.input.value |> should.equal(field2.input.value)
  field1.input.hidden |> should.equal(field2.input.hidden)

  field1.transform |> should.equal(field2.transform)
}

pub fn text_field_test() {
  let string_field = string_fields.text_field()
  let lustre_field = lustre_fields.text_field()

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn email_field_test() {
  let string_field = string_fields.email_field()
  let lustre_field = lustre_fields.email_field()

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn number_field_test() {
  let string_field = string_fields.number_field()
  let lustre_field = lustre_fields.number_field()

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn integer_field_test() {
  let string_field = string_fields.integer_field()
  let lustre_field = lustre_fields.integer_field()

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn boolean_field_test() {
  let string_field = string_fields.boolean_field()
  let lustre_field = lustre_fields.boolean_field()

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn hidden_field_test() {
  let string_field = string_fields.hidden_field()
  let lustre_field = lustre_fields.hidden_field()

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn enum_field_test() {
  let string_field = string_fields.enum_field([#("a", "A"), #("b", "B")])
  let lustre_field = lustre_fields.enum_field([#("a", "A"), #("b", "B")])

  fields_should_be_equal_except_widget(lustre_field, string_field)
}

pub fn list_field_test() {
  let string_field = string_fields.list_field([#("a", "A"), #("b", "B")])
  let lustre_field = lustre_fields.list_field([#("a", "A"), #("b", "B")])

  fields_should_be_equal_except_widget(lustre_field, string_field)
}
