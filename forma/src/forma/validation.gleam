import gleam/float
import gleam/int
import gleam/result
import gleam/string

pub fn string(str: String) -> Result(String, String) {
  case string.trim(str) {
    "" -> Error("Must not be empty")
    trimmed -> Ok(trimmed)
  }
}

pub fn email(input: String) -> Result(String, String) {
  // TODO verify both parts have at least one character?
  case input |> string.trim |> string.split("@") {
    [_, _] -> Ok(input)
    _ -> Error("Must be an email address")
  }
}

pub fn must_be_longer_than(length: Int) -> fn(String) -> Result(String, String) {
  fn(input) {
    case string.length(input) > length {
      True -> Ok(input)
      False ->
        Error("Must be longer than " <> int.to_string(length) <> " characters")
    }
  }
}

pub fn int(str: String) -> Result(Int, String) {
  str
  |> string.trim
  |> int.parse
  |> result.replace_error("Must be a whole number")
}

pub fn number(str: String) -> Result(Float, String) {
  let str = string.trim(str)
  case float.parse(str) {
    Ok(value) -> Ok(value)
    Error(_) -> int.parse(str) |> result.map(int.to_float)
  }
  |> result.replace_error("Must be a number")
}

pub fn and(
  previous: fn(a) -> Result(b, String),
  next: fn(b) -> Result(c, String),
) -> fn(a) -> Result(c, String) {
  fn(data) {
    case previous(data) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  }
}
