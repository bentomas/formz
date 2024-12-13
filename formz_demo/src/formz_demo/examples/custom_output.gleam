import formz.{Field}
import formz_lustre/definition
import formz_lustre/widget
import lustre/attribute
import lustre/element/html

pub fn make_form() {
  use username <- formz.required_field(
    formz.named("username"),
    definition.text_field(),
  )
  use password <- formz.required_field(
    formz.named("password"),
    definition.password_field(),
  )

  formz.create_form(#(username, password))
}

pub fn format_form(form) {
  let assert Ok(Field(
    username_field,
    username_state,
    widget.Widget(username_widget),
  )) = formz.get(form, "username")

  let assert Ok(Field(
    password_field,
    password_state,
    widget.Widget(password_widget),
  )) = formz.get(form, "password")

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
            username_state,
            widget.Args(
              "username",
              widget.LabelledByLabelElement,
              widget.DescribedByNone,
            ),
          ),
        ]),
        html.li([], [
          html.label([attribute.for("password")], [html.text("Password")]),
          password_widget(
            password_field,
            password_state,
            widget.Args(
              "username",
              widget.LabelledByLabelElement,
              widget.DescribedByNone,
            ),
          ),
        ]),
      ]),
    ],
  )
}
