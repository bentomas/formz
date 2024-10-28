import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions
import wisp

pub type Credentials {
  Credentials(username: String, password: String)
}

pub type User {
  User(username: String)
}

pub fn make_form() {
  use username <- formz.with(field("username"), definitions.text_field())
  use password <- formz.with(field("password"), definitions.password_field())

  formz.create_form(Credentials(username, password))
}

pub fn handle_post(formdata: wisp.FormData, form) {
  form
  |> formz.data(formdata.values)
  |> formz.parse_then_try(fn(form, credentials) {
    case credentials {
      Credentials("admin", "l33t") -> Ok(User(credentials.username))
      Credentials("admin", _) ->
        form
        |> formz.update_field("password", field.set_error(_, "Wrong password"))
        |> Error
      Credentials(_, _) ->
        form
        |> formz.update_field("username", field.set_error(_, "Wrong username"))
        |> Error
    }
  })
}
