import forma
import forma/field
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
  |> forma.decoded
  |> should.equal(Ok(1))

  forma.new()
  |> forma.data([])
  |> forma.decodes("Hello")
  |> forma.decoded
  |> should.equal(Ok("Hello"))
}

pub fn parse_single_field_form_test() {
  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.data([#("first", "world")])
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.decoded
  |> should.equal(Ok("hello world"))

  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.data([])
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.decoded
  |> should.equal(Ok("hello "))
}

pub fn parse_double_field_form_test() {
  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.add(field.new("second", field.text_field()))
  |> forma.data([#("first", "hello"), #("second", "world")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.decoded
  |> should.equal(Ok("hello world"))

  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.add(field.new("second", field.text_field()))
  |> forma.data([#("first", "hello")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.decoded
  |> should.equal(Ok("hello "))
}

pub fn parse_double_field_form_extra_data_test() {
  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.add(field.new("second", field.text_field()))
  |> forma.data([#("first", "1"), #("second", "2")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.decoded
  |> should.equal(Ok("1 2"))

  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.add(field.new("second", field.text_field()))
  |> forma.data([#("first", "1"), #("second", "2"), #("second", "3")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.decoded
  |> should.equal(Ok("1 2"))
}

pub fn parse_double_field_form_missing_data_test() {
  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.add(field.new("second", field.text_field()))
  |> forma.data([#("second", "1")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.decoded
  |> should.equal(Ok(" 1"))

  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.add(field.new("second", field.text_field()))
  |> forma.data([#("first", "1"), #("first", "2")])
  |> forma.decodes(fn(a) { fn(b) { a <> " " <> b } })
  |> forma.decoded
  |> should.equal(Ok("1 "))
}

pub fn integer_field_test() {
  forma.new()
  |> forma.add(field.new("first", field.integer_field()))
  |> forma.data([#("first", " 1 ")])
  |> forma.decodes(fn(i) { i })
  |> forma.decoded
  |> should.equal(Ok(1))
}

pub fn can_decodes_in_any_order_test() {
  forma.new()
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.add(field.new("first", field.text_field()))
  |> forma.data([#("first", "world")])
  |> forma.decoded
  |> should.equal(Ok("hello world"))

  forma.new()
  |> forma.add(field.new("first", field.text_field()))
  |> forma.data([#("first", "world")])
  |> forma.decodes(fn(str) { "hello " <> str })
  |> forma.decoded
  |> should.equal(Ok("hello world"))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    forma.new()
    |> forma.add(field.new("first", field.integer_field()))
    |> forma.data([#("first", "world")])
    |> forma.decodes(fn(_) { 1 })
    |> forma.decoded

  let assert [field] = forma.get_fields(f)
  field |> should_be_field_with_error("not an integer")
}

pub fn parse_double_field_form_with_error_test() {
  let form =
    forma.new()
    |> forma.add(field.new("a", field.integer_field()))
    |> forma.add(field.new("b", field.integer_field()))
    |> forma.decodes(fn(_) { fn(_) { 1 } })

  let assert Error(f) =
    form
    |> forma.data([#("a", "not a number"), #("b", "2")])
    |> forma.decoded

  let assert [fielda, fieldb] = forma.get_fields(f)
  fielda |> should_be_field_with_error("not an integer")
  fieldb |> should_be_field_no_error

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "string")])
    |> forma.decoded

  let assert [fielda, fieldb] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("not an integer")

  let assert Error(f) =
    form
    |> forma.data([#("a", "string"), #("b", "string")])
    |> forma.decoded

  let assert [fielda, fieldb] = forma.get_fields(f)
  fielda |> should_be_field_with_error("not an integer")
  fieldb |> should_be_field_with_error("not an integer")
}

pub fn parse_triple_field_form_with_error_test() {
  let form =
    forma.new()
    |> forma.add(field.new("a", field.integer_field()))
    |> forma.add(field.new("b", field.integer_field()))
    |> forma.add(field.new("c", field.integer_field()))
    |> forma.decodes(fn(_) { fn(_) { fn(_) { 1 } } })

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "2"), #("c", "string")])
    |> forma.decoded
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_with_error("not an integer")

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "string"), #("c", "string")])
    |> forma.decoded
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("not an integer")
  fieldc |> should_be_field_with_error("not an integer")

  let assert Error(f) =
    form
    |> forma.data([#("a", "1"), #("b", "string"), #("c", "3")])
    |> forma.decoded
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_no_error
  fieldb |> should_be_field_with_error("not an integer")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> forma.data([#("a", "string"), #("b", "string"), #("c", "3")])
    |> forma.decoded
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_with_error("not an integer")
  fieldb |> should_be_field_with_error("not an integer")
  fieldc |> should_be_field_no_error

  let assert Error(f) =
    form
    |> forma.data([#("a", "string"), #("b", "2"), #("c", "3")])
    |> forma.decoded
  let assert [fielda, fieldb, fieldc] = forma.get_fields(f)
  fielda |> should_be_field_with_error("not an integer")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}

fn should_be_field_no_error(field: forma.Field(String)) {
  should.equal(
    field,
    forma.Field(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      render: field.render,
    ),
  )
}

fn should_be_field_with_error(field: forma.Field(String), str: String) {
  should.equal(
    field,
    forma.InvalidField(
      name: field.name,
      label: field.label,
      help_text: field.help_text,
      value: field.value,
      render: field.render,
      error: str,
    ),
  )
}

pub fn decoded_and_try_test() {
  let f =
    forma.new()
    |> forma.add(field.new("a", field.integer_field()))
    |> forma.add(field.new("b", field.integer_field()))
    |> forma.add(field.new("c", field.integer_field()))
    |> forma.decodes(fn(_) { fn(_) { fn(_) { 1 } } })
    |> forma.data([#("a", "1"), #("b", "2"), #("c", "3")])

  // can succeed
  forma.decode_and_try(f, fn(_, _) { Ok(3) })
  |> should.equal(Ok(3))

  // can change type
  forma.decode_and_try(f, fn(_, _) { Ok("it worked") })
  |> should.equal(Ok("it worked"))

  // can error
  forma.decode_and_try(f, fn(_, form) { Error(form) })
  |> should.equal(Error(f))

  // can change field
  let assert Error(form) =
    forma.decode_and_try(f, fn(_, form) {
      Error(forma.set_field_error(form, "a", "woops"))
    })
  let assert [fielda, fieldb, fieldc] = forma.get_fields(form)
  fielda |> should_be_field_with_error("woops")
  fieldb |> should_be_field_no_error
  fieldc |> should_be_field_no_error
}
