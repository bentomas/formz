import formz
import formz/field.{field}
import formz_string/definition

pub fn make_form() {
  use name <- formz.require(field("name"), definition.text_field())
  formz.create_form("Hello " <> name)
}
