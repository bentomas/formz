import formz/field.{field}
import formz/formz_use as formz
import formz/string_generator/fields
import formz_demo/examples/example_2/types

pub fn make_form() {
  use a <- formz.with(field("a", fields.text_field()))
  use b <- formz.with(field("b", fields.integer_field()))
  use c <- formz.with(field("c", fields.number_field()))
  use d <- formz.with(field("d", fields.boolean_field()))
  use e <- formz.with(field("e", fields.email_field()))
  use f <- formz.with(field("f", fields.enum_field(letters())))
  use g <- formz.with(field("g", fields.list_field(choices())))

  formz.create_form(#(a, b, c, d, e, f, g))
}

fn letters() {
  [
    #("A", types.A),
    #("B", types.B),
    #("C", types.C),
    #("D", types.D),
    #("E", types.E),
    #("F", types.F),
    #("G", types.G),
    #("H", types.H),
    #("I", types.I),
    #("J", types.J),
    #("K", types.K),
    #("L", types.L),
    #("M", types.M),
    #("N", types.N),
    #("O", types.O),
    #("P", types.P),
    #("Q", types.Q),
    #("R", types.R),
    #("S", types.S),
    #("T", types.T),
    #("U", types.U),
    #("V", types.V),
    #("W", types.W),
    #("X", types.X),
    #("Y", types.Y),
    #("Z", types.Z),
  ]
}

fn choices() {
  [#("Yes", True), #("Maybe", True), #("No", False)]
}
