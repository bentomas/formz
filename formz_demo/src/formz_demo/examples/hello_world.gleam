import formz/field.{field}
import formz/formz_use as formz
import formz_string/fields

pub fn make_form() {
  use name <- formz.with(field("name", fields.text_field()))
  formz.create_form("Hello " <> name)
}
