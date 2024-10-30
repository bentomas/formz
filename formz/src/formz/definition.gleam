//// A `Definition` is the second argument needed to add a field to a form. It
//// is what describes how a field works, e.g. how it looks and how it's parsed.
//// It is the heavy compared to the lightness of a [Field](https://hexdocs.pm/formz/formz/field.html);
//// they take a bit more work to make as they are intended to be reusable.
////
//// The first role of a `Definition` is to generate the HTML widget for the field.
//// This library is format-agnostic and you can generate HTML widgets as raw
//// strings, Lustre elements, Nakai nodes, something else, etc, etc. There are
//// currently three formz libraries that provide common field definitions in
//// different formats.
////
//// - [formz_string](https://hexdocs.pm/formz_string/)
//// - [formz_nakai](https://hexdocs.pm/formz_nakai/)
//// - [formz_lustre](https://hexdocs.pm/formz_lustre/) (untested in a browser,
////   would it be useful there??)
////
//// The second role  of a `Definition` is to parse the data from the field.
//// There are a two parts
//// to this, as how you parse a field's value depends on if it is optional or
//// required.  Not all scenarios can be cookie-cutter placed into an `Option`.
//// So you need to provide two parse functions, one for when
//// a field is required, and a second for when it's optional.
////
//// ### Example password field definition
////
//// ```gleam
//// /// you won't often need to do this directly (I think??).  The idea is that
//// /// there'd be libs with the definitions you need.
////
//// import formz/definition.{Definition}
//// import formz/field
//// import formz/validation
//// import formz/widget
//// import lustre/attribute
//// import lustre/element
//// import lustre/element/html
////
//// fn password_widget(
////   field: field.Field,
////   args: widget.Args,
//// ) -> element.Element(msg) {
////   html.input([
////     attribute.type_("password"),
////     attribute.name(field.name),
////     attribute.id(args.id),
////     attribute.attribute("aria-labelledby", field.label),
////   ])
//// }
////
//// pub fn password_field() {
////   Definition(
////     widget: password_widget,
////     parse: validation.string,
////     optional_parse: fn(parse, str) {
////       case str {
////         "" -> Ok(option.None)
////         _ -> parse(str)
////       }
////     },
////     // We need to have a stub value for each parser that's used
////     // when building the decoder and parse functions for the form as the fields
////     // are being added
////     stub: "",
////     optional_stub: option.None,
////   )
//// }
//// ```

import formz/widget
import gleam/option
import gleam/result

pub type Definition(format, required, optional) {
  Definition(
    /// The widget generates the HTML for the field.
    widget: widget.Widget(format),
    /// This parse function takes the raw string from the parsed POST data
    /// and converts it to a Gleam type.  This `parse` is for when a value
    /// is required, so it should return an error if the field is empty.
    parse: fn(String) -> Result(required, String),
    /// The `use`/callbacks pattern for generating a form requires a stub
    /// value for each field, because the actual decode function is called
    /// step by step as the fields are added to the form and `formz` learns
    /// the form's details as it goes.  This stub value is purely used
    /// for navigating the decode function, and just needs to match the type
    /// of the real value that can be parsed.
    stub: required,
    /// If a field is marked as optional, this function is called, with the
    /// above parse as an argument.  The idea is that this function will
    /// call out to the parse function if the field is not empty, and
    /// this should only handle the case where the raw input value is empty.
    /// This function is necessary because not all fields should just be parsed
    /// into an `Option` when they aren't provided.
    /// For example, an optional text field might be an empty string,
    /// an optional checkbox might be `False`, and an optional select might
    /// be `option.None`.
    optional_parse: fn(fn(String) -> Result(required, String), String) ->
      Result(optional, String),
    /// stub for the optional_parse return value
    optional_stub: optional,
  )
}

/// A convenience function to make the simple optional parse function where
/// if a value isn't provided, just return `option.None`, otherwise call out
/// to the parse function and put it's value in `option.Some`.
pub fn make_simple_optional_parse() -> fn(
  fn(String) -> Result(required, String),
  String,
) ->
  Result(option.Option(required), String) {
  fn(fun, str) {
    case str {
      "" -> Ok(option.None)
      _ -> fun(str) |> result.map(option.Some)
    }
  }
}

/// Replace the widget that this `Definition` uses for rendering the field.  Most
/// HTML inputs can be interchangeable, they all generate a `String` after all,
/// but not all are the best UX.  This allows you to choose the one that is the
/// most appropriate for your field.
pub fn set_widget(
  definition: Definition(format, a, b),
  widget: widget.Widget(format),
) -> Definition(format, a, b) {
  Definition(..definition, widget:)
}

/// Chain additional validation onto the `parse` function.  This is
/// useful if you don't need to change the returned type, but might have
/// additional constraints.  Like say, requiring a `String` to be at least
/// a certain length, or that an Int must be positive.
///
/// ### Example
/// ```gleam
/// field
///   |> validate(fn(i) {
///     case i > 0 {
///       True -> Ok(i)
///       False -> Error("must be positive")
///     }
///   }),
/// ```
pub fn validate(
  def: Definition(format, a, b),
  fun: fn(a) -> Result(a, String),
) -> Definition(format, a, b) {
  Definition(..def, parse: fn(val) { val |> def.parse |> result.try(fun) })
}
