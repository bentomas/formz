# formz

[![Package Version](https://img.shields.io/hexpm/v/formz)](https://hex.pm/packages/formz)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/formz/)

A Gleam library for parsing and generating accessible HTML forms.

```gleam
import formz/field.{field}
import formz/formz_builder as formz
import formz_string/definitions

pub fn make_form() {
  formz.new()
  |> formz.add(field("username"), definitions.text_field())
  |> formz.add(field("password"), definitions.password_field())
  |> formz.decodes(fn(username) { fn(password) { #(username, password) } })
}
```

See the [main package](https://github.com/bentomas/formz/tree/main/formz) for more details
