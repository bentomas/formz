import formz/field.{field}
import formz/formz_use as formz
import formz_nakai/fields

pub fn make_form() {
  use a <- formz.with(field("a", fields.text_field()))
  use b <- formz.with(field("b", fields.integer_field()))
  use c <- formz.with(field("c", fields.number_field()))
  use d <- formz.with(field("d", fields.boolean_field()))
  use e <- formz.with(field("e", fields.email_field()))

  formz.create_form(#(a, b, c, d, e))
}
