import formz/definition
import formz/field.{field}
import formz/formz_builder.{Element, Set} as formz
import formz/subform.{subform}
import formz/validation
import gleam/list
import gleam/option
import gleam/result
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn text_field() {
  definition.Definition(
    widget: fn(_, _) { Nil },
    parse: validation.non_empty_string,
    stub: "",
    optional_parse: fn(fun, str) {
      case str {
        "" -> Ok("")
        _ -> fun(str)
      }
    },
    optional_stub: "",
  )
}

pub fn float_field() {
  definition.Definition(
    widget: fn(_, _) { Nil },
    parse: validation.number,
    stub: 0.0,
    optional_parse: fn(fun, str) {
      case str {
        "" -> Ok(option.None)
        _ -> fun(str) |> result.map(option.Some)
      }
    },
    optional_stub: option.Some(0.0),
  )
}

fn integer_field() {
  definition.Definition(
    widget: fn(_, _) { Nil },
    parse: validation.int,
    stub: 0,
    optional_parse: fn(fun, str) {
      case str {
        "" -> Ok(option.None)
        _ -> fun(str) |> result.map(option.Some)
      }
    },
    optional_stub: option.Some(0),
  )
}

fn boolean_field() {
  definition.Definition(
    widget: fn(_, _) { Nil },
    parse: validation.on,
    stub: False,
    optional_parse: fn(fun, str) {
      case str {
        "" -> Ok(False)
        _ -> fun(str)
      }
    },
    optional_stub: False,
  )
}

fn get_form_from_error_result(
  result: Result(output, formz.Form(format, output, decoder, has_decoder)),
) -> formz.Form(format, output, decoder, has_decoder) {
  let assert Error(form) = result
  form
}

