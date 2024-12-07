import formz
import formz/field.{field}
import formz_string/definitions
import wisp

pub type Credentials {
  Credentials(username: String, password: String)
}

pub type User {
  User(username: String)
}

pub fn make_form() {
  use username <- formz.require(field("username"), definitions.text_field())
  use password <- formz.require(field("password"), definitions.password_field())

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
        |> formz.set_field_error("password", "Wrong password")
        |> Error
      Credentials(_, _) ->
        form
        |> formz.set_field_error("username", "Wrong username")
        |> Error
    }
  })
}
