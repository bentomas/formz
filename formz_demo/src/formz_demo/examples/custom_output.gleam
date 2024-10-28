import formz/field.{field}
import formz/formz_use as formz
import formz/widget
import formz_lustre/definitions
import lustre/attribute
import lustre/element/html

pub fn make_form() {
  use username <- formz.with(field("username"), definitions.text_field())
  use password <- formz.with(field("password"), definitions.password_field())

  formz.create_form(#(username, password))
}

pub fn format_form(form) {
  let assert Ok(formz.Element(username_field, username_widget)) =
    formz.get(form, "username")

  let assert Ok(formz.Element(password_field, password_widget)) =
    formz.get(form, "password")

  html.div(
    [
      attribute.role("group"),
      attribute.attribute("aria-labelledby", "h2"),
      attribute.disabled(True),
    ],
    [
      html.h2([attribute.id("h2")], [html.text("Login Form")]),
      html.ul([], [
        html.li([], [
          html.label([attribute.for("username")], [html.text("Username")]),
          username_widget(
            username_field,
            widget.Args(
              "username",
              widget.LabelledByLabelFor,
              widget.DescribedByNone,
            ),
          ),
        ]),
        html.li([], [
          html.label([attribute.for("password")], [html.text("Password")]),
          password_widget(
            password_field,
            widget.Args(
              "password",
              widget.LabelledByLabelFor,
              widget.DescribedByNone,
            ),
          ),
        ]),
      ]),
    ],
  )
}
