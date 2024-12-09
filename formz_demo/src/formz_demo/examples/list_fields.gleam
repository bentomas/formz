import formz
import formz/field.{field}
import formz_string/definition
import gleam/string

pub fn make_form() {
  use cats <- formz.list(
    field("cats") |> field.set_help_text("Any number of cats"),
    definition.text_field()
      |> formz.verify(fn(value) {
        case string.length(value) > 3 {
          True -> Ok(value)
          _ -> Error("must be longer than 3")
        }
      }),
  )
  use dogs <- formz.limited_list(
    formz.limit_at_least(1),
    field("dogs") |> field.set_help_text("At least 1 dog"),
    definition.text_field(),
  )
  use fish <- formz.limited_list(
    formz.limit_at_most(2),
    field("fish") |> field.set_help_text("At most 2 fish"),
    definition.text_field(),
  )
  use hamsters <- formz.limited_list(
    formz.limit_between(2, 4),
    field("hamsters") |> field.set_help_text("Between 2 and 4 hamsters"),
    definition.text_field(),
  )

  formz.create_form(#(cats, dogs, fish, hamsters))
}
