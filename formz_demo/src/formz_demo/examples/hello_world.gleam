import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions

pub fn make_form() {
  use name <- formz.with(field("name"), definitions.text_field())
  formz.create_form("Hello " <> name)
}
