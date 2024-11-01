import formz.{Field} as _
import formz/field.{field}
import formz/formz_use as formz
import formz/widget
import formz_lustre/definitions
import lustre/attribute
import lustre/element/html

pub fn make_form() {
  use username <- formz.require(field("username"), definitions.text_field())
  use password <- formz.require(field("password"), definitions.password_field())

  formz.create_form(#(username, password))
}

pub fn format_form(form) {
  let assert Ok(Field(username_field, username_widget)) =
    formz.get(form, "username")

  let assert Ok(Field(password_field, password_widget)) =
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
            widget.args(widget.LabelledByLabelFor) |> widget.id("username"),
          ),
        ]),
        html.li([], [
          html.label([attribute.for("password")], [html.text("Password")]),
          password_widget(
            password_field,
            widget.args(widget.LabelledByLabelFor) |> widget.id("password"),
          ),
        ]),
      ]),
    ],
  )
}
