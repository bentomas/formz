import forma/field
import forma/forma_use/forma
import forma/generator/string_input
import forma/input.{input}
import forma/validation
import gleeunit
import gleeunit/should

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

fn get_form_from_error_result(
  result: Result(output, forma.Form(format, output)),
) -> forma.Form(format, output) {
  let assert Error(form) = result
  form
}

pub fn main() {
  gleeunit.main()
}

fn empty_form(val) {
  forma.create_form(val)
}

fn one_field_form() {
  use a <- forma.with(input("a", string_input.text_input()))
  forma.create_form("hello " <> a)
}

fn two_field_form() {
  {
    use a <- forma.with(input("a", string_input.text_input()))
    use b <- forma.with(input("b", string_input.text_input()))

    forma.create_form(#(a, b))
  }
}

fn three_field_form() {
  use a <- forma.with(
    input("a", string_input.text_input())
    |> input.validate(validation.must_be_longer_than(3)),
  )
  use b <- forma.with(input("b", string_input.integer_input()))
  use c <- forma.with(input.full("c", "C", "help!", string_input.number_input()))

  forma.create_form(#(a, b, c))
}

pub fn empty_form_test() {
  empty_form(1)
  |> forma.get_fields
  |> should.equal([])
}

pub fn parse_empty_form_test() {
  empty_form(1)
  |> forma.data([])
  |> forma.parse
  |> should.equal(Ok(1))

  empty_form("hello")
  |> forma.data([])
  |> forma.parse
  |> should.equal(Ok("hello"))
}

pub fn parse_single_field_form_test() {
  one_field_form()
  |> forma.data([#("a", "world")])
  |> forma.parse
  |> should.equal(Ok("hello world"))

  one_field_form()
  |> forma.data([])
  |> forma.parse
  |> should.equal(Ok("hello "))

  one_field_form()
  |> forma.data([#("a", "ignored"), #("a", "world")])
  |> forma.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_test() {
  two_field_form()
  |> forma.data([#("a", "hello"), #("b", "world")])
  |> forma.parse
  |> should.equal(Ok(#("hello", "world")))

  // missing second
  two_field_form()
  |> forma.data([#("a", "hello")])
  |> forma.parse
  |> should.equal(Ok(#("hello", "")))

  // missing first
  two_field_form()
  |> forma.data([#("b", "world")])
  |> forma.parse
  |> should.equal(Ok(#("", "world")))

  // missing both
  two_field_form()
  |> forma.data([])
  |> forma.parse
  |> should.equal(Ok(#("", "")))

  // wrong order
  two_field_form()
  |> forma.data([#("b", "world"), #("a", "hello")])
  |> forma.parse
  |> should.equal(Ok(#("hello", "world")))

  // takes second
  two_field_form()
  |> forma.data([
    #("a", "ignored"),
    #("b", "ignored"),
    #("b", "world"),
    #("a", "hello"),
  ])
  |> forma.parse
  |> should.equal(Ok(#("hello", "world")))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    {
      use a <- forma.with(input("a", string_input.integer_input()))
      forma.create_form(a)
    }
    |> forma.data([#("first", "world")])
    |> forma.parse

  let assert [field] = forma.get_fields(f)
  field |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_triple_field_form_with_error_test() {
  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> forma.data([#("a", "string"), #("b", "1"), #("c", "string")])
    |> forma.parse
    |> get_form_from_error_result
    |> forma.get_fields

  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("Must be a number")

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> forma.data([#("a", "string"), #("b", "string"), #("c", "string")])
    |> forma.parse
    |> get_form_from_error_result
    |> forma.get_fields
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_with_error("Must be a number")

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> forma.data([#("a", "string"), #("b", "string"), #("c", "3.4")])
    |> forma.parse
    |> get_form_from_error_result
    |> forma.get_fields
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> forma.data([#("a", ""), #("b", "string"), #("c", "3.4")])
    |> forma.parse
    |> get_form_from_error_result
    |> forma.get_fields
  fielda |> should_be_field_with_error("Must be longer than 3 characters")
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> forma.data([#("a", ""), #("b", "1"), #("c", "3.4")])
    |> forma.parse
    |> get_form_from_error_result
    |> forma.get_fields
  fielda |> should_be_field_with_error("Must be longer than 3 characters")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

pub fn decoded_and_try_test() {
  let f =
    three_field_form()
    |> forma.data([#("a", "string"), #("b", "2"), #("c", "3.0")])

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
      form
      |> forma.field_update("a", fn(field) { field.set_error(field, "woops") })
      |> Error
    })
  let assert [fielda, fieldb, fieldc] = forma.get_fields(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}
