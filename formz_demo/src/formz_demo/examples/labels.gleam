import formz/definition
import formz/field.{field}
import formz/formz_use as formz
import formz/validation
import formz_string/definitions as defs

pub fn make_form() {
  use name <- formz.with(field(named: "name"), is: defs.text_field())
  use age <- formz.with(
    field("age") |> field.set_label("Age"),
    is: defs.integer_field(),
  )
  use height <- formz.with(
    field("height")
      |> field.set_label("Height (cm)")
      |> field.set_help_text("Please enter your height in centimeters"),
    is: defs.integer_field(),
  )

  use _something <- formz.with(
    field(named: "something")
      |> field.make_hidden()
      |> field.set_label("Something")
      |> field.set_help_text("Please enter something"),
    is: defs.text_field()
      |> definition.validates(validation.must_be_longer_than(3)),
  )

  formz.create_form(#(name, age, height))
}
