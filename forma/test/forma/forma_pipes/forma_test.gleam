import forma/field
import forma/forma_pipes/forma
import forma/generator/string_input
import forma/input.{input}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn empty_form_test() {
  forma.new()
  |> forma.get_fields
  |> list.length
  |> should.equal(0)
}

pub fn parse_empty_form_test() {
  forma.new()
  |> forma.data([])
  |> forma.decodes(1)
  |> forma.parse
  |> should.equal(Ok(1))

  forma.new()
  |> forma.data([])
  |> forma.decodes("Hello")
  |> forma.parse
  |> should.equal(Ok("Hello"))
}

pub fn parse_single_field_form_test() {
  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.data([#("first", "world")])
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.parse
  |> should.equal(Ok("hello world"))

  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.data([])
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.parse
  |> should.equal(Ok("hello "))
}

pub fn parse_double_field_form_test() {
  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.add(input("second", string_input.text_input()))
  |> forma.data([#("first", "hello"), #("second", "world")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.parse
  |> should.equal(Ok("hello world"))

  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.add(input("second", string_input.text_input()))
  |> forma.data([#("first", "hello")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.parse
  |> should.equal(Ok("hello "))
}

pub fn parse_double_field_form_extra_data_test() {
  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.add(input("second", string_input.text_input()))
  |> forma.data([#("first", "1"), #("second", "2")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.parse
  |> should.equal(Ok("1 2"))

  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.add(input("second", string_input.text_input()))
  |> forma.data([#("first", "1"), #("second", "2"), #("second", "3")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.parse
  |> should.equal(Ok("1 2"))
}

pub fn parse_double_field_form_missing_data_test() {
  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.add(input("second", string_input.text_input()))
  |> forma.data([#("second", "1")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.parse
  |> should.equal(Ok(" 1"))

  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.add(input("second", string_input.text_input()))
  |> forma.data([#("first", "1"), #("first", "2")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.parse
  |> should.equal(Ok("1 "))
}

pub fn integer_field_test() {
  forma.new()
  |> forma.add(input("first", string_input.integer_input()))
  |> forma.data([#("first", " 1 ")])
  |> forma.decodes(fn(i) { i })
  |> forma.parse
  |> should.equal(Ok(1))
}

pub fn can_decodes_in_any_order_test() {
  forma.new()
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.add(input("first", string_input.text_input()))
  |> forma.data([#("first", "world")])
  |> forma.parse
  |> should.equal(Ok("hello world"))

  forma.new()
  |> forma.add(input("first", string_input.text_input()))
  |> forma.data([#("first", "world")])
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    forma.new()
    |> forma.add(input("first", string_input.integer_input()))
    |> forma.data([#("first", "world")])
    |> forma.decodes(fn(_) { 1 })
    |> forma.parse

  let assert [field] = forma.get_fields(f)
  field |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_double_field_form_with_error_test() {
  let form =
    forma.new()
    |> forma.add(input("a", string_input.integer_input()))
    |> forma.add(input("b", string_input.integer_input()))
    |> forma.decodes(fn(_) { fn(_) { 1 } })

  let assert Error(f) =
    form
    |> forma.data([#("a", "not a number"), #("b", "2")])
    |> forma.parse

  let assert [fielda, fieldb] = forma.get_fields(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_no_error

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "string")])
    |> forma.parse

  let assert [fielda, fieldb] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")

  let assert Error(f) =
    form
    |> forma.data([#("a", "string"), #("b", "string")])
    |> forma.parse

  let assert [fielda, fieldb] = forma.get_fields(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_triple_field_form_with_error_test() {
  let form =
    forma.new()
    |> forma.add(input("a", string_input.integer_input()))
    |> forma.add(input("b", string_input.integer_input()))
    |> forma.add(input("c", string_input.integer_input()))
    |> forma.decodes(fn(_) { fn(_) { fn(_) { 1 } } })

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "2"), #("c", "string")])
    |> forma.parse
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("Must be a whole number")

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "string"), #("c", "string")])
    |> forma.parse
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_with_error("Must be a whole number")

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "string"), #("c", "3")])
    |> forma.parse
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> forma.data([#("a", "string"), #("b", "string"), #("c", "3")])
    |> forma.parse
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> forma.data([#("a", "string"), #("b", "2"), #("c", "3")])
    |> forma.parse
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

fn should_be_field_no_error(field: field.Field(String)) {
  should.equal(
    field,
    field.Field(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      render: field.render,
    ),
  )
}

fn should_be_field_with_error(field: field.Field(String), str: String) {
  should.equal(
    field,
    field.InvalidField(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      render: field.render,
      error: str,
    ),
  )
}

pub fn parse_and_try_test() {
  let f =
    forma.new()
    |> forma.add(input("a", string_input.integer_input()))
    |> forma.add(input("b", string_input.integer_input()))
    |> forma.add(input("c", string_input.integer_input()))
    |> forma.decodes(fn(_) { fn(_) { fn(_) { 1 } } })
    |> forma.data([#("a", "1"), #("b", "2"), #("c", "3")])

  // can succeed
  forma.parse_and_try(f, fn(_, _) { Ok(3) })
  |> should.equal(Ok(3))

  // can change type
  forma.parse_and_try(f, fn(_, _) { Ok("it worked") })
  |> should.equal(Ok("it worked"))

  // can error
  forma.parse_and_try(f, fn(_, form) { Error(form) })
  |> should.equal(Error(f))

  // can change field
  let assert Error(form) =
    forma.parse_and_try(f, fn(_, form) {
      Error(forma.set_field_error(form, "a", "woops"))
    })
  let assert [fielda, fieldb, fieldc] = forma.get_fields(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}
