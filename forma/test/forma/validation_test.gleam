import forma/validation
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn string_test() {
  "" |> validation.string |> should.equal(Error("Must not be empty"))
  " " |> validation.string |> should.equal(Error("Must not be empty"))
  "a" |> validation.string |> should.equal(Ok("a"))
  "b " |> validation.string |> should.equal(Ok("b"))
  " c" |> validation.string |> should.equal(Ok("c"))
  " d " |> validation.string |> should.equal(Ok("d"))
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
