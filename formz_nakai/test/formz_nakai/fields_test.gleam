import formz_nakai/definition

import formz.{type Definition}
import formz_string/definition as string_definition
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn compare_parse_fns(this: Definition(a, b, c), that: Definition(d, b, c), str) {
  formz.get_parse(this)(str) |> should.equal(formz.get_parse(that)(str))
  formz.get_optional_parse(this)(formz.get_parse(this), "")
  |> should.equal(formz.get_optional_parse(that)(formz.get_parse(that), ""))
}

pub fn text_field_test() {
  let string_definition = string_definition.text_field()
  let definition = definition.text_field()

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn email_field_test() {
  let string_definition = string_definition.email_field()
  let definition = definition.email_field()

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn number_field_test() {
  let string_definition = string_definition.number_field()
  let definition = definition.number_field()

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn integer_field_test() {
  let string_definition = string_definition.integer_field()
  let definition = definition.integer_field()

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn boolean_field_test() {
  let string_definition = string_definition.boolean_field()
  let definition = definition.boolean_field()

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn choices_field_test() {
  let string_definition =
    string_definition.choices_field([#("a", "A"), #("b", "B")], "")
  let definition = definition.choices_field([#("a", "A"), #("b", "B")], "")

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn indexed_enum_field_test() {
  let string_definition = string_definition.list_field(["A", "B"])
  let definition = definition.list_field(["A", "B"])

  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}
