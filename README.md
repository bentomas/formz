# formz

[![Package Version](https://img.shields.io/hexpm/v/formz)](https://hex.pm/packages/formz)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/formz/)

A Gleam library for parsing and generating accessible HTML forms.

HTML forms rendered in the browser and the data they are parsed into are
intrinsically linked. Treating the markup and the parsing as two separate
problems to solve is inconvenient and leads to bugs. This library aims
to make that link explicit and easy to manage, while making it really easy
to make accessible forms.

Note: This library is not necessarily well-suited for generating one-off
forms, and is intended for use in projects where you have a few forms to
manage, and would like to keep the form markup and parsing logic in sync.  It
takes some amount of effort to make an actual form generator with markup and
styles, and that might not be worth it for a one-off form. That said, a simple
form generator is provided if you aren't opinionated about your markup.

```sh
gleam add formz@0.1
```

## Creating a form

A `formz` form is a list of fields and a decoder function.  You construct the
decoder function as fields are added:

```gleam
import formz
import formz_string/definitions

pub fn make_form() {
  use username <- formz.field(formz.named("username"), definitions.text_field())
  use password <- formz.field(formz.named("password"), definitions.password_field())

  formz.create_form(#(username, password))
}
```

## Creating fields

There are two arguments to adding a field to a form (seen above):

1. A `Config`, which holds specific, unique details about the field: its name,
   label, help text, and disabled state.
2. A `Definition`, which says (A) how to generate the HTML input element for
   the field, and (B) how to parse the data from the field. These definitions
   are reusable and can be shared across fields, forms and projects.

### Field config

```gleam
// name is required, the other confg are optional
formz.named("username")
|> formz.set_label("Username")
|> formz.set_help_text("Only alphanumeric characters are allowed.")
```

```gleam
formz.named("userid") |> formz.make_disabled
```

### Field definition

A `Definition` describes how an input works, e.g. how it looks and how it's
parsed. Definitions are intended to be reusable.

The first role of a `Defintion` is to generate the HTML input for the field.
This library is format-agnostic and you can generate inputs as raw
strings, Lustre elements, Nakai nodes, something else, etc. The second role
of a `Definition` is to parse the raw string data from the input into a
Gleam type.

There are currently three `formz` libraries that provide common field
definitions for the most common HTML inputs:

- [formz_string](https://hexdocs.pm/formz_string/)
- [formz_nakai](https://hexdocs.pm/formz_nakai/)
- [formz_lustre](https://hexdocs.pm/formz_lustre/)

```gleam
/// you won't often need to do this directly (I think??).  The idea is that
/// there'd be libs with the definitions you need.

import formz
import formz/validation
import lustre/attribute
import lustre/element
import lustre/element/html

fn password_widget(
  config: formz.Config,
  state: formz.InputState,
) -> element.Element(msg) {
  html.input([
    attribute.type_("password"),
    attribute.name(config.name),
    attribute.id(config.name),
    attribute.attribute("aria-labelledby", config.label),
  ])
}

pub fn password_field() {
  definition(
    widget: password_widget,
    parse: validation.string,
    // We need to have a stub value for each definition. The stubs are used when
    // building the decoder functions for the form. This is just any value of
    // the same type that the parse function returns.
    stub: "",
  )
}
```



## Generating HTML for a form

Generally speaking, the idea with a `formz` form is that you are not going
to generate the HTML for each field individually, but rather, you'd use
a function to loop through each field, generating semantic, accessible
markup for each one.

The specifics of how you would do this are going to vary greatly for each
project and its styling/markup needs.

However, the three `formz_*` libraries mentioned above all provide a
simple form generator function that you can use as is, or as a starting
point for your own.  `formz` is BYOS, Bring Your Own Stylesheet, so the
built-in form generators come unstyled. If there is interest, I could add
a super simple CSS file to get the ball rolling and make the default
forms easier to use out of the box.

That said, you can also create the form HTML yourself, directly for each field.
There's [an example](https://github.com/bentomas/formz/blob/main/formz_demo/src/formz_demo/examples/custom_output.gleam)
in the demo project showing how to do this.

### Generating form HTML using the `formz_string` library

The built-in form generators leave it as homework to add the form tags and
submit buttons.

```gleam
import formz_string/simple

pub fn show_form(form) -> String {
  "<form method=\"post\">"
  <> simple.generate(form)
  <> "<p><button type\"submit\">Submit</button></p>"
  <> "</form>"
}
```


## Parsing form data

You can parse a `formz` form with a tuple of values and names, typically from
a POST request.  Here we parse in a `wisp` handler:

```gleam
pub fn handle_form_submission(req: Request) -> Response {
  use formdata <- wisp.require_form(req)

  let result = make_form()
  |> formz.data(formdata.values)
  |> formz.parse

  case result {
    Ok(credentials) -> {
      let #(username, password) = credentials
      wisp.ok()
      |> wisp.html_body(string_builder.from_string("Hello "<>username<>"!"))
    }
    Error(form_with_errors) -> {
      show_form(form_with_errors)
    }
  }
}
```

However, often you want to parse a form, and then... you know... act on that
data, and in doing so you might discover more errors for the form.  In this
situation you can use `decode_then_try`:

```gleam
pub fn handle_form_submission(req: Request) -> Response {
  use formdata <- wisp.require_form(req)

  let result = make_form()
  |> formz.data(formdata.values)
  |> formz.decode_then_try(fn(form, credentials) {
    case credentials {
      #("admin" as username, "l33t") -> Ok(username)
      #("admin", _) ->
        Error(form |> formz.field_error("password", "Wrong password"))
      _ ->
        Error(form |> formz.field_error("username", "Unknown username"))
    }
  })

  case result {
    Ok(username) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string("Hello " <> username <> "!"))
    }
    Error(form_with_errors) -> {
      show_form(form_with_errors)
    }
  }
}
```

## See it in action

There is a [demo wisp app](https://github.com/bentomas/formz/tree/main/formz_demo)
showing a few interactive examples of how `formz` works in the repo.
