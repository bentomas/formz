import formz
import formz/field.{field}
import formz_string/definitions
import formz_string/widgets

pub fn make_form() {
  use id1 <- formz.require(
    field("id_1"),
    definitions.make_hidden(definitions.integer_field()),
  )
  use id2 <- formz.require(
    field("id_2"),
    definitions.integer_field() |> definitions.make_hidden,
  )
  use id3 <- formz.require(
    field("id_3"),
    definitions.integer_field() |> formz.widget(widgets.hidden_widget()),
  )
  formz.create_form(#(id1, id2, id3))
}

pub fn handle_get(
  form: formz.Form(format, output),
) -> formz.Form(format, output) {
  form |> formz.data([#("id_1", "1"), #("id_2", "2"), #("id_3", "3")])
}
