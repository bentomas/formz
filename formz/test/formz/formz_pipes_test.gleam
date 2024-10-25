import formz/field.{field}
import formz/formz_pipes as formz
import formz/input
import formz/string_generator/fields
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn empty_form_test() {
  formz.new()
  |> formz.get_inputs
  |> list.length
  |> should.equal(0)
}

pub fn parse_empty_form_test() {
  formz.new()
  |> formz.data([])
  |> formz.decodes(1)
  |> formz.parse
  |> should.equal(Ok(1))

  formz.new()
  |> formz.data([])
  |> formz.decodes("Hello")
  |> formz.parse
  |> should.equal(Ok("Hello"))
}

pub fn parse_single_field_form_test() {
  formz.new()
  |> formz.add(field("first", fields.text_field()))
  |> formz.data([#("first", "world")])
  |> formz.decodes(fn(str) { "hello " <> str })
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_test() {
  formz.new()
  |> formz.add(field("first", fields.text_field()))
  |> formz.add(field("second", fields.text_field()))
  |> formz.data([#("first", "hello"), #("second", "world")])
  |> formz.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_extra_data_test() {
  formz.new()
  |> formz.add(field("first", fields.text_field()))
  |> formz.add(field("second", fields.text_field()))
  |> formz.data([#("first", "1"), #("second", "2")])
  |> formz.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> formz.parse
  |> should.equal(Ok("1 2"))

  formz.new()
  |> formz.add(field("first", fields.text_field()))
  |> formz.add(field("second", fields.text_field()))
  |> formz.data([#("first", "1"), #("second", "2"), #("second", "3")])
  |> formz.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> formz.parse
  |> should.equal(Ok("1 2"))
}

pub fn integer_field_test() {
  formz.new()
  |> formz.add(field("first", fields.integer_field()))
  |> formz.data([#("first", " 1 ")])
  |> formz.decodes(fn(i) { i })
  |> formz.parse
  |> should.equal(Ok(1))
}

pub fn can_decodes_in_any_order_test() {
  formz.new()
  |> formz.decodes(fn(str) { "hello " <> str })
  |> formz.add(field("first", fields.text_field()))
  |> formz.data([#("first", "world")])
  |> formz.parse
  |> should.equal(Ok("hello world"))

  formz.new()
  |> formz.add(field("first", fields.text_field()))
  |> formz.data([#("first", "world")])
  |> formz.decodes(fn(str) { "hello " <> str })
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    formz.new()
    |> formz.add(field("first", fields.integer_field()))
    |> formz.data([#("first", "world")])
    |> formz.decodes(fn(_) { 1 })
    |> formz.parse

  let assert [field] = formz.get_inputs(f)
  field |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_double_field_form_with_error_test() {
  let form =
    formz.new()
    |> formz.add(field("a", fields.integer_field()))
    |> formz.add(field("b", fields.integer_field()))
    |> formz.decodes(fn(_) { fn(_) { 1 } })

  let assert Error(f) =
    form
    |> formz.data([#("a", "not a number"), #("b", "2")])
    |> formz.parse

  let assert [fielda, fieldb] = formz.get_inputs(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_no_error

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "string")])
    |> formz.parse

  let assert [fielda, fieldb] = formz.get_inputs(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")

  let assert Error(f) =
    form
    |> formz.data([#("a", "string"), #("b", "string")])
    |> formz.parse

  let assert [fielda, fieldb] = formz.get_inputs(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_triple_field_form_with_error_test() {
  let form =
    formz.new()
    |> formz.add(field("a", fields.integer_field()))
    |> formz.add(field("b", fields.integer_field()))
    |> formz.add(field("c", fields.integer_field()))
    |> formz.decodes(fn(_) { fn(_) { fn(_) { 1 } } })

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "2"), #("c", "string")])
    |> formz.parse
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("Must be a whole number")

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "string"), #("c", "string")])
    |> formz.parse
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_with_error("Must be a whole number")

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "string"), #("c", "3")])
    |> formz.parse
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "3")])
    |> formz.parse
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> formz.data([#("a", "string"), #("b", "2"), #("c", "3")])
    |> formz.parse
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

fn should_be_field_no_error(field: input.Input(String)) {
  should.equal(
    field,
    input.Valid(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      widget: field.widget,
      hidden: field.hidden,
      disabled: field.disabled,
      required: field.required,
    ),
  )
}

fn should_be_field_with_error(field: input.Input(String), str: String) {
  should.equal(
    field,
    input.Invalid(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      widget: field.widget,
      hidden: field.hidden,
      error: str,
      disabled: field.disabled,
      required: field.required,
    ),
  )
}

pub fn try_test() {
  let f =
    formz.new()
    |> formz.add(field("a", fields.integer_field()))
    |> formz.add(field("b", fields.integer_field()))
    |> formz.add(field("c", fields.integer_field()))
    |> formz.decodes(fn(a) { fn(b) { fn(c) { [a, b, c] } } })
    |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])

  // can succeed
  formz.try(f, fn(_, _) { Ok(3) })
  |> should.equal(Ok(3))

  // can change type
  formz.try(f, fn(_, _) { Ok("it worked") })
  |> should.equal(Ok("it worked"))

  // can error
  formz.try(f, fn(_, form) { Error(form) })
  |> should.equal(Error(f))

  // can change field
  let assert Error(form) =
    formz.try(f, fn(_, form) {
      Error(formz.update_input(form, "a", input.set_error(_, "woops")))
    })
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}
