import formz
import formz/field.{field}
import formz_string/definitions

pub fn make_form() {
  use name <- formz.require(field("name"), definitions.text_field())
  formz.create_form("Hello " <> name)
}
