import formz
import formz/definition
import formz/field.{field}
import formz_string/definitions
import formz_string/widgets

pub fn make_form() {
  use a <- formz.require(field("text"), definitions.text_field())
  use b <- formz.require(field("int"), definitions.integer_field())
  use c <- formz.require(field("number"), definitions.number_field())
  use d <- formz.require(field("bool"), definitions.boolean_field())
  use e <- formz.require(field("email"), definitions.email_field())
  use f <- formz.require(field("password"), definitions.password_field())
  use g <- formz.require(
    field("choices"),
    definitions.choices_field(letters(), stub: A),
  )
  use h <- formz.require(
    field("list"),
    definitions.list_field(["Dog", "Cat", "Ant"]),
  )
  use i <- formz.require(
    field("textarea_widget"),
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
