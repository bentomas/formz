import formz
import formz_lustre/definition
import formz_lustre/simple
import formz_string/definition as string_definition
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
  use a <- formz.required_field(formz.named("a"), definition.integer_field())
  use b <- formz.required_field(formz.named("b"), definition.integer_field())
  use c <- formz.field(formz.named("c"), definition.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn three_field_string_form() {
  use a <- formz.required_field(
    formz.named("a"),
    string_definition.integer_field(),
  )
  use b <- formz.required_field(
    formz.named("b"),
    string_definition.integer_field(),
  )
  use c <- formz.field(formz.named("c"), string_definition.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn one_field_and_subform_form() {
  use a <- formz.required_field(formz.named("a"), definition.integer_field())
  use b <- formz.subform(formz.named("b"), three_field_form())

  formz.create_form(#(a, b))
}

pub fn one_field_and_subform_string_form() {
  use a <- formz.required_field(
    formz.named("a"),
    string_definition.integer_field(),
  )
  use b <- formz.subform(formz.named("b"), three_field_string_form())

  formz.create_form(#(a, b))
}

pub fn hidden_field_form() {
  use a <- formz.required_field(
    formz.named("a"),
    definition.integer_field() |> definition.make_hidden,
  )

  formz.create_form(#(a))
}

pub fn hidden_field_string_form() {
  use a <- formz.required_field(
    formz.named("a"),
    string_definition.integer_field() |> string_definition.make_hidden,
  )

  formz.create_form(#(a))
}

pub fn list_field_form() {
  use a <- formz.limited_list(
    formz.limit_between(2, 3),
    formz.named("a"),
    definition.integer_field(),
  )
  formz.create_form(a)
}

pub fn list_field_string_form() {
  use a <- formz.limited_list(
    formz.limit_between(2, 3),
    formz.named("a"),
    string_definition.integer_field(),
  )
  formz.create_form(a)
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
    |> formz.update_config("b", formz.set_help_text(_, "this is field b"))
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.update_config("b", formz.set_help_text(_, "this is field b"))
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
    |> formz.update_config("b", formz.set_help_text(_, "this is field b"))
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
    |> formz.validate(["b"])
    |> formz.update_config("b", formz.set_help_text(_, "this is field b"))
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn three_field_form_with_disabled_test() {
  let html =
    three_field_form()
    |> formz.update_config("b", formz.set_disabled(_, True))
    |> simple.generate
    |> convert_to_string
  let string_html =
    three_field_string_form()
    |> formz.update_config("b", formz.set_disabled(_, True))
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

pub fn subform_with_help_text_test() {
  let html =
    one_field_and_subform_form()
    |> formz.update_config("b", formz.set_help_text(_, "this is subform b"))
    |> simple.generate
    |> convert_to_string
  let string_html =
    one_field_and_subform_string_form()
    |> formz.update_config("b", formz.set_help_text(_, "this is subform b"))
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn subform_with_help_text_and_error_test() {
  let html =
    one_field_and_subform_form()
    |> formz.update_config("b", formz.set_help_text(_, "this is subform b"))
    |> formz.field_error("b.a", "woops")
    |> simple.generate
    |> convert_to_string
  let string_html =
    one_field_and_subform_string_form()
    |> formz.update_config("b", formz.set_help_text(_, "this is subform b"))
    |> formz.field_error("b.a", "woops")
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn hidden_field_form_test() {
  let html =
    hidden_field_form()
    |> simple.generate
    |> convert_to_string
  let string_html =
    hidden_field_string_form()
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn list_field_test() {
  let html =
    list_field_form()
    |> simple.generate
    |> convert_to_string
  let string_html =
    list_field_string_form()
    |> string_simple.generate
  html |> should.equal(string_html)
}

pub fn list_field_with_error_test() {
  let html =
    list_field_form()
    |> formz.validate_all
    |> formz.listfield_errors("a", [Ok(Nil), Error("woops")])
    |> simple.generate
    |> convert_to_string
  let string_html =
    list_field_string_form()
    |> formz.validate_all
    |> formz.listfield_errors("a", [Ok(Nil), Error("woops")])
    |> string_simple.generate
  html |> should.equal(string_html)
}
