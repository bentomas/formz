import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions

pub fn make_form() {
  use name <- formz.with(field(named: "name"), is: definitions.text_field())
  use age <- formz.with(
    field("age") |> field.set_label("Age"),
    is: definitions.integer_field(),
  )
  use height <- formz.with(
    field("height")
      |> field.set_label("Height (cm)")
      |> field.set_help_text("Please enter your height in centimeters"),
    is: definitions.integer_field(),
  )

  formz.create_form(#(name, age, height))
}
