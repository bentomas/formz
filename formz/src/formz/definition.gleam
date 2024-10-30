import formz/widget
import gleam/option
import gleam/result

pub type Definition(format, required, optional) {
  Definition(
    widget: widget.Widget(format),
    parse: fn(String) -> Result(required, String),
    stub: required,
    optional_parse: fn(fn(String) -> Result(required, String), String) ->
      Result(optional, String),
    optional_stub: optional,
  )
}

pub fn set_widget(
  definition: Definition(format, a, b),
  widget: widget.Widget(format),
) -> Definition(format, a, b) {
  Definition(..definition, widget:)
}

pub fn validate(
  def: Definition(format, a, b),
  fun: fn(a) -> Result(a, String),
) -> Definition(format, a, b) {
  Definition(..def, parse: fn(val) { val |> def.parse |> result.try(fun) })
}

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
