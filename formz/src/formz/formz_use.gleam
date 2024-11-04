//// A form is a list of fields and a decoder function. This module uses a
//// series of callbacks to construct a decoder function as the fields are
//// being added to the form.  The idea is that you'd have a function that
//// makes the form using the `use` syntax, and then be able to use the form
//// later for parsing or rendering in different contexts.
////
//// ### Examples
////
//// ```gleam
//// fn make_form() {
////  use name <- formz.require(field("name"), defintions.text_field())
////
////  formz.create_form(name)
//// }
////
//// fn process_form() {
////   make_form()
////   |> formz.data([#("name", "Louis"))])
////   |> formz.parse
////   # -> Ok("Louis")
//// }
//// ```
////
//// ```gleam
//// fn make_form() {
////  use greeting <- optional(field("greeting"), defintions.text_field())
////  use name <- optional(field("name"), defintions.text_field())
////
////  formz.create_form(greeting <> " " <> name)
//// }
////
//// fn process_form() {
////   make_form()
////   |> data([#("greeting", "Hello"), #("name", "World")])
////   |> formz.parse
////   # -> Ok("Hello World")
//// }
//// ```

import formz.{type FormItem, Field, SubForm}
import formz/definition.{type Definition, Definition}
import formz/field
import formz/subform
import formz/widget
import gleam/dict
import gleam/list
import gleam/result

pub opaque type Form(format, output) {
  Form(
    items: List(FormItem(format)),
    parse: fn(List(FormItem(format))) -> Result(output, List(FormItem(format))),
    placeholder: output,
  )
}

/// Create an empty form that only parses to `thing`. This is primarily
/// intended to be the final return value of a chain of callbacks that adds
/// the form's fields.
///
/// ```gleam
/// create_form(1)
/// |> parse
/// # -> Ok(1)
/// ```
/// ```gleam
/// fn make_form() {
///   use field1 <- formz.require(field("field1"), definitions.text_field())
///   use field2 <- formz.require(field("field2"), definitions.text_field())
///   use field3 <- formz.require(field("field3"), definitions.text_field())
///
///   create_form(#(field1, field2, field3))
/// }
/// ```
pub fn create_form(thing: thing) -> Form(format, thing) {
  Form([], fn(_) { Ok(thing) }, thing)
}

