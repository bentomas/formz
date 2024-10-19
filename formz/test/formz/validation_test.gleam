import formz/validation
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub type Alphabet {
  A
  B
  C
  D
  E
  F
  G
  H
  I
  J
  K
  L
  M
  N
  O
  P
  Q
  R
  S
  T
  U
  V
  W
  X
  Y
  Z
}

pub fn string_test() {
  "" |> validation.string |> should.equal(Error("Must not be empty"))
  " " |> validation.string |> should.equal(Error("Must not be empty"))
  "a" |> validation.string |> should.equal(Ok("a"))
  "b " |> validation.string |> should.equal(Ok("b"))
  " c" |> validation.string |> should.equal(Ok("c"))
  " d " |> validation.string |> should.equal(Ok("d"))
}

pub fn must_be_longer_than_test() {
  ""
  |> validation.must_be_longer_than(2)
  |> should.equal(Error("Must be longer than 2"))
  "a"
  |> validation.must_be_longer_than(2)
  |> should.equal(Error("Must be longer than 2"))
  "ab"
  |> validation.must_be_longer_than(2)
  |> should.equal(Error("Must be longer than 2"))
  "abc" |> validation.must_be_longer_than(2) |> should.equal(Ok("abc"))
  "abcd" |> validation.must_be_longer_than(2) |> should.equal(Ok("abcd"))
}

pub fn email_test() {
  "xxxxx" |> validation.email |> should.equal(Error("Must be an email address"))
  "a@" |> validation.email |> should.equal(Ok("a@"))
  "@a" |> validation.email |> should.equal(Ok("@a"))
  "a@a" |> validation.email |> should.equal(Ok("a@a"))
}

pub fn integer_test() {
  "" |> validation.int |> should.equal(Error("Must be a whole number"))
  "a" |> validation.int |> should.equal(Error("Must be a whole number"))
  "1.0" |> validation.int |> should.equal(Error("Must be a whole number"))
  "1" |> validation.int |> should.equal(Ok(1))
}

pub fn number_test() {
  "" |> validation.number |> should.equal(Error("Must be a number"))
  "a" |> validation.number |> should.equal(Error("Must be a number"))
  "1.0" |> validation.number |> should.equal(Ok(1.0))
  "1" |> validation.number |> should.equal(Ok(1.0))
}

pub fn enum_test() {
  "x"
  |> validation.enum(variants() |> list.take(1))
  |> should.equal(Error("Must be A"))
  "x"
  |> validation.enum(variants() |> list.take(2))
  |> should.equal(Error("Must be one of A, B"))
  "x"
  |> validation.enum(variants() |> list.take(3))
  |> should.equal(Error("Must be one of A, B, C"))
  "x"
  |> validation.enum(variants() |> list.take(4))
  |> should.equal(Error("Must be one of A, B, C, D"))
  "x"
  |> validation.enum(variants())
  |> should.equal(Error("Must be one of A, B, C, D..."))
  "A" |> validation.enum(variants()) |> should.equal(Ok(A))
  "Y" |> validation.enum(variants()) |> should.equal(Ok(Y))
}

pub fn list_item_test() {
  "x"
  |> validation.list_item(variants() |> list.take(1))
  |> should.equal(Error("Must be A"))
  "x"
  |> validation.list_item(variants() |> list.take(2))
  |> should.equal(Error("Must be one of A, B"))
  "x"
  |> validation.list_item(variants() |> list.take(3))
  |> should.equal(Error("Must be one of A, B, C"))
  "x"
  |> validation.list_item(variants() |> list.take(4))
  |> should.equal(Error("Must be one of A, B, C, D"))
  "x"
  |> validation.list_item(variants())
  |> should.equal(Error("Must be one of A, B, C, D..."))
  "0" |> validation.list_item(variants()) |> should.equal(Ok(A))
  "24" |> validation.list_item(variants()) |> should.equal(Ok(Y))
}

pub fn boolean_test() {
  "x" |> validation.boolean |> should.equal(Error("Must be true or false"))
  "" |> validation.boolean |> should.equal(Ok(False))
  "true" |> validation.boolean |> should.equal(Ok(True))
  "false" |> validation.boolean |> should.equal(Ok(False))
  "True" |> validation.boolean |> should.equal(Ok(True))
  "False" |> validation.boolean |> should.equal(Ok(False))
  "on" |> validation.boolean |> should.equal(Ok(True))
  "off" |> validation.boolean |> should.equal(Ok(False))
}

pub fn true_test() {
  "" |> validation.true |> should.equal(Error("Must be true"))
  "false" |> validation.true |> should.equal(Error("Must be true"))
  "False" |> validation.true |> should.equal(Error("Must be true"))
  "off" |> validation.true |> should.equal(Error("Must be true"))
  "true" |> validation.true |> should.equal(Ok(True))
  "True" |> validation.true |> should.equal(Ok(True))
  "on" |> validation.true |> should.equal(Ok(True))
}

pub fn and_test() {
  let v =
    validation.enum([#("off", "off"), #("yes", "yes")])
    |> validation.and(validation.true)

  "" |> v |> should.equal(Error("Must be one of off, yes"))
  "\"on\"" |> v |> should.equal(Error("Must be one of off, yes"))
  "\"off\"" |> v |> should.equal(Error("Must be true"))
  "\"yes\"" |> v |> should.equal(Ok(True))
}

pub fn or_test() {
  let v =
    validation.enum([#("off", "off"), #("yes", "yes")])
    |> validation.or(validation.enum([#("on", "on"), #("true", "true")]))

  ""
  |> v
  |> should.equal(Error("Must be one of off, yes or Must be one of on, true"))
  "\"off\"" |> v |> should.equal(Ok("off"))
  "\"yes\"" |> v |> should.equal(Ok("yes"))
  "\"on\"" |> v |> should.equal(Ok("on"))
  "\"true\"" |> v |> should.equal(Ok("true"))
}

pub fn replace_error_test() {
  let v =
    validation.int
    |> validation.replace_error("Uh oh!")

  "x"
  |> v
  |> should.equal(Error("Uh oh!"))
}

fn variants() {
  [
    #("A", A),
    #("B", B),
    #("C", C),
    #("D", D),
    #("E", E),
    #("F", F),
    #("G", G),
    #("H", H),
    #("I", I),
    #("J", J),
    #("K", K),
    #("L", L),
    #("M", M),
    #("N", N),
    #("O", O),
    #("P", P),
    #("Q", Q),
    #("R", R),
    #("S", S),
    #("T", T),
    #("U", U),
    #("V", V),
    #("W", W),
    #("X", X),
    #("Y", Y),
    #("Z", Z),
  ]
}
