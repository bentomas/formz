# formz

[![Package Version](https://img.shields.io/hexpm/v/formz)](https://hex.pm/packages/formz)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/formz/)

A Gleam library for parsing and generating accessible HTML forms.

HTML forms rendered in the browser and the data they are parsed into are
intrinsically linked. Treating the markup and the parsing as two separate
problems to solve is inconvenient and leads to bugs. This library aims
to make that link explicit and easy to manage, while making it really easy
to make accessible forms.

```sh
gleam add formz@0.1
```

## Creating a form

A `formz` form is a list of fields and a decoder function.

> **Note:** This library currently has two non-interoperable ways to define forms,
one using the builder pattern, and one using a series of `use` calls like with
the [toy](https://hexdocs.pm/toy/) or [decode/zero](https://hexdocs.pm/decode/)
packages.  After gathering some feedback, only one of them will be kept and this
library will be moved do version 1.0.0.

### builder pattern

With the builder pattern, you add the fields and then explicitly specify the
decoder function...

```gleam
import formz/field.{field}
import formz/formz_builder as formz
import formz_string/definitions

pub fn make_form() {
  formz.decodes(fn(username) {fn(password) { #(username, password) } })
  |> formz.require(field("username"), definitions.text_field())
  |> formz.require(field("password"), definitions.password_field())
}
```

### `use`/callbacks pattern

With the `use`/callbakcks pattern, you create the decoder function as you add
the fields...

```gleam
import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions

pub fn make_form() {
  use username <- formz.require(field("username"), definitions.text_field())
  use password <- formz.require(field("password"), definitions.password_field())

  formz.create_form(#(username, password))
}
```

## Creating fields

There are two arguments to adding a field to a form (seen above):

1. A [Field](https://hexdocs.pm/formz/formz/field.html), which holds specific,
   unique details about the field, such as its name, label, help text, disabled
   state, etc.
2. A [Definition](https://hexdocs.pm/formz/formz/definition.html), which
   says (A) how to generate the HTML input element for the field, and (B) how
   to parse the data from the field. These definitions are reusable and can be
   shared across fields, forms and projects.

### Field details

```gleam
// name is required, the other details are optional
field(named: "username")
|> field.set_label("Username")
|> field.set_help_text("Only alphanumeric characters are allowed.")
```

```gleam
field(named: "userid") |> field.make_hidden |> field.set_raw_value("42")
```

### Field definition

[Defintions](https://hexdocs.pm/formz/formz/definition.html) are the heavy
compared to the lightness of fields; they take a bit more work to make as they
are intended to be more reusable.

The first role of a `Defintion` is to generate the HTML widget for the field.
This library is format-agnostic and you can generate HTML widgets as raw
strings, Lustre elements, Nakai nodes, something else, etc. There are
currently three `formz` libraries that provide common field definitions for the
most common HTML formats.

- [formz_string](https://hexdocs.pm/formz_string/)
- [formz_nakai](https://hexdocs.pm/formz_nakai/)
- [formz_lustre](https://hexdocs.pm/formz_lustre/) (untested in a browser,
  would it be useful there??)

The second role  of a `Definition` is to parse the data from the field. There
are a two parts to this, as how you parse a field's value depends on if it is
optional or required.  Not all scenarios can be cookie-cutter placed into an
`Option`. So you need to provide two parse functions, one for when a field is
required, and a second for when it's optional.

```gleam
/// you won't often need to do this directly (I think??).  The idea is that
/// there'd be libs with the definitions you need.

import formz/definition.{Definition}
import formz/field
import formz/validation
import formz/widget
import lustre/attribute
import lustre/element
import lustre/element/html

fn password_widget(
  field: field.Field,
  args: widget.Args,
) -> element.Element(msg) {
  html.input([
    attribute.type_("password"),
    attribute.name(field.name),
    attribute.id(args.id),
    attribute.attribute("aria-labelledby", field.label),
  ])
}

pub fn password_field() {
  Definition(
    widget: password_widget,
    parse: validation.string,
    optional_parse: fn(parse, str) {
      case str {
        "" -> Ok(option.None)
        _ -> parse(str)
      }
    },
    // We need to have a stub value for each parser. The stubs are used when
    // building the decoder and parse functions for the form.
    stub: "",
    optional_stub: option.None,
  )
}
```



## Generating HTML for a form

Generally speaking, the idea with a `formz` form is that you are not going
to generate the HTML for each field individually, but rather, you'd use
a function to loop through each field, generating semantic, accessible
markup for each one.

The specifics of how you would do this are going
to vary greatly for each project and its styling/markup needs.

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
  <> simple.generate_form(form)
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
situation you can use `parse_then_try`:

```gleam
pub fn handle_form_submission(req: Request) -> Response {
  use formdata <- wisp.require_form(req)

  let result = make_form()
  |> formz.data(formdata.values)
  |> formz.parse_then_try(fn(form, credentials) {
    case credentials {
      #("admin" as username, "l33t") -> Ok(username)
      #("admin", _) ->
        form
        |> formz.update_field("password", field.set_error(_, "Wrong password"))
        |> Error
      _ ->
        form
        |> formz.update_field("username", field.set_error(_, "Unknown username"))
        |> Error
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
