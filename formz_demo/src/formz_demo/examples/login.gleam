import formz/field.{field}
import formz/formz_use as formz
import formz/input
import formz/string_generator/fields
import formz/string_generator/widgets
import wisp

pub type Credentials {
  Credentials(username: String, password: String)
}

pub type User {
  User(username: String)
}

pub fn make_form() {
  use username <- formz.with(field("username", fields.text_field()))
  use password <- formz.with(
    field("password", fields.text_field())
    |> field.set_widget(widgets.password_widget()),
  )

  formz.create_form(Credentials(username, password))
}

pub fn handle_post(formdata: wisp.FormData, form) {
  use cred, form <- formz.try(form |> formz.data(formdata.values))

  case cred {
    Credentials("admin", "l33t") -> Ok(User(cred.username))
    Credentials("admin", _) ->
      form
      |> formz.update_input("password", input.set_error(_, "wrong password"))
      |> Error
    Credentials(_, _) ->
      form
      |> formz.update_input("username", input.set_error(_, "wrong username"))
      |> Error
  }
}
