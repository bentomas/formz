import formz
import formz/field.{field}
import formz_string/definition
import formz_string/widget

pub fn make_form() {
  use a <- formz.require(field("text"), definition.text_field())
  use b <- formz.require(field("int"), definition.integer_field())
  use c <- formz.require(field("number"), definition.number_field())
  use d <- formz.require(field("bool"), definition.boolean_field())
  use e <- formz.require(field("email"), definition.email_field())
  use f <- formz.require(field("password"), definition.password_field())
  use g <- formz.require(
    field("choices"),
    definition.choices_field(letters(), stub: A),
  )
  use h <- formz.require(
    field("list"),
    definition.list_field(["Dog", "Cat", "Ant"]),
  )
  use i <- formz.require(
    field("textarea_widget"),
    definition.text_field()
      |> formz.widget(widget.textarea_widget()),
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
