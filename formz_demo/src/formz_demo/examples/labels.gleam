import formz/field.{field}
import formz/formz_use as formz
import formz/input.{input}
import formz/string_generator/fields

pub fn make_form() {
  use name <- formz.with(
    field("name", fields.text_field())
    |> field.set_label("Name"),
  )
  use age <- formz.with(
    field("age", fields.integer_field())
    |> field.set_label("Age"),
  )
  use height <- formz.with(
    field("height", fields.integer_field())
    |> field.set_label("Height (cm)")
    |> field.set_help_text("Please enter your height in centimeters"),
  )

  formz.create_form(#(name, age, height))
}