fn add(
  field: field.Field,
  widget: widget.Widget(format),
  parse_field: fn(String) -> Result(input_output, String),
  stub: input_output,
  rest fun: fn(input_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  // we pass in our stub value, and we're going to throw away the
  // decoded result here, we just care about pulling out the fields
  // from the form.
  let next_form = fun(stub)

  // prepend the new field to the items from the form we got in the
  // previous step.
  let updated_items = [Field(field, widget), ..next_form.items]

  // now create the parse function. parse function accepts most recent
  // version of input list, since data can be added to it.  the list
  // above we just needed for the initial setup.
  let parse = fn(items: List(FormItem(format))) {
    // pull out the latest version of this field to get latest input data
    let assert Ok(#(Field(field, widget), pop_fields)) = pop_field(items)

    // transform the input data using the transform/validate/decode/etc function
    let input_output = parse_field(field.value)

    // pass our transformed input data to the next function/form. if
    // we errored we still do this with our placeholder so we can continue
    // processing all the fields in the form.  if we're on the error track
    // we'll throw away the "output" made with this and just keep the error
    let next_form = fun(input_output |> result.unwrap(stub))
    let form_output = next_form.parse(pop_fields)

    // ok, check which track we're on
    case form_output, input_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so add it to the list
      // of fields as is.
      Error(items), Ok(_value) -> Error([Field(field, widget), ..items])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        field
        |> field.set_error(error)
        |> Field(widget)
        |> list.prepend(pop_fields, _)
        |> Error

      // form already has errors and this field errored, so add this field
      // to the list of errors
      Error(items), Error(error) ->
        field
        |> field.set_error(error)
        |> Field(widget)
        |> list.prepend(items, _)
        |> Error
    }
  }
  Form(items: updated_items, parse:, placeholder: next_form.placeholder)
}

/// Add an optional field to a form.
///
/// This will use both the `parse` and `optional_parse` functions from the
/// definition to parse the input data when parsing this field.  Ultimately
/// whether a field is actually optional or not comes down to the details
/// of the definition.
///
/// The final argument is a callback that will be called when the form
/// is being constructed to look for more fields; validated to check for errors;
/// and when the form is being parsed, to decode the input data.  **For this
/// reason, the callback should be a function without side effects.** It can be
/// called any number of times. Don't do anything but create the type with the
/// data you need!
pub fn optional(
  field: field.Field,
  is definition: Definition(format, _, input_output),
  rest fun: fn(input_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  add(
    field |> field.set_required(False),
    definition.widget,
    definition.optional_parse(definition.parse, _),
    definition.optional_stub,
    fun,
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
///
/// The final argument is a callback that will be called when the form
/// is being constructed to look for more fields; validated to check for errors;
/// and when the form is being parsed, to decode the input data.  **For this
/// reason, the callback should be a function without side effects.** It can be
/// called any number of times. Don't do anything but create the type with the
/// data you need!
pub fn require(
  field: field.Field,
  is definition: Definition(format, required_output, _),
  rest fun: fn(required_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  add(
    field |> field.set_required(True),
    definition.widget,
    definition.parse,
    definition.stub,
    fun,
  )
}

/// Add a form as a subform.  This will essentially append the fields from the
/// subform to the current form, prefixing their names with the name of the
/// subform.  Form generators will still see the fields as a set though, so they
/// can be marked up as a group for accessibility reasons.
///
/// The final argument is a callback that will be called when the form
/// is being constructed to look for more fields; validated to check for errors;
/// and when the form is being parsed, to decode the input data.  **For this
/// reason, the callback should be a function without side effects.** It can be
/// called any number of times. Don't do anything but create the type with the
/// data you need!
pub fn subform(
  details: subform.SubForm,
  sub: Form(format, sub_output),
  fun: fn(sub_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  let next_form = fun(sub.placeholder)

  let sub_items =
    sub.items
    |> update_fields(fn(field) {
      field |> field.set_name(details.name <> "." <> field.name)
    })

  let updated_items = [SubForm(details, sub_items), ..next_form.items]

  let parse = fn(items: List(FormItem(format))) {
    // pull out the latest version of this field to get latest input data
    let assert [SubForm(details, sub_items), ..next_items] = items

    let sub_output = sub.parse(sub_items)

    let next_form = fun(sub_output |> result.unwrap(sub.placeholder))
    let form_output = next_form.parse(next_items)

    // ok, check which track we're on
    case form_output, sub_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this sub form was good, so add it to the list
      // of items as is.
      Error(items), Ok(_value) -> Error([SubForm(details, items), ..items])

      // form was good so far, but this sub form errored, so need to
      // hop on error track
      Ok(_), Error(error_fields) ->
        Error([SubForm(details, error_fields), ..next_items])

      // form already has errors and this form errored, so add this field
      // to the list of errors
      Error(fields), Error(error_fields) ->
        Error(list.prepend(fields, SubForm(details, error_fields)))
    }
  }
  Form(updated_items, parse: parse, placeholder: next_form.placeholder)
}

fn pop_field(
  items: List(FormItem(format)),
) -> Result(#(FormItem(format), List(FormItem(format))), Nil) {
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
pub fn get_fields(form: Form(format, output)) -> List(field.Field) {
  form.items |> do_get_fields
}

fn do_get_fields(items: List(FormItem(format))) -> List(field.Field) {
  list.fold(items, [], fn(acc, item) {
    case item {
      Field(f, _) -> [f, ..acc]
      SubForm(_, sub_items) -> list.flatten([do_get_fields(sub_items), acc])
    }
  })
  |> list.reverse
}

fn update_fields(
  items: List(FormItem(format)),
  fun: fn(field.Field) -> field.Field,
) -> List(FormItem(format)) {
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
///
/// The input data is a list of tuples, where the first element is the name of the
/// field and the second element is the value to set.  If the field does not exist
/// the data is ignored, and if multiple values are given for the same field, the
/// last one wins.
pub fn data(
  form: Form(format, output),
  input_data: List(#(String, String)),
) -> Form(format, output) {
  let data = dict.from_list(input_data)
  let Form(items, parse, placeholder) = form
  items
  |> update_fields(fn(field) {
    case dict.get(data, field.name) {
      Ok(value) -> field.set_raw_value(field, value)
      Error(_) -> field
    }
  })
  |> Form(parse, placeholder)
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
pub fn parse(form: Form(format, output)) -> Result(output, Form(format, output)) {
  case form.parse(form.items) {
    Ok(output) -> Ok(output)
    Error(items) -> Error(Form(..form, items:))
  }
}

/// Parse the form, then apply a function to the output if it was successful.
/// This is a very thin wrapper around `parse` and `result.try`, but the
/// difference being it will pass the form along to the function as a second
/// argument in addition to the successful result.  This allows you to easily
/// update the form fields with errors or other information based on the output.
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
  form: Form(format, output),
  apply fun: fn(Form(format, output), output) -> Result(c, Form(format, output)),
) -> Result(c, Form(format, output)) {
  form |> parse |> result.try(fun(form, _))
}

/// Validate specific fields of the form.  This is similar to `parse`, but
/// instead of returning the decoded output if there are no errors, it returns
/// the valid form.  This is useful for if you want to be able to give feedback
/// to the user about whether certain fields are valid or not. In this case you
/// could just validate only fields that the user has interacted with.
pub fn validate(
  form: Form(format, output),
  names: List(String),
) -> Form(format, output) {
  case form.parse(form.items) {
    Ok(_) -> form
    Error(items) -> {
      let items =
        update_fields(items, fn(field) {
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
pub fn validate_all(form: Form(format, output)) -> Form(format, output) {
  let names =
    form
    |> get_fields()
    |> list.map(fn(f) { f.name })

  validate(form, names)
}

/// Get each [`FormItem`](https://hexdocs.pm/formz/formz.html#FormItem) added
/// to the form.  Any time a field or subform are added, a FormItem is created.
pub fn items(form: Form(format, output)) -> List(FormItem(format)) {
  form.items
}

/// Get the [`FormItem`](https://hexdocs.pm/formz/formz.html#FormItem) with the
/// given name.  If multiple items have the same name, the first one is returned.
pub fn get(
  form: Form(format, output),
  name: String,
) -> Result(FormItem(format), Nil) {
  list.find(form.items, fn(item) {
    case item {
      Field(i, _) if i.name == name -> True
      SubForm(s, _) if s.name == name -> True
      _ -> False
    }
  })
}

/// Update the [`FormItem`](https://hexdocs.pm/formz/formz.html#FormItem) with
/// the given name using the provided function.  If multiple items have the same
/// name, it will be called on all of them.
pub fn update(
  form: Form(format, output),
  name: String,
  fun: fn(FormItem(format)) -> FormItem(format),
) {
  let items = do_formitems_update(form.items, name, fun)
  Form(..form, items:)
}

fn do_formitems_update(
  items: List(FormItem(format)),
  name: String,
  fun: fn(FormItem(format)) -> FormItem(format),
) -> List(FormItem(format)) {
  list.map(items, fn(item) {
    case item {
      Field(f, _) if f.name == name -> fun(item)
      SubForm(s, _) if s.name == name -> fun(item)
      SubForm(s, items) -> SubForm(s, do_formitems_update(items, name, fun))
      _ -> item
    }
  })
}

/// Update the [`Field`](https://hexdocs.pm/formz/formz/field.html) with
/// the given name using the provided function.  If multiple items have the same
/// name, it will be called on all of them.
///
/// ```gleam
/// let form = make_form()
/// update(form, "name", field.set_label(_, "Full Name"))
/// ```
pub fn update_field(
  form: Form(format, output),
  name: String,
  fun: fn(field.Field) -> field.Field,
) -> Form(format, output) {
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
  form: Form(format, output),
  name: String,
  fun: fn(subform.SubForm) -> subform.SubForm,
) -> Form(format, output) {
  update(form, name, fn(item) {
    case item {
      SubForm(details, items) -> SubForm(fun(details), items)
      _ -> item
    }
  })
}
