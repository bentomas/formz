import formz/field.{field}
import formz/formz_use as formz
import formz/input
import formz/string_fields
import formz/validation
import gleam/option
import gleeunit
import gleeunit/should

fn should_be_field_no_error(field: input.Input(String)) {
  should.equal(
    field,
    input.Input(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      render: field.render,
    ),
  )
}

fn should_be_field_with_error(field: input.Input(String), str: String) {
  should.equal(
    field,
    input.InvalidInput(
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
  result: Result(output, formz.Form(format, output)),
) -> formz.Form(format, output) {
  let assert Error(form) = result
  form
}

pub fn main() {
  gleeunit.main()
}

fn empty_form(val) {
  formz.create_form(val)
}

fn one_field_form() {
  use a <- formz.with(field("a", string_fields.text_field()))
  formz.create_form("hello " <> a)
}

fn two_field_form() {
  {
    use a <- formz.with(field("a", string_fields.text_field()))
    use b <- formz.with(field("b", string_fields.text_field()))

    formz.create_form(#(a, b))
  }
}

fn three_field_form() {
  use a <- formz.with(
    field("x", string_fields.text_field())
    |> field.name("a")
    |> field.label("A")
    |> field.validate(validation.must_be_longer_than(3)),
  )
  use b <- formz.with(field("b", string_fields.integer_field()))
  use c <- formz.with(field.full(
    "c",
    "C",
    "help!",
    string_fields.number_field(),
  ))

  formz.create_form(#(a, b, c))
}

pub fn empty_form_test() {
  empty_form(1)
  |> formz.get_inputs
  |> should.equal([])
}

pub fn parse_empty_form_test() {
  empty_form(1)
  |> formz.data([])
  |> formz.parse
  |> should.equal(Ok(1))

  empty_form("hello")
  |> formz.data([])
  |> formz.parse
  |> should.equal(Ok("hello"))
}

pub fn parse_single_field_form_test() {
  one_field_form()
  |> formz.data([#("a", "world")])
  |> formz.parse
  |> should.equal(Ok("hello world"))

  one_field_form()
  |> formz.data([#("a", "ignored"), #("a", "world")])
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_test() {
  two_field_form()
  |> formz.data([#("a", "hello"), #("b", "world")])
  |> formz.parse
  |> should.equal(Ok(#("hello", "world")))

  // wrong order
  two_field_form()
  |> formz.data([#("b", "world"), #("a", "hello")])
  |> formz.parse
  |> should.equal(Ok(#("hello", "world")))

  // takes second
  two_field_form()
  |> formz.data([
    #("a", "ignored"),
    #("b", "ignored"),
    #("b", "world"),
    #("a", "hello"),
  ])
  |> formz.parse
  |> should.equal(Ok(#("hello", "world")))
}

pub fn parse_double_optional_field_form_test() {
  let f = {
    use a <- formz.with(
      field("a", string_fields.text_field()) |> field.optional,
    )
    use b <- formz.with(
      field("b", string_fields.text_field()) |> field.optional,
    )

    formz.create_form(#(a, b))
  }

  f
  |> formz.data([#("a", "hello"), #("b", "world")])
  |> formz.parse
  |> should.equal(Ok(#(option.Some("hello"), option.Some("world"))))

  // missing second
  f
  |> formz.data([#("a", "hello")])
  |> formz.parse
  |> should.equal(Ok(#(option.Some("hello"), option.None)))

  // missing first
  f
  |> formz.data([#("b", "world")])
  |> formz.parse
  |> should.equal(Ok(#(option.None, option.Some("world"))))

  // missing both
  f
  |> formz.data([])
  |> formz.parse
  |> should.equal(Ok(#(option.None, option.None)))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    {
      use a <- formz.with(field("a", string_fields.integer_field()))
      formz.create_form(a)
    }
    |> formz.data([#("first", "world")])
    |> formz.parse

  let assert [field] = formz.get_inputs(f)
  field |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_triple_field_form_with_error_test() {
  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "1"), #("c", "string")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_inputs

  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("Must be a number")

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "string")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_inputs
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_with_error("Must be a number")

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_inputs
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> formz.data([#("a", "."), #("b", "string"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_inputs
  fielda |> should_be_field_with_error("Must be longer than 3 characters")
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert [fielda, fieldb, fieldc] =
    three_field_form()
    |> formz.data([#("a", "."), #("b", "1"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_inputs
  fielda |> should_be_field_with_error("Must be longer than 3 characters")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

pub fn decoded_and_try_test() {
  let f =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "2"), #("c", "3.0")])

  // can succeed
  formz.parse_and_try(f, fn(_, _) { Ok(3) })
  |> should.equal(Ok(3))

  // can change type
  formz.parse_and_try(f, fn(_, _) { Ok("it worked") })
  |> should.equal(Ok("it worked"))

  // can error
  formz.parse_and_try(f, fn(_, form) { Error(form) })
  |> should.equal(Error(f))

  // can change field
  let assert Error(form) =
    formz.parse_and_try(f, fn(_, form) {
      form
      |> formz.update_input("a", input.set_error(_, "woops"))
      |> Error
    })
  let assert [fielda, fieldb, fieldc] = formz.get_inputs(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}
