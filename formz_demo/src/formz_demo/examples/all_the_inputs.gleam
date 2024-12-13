import formz
import formz_string/definition
import formz_string/widget

pub fn make_form() {
  use a <- formz.field(formz.named("text"), definition.text_field())
  use b <- formz.field(formz.named("int"), definition.integer_field())
  use c <- formz.field(formz.named("number"), definition.number_field())
  use d <- formz.field(formz.named("bool"), definition.boolean_field())
  use e <- formz.field(formz.named("email"), definition.email_field())
  use f <- formz.field(formz.named("password"), definition.password_field())
  use g <- formz.field(
    formz.named("choices"),
    definition.choices_field(letters(), A),
  )
  use h <- formz.field(
    formz.named("list"),
    definition.list_field(["Dog", "Cat", "Ant"]),
  )
  use i <- formz.field(
    formz.named("textarea_widget"),
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
