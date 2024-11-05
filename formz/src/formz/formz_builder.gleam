//// This module is used to construct a form using the builder pattern.
//// A form is a list of fields and a decoder function.
////
//// ### Examples
////
//// ```gleam
//// decodes(fn(field) { field })
//// |> require(field("name"), defintions.text_field())
//// |> data([#("name", "Louis"))])
//// |> parse
//// # -> Ok("Louis")
//// ```
////
//// ```gleam
//// new()
//// |> optional(field("greeting"), defintions.text_field())
//// |> optional(field("name"), defintions.text_field())
//// |> data([#("greeting", "Hello"), #("name", "World")])
//// |> set_decoder(fn(greeting) { fn(name) { greeting <> " " <> name } })
//// |> parse
//// # -> Ok("Hello World")
//// ```

import formz.{type FormItem, Field, SubForm}
import formz/definition.{type Definition, Definition}
import formz/field
import formz/subform
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

/// A phantom type used to tag a form as having a decoder.
pub type HasDecoder

/// A phantom type used to tag a form as not having a decoder.
pub type NoDecoder

pub opaque type Form(widget, output, decoder, has_decoder) {
  Form(
    items: List(FormItem(widget)),
    parse_with: fn(List(FormItem(widget)), decoder) ->
      Result(output, List(FormItem(widget))),
    decoder: Option(decoder),
  )
}

/// Create a new empty form with no fields that a decoder will have to be added
/// to in order to parse it.
///
/// ### Example
///
/// ```gleam
/// new()
/// |> set_decoder(1)
/// |> parse
/// # -> Ok(1)
/// ```
pub fn new() -> Form(widget, thing, thing, NoDecoder) {
  Form([], fn(_, output) { Ok(output) }, None)
}

/// Create a new empty form with no fields that uses the provided decoder when
/// parsing to provide the final value of a valid form.
///
/// A decoder is required in order to parse a form, though you can use `new()`
/// to create a form without one, to be added later.
///
/// The type signature of the decoder must match the types of the
/// definitions of the fields added to the form.  If one field has been added,
/// then the decoder needs to be a function that returns a value.  If 15 fields
/// have been added, then the decoder needs to be a function that returns a
/// function that returns a function and so on, until 15 functions have been
/// called to return the final value.
///
/// ### Example
///
/// ```gleam
/// decodes(1)
/// |> parse
/// # -> Ok(1)
/// ```
/// ```gleam
/// decodes(fn(field) { field })
/// |> require(field("name"), defintions.text_field())
/// |> data([#("name", "Louis"))])
/// |> parse
/// # -> Ok("Louis")
/// ```
/// ```gleam
/// decodes(fn(greeting) { fn(name) { greeting <> " " <> name } })
/// |> optional(field("greeting"), defintions.text_field())
/// |> optional(field("name"), defintions.text_field())
/// |> data([#("greeting", "Hello"), #("name", "World")])
/// |> parse
/// # -> Ok("Hello World")
/// ```
pub fn decodes(decoder: thing) -> Form(widget, thing, thing, HasDecoder) {
  new() |> set_decoder(decoder)
}

