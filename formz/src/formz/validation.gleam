import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Chain validations together.
///
/// ## Examples
///
/// ```gleam
/// let is_even = fn(num) {
///   case num % 2 == 0 {
///     True -> Ok(num)
///     False -> Error("must be even")
///   }
/// }
/// let check = and(int, is_even)
///
/// check("2")
/// # -> Ok(2)
///
/// check("hi")
/// # -> Error("bust be a whole number")
///
/// check("1")
/// # -> Error("must be even")
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

/// Parse the input as a boolean in a permissive way.
///
/// ## Examples
///
/// ```gleam
/// number("1")
/// number("true")
/// number("yes")
/// number("on")
/// # -> Ok(True)
/// ```
///
/// ```gleam
/// number("0")
/// number("")
/// number("no")
/// number("false")
/// number("off")
/// # -> Ok(False)
/// ```
///
/// ```gleam
/// number("hi")
/// # -> Error("Must be true or false")
/// ```
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
    _ -> Error("must be true or false")
  }
}

/// Parse the input as a String that looks like an email address, i.e. it
/// containts an `@` character.
///
/// ## Examples
///
/// ```gleam
/// email("hello@example.com")
/// # -> Ok("hello@example.com")
/// ```
///
/// ```gleam
/// email("@")
/// # -> Ok("@")
/// ```
///
/// ```gleam
/// number("hello")
/// # -> Error("Must be an email address")
/// ```
/// ```gleam
/// number("1")
/// # -> Error("ust be an email address")
/// ```
pub fn email(input: String) -> Result(String, String) {
  // TODO verify both parts have at least one character?
  case input |> string.trim |> string.split("@") {
    [_, _] -> Ok(input)
    _ -> Error("must be an email address")
  }
}

/// Parse the input as a float.  this is forgiving and will also parse
/// ints into floats.
///
/// ## Examples
///
/// ```gleam
/// number("1")
/// # -> Ok(1.0)
/// ```
///
/// ```gleam
/// number("3.4")
/// # -> Ok(3.4)
/// ```
/// ```gleam
/// number("hello")
/// # -> Error("Must be a number")
/// ```
pub fn number(str: String) -> Result(Float, String) {
  let str = string.trim(str)
  case float.parse(str) {
    Ok(value) -> Ok(value)
    Error(_) -> int.parse(str) |> result.map(int.to_float)
  }
  |> result.replace_error("must be a number")
}

/// Parse the input as an int.
///
/// ## Examples
///
/// ```gleam
/// number("1")
/// # -> Ok(1)
/// ```
///
/// ```gleam
/// number("3.4")
/// # -> Error("Must be a whole number")
/// ```
/// ```gleam
/// number("hello")
/// # -> Error("Must be a whole number")
/// ```
pub fn int(str: String) -> Result(Int, String) {
  str
  |> string.trim
  |> int.parse
  |> result.replace_error("must be a whole number")
}

/// Validates that the input is one from a list of allowed values. Takes a list
/// of Gleam values that can be chosen.  This uses the index of the item in to
/// find the desired value.
///
/// ## Examples
///
/// ```gleam
/// enum(["One","Two","Three"])("1")
/// # -> Ok("Two")
/// ```
///
/// ```gleam
/// enum([True, False])("42")
/// # -> Error("must be an item in list")
/// ```
///
/// ```gleam
/// enum([True, False])("ok")
/// # -> Error("must be an item in list")
/// ```
pub fn list_item_by_index(
  variants: List(enum),
) -> fn(String) -> Result(enum, String) {
  fn(str) {
    variants
    // not the most effecient, but it's simple.  and I can't imagine <select>`s
    // will get that long in practice.
    |> list.index_map(fn(val, i) { #(int.to_string(i), val) })
    |> list.key_find(str)
    |> result.replace_error("must be an item in list")
  }
}

/// Replace the error message of a validation with a new one.  Most of the built-in
/// error messages are pretty rudimentary.
pub fn replace_error(
  previous: fn(a) -> Result(b, String),
  error: String,
) -> fn(a) -> Result(b, String) {
  fn(data) { previous(data) |> result.replace_error(error) }
}

/// Default field parser.  Trims the input and returns it as is.
pub fn string(str: String) -> Result(String, String) {
  Ok(string.trim(str))
}
