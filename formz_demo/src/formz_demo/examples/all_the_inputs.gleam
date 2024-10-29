import formz/definition
import formz/field.{field}
import formz/formz_use as formz
import formz_string/definitions
import formz_string/widgets

pub fn make_form() {
  use a <- formz.with(field("a"), definitions.text_field())
  use b <- formz.with(field("b"), definitions.integer_field())
  use c <- formz.with(field("c"), definitions.number_field())
  use d <- formz.with(field("d"), definitions.boolean_field())
  use e <- formz.with(field("e"), definitions.email_field())
  use f <- formz.with(field("f"), definitions.password_field())
  use g <- formz.with(
    field("g"),
    definitions.choices_field(letters(), placeholder: A),
  )
  use h <- formz.with(field("h"), definitions.list_field(["Dog", "Cat", "Ant"]))
  use i <- formz.with(
    field("i"),
    definitions.text_field()
      |> definition.set_widget(widgets.textarea_widget()),
  )

  formz.create_form(#(a, b, c, d, e, f, g, h, i))
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
