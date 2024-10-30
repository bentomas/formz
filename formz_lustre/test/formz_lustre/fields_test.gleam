import formz_lustre/definitions

import formz/definition.{type Definition}
import formz_string/definitions as string_definitions
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn compare_parse_fns(this: Definition(a, b, c), that: Definition(d, b, c), str) {
  this.parse(str) |> should.equal(that.parse(str))
  this.optional_parse(this.parse, "")
  |> should.equal(that.optional_parse(that.parse, ""))
}

pub fn text_field_test() {
  let string_definition = string_definitions.text_field()
  let definition = definitions.text_field()

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn email_field_test() {
  let string_definition = string_definitions.email_field()
  let definition = definitions.email_field()

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn number_field_test() {
  let string_definition = string_definitions.number_field()
  let definition = definitions.number_field()

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn integer_field_test() {
  let string_definition = string_definitions.integer_field()
  let definition = definitions.integer_field()

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn boolean_field_test() {
  let string_definition = string_definitions.boolean_field()
  let definition = definitions.boolean_field()

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn choices_field_test() {
  let string_definition =
    string_definitions.choices_field([#("a", "A"), #("b", "B")], "")
  let definition = definitions.choices_field([#("a", "A"), #("b", "B")], "")

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}

pub fn indexed_enum_field_test() {
  let string_definition = string_definitions.list_field(["A", "B"])
  let definition = definitions.list_field(["A", "B"])

  definition.stub |> should.equal(string_definition.stub)
  definition.optional_stub |> should.equal(string_definition.optional_stub)
  compare_parse_fns(definition, string_definition, "")
  compare_parse_fns(definition, string_definition, "a")
}
