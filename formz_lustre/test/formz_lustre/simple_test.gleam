import formz/field.{field}
import formz/formz_use as formz
import formz/subform
import formz_lustre/definitions
import formz_lustre/simple
import formz_string/definitions as string_definitions
import formz_string/simple as string_simple
import gleeunit
import gleeunit/should
import lustre/element

pub fn main() {
  gleeunit.main()
}

fn convert_to_string(input) {
  input
  |> element.to_string
}

pub fn three_field_form() {
  use a <- formz.require(field("a"), definitions.integer_field())
  use b <- formz.require(field("b"), definitions.integer_field())
  use c <- formz.optional(field("c"), definitions.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn three_field_string_form() {
  use a <- formz.require(field("a"), string_definitions.integer_field())
  use b <- formz.require(field("b"), string_definitions.integer_field())
  use c <- formz.optional(field("c"), string_definitions.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn one_field_and_subform_form() {
  use a <- formz.require(field("a"), definitions.integer_field())
  use b <- formz.with_form(subform.subform("b"), three_field_form())

  formz.create_form(#(a, b))
}

pub fn one_field_and_subform_string_form() {
  use a <- formz.require(field("a"), string_definitions.integer_field())
  use b <- formz.with_form(subform.subform("b"), three_field_string_form())

  formz.create_form(#(a, b))
}

pub fn three_field_form_test() {
  let html = three_field_form() |> simple.generate_form |> convert_to_string
  let string_html = three_field_string_form() |> string_simple.generate_form
  html |> should.equal(string_html)
}

pub fn three_field_form_with_data_test() {
  let html =
    three_field_form()
    |> formz.data([#("a", "1"), #("b", "2")])
    |> simple.generate_form
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "1"), #("b", "2")])
    |> string_simple.generate_form
  html |> should.equal(string_html)
}

pub fn three_field_form_with_help_test() {
  let html =
    three_field_form()
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> simple.generate_form
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> string_simple.generate_form
  html |> should.equal(string_html)
}

pub fn three_field_form_with_error_test() {
  let html =
    three_field_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> simple.generate_form
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> string_simple.generate_form
  html |> should.equal(string_html)
}

pub fn three_field_form_with_error_and_help_test() {
  let html =
    three_field_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> simple.generate_form
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> string_simple.generate_form
  html |> should.equal(string_html)
}

pub fn three_field_form_with_disabled_test() {
  let html =
    three_field_form()
    |> formz.update_field("b", field.set_disabled(_, True))
    |> simple.generate_form
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.update_field("b", field.set_disabled(_, True))
    |> string_simple.generate_form
  html |> should.equal(string_html)
}

pub fn subform_test() {
  let html =
    one_field_and_subform_form()
    |> simple.generate_form
    |> convert_to_string
  let string_html =
    one_field_and_subform_string_form()
    |> string_simple.generate_form
  html |> should.equal(string_html)
}
