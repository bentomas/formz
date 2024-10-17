import formz/field.{field}
import formz/formz_use as formz
import formz_lustre/fields

pub fn make_form() {
  use name <- formz.with(field.full("name", "Name", "", fields.text_field()))
  use age <- formz.with(field.full("age", "Age", "", fields.integer_field()))

  use height <- formz.with(
    field("height", fields.integer_field())
    |> field.set_label("Height (cm)"),
  )

  formz.create_form(#(name, age, height))
}
