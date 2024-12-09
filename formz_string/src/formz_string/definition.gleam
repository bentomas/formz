//// Hopefully these are pretty self-explanatory. I haven't provided any
//// examples here, as these are all used to build HTML forms and I don't know
//// how helpful it would be to see the raw HTML.  If you'd like to see
//// examples of these in action, please see the [formz_demo](https://github.com/bentomas/formz/tree/main/formz_demo)
//// example project.

import formz
import formz/validation
import formz_string/widget
import gleam/int
import gleam/list
import gleam/option

/// Create a basic form input. Parsed as a String.
pub fn text_field() -> formz.Definition(widget.Widget, String, String) {
  formz.definition_with_custom_optional(
    widget.input_widget("text"),
    validation.non_empty_string,
    "",
    fn(fun, str) {
      case str {
        "" -> Ok("")
        _ -> fun(str)
      }
    },
    "",
  )
}

/// Create an email form input. Parsed as a String but must
/// look like an email address, i.e. the string has an `@`.
pub fn email_field() -> formz.Definition(
  widget.Widget,
  String,
  option.Option(String),
) {
  formz.definition(widget.input_widget("email"), validation.email, "")
}

/// Create a whole number form input. Parsed as an Int.
pub fn integer_field() -> formz.Definition(
  widget.Widget,
  Int,
  option.Option(Int),
) {
  formz.definition(widget.number_widget(""), validation.int, 0)
}

/// Create a number form input. Parsed as a Float.
pub fn number_field() -> formz.Definition(
  widget.Widget,
  Float,
  option.Option(Float),
) {
  formz.definition(widget.number_widget("0.01"), validation.number, 0.0)
}

/// Create a checkbox form input. Parsed as a `Bool`. If required, the parsed
/// `Bool` must be `True`.
pub fn boolean_field() -> formz.Definition(widget.Widget, Bool, Bool) {
  formz.definition_with_custom_optional(
    widget: widget.checkbox_widget(),
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

/// Create a password form input, which hides the input value. Parsed as a String.
pub fn password_field() -> formz.Definition(
  widget.Widget,
  String,
  option.Option(String),
) {
  formz.definition(widget.password_widget(), validation.non_empty_string, "")
}

/// Creates a `<select>` input.  Takes a tuple of `#(String, String)` where the first
/// item in the tuple is the label, and the second item can be any Gleam type and
/// is the value that would be parsed for a given selection.  The actual values
/// rendered in the `<option>` tags are the numeric indeces of the items in the
/// list.
///
/// Because of how you build `formz` forms, you need to provide a stub of
/// the value type.  Is this annoying?  Would it be more or less annoying if I
/// required a non-empty list for the variants instead? I'm not sure.  Let me know!
pub fn choices_field(
  variants: List(#(String, enum)),
  stub stub: enum,
) -> formz.Definition(widget.Widget, enum, option.Option(enum)) {
  let keys_indexed =
    variants
    |> list.index_map(fn(t, i) { #(t.0, int.to_string(i)) })
  let values = variants |> list.map(fn(t) { t.1 })

  formz.definition(
    widget.select_widget(keys_indexed),
    validation.list_item_by_index(values)
      |> validation.replace_error("is required"),
    stub,
  )
}

/// Creates a `<select>` input from a list of strings.  Validates that the parsed
/// value is one of the strings in the list.
pub fn list_field(
  variants: List(String),
) -> formz.Definition(widget.Widget, String, option.Option(String)) {
  let labels_and_values = list.map(variants, fn(s) { #(s, s) })
  choices_field(labels_and_values, "")
}

pub fn make_hidden(
  def: formz.Definition(widget.Widget, a, b),
) -> formz.Definition(widget.Widget, a, b) {
  def |> formz.widget(widget.hidden_widget())
}