fn add(
  previous_form: Form(
    widget,
    fn(decoder_step_input) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  widget: widget,
  parse_field: fn(String) -> Result(decoder_step_input, String),
) -> Form(widget, decoder_step_output, form_output, has_decoder) {
  let updated_items = [Field(field, widget), ..previous_form.items]

  let parse_with = fn(items, decoder: form_output) {
    // can do let assert because we know there's at least one field since
    // we just added one
    let assert Ok(#(Field(field, widget), rest)) = pop_field(items)

    let previous_form_output = previous_form.parse_with(rest, decoder)
    let input_output = parse_field(field.value)

    case previous_form_output, input_output {
      // the form we've already parsed has no errors and the field
      // we just parsed has no errors.  each intermediary step of a form
      // is a part of a decoder, so since we successfully parsed this form,
      // we can call the successful decoder that it returned.
      Ok(previous_decoder), Ok(value) -> Ok(previous_decoder(value))

      // the form already has errors even though this one succeeded.
      // so add this to the list and stop anymore parsing
      Error(items), Ok(_value) -> Error([Field(field, widget), ..items])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        field
        |> field.set_error(error)
        |> Field(widget)
        |> list.prepend(rest, _)
        |> Error

      // form already has errors and this field errored, so add this field
      // to the list
      Error(items), Error(error) ->
        field
        |> field.set_error(error)
        |> Field(widget)
        |> list.prepend(items, _)
        |> Error
    }
  }

  Form(items: updated_items, parse_with:, decoder: previous_form.decoder)
}

/// Add an optional field to a form.
///
/// This will use both the `parse` and `optional_parse` functions from the
/// definition to parse the input data when parsing this field.
pub fn optional(
  previous_form: Form(
    widget,
    fn(decoder_step_input) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  definition: Definition(widget, _, decoder_step_input),
) -> Form(widget, decoder_step_output, form_output, has_decoder) {
  add(
    previous_form,
    field |> field.set_required(False),
    definition.widget,
    definition.optional_parse(definition.parse, _),
  )
}

/// Add a required field to a form.
///
/// This will use only the `parse` function from the definition to parse the
/// input data when parsing this field. Ultimately whether a field is actually
/// required or not comes down to the details of the definition.
///
/// This will also set the `required` value on the field to `True`.  Form
/// generators can use this to mark the HTML input elements as required for
/// accessibility.
pub fn require(
  previous_form: Form(
    widget,
    fn(field_output) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  definition: Definition(widget, field_output, _),
) -> Form(widget, decoder_step_output, form_output, has_decoder) {
  add(
    previous_form,
    field |> field.set_required(True),
    definition.widget,
    definition.parse,
  )
}

/// Add a form as a subform.  This will essentially append the fields from the
/// subform to the current form, prefixing their names with the name of the
/// subform.  Form generators will still see the fields as a set though, so they
/// can be marked up as a group for accessibility reasons.
pub fn subform(
  previous_form: Form(
    widget,
    fn(sub_output) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  details: subform.SubForm,
  sub: Form(widget, sub_output, sub_decoder, HasDecoder),
) -> Form(widget, decoder_step_output, form_output, has_decoder) {
  let sub_items =
    sub.items
    |> update_fields(fn(field) {
      field |> field.set_name(details.name <> "." <> field.name)
    })

  let updated_items = [SubForm(details, sub_items), ..previous_form.items]

  let parse_with = fn(items, decoder: form_output) {
    // can do let assert because we know there's at least one field since
    // we just added one
    let assert Ok(#(SubForm(details, sub_items), rest)) = pop_field(items)

    let assert Form(_, sub_parse_with, Some(sub_decoder)) = sub
    let form_output = sub_parse_with(sub_items, sub_decoder)

    let previous_form_output = previous_form.parse_with(rest, decoder)
    case previous_form_output, form_output {
      // everything is good!  pass along the output
      Ok(next), Ok(value) -> Ok(next(value))

      // form has errors, but this sub form was good, so add it to the list
      // of items as is.
      Error(items), Ok(_value) -> Error([SubForm(details, items), ..items])

      // form was good so far, but this sub form errored, so need to
      // hop on error track
      Ok(_), Error(error_fields) ->
        Error([SubForm(details, error_fields), ..rest])

      // form already has errors and this form errored, so add this field
      // to the list of errors
      Error(fields), Error(error_fields) ->
        Error(list.prepend(fields, SubForm(details, error_fields)))
    }
  }
  Form(items: updated_items, parse_with:, decoder: previous_form.decoder)
}

fn pop_field(
  items: List(FormItem(widget)),
) -> Result(#(FormItem(widget), List(FormItem(widget))), Nil) {
  case items {
    [] -> Error(Nil)
    [only] -> Ok(#(only, []))
    [Field(..) as item, ..rest] -> Ok(#(item, rest))
    [SubForm(_, []), ..rest] -> pop_field(rest)
    [SubForm(s, [first, ..rest_1]), ..rest_2] ->
      pop_field(list.flatten([[first], [SubForm(s, rest_1)], rest_2]))
  }
}

@internal
pub fn get_fields(
  form: Form(widget, output, decoder, has_decoder),
) -> List(field.Field) {
  form.items |> do_get_fields
}

fn do_get_fields(items: List(FormItem(widget))) -> List(field.Field) {
  list.fold(items, [], fn(acc, item) {
    case item {
      Field(f, _) -> [f, ..acc]
      SubForm(_, sub_items) -> list.flatten([do_get_fields(sub_items), acc])
    }
  })
}

fn update_fields(
  items: List(FormItem(widget)),
  fun: fn(field.Field) -> field.Field,
) -> List(FormItem(widget)) {
  list.map(items, fn(item) {
    case item {
      Field(field, widget) -> Field(fun(field), widget)
      SubForm(s, items) -> SubForm(s, update_fields(items, fun))
    }
  })
}

/// Add input data to this form. This will set the raw string value of the fields.
/// It does not trigger any parsing, so you can also use this to set default values
/// (if you do it in your form generator function) or initial values (if you do it
/// before rendering an empty form).
pub fn data(
  form: Form(widget, output, decoder, has_decoder),
  input_data: List(#(String, String)),
) -> Form(widget, output, decoder, has_decoder) {
  let data = dict.from_list(input_data)
  let Form(items, parse, decoder) = form
  items
  |> update_fields(fn(field) {
    case dict.get(data, field.name) {
      Ok(value) -> field.set_raw_value(field, value)
      Error(_) -> field
    }
  })
  |> Form(parse, decoder)
}

/// Replace or set the decoder for the form.  A decoder is required in order to
/// parse a form.  The type signature of the decoder must match the types of the
/// definitions of the fields added to the form.  If one field has been added,
/// then the decoder needs to be a function that returns a value.  If 15 fields
/// have been added, then the decoder needs to be a function that returns a
/// function that returns a function and so on, until 15 functions have been
/// called to return the final value.
pub fn set_decoder(
  form: Form(widget, output, decoder, has_decoder),
  decoder: decoder,
) -> Form(widget, output, decoder, HasDecoder) {
  let Form(fields, parse_with, _) = form
  Form(fields, parse_with, Some(decoder))
}

/// Parse the form.  This means step through the fields one by one, parsing
/// them individually.  If any field fails to parse, the whole form is considered
/// invalid, however it will still continue parsing the rest of the fields to
/// collect all errors.  This is useful for showing all errors at once.  If no
/// fields fail to parse, the decoded value is returned, which is the value given
/// to `create_form`.
///
/// If you'd like to parse the form but not get the output, so you can give
/// feedback to a user in response to input, you can use `validate` or `validate_all`.
pub fn parse(
  form: Form(widget, output, decoder, HasDecoder),
) -> Result(output, Form(widget, output, decoder, HasDecoder)) {
  // we've tagged that we have a decoder with our has_decoder phantom type
  // so we can get away with let assert here
  let assert Form(items, parse_with, Some(decoder)) = form
  case parse_with(items, decoder) {
    Ok(output) -> Ok(output)
    Error(items) -> Error(Form(items, parse_with, Some(decoder)))
  }
}

/// Parse the form, then apply a function to the output if it was successful.
/// This is a very thin wrapper around `parse` and `result.try`, but the
/// difference being it will pass the form along to the function as the
/// successful result.  This allows you to easily update the form fields with
/// errors or other information based on the output.
///
/// This is useful for situations where you can have errors in the form that
/// aren't easily checked in simple parsing functions.  Like, say, hitting a
/// db to check if a username is taken.
///
/// ```gleam
/// make_form()
/// |> data(form_data)
/// |> parse_then_try(fn(username, form) {
///   case is_username_taken(username) {
///     Ok(false) -> Ok(form)
///     Ok(true) -> update_field(form, "username", field.set_error(_, "Username is taken"))
///   }
/// }
pub fn parse_then_try(
  form: Form(widget, output, decoder, HasDecoder),
  apply fun: fn(Form(widget, output, decoder, HasDecoder), output) ->
    Result(c, Form(widget, output, decoder, HasDecoder)),
) -> Result(c, Form(widget, output, decoder, HasDecoder)) {
  parse(form) |> result.try(fun(form, _))
}

/// Validate specific fields of the form.  This is similar to `parse`, but
/// instead of returning the decoded output if there are no errors, it returns
/// the valid form.  This is useful for if you want to be able to give feedback
/// to the user about whether certain fields are valid or not. In this case you
/// could just validate only fields that the user has interacted with.
pub fn validate(
  form: Form(widget, output, decoder, HasDecoder),
  names: List(String),
) -> Form(widget, output, decoder, HasDecoder) {
  case parse(form) {
    Ok(_) -> form
    Error(f) -> {
      let items =
        update_fields(f.items, fn(field) {
          case list.find(names, fn(name) { field.name == name }) {
            Ok(_) -> field
            Error(_) ->
              case get(form, field.name) {
                Ok(Field(f, _)) -> f
                _ -> field
              }
          }
        })
      Form(..form, items:)
    }
  }
}

/// Validate all the fields in the form.  This is similar to `parse`, but
/// instead of returning the decoded output if there are no errors, it returns
/// the valid form.  This is useful for if you want to be able to give feedback
/// to the user about whether certain fields are valid or not.
pub fn validate_all(
  form: Form(widget, output, decoder, HasDecoder),
) -> Form(widget, output, decoder, HasDecoder) {
  let names =
    form
    |> get_fields()
    |> list.map(fn(f) { f.name })

  validate(form, names)
}

/// Get each [`FormItem`](https://hexdocs.pm/formz/formz.html#FormItem) added
/// to the form.  Any time a field or subform are added, a FormItem is created.
pub fn items(form: Form(widget, a, b, has_decoder)) -> List(FormItem(widget)) {
  form.items |> list.reverse
}

/// Get the [`FormItem`](https://hexdocs.pm/formz/formz.html#FormItem) with the
/// given name.  If multiple items have the same name, the first one is returned.
pub fn get(
  form: Form(widget, output, decoder, has_decoder),
  name: String,
) -> Result(FormItem(widget), Nil) {
  form.items
  |> list.filter(fn(item) {
    case item {
      Field(i, _) if i.name == name -> True
      SubForm(s, _) if s.name == name -> True
      _ -> False
    }
  })
  |> list.first
}

/// Update the [`FormItem`](https://hexdocs.pm/formz/formz.html#FormItem) with
/// the given name using the provided function.  If multiple items have the same
/// name, it will be called on all of them.
pub fn update(
  form: Form(widget, output, decoder, has_decoder),
  name: String,
  fun: fn(FormItem(widget)) -> FormItem(widget),
) {
  form.items
  |> do_formitem_update(name, fun)
  |> Form(form.parse_with, form.decoder)
}

fn do_formitem_update(
  items: List(FormItem(widget)),
  name: String,
  fun: fn(FormItem(widget)) -> FormItem(widget),
) -> List(FormItem(widget)) {
  items
  |> list.map(fn(item) {
    case item {
      Field(i, _) if i.name == name -> fun(item)
      SubForm(s, _) if s.name == name -> fun(item)
      SubForm(s, items) -> SubForm(s, do_formitem_update(items, name, fun))
      _ -> item
    }
  })
}

/// Update the [`Field`](https://hexdocs.pm/formz/formz/field.html) with
/// the given name using the provided function.  If multiple fields have the same
/// name, it will be called on all of them.
///
/// ```gleam
/// let form = make_form()
/// update(form, "name", field.set_label(_, "Full Name"))
/// ```
pub fn update_field(
  form: Form(widget, output, decoder, has_decoder),
  name: String,
  fun: fn(field.Field) -> field.Field,
) -> Form(widget, output, decoder, has_decoder) {
  update(form, name, fn(item) {
    case item {
      Field(field, widget) -> Field(fun(field), widget)
      _ -> item
    }
  })
}

/// Update the [`SubForm`](https://hexdocs.pm/formz/formz/subform.html) with
/// the given name using the provided function.  If multiple subforms have the same
/// name, it will be called on all of them.
///
/// ```gleam
/// let form = make_form()
/// update(form, "name", subform.set_help_text(_, "..."))
/// ```
pub fn update_subform(
  form: Form(widget, output, decoder, has_decoder),
  name: String,
  fun: fn(subform.SubForm) -> subform.SubForm,
) -> Form(widget, output, decoder, has_decoder) {
  update(form, name, fn(item) {
    case item {
      SubForm(details, items) -> SubForm(fun(details), items)
      _ -> item
    }
  })
}
