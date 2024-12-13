import formz
import formz_string/definition

pub fn make_form() {
  use name <- formz.required_field(formz.named("name"), definition.text_field())
  formz.create_form("Hello " <> name)
}
