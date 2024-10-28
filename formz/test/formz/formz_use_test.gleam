import formz/definition
import formz/field.{field}
import formz/form_details.{form_details}
import formz/formz_use.{Element, Set} as formz

import formz/validation
import gleeunit
import gleeunit/should

pub fn text_field() {
  definition.Definition(fn(_, _) { "" }, validation.string, "")
}

pub fn integer_field() {
  definition.Definition(fn(_, _) { "" }, validation.int, 0)
}

pub fn float_field() {
  definition.Definition(fn(_, _) { "" }, validation.number, 0.0)
}

fn should_be_field_no_error(field: field.Field) {
  should.equal(
    field,
    field.Valid(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      hidden: field.hidden,
      disabled: field.disabled,
      required: field.required,
    ),
  )
}

fn should_be_field_with_error(field: field.Field, str: String) {
  should.equal(
    field,
    field.Invalid(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      hidden: field.hidden,
      error: str,
      disabled: field.disabled,
      required: field.required,
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
  use a <- formz.with(field("a"), text_field())
  formz.create_form("hello " <> a)
}

fn two_field_form() {
  {
    use a <- formz.with(field("a"), text_field())
    use b <- formz.with(field("b"), text_field())

    formz.create_form(#(a, b))
  }
}

fn three_field_form() {
  use a <- formz.with(
    field("x")
      |> field.set_name("a")
      |> field.set_label("A"),
    text_field()
      |> definition.validates(validation.must_be_longer_than(3)),
  )

  use b <- formz.with(field(named: "b"), integer_field())
  use c <- formz.with(
    field(named: "c")
      |> field.set_name("c")
      |> field.set_label("C"),
    float_field(),
  )

  formz.create_form(#(a, b, c))
}

pub fn empty_form_test() {
  empty_form(1)
  |> formz.items
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

// pub fn parse_double_optional_field_form_test() {
//   let f = {
//     use a <- formz.with(field("a") |> field.set_optional, text_field())
//     use b <- formz.with(field("b") |> field.set_optional, text_field())

//     formz.create_form(#(a, b))
//   }

//   f
//   |> formz.data([#("a", "hello"), #("b", "world")])
//   |> formz.parse
//   |> should.equal(Ok(#(option.Some("hello"), option.Some("world"))))

//   // missing second
//   f
//   |> formz.data([#("a", "hello")])
//   |> formz.parse
//   |> should.equal(Ok(#(option.Some("hello"), option.None)))

//   // missing first
//   f
//   |> formz.data([#("b", "world")])
//   |> formz.parse
//   |> should.equal(Ok(#(option.None, option.Some("world"))))

//   // missing both
//   f
//   |> formz.data([])
//   |> formz.parse
//   |> should.equal(Ok(#(option.None, option.None)))
// }

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    {
      use a <- formz.with(field("a"), integer_field())
      formz.create_form(a)
    }
    |> formz.data([#("first", "world")])
    |> formz.parse

  let assert [Element(field, _)] = formz.items(f)
  field |> should_be_field_with_error("Must be a whole number")
}

pub fn parse_triple_field_form_with_error_test() {
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    three_field_form()
    |> formz.data([#("a", "xxxx"), #("b", "1"), #("c", "x")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.items

  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("Must be a number")

  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "string")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.items
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_with_error("Must be a number")

  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.items
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    three_field_form()
    |> formz.data([#("a", "."), #("b", "string"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.items
  fielda |> should_be_field_with_error("Must be longer than 3")
  fieldb |> should_be_field_with_error("Must be a whole number")
  fieldc |> should_be_field_no_error

  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    three_field_form()
    |> formz.data([#("a", "."), #("b", "1"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.items
  fielda |> should_be_field_with_error("Must be longer than 3")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

pub fn sub_form_test() {
  let f1 = {
    use a <- formz.with(field("a"), integer_field())
    use b <- formz.with(field("b"), integer_field())
    use c <- formz.with(field("c"), integer_field())

    formz.create_form(#(a, b, c))
  }

  let f2 = {
    use a <- formz.with_form(form_details("name"), f1)
    use b <- formz.with(field("d"), integer_field())

    formz.create_form(#(a, b))
  }

  f2
  |> formz.data([
    #("name.a", "1"),
    #("name.b", "2"),
    #("name.c", "3"),
    #("d", "4"),
  ])
  |> formz.parse
  |> should.equal(Ok(#(#(1, 2, 3), 4)))
}

pub fn sub_form_error_test() {
  let f1 = {
    use a <- formz.with(field("a"), integer_field())
    use b <- formz.with(field("b"), integer_field())
    use c <- formz.with(field("c"), integer_field())

    formz.create_form(#(a, b, c))
  }

  let f2 = {
    use a <- formz.with_form(form_details("name"), f1)
    use b <- formz.with(field("d"), integer_field())

    formz.create_form(#(a, b))
  }

  let assert [
    Set(_, [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)]),
    Element(fieldd, _),
  ] =
    f2
    |> formz.data([
      #("name.a", "a"),
      #("name.b", "2"),
      #("name.c", "3"),
      #("d", "4"),
    ])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.items

  fielda |> should_be_field_with_error("Must be a whole number")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
  fieldd |> should_be_field_no_error
}

pub fn decoded_and_try_test() {
  let f =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "2"), #("c", "3.0")])

  // can succeed
  formz.parse_then_try(f, fn(_, _) { Ok(3) })
  |> should.equal(Ok(3))

  // can change type
  formz.parse_then_try(f, fn(_, _) { Ok("it worked") })
  |> should.equal(Ok("it worked"))

  // can error
  formz.parse_then_try(f, fn(form, _) { Error(form) })
  |> should.equal(Error(f))

  // can change field
  let assert Error(form) =
    formz.parse_then_try(f, fn(form, _) {
      form
      |> formz.update_field("a", field.set_error(_, "woops"))
      |> Error
    })
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}
