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
  "" |> validation.string |> should.equal(Ok(""))
  " " |> validation.string |> should.equal(Ok(""))
  "a" |> validation.string |> should.equal(Ok("a"))
  "b " |> validation.string |> should.equal(Ok("b"))
  " c" |> validation.string |> should.equal(Ok("c"))
  " d " |> validation.string |> should.equal(Ok("d"))
}

pub fn email_test() {
  "xxxxx" |> validation.email |> should.equal(Error("must be an email address"))
  "a@" |> validation.email |> should.equal(Ok("a@"))
  "@a" |> validation.email |> should.equal(Ok("@a"))
  "a@a" |> validation.email |> should.equal(Ok("a@a"))
}

pub fn int_test() {
  "" |> validation.int |> should.equal(Error("must be a whole number"))
  "a" |> validation.int |> should.equal(Error("must be a whole number"))
  "1.0" |> validation.int |> should.equal(Error("must be a whole number"))
  "1" |> validation.int |> should.equal(Ok(1))
}

pub fn number_test() {
  "" |> validation.number |> should.equal(Error("must be a number"))
  "a" |> validation.number |> should.equal(Error("must be a number"))
  "1.0" |> validation.number |> should.equal(Ok(1.0))
  "1" |> validation.number |> should.equal(Ok(1.0))
}

pub fn list_item_test() {
  "x"
  |> validation.list_item_by_index(alphabet() |> list.take(1))
  |> should.equal(Error("must be an item in list"))
  "x"
  |> validation.list_item_by_index(alphabet() |> list.take(2))
  |> should.equal(Error("must be an item in list"))
  "x"
  |> validation.list_item_by_index(alphabet() |> list.take(3))
  |> should.equal(Error("must be an item in list"))
  "x"
  |> validation.list_item_by_index(alphabet() |> list.take(4))
  |> should.equal(Error("must be an item in list"))
  "x"
  |> validation.list_item_by_index(alphabet())
  |> should.equal(Error("must be an item in list"))
  "0" |> validation.list_item_by_index(alphabet()) |> should.equal(Ok("A"))
  "24" |> validation.list_item_by_index(alphabet()) |> should.equal(Ok("Y"))
}

pub fn boolean_test() {
  "x" |> validation.boolean |> should.equal(Error("must be true or false"))
  "" |> validation.boolean |> should.equal(Ok(False))
  "true" |> validation.boolean |> should.equal(Ok(True))
  "false" |> validation.boolean |> should.equal(Ok(False))
  "True" |> validation.boolean |> should.equal(Ok(True))
  "False" |> validation.boolean |> should.equal(Ok(False))
  "on" |> validation.boolean |> should.equal(Ok(True))
  "off" |> validation.boolean |> should.equal(Ok(False))
}

pub fn and_test() {
  let is_even = fn(num) {
    case num % 2 == 0 {
      True -> Ok(num)
      False -> Error("must be even")
    }
  }
  let v =
    validation.and(validation.list_item_by_index([1, 2, 3, 5, 7, 9]), is_even)

  "" |> v |> should.equal(Error("must be an item in list"))
  "10" |> v |> should.equal(Error("must be an item in list"))
  "x" |> v |> should.equal(Error("must be an item in list"))
  "0" |> v |> should.equal(Error("must be even"))
  "1" |> v |> should.equal(Ok(2))
}

pub fn replace_error_test() {
  let v =
    validation.int
    |> validation.replace_error("Uh oh!")

  "x"
  |> v
  |> should.equal(Error("Uh oh!"))
}

fn alphabet() {
  [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  ]
}
