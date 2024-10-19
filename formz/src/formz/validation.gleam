import gleam/float
import gleam/int
import gleam/list
import gleam/pair
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
      False -> Error("Must be longer than " <> int.to_string(length))
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

pub fn enum(
  variants: List(#(String, enum)),
) -> fn(String) -> Result(enum, String) {
  fn(str) {
    variants
    |> list.filter_map(fn(t) {
      case string.inspect(t.1) == str {
        True -> Ok(t.1)
        False -> Error(Nil)
      }
    })
    |> list.first
    |> result.map_error(map_error_for_list(variants))
  }
}

pub fn list_item(
  variants: List(#(String, enum)),
) -> fn(String) -> Result(enum, String) {
  fn(str) {
    let vals_indexed =
      list.index_map(variants, fn(t, i) { #(int.to_string(i), t.1) })

    list.key_find(vals_indexed, str)
    |> result.map_error(map_error_for_list(variants))
  }
}

fn map_error_for_list(variants) {
  fn(_) {
    case variants {
      [] -> "No allowed values"
      [a] -> "Must be " <> a |> pair.first
      [_, _] | [_, _, _] | [_, _, _, _] ->
        "Must be one of " <> list.map(variants, pair.first) |> string.join(", ")
      [a, b, c, d, _, ..] ->
        "Must be one of "
        <> list.map([a, b, c, d], pair.first) |> string.join(", ")
        <> "..."
    }
  }
}

pub fn boolean(str: String) -> Result(Bool, String) {
  case string.trim(str) {
    "True" -> Ok(True)
    "true" -> Ok(True)
    "Yes" -> Ok(True)
    "yes" -> Ok(True)
    "On" -> Ok(True)
    "on" -> Ok(True)
    "1" -> Ok(True)
    "False" -> Ok(False)
    "false" -> Ok(False)
    "No" -> Ok(False)
    "no" -> Ok(False)
    "Off" -> Ok(False)
    "off" -> Ok(False)
    "0" -> Ok(False)
    "" -> Ok(False)
    _ -> Error("Must be true or false")
  }
}

pub fn true(str: String) -> Result(Bool, String) {
  case boolean(str) {
    Ok(True) -> Ok(True)
    _ -> Error("Must be true")
  }
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

pub fn or(
  previous: fn(a) -> Result(b, String),
  next: fn(a) -> Result(b, String),
) -> fn(a) -> Result(b, String) {
  fn(data) {
    case previous(data) {
      Ok(value) -> Ok(value)
      Error(err1) ->
        case next(data) {
          Ok(value) -> Ok(value)
          Error(err2) -> Error(err1 <> " or " <> err2)
        }
    }
  }
}

pub fn replace_error(
  previous: fn(a) -> Result(b, String),
  error: String,
) -> fn(a) -> Result(b, String) {
  fn(data) { previous(data) |> result.replace_error(error) }
}
