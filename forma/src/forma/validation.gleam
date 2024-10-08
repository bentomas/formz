import gleam/int
import gleam/result
import gleam/string

pub fn string(str: String) -> Result(String, String) {
  Ok(str)
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

pub fn trim(str: String) -> Result(String, String) {
  Ok(string.trim(str))
}

pub fn int(str: String) -> Result(Int, String) {
  str |> int.parse |> result.replace_error("not an integer")
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
