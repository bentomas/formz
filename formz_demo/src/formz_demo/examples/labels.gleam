import formz/definition as d
import formz/field.{field}
import formz/formz_use as formz
import formz/validation
import formz_string/fields

pub fn make_form() {
  use name <- formz.with(field(named: "name"), fields.text_field())
  use age <- formz.with(
    field("age") |> field.set_label("Age"),
    fields.integer_field(),
  )
  use height <- formz.with(
    field("height")
      |> field.set_label("Height (cm)")
      |> field.set_help_text("Please enter your height in centimeters"),
    fields.integer_field(),
  )

  // use something <- formz.with(
  //   field(named: "something")
  //     |> field.make_hidden()
  //     |> field.set_label("Something")
  //     |> field.set_help_text("Please enter something"),
  //   fields.text_field()
  //     |> d.validates(validation.must_be_longer_than(3)),
  // )

  formz.create_form(#(name, age, height))
}
