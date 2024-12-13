import formz.{named}
import formz_string/definition
import wisp

pub type Credentials {
  Credentials(username: String, password: String)
}

pub type User {
  User(username: String)
}

pub fn make_form() {
  use username <- formz.required_field(
    named("username"),
    definition.text_field(),
  )
  use password <- formz.required_field(
    named("password"),
    definition.password_field(),
  )

  formz.create_form(Credentials(username, password))
}

pub fn handle_post(formdata: wisp.FormData, form) {
  form
  |> formz.data(formdata.values)
  |> formz.decode_then_try(fn(form, credentials) {
    case credentials {
      Credentials("admin", "l33t") -> Ok(User(credentials.username))
      Credentials("admin", _) ->
        form
        |> formz.field_error("password", "Wrong password")
        |> Error
      Credentials(_, _) ->
        form
        |> formz.field_error("username", "Wrong username")
        |> Error
    }
  })
}
