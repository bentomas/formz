import formz.{Field, Invalid, Valid}
import formz/definition
import formz/field.{field}
import formz/subform.{subform}
import formz/validation
import gleam/option.{None, Some}
import gleam/result
import gleam/string
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
        "" -> Ok(None)
        _ -> fun(str) |> result.map(Some)
      }
    },
    optional_stub: Some(0.0),
  )
}

fn integer_field() {
  definition.Definition(
    widget: fn(_, _) { Nil },
    parse: validation.int,
    stub: 0,
    optional_parse: fn(fun, str) {
      case str {
        "" -> Ok(None)
        _ -> fun(str) |> result.map(Some)
      }
    },
    optional_stub: Some(0),
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

fn state_should_be(state: formz.State, expected: formz.State) {
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
  use a <- formz.optional(field("a"), text_field())
  formz.create_form("hello " <> a)
}

fn two_field_form() {
  use a <- formz.optional(field("a"), text_field())
  use b <- formz.optional(field("b"), text_field())

  formz.create_form(#(a, b))
}

fn three_field_form() {
  use a <- formz.optional(
    field("x") |> field.set_name("a") |> field.set_label("A"),
    text_field()
      |> definition.validate(fn(str) {
        case string.length(str) > 3 {
          True -> Ok(str)
          False -> Error("must be longer than 3")
        }
      }),
  )

  use b <- formz.optional(
    field(named: "b"),
    integer_field()
      |> definition.validate(fn(i) {
        case i > 0 {
          True -> Ok(i)
          False -> Error("must be positive")
        }
      }),
  )

  use c <- formz.optional(
    field(named: "c") |> field.set_name("c") |> field.set_label("C"),
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

pub fn parse_single_field_form_with_error_test() {
  let assert Error(f) =
    {
      use a <- formz.optional(field("a"), boolean_field())
      formz.create_form(a)
    }
    |> formz.data([#("a", "world")])
    |> formz.parse

  let assert [state] = formz.get_states(f)
  state |> state_should_be(Invalid("world", "must be on"))
}

pub fn parse_triple_field_form_with_error_test() {
  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "1"), #("c", "string")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states

  statea |> state_should_be(Valid("string"))
  stateb |> state_should_be(Valid("1"))
  statec |> state_should_be(Invalid("string", "must be a number"))

  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "string")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states
  statea |> state_should_be(Valid("string"))
  stateb |> state_should_be(Invalid("string", "must be a whole number"))
  statec |> state_should_be(Invalid("string", "must be a number"))

  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "string"), #("b", "string"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states
  statea |> state_should_be(Valid("string"))
  stateb |> state_should_be(Invalid("string", "must be a whole number"))
  statec |> state_should_be(Valid("3.4"))

  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "."), #("b", "string"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states
  statea |> state_should_be(Invalid(".", "must be longer than 3"))
  stateb |> state_should_be(Invalid("string", "must be a whole number"))
  statec |> state_should_be(Valid("3.4"))

  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "."), #("b", "1"), #("c", "3.4")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states
  statea |> state_should_be(Invalid(".", "must be longer than 3"))
  stateb |> state_should_be(Valid("1"))
  statec |> state_should_be(Valid("3.4"))
}

pub fn set_required_field_test() {
  let f = {
    use a <- formz.require(
      field("a") |> field.set_required(False),
      integer_field(),
    )
    use b <- formz.optional(
      field("b") |> field.set_required(True),
      integer_field(),
    )
    formz.create_form(#(a, b))
  }

  let assert [Field(fielda, _, _), Field(fieldb, _, _)] = formz.items(f)

  fielda.required |> should.equal(True)
  fieldb.required |> should.equal(False)
}

pub fn sub_form_test() {
  let f1 = {
    use a <- formz.require(field("a"), integer_field())
    use b <- formz.require(field("b"), integer_field())
    use c <- formz.require(field("c"), integer_field())

    formz.create_form(#(a, b, c))
  }

  let f2 = {
    use a <- formz.subform(subform("name"), f1)
    use b <- formz.require(field("d"), integer_field())

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

pub fn get_fields_test() {
  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])
    |> formz.get_states

  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Valid("2"))
  statec |> state_should_be(Valid("3"))
}

pub fn validate_test() {
  let f =
    three_field_form()
    |> formz.data([#("a", "1"), #("b", "-1"), #("c", "x")])

  // haven't validated yet
  let assert [statea, stateb, statec] = f |> formz.get_states
  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Valid("-1"))
  statec |> state_should_be(Valid("x"))

  // validate first 2
  let assert [statea, stateb, statec] =
    f |> formz.validate(["a", "b"]) |> formz.get_states
  statea |> state_should_be(Invalid("1", "must be longer than 3"))
  stateb |> state_should_be(Invalid("-1", "must be positive"))
  statec |> state_should_be(Valid("x"))

  // validate middle
  let assert [statea, stateb, statec] =
    f |> formz.validate(["b"]) |> formz.get_states
  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Invalid("-1", "must be positive"))
  statec |> state_should_be(Valid("x"))

  //validate last
  let assert [statea, stateb, statec] =
    f |> formz.validate(["c"]) |> formz.get_states
  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Valid("-1"))
  statec |> state_should_be(Invalid("x", "must be a number"))
}

pub fn validate_all_test() {
  let assert [statea, stateb, statec] =
    three_field_form()
    |> formz.data([#("a", "1"), #("b", "-1"), #("c", "x")])
    |> formz.validate_all
    |> formz.get_states

  statea |> state_should_be(Invalid("1", "must be longer than 3"))
  stateb |> state_should_be(Invalid("-1", "must be positive"))
  statec |> state_should_be(Invalid("x", "must be a number"))
}

pub fn sub_form_error_test() {
  let f1 = {
    use a <- formz.optional(field("a"), integer_field())
    use b <- formz.require(field("b"), integer_field())
    use c <- formz.optional(field("c"), integer_field())

    formz.create_form(#(a, b, c))
  }

  let f2 = {
    use a <- formz.subform(subform("name"), f1)
    use b <- formz.optional(field("d"), integer_field())

    formz.create_form(#(a, b))
  }

  let tmp =
    f2
    |> formz.data([
      #("name.a", "a"),
      #("name.b", "2"),
      #("name.c", "3"),
      #("d", "4"),
    ])
    |> formz.parse
    |> get_form_from_error_result

  tmp |> formz.items
  let assert [statea, stateb, statec, stated] = tmp |> formz.get_states

  statea |> state_should_be(Invalid("a", "must be a whole number"))
  stateb |> state_should_be(Valid("2"))
  statec |> state_should_be(Valid("3"))
  stated |> state_should_be(Valid("4"))

  let assert [statea, stateb, statec, stated] =
    f2
    |> formz.data([
      #("name.a", "1"),
      #("name.b", "2"),
      #("name.c", "3"),
      #("d", "a"),
    ])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states

  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Valid("2"))
  statec |> state_should_be(Valid("3"))
  stated |> state_should_be(Invalid("a", "must be a whole number"))
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
      Error(form |> formz.set_field_error("a", "woops"))
    })
  let assert [statea, stateb, statec] = formz.get_states(form)
  statea |> state_should_be(Invalid("string", "woops"))
  stateb |> state_should_be(Valid("2"))
  statec |> state_should_be(Valid("3.0"))
}

pub fn multi_test() {
  let f = {
    use a <- formz.list(field("a"), float_field())
    use b <- formz.list(field("b"), float_field())
    use c <- formz.list(field("c"), float_field())

    formz.create_form(#(a, b, c))
  }

  f
  |> formz.data([#("a", "1"), #("b", "2"), #("c", "3")])
  |> formz.parse
  |> should.equal(Ok(#([1.0], [2.0], [3.0])))

  f
  |> formz.data([#("a", "1.1"), #("a", "1.2"), #("b", "2"), #("c", "3")])
  |> formz.parse
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
  |> formz.parse
  |> should.equal(Ok(#([1.1, 1.2], [2.1, 2.2], [3.1, 3.2])))

  let assert [statea, stateb, statec] =
    f
    |> formz.data([#("a", "a"), #("b", "2"), #("c", "3")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states

  statea |> state_should_be(Invalid("a", "must be a number"))
  stateb |> state_should_be(Valid("2"))
  statec |> state_should_be(Valid("3"))

  let assert [statea, stateb, statec, stated] =
    f
    |> formz.data([#("a", "a1"), #("a", "a2"), #("b", "2"), #("c", "3")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states

  statea |> state_should_be(Invalid("a1", "must be a number"))
  stateb |> state_should_be(Invalid("a2", "must be a number"))
  statec |> state_should_be(Valid("2"))
  stated |> state_should_be(Valid("3"))

  let assert [statea, stateb, statec, stated] =
    f
    |> formz.data([#("a", "1"), #("a", "a2"), #("b", "2"), #("c", "3")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states

  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Invalid("a2", "must be a number"))
  statec |> state_should_be(Valid("2"))
  stated |> state_should_be(Valid("3"))

  let assert [statea, stateb, statec, stated] =
    f
    |> formz.data([#("a", "1"), #("b", "b1"), #("b", "2"), #("c", "c")])
    |> formz.parse
    |> get_form_from_error_result
    |> formz.get_states

  statea |> state_should_be(Valid("1"))
  stateb |> state_should_be(Invalid("b1", "must be a number"))
  statec |> state_should_be(Valid("2"))
  stated |> state_should_be(Invalid("c", "must be a number"))
}
