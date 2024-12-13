import formz.{Invalid, Optional, Required, Unvalidated, Valid}
import formz/validation
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

fn text_field() {
  formz.definition_with_custom_optional(
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
  formz.definition(
    widget: fn(_, _) { Nil },
    parse: validation.number,
    stub: 0.0,
  )
}

fn integer_field() {
  formz.definition(widget: fn(_, _) { Nil }, parse: validation.int, stub: 0)
}

fn boolean_field() {
  formz.definition_with_custom_optional(
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

fn state_should_be(state: formz.InputState, expected: formz.InputState) {
  should.equal(state, expected)
}

fn get_form_from_error_result(
  result: Result(output, formz.Form(format, output)),
) -> formz.Form(format, output) {
  let assert Error(form) = result
  form
}

fn empty_form(val) {
  formz.create_form(val)
}

fn one_field_form() {
  use a <- formz.field(formz.named("a"), text_field())
  formz.create_form("hello " <> a)
}

fn two_field_form() {
  use a <- formz.field(formz.named("a"), text_field())
  use b <- formz.field(formz.named("b"), text_field())

  formz.create_form(#(a, b))
}

fn three_field_form() {
  use a <- formz.field(
    formz.named("x") |> formz.set_name("a") |> formz.set_label("A"),
    text_field()
      |> formz.verify(fn(str) {
        case string.length(str) > 3 {
          True -> Ok(str)
          False -> Error("must be longer than 3")
        }
      }),
  )

  use b <- formz.field(
    formz.named("b"),
    integer_field()
      |> formz.verify(fn(i) {
        case i > 0 {
          True -> Ok(i)
          False -> Error("must be positive")
        }
      }),
  )

  use c <- formz.field(
    formz.named("c") |> formz.set_name("c") |> formz.set_label("C"),
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
  |> formz.decode
  |> should.equal(Ok(1))

  empty_form("hello")
  |> formz.data([])
  |> formz.decode
  |> should.equal(Ok("hello"))
}

pub fn parse_single_field_form_test() {
  one_field_form()
  |> formz.data([#("a", "world")])
  |> formz.decode
  |> should.equal(Ok("hello world"))

  one_field_form()
  |> formz.data([#("a", "ignored"), #("a", "world")])
  |> formz.decode
  |> should.equal(Ok("hello world"))
}

pub fn parse_double_field_form_test() {
  two_field_form()
  |> formz.data([#("a", "hello"), #("b", "world")])
  |> formz.decode
  |> should.equal(Ok(#("hello", "world")))

  // wrong order
  two_field_form()
  |> formz.data([#("b", "world"), #("a", "hello")])
  |> formz.decode
  |> should.equal(Ok(#("hello", "world")))

  // takes second
  two_field_form()
  |> formz.data([
    #("a", "ignored"),
    #("b", "ignored"),
    #("b", "world"),
    #("a", "hello"),
  ])
  |> formz.decode
  |> should.equal(Ok(#("hello", "world")))
}

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    {
      use a <- formz.field(formz.named("a"), boolean_field())
      formz.create_form(a)
    }
    |> formz.data([#("a", "world")])
    |> formz.decode

  let assert [state] = formz.get_states(f)
  state |> state_should_be(Invalid("world", Optional, "must be on"))
}

pub fn parse_triple_field_form_with_error_test() {
  three_field_form()
  |> formz.data([#("a", "string"), #("b", "1"), #("c", "string")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("string", Optional),
    Valid("1", Optional),
    Invalid("string", Optional, "must be a number"),
  ])

  three_field_form()
  |> formz.data([#("a", "string"), #("b", "string"), #("c", "string")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("string", Optional),
    Invalid("string", Optional, "must be a whole number"),
    Invalid("string", Optional, "must be a number"),
  ])

  three_field_form()
  |> formz.data([#("a", "string"), #("b", "string"), #("c", "3.4")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("string", Optional),
    Invalid("string", Optional, "must be a whole number"),
    Valid("3.4", Optional),
  ])

  three_field_form()
  |> formz.data([#("a", "."), #("b", "string"), #("c", "3.4")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid(".", Optional, "must be longer than 3"),
    Invalid("string", Optional, "must be a whole number"),
    Valid("3.4", Optional),
  ])

  three_field_form()
  |> formz.data([#("a", "."), #("b", "1"), #("c", "3.4")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid(".", Optional, "must be longer than 3"),
    Valid("1", Optional),
    Valid("3.4", Optional),
  ])
}

pub fn sub_form_test() {
  let f1 = {
    use a <- formz.required_field(formz.named("a"), integer_field())
    use b <- formz.required_field(formz.named("b"), integer_field())
    use c <- formz.required_field(formz.named("c"), integer_field())

    formz.create_form(#(a, b, c))
  }

  let f2 = {
    use a <- formz.subform(formz.named("name"), f1)
    use b <- formz.required_field(formz.named("d"), integer_field())

    formz.create_form(#(a, b))
  }

  f2
  |> formz.data([
    #("name-a", "1"),
    #("name-b", "2"),
    #("name-c", "3"),
    #("d", "4"),
  ])
  |> formz.decode
  |> should.equal(Ok(#(#(1, 2, 3), 4)))
}

pub fn get_fields_test() {
  three_field_form()
  |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])
  |> formz.get_states
  |> should.equal([
    Unvalidated("1", Optional),
    Unvalidated("2", Optional),
    Unvalidated("3", Optional),
  ])
}

pub fn validate_errors_test() {
  let f =
    three_field_form()
    |> formz.data([#("a", "1"), #("b", "-1"), #("c", "x")])

  // haven't validated yet
  f
  |> formz.get_states
  |> should.equal([
    Unvalidated("1", Optional),
    Unvalidated("-1", Optional),
    Unvalidated("x", Optional),
  ])

  // validate first 2

  f
  |> formz.validate(["a", "b"])
  |> formz.get_states
  |> should.equal([
    Invalid("1", Optional, "must be longer than 3"),
    Invalid("-1", Optional, "must be positive"),
    Unvalidated("x", Optional),
  ])

  // validate middle
  f
  |> formz.validate(["b"])
  |> formz.get_states
  |> should.equal([
    Unvalidated("1", Optional),
    Invalid("-1", Optional, "must be positive"),
    Unvalidated("x", Optional),
  ])

  //validate last
  f
  |> formz.validate(["c"])
  |> formz.get_states
  |> should.equal([
    Unvalidated("1", Optional),
    Unvalidated("-1", Optional),
    Invalid("x", Optional, "must be a number"),
  ])
}

pub fn validate_ok_test() {
  let f =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "1"), #("c", "1.0")])

  // haven't validated yet
  f
  |> formz.get_states
  |> should.equal([
    Unvalidated("string", Optional),
    Unvalidated("1", Optional),
    Unvalidated("1.0", Optional),
  ])

  // validate first 2

  f
  |> formz.validate(["a", "b"])
  |> formz.get_states
  |> should.equal([
    Valid("string", Optional),
    Valid("1", Optional),
    Unvalidated("1.0", Optional),
  ])

  // validate middle
  f
  |> formz.validate(["b"])
  |> formz.get_states
  |> should.equal([
    Unvalidated("string", Optional),
    Valid("1", Optional),
    Unvalidated("1.0", Optional),
  ])

  //validate last
  f
  |> formz.validate(["c"])
  |> formz.get_states
  |> should.equal([
    Unvalidated("string", Optional),
    Unvalidated("1", Optional),
    Valid("1.0", Optional),
  ])
}

pub fn validate_all_test() {
  three_field_form()
  |> formz.data([#("a", "1"), #("b", "-1"), #("c", "x")])
  |> formz.validate_all
  |> formz.get_states
  |> should.equal([
    Invalid("1", Optional, "must be longer than 3"),
    Invalid("-1", Optional, "must be positive"),
    Invalid("x", Optional, "must be a number"),
  ])

  three_field_form()
  |> formz.data([#("a", "string"), #("b", "1"), #("c", "1.0")])
  |> formz.validate_all
  |> formz.get_states
  |> should.equal([
    Valid("string", Optional),
    Valid("1", Optional),
    Valid("1.0", Optional),
  ])
}

pub fn sub_form_error_test() {
  let f1 = {
    use a <- formz.field(formz.named("a"), integer_field())
    use b <- formz.required_field(formz.named("b"), integer_field())
    use c <- formz.field(formz.named("c"), integer_field())

    formz.create_form(#(a, b, c))
  }

  let f2 = {
    use a <- formz.subform(formz.named("name"), f1)
    use b <- formz.field(formz.named("d"), integer_field())

    formz.create_form(#(a, b))
  }

  f2
  |> formz.data([
    #("name-a", "a"),
    #("name-b", "2"),
    #("name-c", "3"),
    #("d", "4"),
  ])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid("a", Optional, "must be a whole number"),
    Valid("2", Required),
    Valid("3", Optional),
    Valid("4", Optional),
  ])

  f2
  |> formz.data([
    #("name-a", "1"),
    #("name-b", "2"),
    #("name-c", "3"),
    #("d", "a"),
  ])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("1", Optional),
    Valid("2", Required),
    Valid("3", Optional),
    Invalid("a", Optional, "must be a whole number"),
  ])
}

pub fn decoded_and_try_test() {
  let f =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "2"), #("c", "3.0")])

  // can succeed
  formz.decode_then_try(f, fn(_, _) { Ok(3) })
  |> should.equal(Ok(3))

  // can change type
  formz.decode_then_try(f, fn(_, _) { Ok("it worked") })
  |> should.equal(Ok("it worked"))

  // can error
  formz.decode_then_try(f, fn(form, _) { Error(form) })
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("string", Optional),
    Valid("2", Optional),
    Valid("3.0", Optional),
  ])

  // can change field
  let assert Error(form) =
    formz.decode_then_try(f, fn(form, _) {
      Error(form |> formz.field_error("a", "woops"))
    })
  formz.get_states(form)
  |> should.equal([
    Invalid("string", Optional, "woops"),
    Valid("2", Optional),
    Valid("3.0", Optional),
  ])

  let f = {
    use a <- formz.list(formz.named("a"), float_field())
    formz.create_form(a)
  }

  formz.data(f, [#("a", "1"), #("a", "2")])
  |> formz.decode_then_try(fn(form, _) {
    Error(
      formz.listfield_errors(form, "a", [Error("woops 1"), Error("woops 2")]),
    )
  })
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid("1", Optional, "woops 1"),
    Invalid("2", Optional, "woops 2"),
  ])

  formz.data(f, [#("a", "1"), #("a", "2")])
  |> formz.decode_then_try(fn(form, _) {
    Error(formz.listfield_errors(form, "a", [Error("woops"), Ok(Nil)]))
  })
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([Invalid("1", Optional, "woops"), Valid("2", Optional)])

  formz.data(f, [#("a", "1"), #("a", "2")])
  |> formz.decode_then_try(fn(form, _) {
    Error(formz.listfield_errors(form, "a", [Ok(Nil), Error("woops")]))
  })
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([Valid("1", Optional), Invalid("2", Optional, "woops")])
}

pub fn list_test() {
  let f = {
    use a <- formz.list(formz.named("a"), float_field())
    use b <- formz.list(formz.named("b"), float_field())
    use c <- formz.list(formz.named("c"), float_field())

    formz.create_form(#(a, b, c))
  }

  f
  |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])
  |> formz.decode
  |> should.equal(Ok(#([1.0], [2.0], [3.0])))

  f
  |> formz.data([#("a", "1.1"), #("a", "1.2"), #("b", "2"), #("c", "3")])
  |> formz.decode
  |> should.equal(Ok(#([1.1, 1.2], [2.0], [3.0])))

  f
  |> formz.data([
    #("a", "1.1"),
    #("a", "1.2"),
    #("b", "2.1"),
    #("b", "2.2"),
    #("c", "3.1"),
    #("c", "3.2"),
  ])
  |> formz.decode
  |> should.equal(Ok(#([1.1, 1.2], [2.1, 2.2], [3.1, 3.2])))

  f
  |> formz.data([#("a", "a"), #("b", "2"), #("c", "3")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid("a", Optional, "must be a number"),
    Valid("", Optional),
    Valid("2", Optional),
    Valid("", Optional),
    Valid("3", Optional),
    Valid("", Optional),
  ])

  f
  |> formz.data([#("a", "a1"), #("a", "a2"), #("b", "2"), #("c", "3")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid("a1", Optional, "must be a number"),
    Invalid("a2", Optional, "must be a number"),
    Valid("", Optional),
    Valid("2", Optional),
    Valid("", Optional),
    Valid("3", Optional),
    Valid("", Optional),
  ])

  f
  |> formz.data([#("a", "1"), #("a", "a2"), #("b", "2"), #("c", "3")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("1", Optional),
    Invalid("a2", Optional, "must be a number"),
    Valid("", Optional),
    Valid("2", Optional),
    Valid("", Optional),
    Valid("3", Optional),
    Valid("", Optional),
  ])

  f
  |> formz.data([#("a", "1"), #("b", "b1"), #("b", "2"), #("c", "c")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("1", Optional),
    Valid("", Optional),
    Invalid("b1", Optional, "must be a number"),
    Valid("2", Optional),
    Valid("", Optional),
    Invalid("c", Optional, "must be a number"),
    Valid("", Optional),
  ])
}

pub fn limited_list_test() {
  let zero_extra = {
    use a <- formz.limited_list(
      formz.simple_limit_check(1, 4, 0),
      formz.named("a"),
      integer_field(),
    )

    formz.create_form(a)
  }
  let one_extra = {
    use a <- formz.limited_list(
      formz.simple_limit_check(1, 4, 1),
      formz.named("a"),
      integer_field(),
    )

    formz.create_form(a)
  }

  let two_extra = {
    use a <- formz.limited_list(
      formz.simple_limit_check(1, 4, 2),
      formz.named("a"),
      integer_field(),
    )

    formz.create_form(a)
  }

  one_extra
  |> formz.get_states
  |> should.equal([Unvalidated("", Required)])

  two_extra
  |> formz.get_states
  |> should.equal([Unvalidated("", Required), Unvalidated("", Optional)])

  two_extra
  |> formz.data([#("a", "1")])
  |> formz.get_states
  |> should.equal([
    Unvalidated("1", Required),
    Unvalidated("", Optional),
    Unvalidated("", Optional),
  ])

  two_extra
  |> formz.data([#("a", "1"), #("a", "2")])
  |> formz.get_states
  |> should.equal([
    Unvalidated("1", Required),
    Unvalidated("2", Optional),
    Unvalidated("", Optional),
    Unvalidated("", Optional),
  ])

  one_extra
  |> formz.data([#("a", "a"), #("a", "2")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid("a", Required, "must be a whole number"),
    Valid("2", Optional),
    Valid("", Optional),
  ])

  zero_extra
  |> formz.get_states
  |> should.equal([Unvalidated("", Required)])

  zero_extra
  |> formz.data([#("a", "1")])
  |> formz.get_states
  |> should.equal([Unvalidated("1", Required)])

  zero_extra
  |> formz.data([#("a", "1"), #("a", "2")])
  |> formz.get_states
  |> should.equal([Unvalidated("1", Required), Unvalidated("2", Optional)])

  zero_extra
  |> formz.data([#("a", "a"), #("a", "2")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Invalid("a", Required, "must be a whole number"),
    Valid("2", Optional),
  ])
}

pub fn limited_list_too_many_test() {
  let f = {
    use a <- formz.limited_list(
      formz.limit_between(2, 3),
      formz.named("a"),
      integer_field(),
    )

    formz.create_form(a)
  }

  // straight up too many
  f
  |> formz.data([
    #("a", "1"),
    #("a", "2"),
    #("a", "3"),
    #("a", "4"),
    #("a", "5"),
  ])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("1", Required),
    Valid("2", Required),
    Valid("3", Optional),
    Invalid("4", Optional, "exceeds maximum allowed items"),
    Invalid("5", Optional, "exceeds maximum allowed items"),
  ])

  // too many but with an empty value that should be skipped
  f
  |> formz.data([#("a", "1"), #("a", ""), #("a", "3"), #("a", "4"), #("a", "5")])
  |> formz.decode
  |> get_form_from_error_result
  |> formz.get_states
  |> should.equal([
    Valid("1", Required),
    Valid("3", Required),
    Valid("4", Optional),
    Invalid("5", Optional, "exceeds maximum allowed items"),
  ])
}
