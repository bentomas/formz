import formz/field
import formz/formz_use as formz
import formz/string_generator/fields as string_fields
import formz_lustre/fields as lustre_fields
import formz_nakai/fields as nakai_fields

pub fn make_forms() {
  #(
    "import formz
import formz/field.{field}
import formz/string_generator/fields

pub fn hello_world_form() {
  use name <- formz.with(field(\"name\", fields.text_field()))
  formz.create_form(\"Hello \" <> name)
}",
    {
      use name <- formz.with(field.field("name", string_fields.text_field()))
      formz.create_form("Hello " <> name)
    },
    {
      use name <- formz.with(field.field("name", lustre_fields.text_field()))
      formz.create_form("Hello " <> name)
    },
    {
      use name <- formz.with(field.field("name", nakai_fields.text_field()))
      formz.create_form("Hello " <> name)
    },
  )
}