pub fn empty_form_test() {
  formz.new()
  |> formz.items
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
  |> formz.optional(field("first"), text_field())
  |> formz.data([#("first", "world")])
  |> formz.decodes(fn(str) { "hello " <> str })
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_test() {
  formz.new()
  |> formz.optional(field("first"), text_field())
  |> formz.optional(field("second"), text_field())
  |> formz.data([#("first", "hello"), #("second", "world")])
  |> formz.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_extra_data_test() {
  formz.new()
  |> formz.optional(field("first"), text_field())
  |> formz.optional(field("second"), text_field())
  |> formz.data([#("first", "1"), #("second", "2")])
  |> formz.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> formz.parse
  |> should.equal(Ok("1 2"))

  formz.new()
  |> formz.optional(field("first"), text_field())
  |> formz.optional(field("second"), text_field())
  |> formz.data([#("first", "1"), #("second", "2"), #("second", "3")])
  |> formz.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> formz.parse
  |> should.equal(Ok("1 3"))
}

pub fn integer_field_test() {
  formz.new()
  |> formz.optional(field("first"), integer_field())
  |> formz.data([#("first", " 1 ")])
  |> formz.decodes(fn(i) { i })
  |> formz.parse
  |> should.equal(Ok(option.Some(1)))

  formz.new()
  |> formz.require(field("first"), integer_field())
  |> formz.data([#("first", " 1 ")])
  |> formz.decodes(fn(i) { i })
  |> formz.parse
  |> should.equal(Ok(1))
}

pub fn boolean_field_test() {
  formz.new()
  |> formz.optional(field("first"), boolean_field())
  |> formz.data([#("first", "")])
  |> formz.decodes(fn(i) { i })
  |> formz.parse
  |> should.equal(Ok(False))

  formz.new()
  |> formz.require(field("first"), boolean_field())
  |> formz.data([#("first", "on")])
  |> formz.decodes(fn(i) { i })
  |> formz.parse
  |> should.equal(Ok(True))

  let assert Error(f) =
    formz.new()
    |> formz.require(field("first"), boolean_field())
    |> formz.data([#("first", "")])
    |> formz.decodes(fn(i) { i })
    |> formz.parse

  let assert [Element(fielda, _)] = formz.items(f)
  fielda |> should_be_field_with_error("must be on")
}

pub fn can_decodes_in_any_order_test() {
  formz.new()
  |> formz.decodes(fn(str) { "hello " <> str })
  |> formz.optional(field("first"), text_field())
  |> formz.data([#("first", "world")])
  |> formz.parse
  |> should.equal(Ok("hello world"))

  formz.new()
  |> formz.optional(field("first"), text_field())
  |> formz.data([#("first", "world")])
  |> formz.decodes(fn(str) { "one " <> str })
  |> formz.decodes(fn(str) { "hello " <> str })
  |> formz.parse
  |> should.equal(Ok("hello world"))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    formz.new()
    |> formz.optional(field("first"), integer_field())
    |> formz.data([#("first", "world")])
    |> formz.decodes(fn(_) { 1 })
    |> formz.parse

  let assert [Element(field, _)] = formz.items(f)
  field |> should_be_field_with_error("must be a whole number")
}

pub fn parse_double_field_form_with_error_test() {
  let form =
    formz.new()
    |> formz.optional(field("a"), integer_field())
    |> formz.optional(field("b"), integer_field())
    |> formz.decodes(fn(_) { fn(_) { 1 } })

  let assert Error(f) =
    form
    |> formz.data([#("a", "not a number"), #("b", "2")])
    |> formz.parse

  let assert [Element(fielda, _), Element(fieldb, _)] = formz.items(f)
  fielda |> should_be_field_with_error("must be a whole number")
  fieldb |> should_be_field_no_error

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "string")])
    |> formz.parse

  let assert [Element(fielda, _), Element(fieldb, _)] = formz.items(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("must be a whole number")

  let assert Error(f) =
    form
    |> formz.data([#("a", "string"), #("b", "string")])
    |> formz.parse

  let assert [Element(fielda, _), Element(fieldb, _)] = formz.items(f)
  fielda |> should_be_field_with_error("must be a whole number")
  fieldb |> should_be_field_with_error("must be a whole number")
}

pub fn parse_triple_field_form_with_error_test() {
  let form =
    formz.new()
    |> formz.optional(field("a"), integer_field())
    |> formz.optional(field("b"), integer_field())
    |> formz.optional(field("c"), integer_field())
    |> formz.decodes(fn(_) { fn(_) { fn(_) { 1 } } })

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "2"), #("c", "string")])
    |> formz.parse
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("must be a whole number")

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "string"), #("c", "string")])
    |> formz.parse
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("must be a whole number")
  fieldc |> should_be_field_with_error("must be a whole number")

  let assert Error(f) =
    form
    |> formz.data([#("a", "1"), #("b", "string"), #("c", "3")])
    |> formz.parse
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("must be a whole number")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "3")])
    |> formz.parse
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(f)
  fielda |> should_be_field_with_error("must be a whole number")
  fieldb |> should_be_field_with_error("must be a whole number")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> formz.data([#("a", "string"), #("b", "2"), #("c", "3")])
    |> formz.parse
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(f)
  fielda |> should_be_field_with_error("must be a whole number")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
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

pub fn try_test() {
  let f =
    formz.new()
    |> formz.optional(field("a"), integer_field())
    |> formz.optional(field("b"), integer_field())
    |> formz.optional(field("c"), integer_field())
    |> formz.decodes(fn(a) { fn(b) { fn(c) { [a, b, c] } } })
    |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])

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
      Error(formz.update_field(form, "a", field.set_error(_, "woops")))
    })
  let assert [Element(fielda, _), Element(fieldb, _), Element(fieldc, _)] =
    formz.items(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

pub fn sub_form_test() {
  let f1 =
    formz.new()
    |> formz.require(field("a"), integer_field())
    |> formz.require(field("b"), integer_field())
    |> formz.require(field("c"), integer_field())
    |> formz.decodes(fn(a) { fn(b) { fn(c) { #(a, b, c) } } })

  let f2 =
    formz.new()
    |> formz.add_form(subform("name"), f1)
    |> formz.require(field("d"), integer_field())
    |> formz.decodes(fn(a) { fn(b) { #(a, b) } })

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

pub fn sub_form_error_tst() {
  let f1 =
    formz.new()
    |> formz.require(field("a"), integer_field())
    |> formz.require(field("b"), integer_field())
    |> formz.require(field("c"), integer_field())
    |> formz.decodes(fn(a) { fn(b) { fn(c) { #(a, b, c) } } })

  let f2 =
    formz.new()
    |> formz.add_form(subform("name"), f1)
    |> formz.optional(field("d"), integer_field())
    |> formz.decodes(fn(a) { fn(b) { #(a, b) } })

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

  fielda |> should_be_field_with_error("must be a whole number")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
  fieldd |> should_be_field_no_error
}
