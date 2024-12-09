import formz
import formz/field.{field}
import formz/subform
import formz_nakai/definition
import formz_nakai/simple
import formz_string/definition as string_definition
import formz_string/simple as string_simple
import gleam/string
import gleeunit
import gleeunit/should
import nakai

pub fn main() {
  gleeunit.main()
}

fn remove_self_closing_slash(str: String) -> String {
  string.replace(str, " />", ">")
}

fn remove_trues(str: String) -> String {
  str
  |> string.replace("checked=\"true\"", "checked")
  |> string.replace("disabled=\"true\"", "disabled")
}

fn remove_empty_attributes(str: String) -> String {
  string.replace(str, "=\"\"", "")
}

fn convert_to_string(input) {
  input
  |> nakai.to_inline_string
  |> remove_self_closing_slash
  |> remove_trues
  |> remove_empty_attributes
}

pub fn three_field_form() {
  use a <- formz.require(field("a"), definition.integer_field())
  use b <- formz.require(field("b"), definition.integer_field())
  use c <- formz.optional(field("c"), definition.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn three_field_string_form() {
  use a <- formz.require(field("a"), string_definition.integer_field())
  use b <- formz.require(field("b"), string_definition.integer_field())
  use c <- formz.optional(field("c"), string_definition.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn one_field_and_subform_form() {
  use a <- formz.require(field("a"), definition.integer_field())
  use b <- formz.subform(subform.subform("b"), three_field_form())

  formz.create_form(#(a, b))
}

pub fn one_field_and_subform_string_form() {
  use a <- formz.require(field("a"), string_definition.integer_field())
  use b <- formz.subform(subform.subform("b"), three_field_string_form())

  formz.create_form(#(a, b))
}

pub fn three_field_form_test() {
  let html = three_field_form() |> simple.generate |> convert_to_string
  let string_html = three_field_string_form() |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn three_field_form_with_data_test() {
  let html =
    three_field_form()
    |> formz.data([#("a", "1"), #("b", "2")])
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "1"), #("b", "2")])
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn three_field_form_with_help_test() {
  let html =
    three_field_form()
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn three_field_form_with_error_test() {
  let html =
    three_field_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn three_field_form_with_error_and_help_test() {
  let html =
    three_field_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> formz.update_field("b", field.set_help_text(_, "this is field b"))
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn three_field_form_with_disabled_test() {
  let html =
    three_field_form()
    |> formz.update_field("b", field.set_disabled(_, True))
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.update_field("b", field.set_disabled(_, True))
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn subform_test() {
  let html =
    one_field_and_subform_form()
    |> simple.generate
    |> convert_to_string
  let string_html =
    one_field_and_subform_string_form()
    |> string_simple.generate
  html |> should.equal(string_html)
}
