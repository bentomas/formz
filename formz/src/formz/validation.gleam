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
/// # -> Error("must be a whole number")
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

/// Parse the input as a String that looks like an email address, i.e. it
/// contains an `@` character, with at least one other character on either
/// side
///
/// (this behavior more closely matches what the browser does than just
/// checking for an `@`).
///
/// ## Examples
///
/// ```gleam
/// email("hello@example.com")
/// # -> Ok("hello@example.com")
/// ```
/// ```gleam
/// email("@")
/// # -> Error("Must be an email address")
/// ```
/// ```gleam
/// email("hello")
/// # -> Error("Must be an email address")
/// ```
pub fn email(input: String) -> Result(String, String) {
  case input |> string.trim {
    "" -> Error("is required")
    trimmed ->
      case trimmed |> string.split("@") |> list.map(string.length) {
        [before, after] if before > 0 && after > 0 -> Ok(trimmed)
        _ -> Error("must be an email address")
      }
  }
  // TODO verify both parts have at least one character?
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
/// int("1")
/// # -> Ok(1)
/// ```
///
/// ```gleam
/// int("3.4")
/// # -> Error("Must be a whole number")
/// ```
/// ```gleam
/// int("hello")
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

/// Trim and leave the input as it is, but verify it is non-empty.
///
/// ```gleam
/// non_empty_string("hello")
/// # -> Ok("hello")
/// ```
///
/// ```gleam
/// non_empty_string("  ")
/// # -> Error("is required")
/// ```
pub fn non_empty_string(str: String) -> Result(String, String) {
  case string.trim(str) {
    "" -> Error("is required")
    trimmed -> Ok(trimmed)
  }
}

/// Parse the input as a boolean, where only "on" is True and allowed.
/// All other values are an error.  This is useful for HTML checkboxes, which
/// the browser sends the empty string if unchecked, and `"on"` if  checked.
///
/// ## Examples
///
/// ```gleam
/// on("on")
/// # -> Ok(True)
/// ```
///
/// ```gleam
/// on("")
/// # -> Error("is required")
/// ```
///
/// ```gleam
/// on("hi")
/// # -> Error("is required")
/// ```
pub fn on(val: String) -> Result(Bool, String) {
  case val {
    "on" -> Ok(True)
    _ -> Error("must be on")
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
