import formz/field.{field}
import formz/formz_use as formz
import formz/input
import formz/string_generator/fields

pub fn make_form() {
  let choices = [#("Yes", True), #("Maybe", True), #("No", False)]

  use a <- formz.with(field("a", fields.text_field()))
  use b <- formz.with(field("b", fields.integer_field()))
  use c <- formz.with(field("c", fields.number_field()))
  use d <- formz.with(field("d", fields.boolean_field()))
  use e <- formz.with(field("e", fields.email_field()))
  use f <- formz.with(field("f", fields.hidden_field()))
  use g <- formz.with(field("g", fields.enum_field(letters())))
  use h <- formz.with(field("h", fields.list_field(choices)))

  formz.create_form(#(a, b, c, d, e, f, g, h))
}

pub fn handle_get(form) {
  form
  |> formz.update_input("f", input.set_value(_, "hidden"))
}

pub type Alphabet {
  A
  B
  C
  D
  E
  F
  G
  H
  I
  J
  K
  L
  M
  N
  O
  P
  Q
  R
  S
  T
  U
  V
  W
  X
  Y
  Z
}

pub fn letters() {
  [
    #("A", A),
    #("B", B),
    #("C", C),
    #("D", D),
    #("E", E),
    #("F", F),
    #("G", G),
    #("H", H),
    #("I", I),
    #("J", J),
    #("K", K),
    #("L", L),
    #("M", M),
    #("N", N),
    #("O", O),
    #("P", P),
    #("Q", Q),
    #("R", R),
    #("S", S),
    #("T", T),
    #("U", U),
    #("V", V),
    #("W", W),
    #("X", X),
    #("Y", Y),
    #("Z", Z),
  ]
}
