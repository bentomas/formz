import birdie
import formz
import formz_string/definition
import formz_string/generator
import formz_string/widget
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn three_field_form() {
  use a <- formz.required_field(formz.named("a"), definition.integer_field())
  use b <- formz.required_field(formz.named("b"), definition.integer_field())
  use c <- formz.field(formz.named("c"), definition.integer_field())

  formz.create_form(#(a, b, c))
}

pub fn one_field_and_subform_form() {
  use a <- formz.required_field(formz.named("a"), definition.integer_field())
  use b <- formz.subform(formz.named("b"), three_field_form())

  formz.create_form(#(a, b))
}

pub fn hidden_field_form() {
  use a <- formz.required_field(
    formz.named("a"),
    definition.integer_field() |> definition.make_hidden,
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

pub fn three_field_form_test() {
  three_field_form()
  |> generator.build
  |> birdie.snap(title: "three field form")
}

pub fn three_field_form_with_data_test() {
  three_field_form()
  |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])
  |> generator.build
  |> birdie.snap(title: "three field form with data")
}

pub fn three_field_form_with_help_test() {
  three_field_form()
  |> formz.update_config("b", formz.set_help_text(_, "this is field b"))
  |> generator.build
  |> birdie.snap(title: "three field form with help text")
}

pub fn three_field_form_with_error_test() {
  three_field_form()
  |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
  |> formz.validate(["b"])
  |> generator.build
  |> birdie.snap(title: "three field form with error")
}

pub fn three_field_form_with_error_and_help_test() {
  three_field_form()
  |> formz.data([#("a", "x"), #("b", "x"), #("c", "x")])
  |> formz.validate(["b"])
  |> formz.update_config("b", formz.set_help_text(_, "this is field b"))
  |> generator.build
  |> birdie.snap(title: "three field form with error and help text")
}

pub fn three_field_form_with_disabled_test() {
  three_field_form()
  |> formz.update_config("b", formz.set_disabled(_, True))
  |> generator.build
  |> birdie.snap(title: "three field form with disabled field")
}

pub fn subform_test() {
  one_field_and_subform_form()
  |> generator.build
  |> birdie.snap(title: "subform")
}

pub fn subform_with_help_text_test() {
  one_field_and_subform_form()
  |> formz.update_config("b", formz.set_help_text(_, "this is subform b"))
  |> generator.build
  |> birdie.snap(title: "subform with help text")
}

pub fn subform_with_help_text_and_error_test() {
  one_field_and_subform_form()
  |> formz.update_config("b", formz.set_help_text(_, "this is subform b"))
  |> formz.field_error("b-a", "woops")
  |> generator.build
  |> birdie.snap(title: "subform with help text and error")
}

pub fn hidden_field_form_test() {
  hidden_field_form()
  |> formz.data([#("a", "1")])
  |> generator.build
  |> birdie.snap(title: "hidden field form")
}

pub fn hidden_field_form_no_value_test() {
  hidden_field_form()
  |> generator.build
  |> birdie.snap(title: "hidden field form no value")
}

pub fn list_field_test() {
  list_field_form()
  |> generator.build
  |> birdie.snap(title: "list field form")
}

pub fn list_field_with_error_test() {
  list_field_form()
  |> formz.validate_all
  |> formz.listfield_errors("a", [Ok(Nil), Error("woops")])
  |> generator.build
  |> birdie.snap(title: "list field form with error")
}

pub fn list_field_hidden_test() {
  list_field_form()
  |> formz.update("a", fn(item) {
    case item {
      formz.ListField(..) -> formz.ListField(..item, widget: widget.Hidden)
      _ -> item
    }
  })
  |> formz.data([#("a", "1"), #("a", "2")])
  |> generator.build
  |> birdie.snap(title: "list field form hidden")
}
