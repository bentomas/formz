import formz
import formz_string/definition

pub fn make_form() {
  use name <- formz.required_field(formz.named("name"), definition.text_field())
  use age <- formz.required_field(
    formz.named("age")
      |> formz.set_label("Age")
      |> formz.set_help_text("Please enter your age"),
    definition.integer_field(),
  )
  use height <- formz.required_field(
    formz.named("height")
      |> formz.set_label("Height (cm)")
      |> formz.set_help_text("Please enter your height in centimeters"),
    definition.integer_field(),
  )

  formz.create_form(#(name, age, height))
}
