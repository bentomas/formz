import birdie
import formz/field.{field}
import formz/formz_use as formz
import formz/subform
import formz_string/definitions
import formz_string/simple
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn two_field_form() {
  use a <- formz.require(field("a"), definitions.integer_field())
  use b <- formz.require(field("b"), definitions.integer_field())

  formz.create_form(#(a, b))
}

pub fn three_field_form() {
  use a <- formz.require(field("a"), definitions.integer_field())
  use b <- formz.require(field("b"), definitions.integer_field())
  use c <- formz.optional(field("c"), definitions.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn one_field_and_subform_form() {
  use a <- formz.require(field("a"), definitions.integer_field())
  use b <- formz.with_form(subform.subform("b"), two_field_form())

  formz.create_form(#(a, b))
}

pub fn two_field_form_test() {
  two_field_form()
  |> simple.generate_form
  |> birdie.snap(title: "two field form")
}

pub fn two_field_form_with_data_test() {
  two_field_form()
  |> formz.data([#("a", "1"), #("b", "2")])
  |> simple.generate_form
  |> birdie.snap(title: "two field form with data")
}

pub fn three_field_form_with_help_test() {
  three_field_form()
  |> formz.update_field("b", field.set_help_text(_, "this is field b"))
  |> simple.generate_form
  |> birdie.snap(title: "three field form with help text")
}

pub fn three_field_form_with_error_test() {
  three_field_form()
  |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
  |> formz.validate(["b"])
  |> simple.generate_form
  |> birdie.snap(title: "three field form with error")
}

pub fn three_field_form_with_error_and_help_test() {
  three_field_form()
  |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
  |> formz.validate(["b"])
  |> formz.update_field("b", field.set_help_text(_, "this is field b"))
  |> simple.generate_form
  |> birdie.snap(title: "three field form with error and help text")
}

pub fn two_field_form_with_disabled_test() {
  two_field_form()
  |> formz.update_field("b", field.set_disabled(_, True))
  |> simple.generate_form
  |> birdie.snap(title: "two field form with disabled field")
}

pub fn subform_test() {
  one_field_and_subform_form()
  |> simple.generate_form
  |> birdie.snap(title: "subform")
}
