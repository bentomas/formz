//// Hopefully these are pretty self-explanatory. I haven't provided any
//// examples here, as these are all used to build HTML forms and I don't know
//// how helpful it would be to see the raw HTML.  If you'd like to see
//// examples of these in action, please see the [formz_demo](https://github.com/bentomas/formz/tree/main/formz_demo)
//// example project.

import formz_lustre/widgets

import formz/definition.{Definition}
import formz/validation
import gleam/int
import gleam/list
import gleam/option

/// Create a basic form input. Parsed as a String.
pub fn text_field() {
  Definition(
    widgets.input_widget("text"),
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
pub fn email_field() {
  Definition(
    widgets.input_widget("email"),
    validation.email,
    "",
    definition.make_simple_optional_parse(),
    option.None,
  )
}

/// Create a whole number form input. Parsed as an Int.
pub fn integer_field() {
  Definition(
    widgets.number_widget(""),
    validation.int,
    0,
    definition.make_simple_optional_parse(),
    option.None,
  )
}

/// Create a number form input. Parsed as a Float.
pub fn number_field() {
  Definition(
    widgets.number_widget("0.01"),
    validation.number,
    0.0,
    definition.make_simple_optional_parse(),
    option.None,
  )
}

/// Create a checkbox form input. Parsed as a Boolean.
pub fn boolean_field() {
  definition.Definition(
    widget: widgets.checkbox_widget(),
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

/// Create a password form input, which hides the input value. Parsed as a String
pub fn password_field() {
  Definition(
    widgets.password_widget(),
    validation.non_empty_string,
    "",
    definition.make_simple_optional_parse(),
    option.None,
  )
}

/// Creates a `<select>` input.  Takes a tuple of `#(String, String)` where the first
/// item in the tuple is the label, and the second item can be any Gleam type and
/// is the value that would be parsed for a given selection.
///
/// Because of how you build `formz` forms, you need to provide a placeholder of
/// the value type.  Is this annoying?  Would it be more or less annoying if I
/// required a non-empty list for the variants instead? I'm not sure.  Let me know!
pub fn choices_field(variants: List(#(String, enum)), stub stub: enum) {
  let keys_indexed =
    variants
    |> list.index_map(fn(t, i) { #(t.0, int.to_string(i)) })
  let values = variants |> list.map(fn(t) { t.1 })

  Definition(
    widgets.select_widget(keys_indexed),
    validation.list_item_by_index(values)
      |> validation.replace_error("is required"),
    stub,
    definition.make_simple_optional_parse(),
    option.None,
  )
}

/// Creates a `<select>` input from a list of strings.  Validates that the parsed
/// value is one of the strings in the list.
pub fn list_field(variants: List(String)) {
  let labels_and_values = list.map(variants, fn(s) { #(s, s) })
  choices_field(labels_and_values, "")
}
