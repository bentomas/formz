import gleeunit
import gleeunit/should

import formz_lustre/definitions
import formz_string/definitions as string_definitions

pub fn main() {
  gleeunit.main()
}

pub fn text_field_test() {
  let string_field = string_definitions.text_field()
  let field = definitions.text_field()

  field.transform |> should.equal(string_field.transform)
}

pub fn email_field_test() {
  let string_field = string_definitions.email_field()
  let field = definitions.email_field()

  field.transform |> should.equal(string_field.transform)
}

pub fn number_field_test() {
  let string_field = string_definitions.number_field()
  let field = definitions.number_field()

  field.transform |> should.equal(string_field.transform)
}

pub fn integer_field_test() {
  let string_field = string_definitions.integer_field()
  let field = definitions.integer_field()

  field.transform |> should.equal(string_field.transform)
}

pub fn boolean_field_test() {
  let string_field = string_definitions.boolean_field()
  let field = definitions.boolean_field()

  field.transform |> should.equal(string_field.transform)
}

pub fn choices_field_test() {
  let string_field =
    string_definitions.choices_field([#("a", "A"), #("b", "B")], "")
  let field = definitions.choices_field([#("a", "A"), #("b", "B")], "")

  field.transform |> should.equal(string_field.transform)
}

pub fn indexed_enum_field_test() {
  let string_field = string_definitions.list_field(["A", "B"])
  let field = definitions.list_field(["A", "B"])

  field.transform |> should.equal(string_field.transform)
}
