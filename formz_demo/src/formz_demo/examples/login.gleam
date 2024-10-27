import formz/definition
import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions
import formz_string/widgets
import wisp

pub type Credentials {
  Credentials(username: String, password: String)
}

pub type User {
  User(username: String)
}

pub fn make_form() {
  use username <- formz.with(field("username"), definitions.text_field())
  use password <- formz.with(
    field("password"),
    definitions.text_field() |> definition.set_widget(widgets.password_widget()),
  )

  formz.create_form(Credentials(username, password))
}

pub fn handle_post(formdata: wisp.FormData, form) {
  use cred, form <- formz.parse_try(form |> formz.data(formdata.values))

  case cred {
    Credentials("admin", "l33t") -> Ok(User(cred.username))
    Credentials("admin", _) ->
      form
      |> formz.update_field("password", field.set_error(_, "wrong password"))
      |> Error
    Credentials(_, _) ->
      form
      |> formz.update_field("username", field.set_error(_, "wrong username"))
      |> Error
  }
}
