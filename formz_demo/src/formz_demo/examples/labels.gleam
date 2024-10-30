import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions

pub fn make_form() {
  use name <- formz.require(field(named: "name"), is: definitions.text_field())
  use age <- formz.require(
    field("age") |> field.set_label("Age"),
    is: definitions.integer_field(),
  )
  use height <- formz.require(
    field("height")
      |> field.set_label("Height (cm)")
      |> field.set_help_text("Please enter your height in centimeters"),
    is: definitions.integer_field(),
  )

  formz.create_form(#(name, age, height))
}
