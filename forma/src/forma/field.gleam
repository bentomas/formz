import forma.{type Field, type Input, Field, Input}
import forma/validation
import forma/widget
import justin

pub fn text_field() -> Input(String, String) {
  Input(widget.text_input, validation.string)
}

pub fn email_field() -> Input(String, String) {
  Input(widget.text_input, validation.email)
}

pub fn integer_field() -> Input(Int, String) {
  Input(widget.text_input, validation.trim |> validation.and(validation.int))
}

pub fn new(
  name: String,
  input: Input(output, format),
) -> #(Field(format), fn(String) -> Result(output, String)) {
  #(
    Field(name, justin.sentence_case(name), "", input.render, ""),
    input.validate,
  )
}

pub fn help_text(
  thing: #(Field(format), fn(String) -> Result(b, String)),
  help_text: String,
) -> #(Field(format), fn(String) -> Result(b, String)) {
  let #(field, validate) = thing

  let field =
    Field(field.name, field.label, help_text, field.render, field.value)

  #(field, validate)
}

pub fn validate(
  thing: #(Field(format), fn(String) -> Result(b, String)),
  next: fn(b) -> Result(c, String),
) -> #(Field(format), fn(String) -> Result(c, String)) {
  let #(field, previous) = thing

  #(field, fn(str) {
    case previous(str) {
      Ok(value) -> next(value)
      Error(error) -> Error(error)
    }
  })
}
