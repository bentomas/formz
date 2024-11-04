# formz

[![Package Version](https://img.shields.io/hexpm/v/formz)](https://hex.pm/packages/formz)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/formz/)

A Gleam library for parsing and generating accessible HTML forms.

```gleam
import formz/field.{field}
import formz/formz_builder as formz
import formz_string/definitions

pub fn make_form() {
  formz.decodes(fn(username) { fn(password) { #(username, password) } })
  |> formz.require(field("username"), definitions.text_field())
  |> formz.require(field("password"), definitions.password_field())
}
```

See the [main package](https://github.com/bentomas/formz/tree/main/formz) for more details
