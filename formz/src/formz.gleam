//// A form is a list of fields and a decoder function. This module uses a
//// series of callbacks to construct the decoder function as the fields are
//// being added to the form.  The idea is that you'd have a function that
//// makes the form using the `use` syntax, and then be able to use the form
//// later for parsing or rendering in different contexts.
////
//// You can use this cheatsheet to navigate the module documentation:
////
//// <table>
//// <tr>
////   <td>Creating a form</td>
////   <td>
////     <a href="#create_form">create_form</a><br>
////     <a href="#require">require</a><br>
////     <a href="#optional">optional</a><br>
////     <a href="#list">list</a><br>
////     <a href="#limited_list">limited_list</a><br>
////     <a href="#subform">subform</a>
////   </td>
//// </tr>
//// <tr>
////   <td>Decoding and validating a form</td>
////   <td>
////     <a href="#data">data</a><br>
////     <a href="#decode">decode</a><br>
////     <a href="#decode_then_try">decode_then_try</a><br>
////     <a href="#validate">validate</a><br>
////     <a href="#validate_all">validate_all</a>
////   </td>
//// </tr>
//// <tr>
////   <td>Creating a field definition</td>
////   <td>
////     <a href="#definition">definition</a><br>
////     <a href="#definition_with_custom_optional">definition_with_custom_optional</a><br>
////     <a href="#verify">verify</a><br>
////     <a href="#widget">widget</a>
////   </td>
//// </tr>
//// <tr>
////   <td>Creating a limited list</td>
////   <td>
////     <a href="#limit_at_least">limit_at_least</a><br>
////     <a href="#limit_at_most">limit_at_most</a><br>
////     <a href="#limit_between">limit_between</a><br>
////     <a href="#simple_limit_check">simple_limit_check</a>
////   </td>
//// </tr>
//// <tr>
////   <td>Accessing and manipulating form items</td>
////   <td>
////     <a href="#get">get</a><br>
////     <a href="#items">items</a><br>
////     <a href="#set_field_error">set_field_error</a><br>
////     <a href="#set_listfield_errors">set_listfield_errors</a><br>
////     <a href="#update">update</a><br>
////     <a href="#update_field">update_field</a><br>
////     <a href="#update_listfield">update_listfield</a><br>
////     <a href="#update_subform">update_subform</a>
////   </td>
//// </tr>
//// </table>
////
//// ### Examples
////
//// ```gleam
//// fn make_form() {
////  use name <- formz.require(field("name"), definitions.text_field())
////
////  formz.create_form(name)
//// }
////
//// fn process_form() {
////   make_form()
////   |> formz.data([#("name", "Louis"))])
////   |> formz.decode
////   # -> Ok("Louis")
//// }
//// ```
////
//// ```gleam
//// fn make_form() {
////  use greeting <- optional(field("greeting"), definitions.text_field())
////  use name <- optional(field("name"), definitions.text_field())
////
////  formz.create_form(greeting <> " " <> name)
//// }
////
//// fn process_form() {
////   make_form()
////   |> data([#("greeting", "Hello"), #("name", "World")])
////   |> formz.decode
////   # -> Ok("Hello World")
//// }
//// ```

import formz/field
import formz/subform
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

/// You create this using the `create_form` function.
///
/// The `widget` type is set by the `Definition`s used to add fields for
/// this form, and has the details of how to turn given fields into HTML inputs.
///
/// The `output` type is the type of the decoded data from the form. This is
/// set directly by the `create_form` function, after all the fields have
/// been added.
pub opaque type Form(widget, output) {
  Form(
    items: List(Item(widget)),
    decode: fn(List(Item(widget))) -> Result(output, List(Item(widget))),
    stub: output,
  )
}

/// You add an `Item` to a form using the `optional`, `require`, `list`,
/// `limited_list` and `subform` functions. A form is a list of `Item`s and
/// each item is parsed to a single value, which the decode function will
/// choose how to use.
///
/// You primarily only use an `Item` directly when writing a form generator
/// function to output your function to HTML.
///
/// You can also manipulate an `Item` after a form has been created, to change
/// things like labels, help text, etc. There are specific functions,
/// `update_field`, `update_listfield` and `update_subform`, to help with this,
/// so you don't have to pattern match when updating a specific item.
///
/// ```
/// let form = make_form()
/// form.update_field("name", field.set_label(_, "Full Name"))
/// ```
pub type Item(widget) {
  /// A single field that (generally speaking) corresponds to a single
  /// HTML input
  Field(detail: field.Field, state: InputState, widget: widget)
  /// A single field that a consumer can submit multiple values for.
  ListField(
    detail: field.Field,
    states: List(InputState),
    limit_check: LimitCheck,
    widget: widget,
  )
  /// A group of fields that are added as and then parsed to a single unit.
  SubForm(detail: subform.SubForm, items: List(Item(widget)))
}

/// The state of the an input for a field. This is used to track the current
/// raw value,  whether a value is required or not, if the value has been
/// validated, and the outcome of that validation.
pub type InputState {
  Unvalidated(value: String, requirement: Requirement)
  Valid(value: String, requirement: Requirement)
  Invalid(value: String, requirement: Requirement, error: String)
}

/// Whether an input value is required for an input field.
pub type Requirement {
  Optional
  Required
}

/// A `Definition` describes how a field works, e.g. how it looks and how it's
/// parsed. It is the heavy compared to the lightness of a
/// [Field](https://hexdocs.pm/formz/formz/field.html);
/// definitions take a bit more work to make as they are intended to be reusable.
///
/// The first role of a `Defintion` is to generate the HTML input for the field.
/// This library is format-agnostic and you can generate inputs as raw
/// strings, Lustre elements, Nakai nodes, something else, etc. The second role
/// of a `Definition` is to parse the raw string data from the input into a
/// Gleam type.
///
/// There are currently three `formz` libraries that provide common field
/// definitions for the most common HTML inputs:
///
/// - [formz_string](https://hexdocs.pm/formz_string/)
/// - [formz_nakai](https://hexdocs.pm/formz_nakai/)
/// - [formz_lustre](https://hexdocs.pm/formz_lustre/)
///
/// How a definition parses an input value depends on whether a value is required
/// for that input (i.e.  whether `optional`, `require`, `list`, or `limited_list`
/// was used to add it to the form).  If a value is required, the definition is
/// expected to return a string error if the input is empty, or the `required` type
/// if it isn't.  You can use the `definition` function to create a simple
/// definition that just parses to an `Option` if an input is empty.
///
/// However, not all fields should be parsed into an `Option` when
/// given an empty input value. For example, an optional text field might be an
/// empty string or an optional checkbox might be False.  For these cases, you
/// can use the `definition_with_custom_optional` function to create a definition
/// that can parse to any type when the input is empty.
pub opaque type Definition(widget, required, optional) {
  Definition(
    widget: widget,
    parse: fn(String) -> Result(required, String),
    stub: required,
    /// If a field is marked as optional, this function is called, with the
    /// above parse as an argument.  The idea is that this function will
    /// call out to the parse function if the field is not empty, and
    /// this should only handle the case where the raw input value is empty.
    /// This function is necessary because not all fields should just be parsed
    /// into an `Option` when they aren't provided.
    /// For example, an optional text field might be an empty string,
    /// an optional checkbox might be `False`, and an optional select might
    /// be `option.None`.
    optional_parse: fn(fn(String) -> Result(required, String), String) ->
      Result(optional, String),
    optional_stub: optional,
  )
}

/// When adding a list field to a form with `limited_list`, you have to provide
/// a `LimitCheck` function that checks the number of inputs (and associated
/// values) for the field. This function can either say the number of inputs
/// is Ok and optionally add more, or say the number of inputs was too high
/// and return an error. For example, you are presenting a blank form to a
/// consumer, and you want to show three initial fields for them to fill out,
/// or you want to always show one more additional field than the number of
/// values that have already belong to the form, etc.
///
/// There are helper functions, `limit_at_least`, `limit_at_most`, and
/// `limit_between` or more generally `simple_limit_check` to make a
/// `LimitCheck` function for you.  I would imagine that those will cover 99.9%
/// of cases and almost no one will need to write their own `LimitCheck`.  But
/// if you do, look at the source for `simple_limit_check` for a better idea
/// of how to write one.
///
/// This function takes as its only argument, the number of fields that already
/// have a value.  It should return a list of `Unvalidated` `InputState` items
/// that specify if the value is required or not.
///
/// This is used multiple times... when the form is created so we know how many
/// initial inputs to present, when data is added so we know if we need to add
/// more inputs so users can add more items, and when the form is decoded and
/// we are checking if too many fields have been added.
pub type LimitCheck =
  fn(Int) -> Result(List(InputState), Int)

type ListParsingResult(input_output) {
  ListParsingResult(
    value: String,
    requirement: Requirement,
    output: Result(input_output, String),
  )
}

/// Create an empty form that "decodes" directly to `thing`. This is
/// intended to be the final return value of a chain of callbacks that adds
/// the form's fields.
///
/// ```gleam
/// create_form(1)
/// |> decode
/// # -> Ok(1)
/// ```
/// ```gleam
/// fn make_form() {
///   use field1 <- formz.require(field("field1"), definitions.text_field())
///   use field2 <- formz.require(field("field2"), definitions.text_field())
///   use field3 <- formz.require(field("field3"), definitions.text_field())
///
///   formz.create_form(#(field1, field2, field3))
/// }
/// ```
pub fn create_form(thing: thing) -> Form(widget, thing) {
  Form([], fn(_) { Ok(thing) }, thing)
}

/// Add an optional field to a form.
///
/// Ultimately whether a field is actually optional or not comes down to the
/// details of the definition.  The definition will receive the raw input string
/// and is in charge of returning an error or an optional value.
///
/// If multiple values are submitted for this field, the last one will be used.
///
/// The final argument is a callback that will be called when the form
/// is being... constructed to look for more fields; validated to check for
/// errors; and decoded to parse the input data.  **For this reason, the
/// callback should be a function without side effects.** It can be called any
/// number of times. Don't do anything but create the type with the data you
/// need!  If you need to do decoding that has side effects, you should use
/// `decode_then_try`.
pub fn optional(
  field: field.Field,
  definition: Definition(widget, _, input_output),
  next: fn(input_output) -> Form(widget, form_output),
) -> Form(widget, form_output) {
  add_field(
    field,
    Optional,
    definition.widget,
    definition.optional_parse(definition.parse, _),
    definition.optional_stub,
    next,
  )
}

/// Add a required field to a form.
///
/// Ultimately whether a field is actually required or not comes down to the
/// details of the definition.  The definition will receive the raw input string
/// and is in charge of returning an error or a value.
///
/// If multiple values are submitted for this field, the last one will be used.
///
/// The final argument is a callback that will be called when the form
/// is being... constructed to look for more fields; validated to check for
/// errors; and decoded to parse the input data.  **For this reason, the
/// callback should be a function without side effects.** It can be called any
/// number of times. Don't do anything but create the type with the data you
/// need!  If you need to do decoding that has side effects, you should use
/// `decode_then_try`.
pub fn require(
  field: field.Field,
  is definition: Definition(widget, required_output, _),
  next next: fn(required_output) -> Form(widget, form_output),
) -> Form(widget, form_output) {
  add_field(
    field,
    Required,
    definition.widget,
    definition.parse,
    definition.stub,
    next,
  )
}

fn add_field(
  field: field.Field,
  requirement: Requirement,
  widget: widget,
  parse_field: fn(String) -> Result(input_output, String),
  stub: input_output,
  next: fn(input_output) -> Form(widget, form_output),
) -> Form(widget, form_output) {
  // we pass in our stub value, and we're going to throw away the
  // decoded result here, we just care about pulling out the fields
  // from the form.
  let next_form = next(stub)

  // prepend the new field to the items from the form we got in the previous step.
  let updated_items = [
    Field(field, Unvalidated("", requirement), widget),
    ..next_form.items
  ]

  // now create the decode function. decode function accepts most recent
  // version of input list, since data can be added to it.  the list
  // above we just needed for the initial setup.
  let decode = fn(items: List(Item(widget))) {
    // pull out the latest version of this field to get latest input data
    let assert [Field(field, state, widget), ..next_items] = items

    // transform the input data using the decode function
    let item_output = parse_field(state.value)

    // pass our transformed input data to the next function/form. if
    // we errored we still do this with our stub so we can continue
    // processing all the fields in the form.  if we're on the error track
    // we'll throw away the "output" made with this and just keep the error
    let next_form = next(item_output |> result.unwrap(stub))
    let form_output = next_form.decode(next_items)

    // ok, check which track we're on
    case form_output, item_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so add it to the list
      // of fields as is.
      Error(error_items), Ok(_) -> {
        let f = Field(field, Valid(state.value, requirement), widget)
        Error([f, ..error_items])
      }

      // form was good so far, but this field errored, so need to
      // mark this field as invalid, mark all the existing fields as valid,
      // and return all the fields we've got so far
      Ok(_), Error(error) -> {
        let f = Field(field, Invalid(state.value, requirement, error), widget)
        Error([f, ..mark_all_fields_as_valid(next_items)])
      }

      // form already has errors and this field errored, so mark this field
      // as invalid, and add it to the list of errors
      Error(error_items), Error(error) -> {
        let f = Field(field, Invalid(state.value, requirement, error), widget)
        Error([f, ..error_items])
      }
    }
  }
  Form(items: updated_items, decode:, stub: next_form.stub)
}

/// Convenience function for creating a `LimitCheck` function.  This takes
/// the minimum number of required values, the maximum number of allowed values,
/// and the number of "extra" blank inputs that should be offered to the user
/// for filling out.
///
/// If "extra" is 0, (say, to manage blank fields via javascript), then this
/// will show 1 blank field initially.
pub fn simple_limit_check(min: Int, max: Int, extra: Int) -> LimitCheck {
  fn(num_nonempty) {
    case max - num_nonempty {
      x if x < 0 -> Error(x)
      _ -> {
        int.max(1 - num_nonempty, int.min(extra, max - num_nonempty))
        list.fold([1, extra, min], 0, int.max)

        // if they've specified a minimum required, then start there
        let num_required = int.max(min - num_nonempty, 0)

        // at least one field needs to be present.  don't want a form that is asking
        // for no input
        let num_base = case num_nonempty, num_required {
          x, y if x > 0 || y > 0 -> 0
          _, _ -> 1
        }

        // they've asked for extra fields, add those unless doing so would
        // exceed the max
        let num_extra = int.min(extra, max - num_nonempty)

        // take whatever's bigger for our optional ones, either the bare minimum
        // (base) or the extra if they've got room for it and they've asked for it
        let num_optional = int.max(num_base, num_extra) - num_required

        Ok(list.append(
          list.repeat(Unvalidated("", Required), num_required),
          list.repeat(Unvalidated("", Optional), num_optional),
        ))
      }
    }
  }
}

/// Convenience function for creating a `LimitCheck` with a minimum number
/// of required values.  This sets the maximum to `1,000,000`, effectively unlimited.
pub fn limit_at_least(min: Int) -> LimitCheck {
  simple_limit_check(min, 1_000_000, 1)
}

/// Convenience function for creating a `LimitCheck` with a maximum number
/// of accepted values.  This sets the minimum to `0`.
pub fn limit_at_most(max: Int) -> LimitCheck {
  simple_limit_check(0, max, 1)
}

/// Convenience function for creating a `LimitCheck` with a minimum and maximum
/// number of values.
pub fn limit_between(min: Int, max: Int) -> LimitCheck {
  simple_limit_check(min, max, 1)
}

/// Add a list field to a form, but with limits on the number of values that
/// can be submitted.  The `limit_check` function is used to impose those
/// limits, and the `limit_at_least`, `limit_at_most`, and `limit_between`
/// functions help you create this function for the most likely scenarios.
///
/// The final argument is a callback that will be called when the form
/// is being... constructed to look for more fields; validated to check for
/// errors; and decoded to parse the input data.  **For this reason, the
/// callback should be a function without side effects.** It can be called any
/// number of times. Don't do anything but create the type with the data you
/// need!  If you need to do decoding that has side effects, you should use
/// `decode_then_try`.
///
///### Example
///
/// ```gleam
/// fn make_form() {
///  use names <- formz.limited_list(formz.limit_at_most(4), field("name"), definitions.text_field())
///  // names is a List(String)
///  formz.create_form(name)
/// }
pub fn limited_list(
  limit_check: fn(Int) -> Result(List(InputState), Int),
  field: field.Field,
  is definition: Definition(widget, required_output, _),
  next next: fn(List(required_output)) -> Form(widget, form_output),
) -> Form(widget, form_output) {
  // we pass in our stub value, and we're going to throw away the
  // decoded result here, we just care about pulling out the fields
  // from the form.
  let next_form = next([definition.stub])

  let initial_fields = limit_check(0) |> result.unwrap([])
  // prepend the new field to the items from the form we got in the previous step.
  let updated_items = [
    ListField(field, initial_fields, limit_check, definition.widget),
    ..next_form.items
  ]

  // now create the decode function. decode function accepts most recent
  // version of input list, since data can be added to it.  the list
  // above we just needed for the initial setup.
  let decode = fn(items: List(Item(widget))) {
    // pull out the latest version of this field to get latest input data
    let assert [ListField(field, states, limit_check, widget), ..next_items] =
      items

    // go through all decode all input values.  these can have empty rows
    // that were offered to the consumer, but they didn't fill out.  we need
    // to keep track of those so they can be used when generating the form
    // again on error
    let item_results =
      list.map(states, parse_list_state(_, definition.parse, definition.stub))

    // but we don't want them for considering the output of this list field,
    // so remove the empty optional fields and just grab the outputs
    let item_outputs =
      item_results |> outputs_for_required_or_nonempty |> result.all

    // pass our transformed input data to the next function/form. if
    // we errored we still do this with our stub so we can continue
    // processing all the fields in the form.  if we're on the error track
    // we'll throw away the "output" made with this and just keep the error
    let next_form = next(item_outputs |> result.unwrap([definition.stub]))
    let form_output = next_form.decode(next_items)

    // ok, check which track we're on
    case form_output, item_outputs {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so mark all states as valid
      Error(error_items), Ok(_) -> {
        let states = states |> list.map(fn(s) { Valid(s.value, s.requirement) })
        let f = ListField(field, states, limit_check, widget)
        Error([f, ..error_items])
      }

      // form was good so far, but this field errored, so need to
      // mark the errored states as invalid, and mark the successful fields as
      // valid, and then return all these fields we've got so far
      Ok(_), Error(_) -> {
        let states = list.map(item_results, state_from_parse_result)
        let f = ListField(field, states, limit_check, widget)
        Error([f, ..mark_all_fields_as_valid(next_items)])
      }

      // form already has errors and this field errored, so add this field
      // to the list of errors, but first marking the invalid states as... invalid
      Error(error_items), Error(_) -> {
        let states = list.map(item_results, state_from_parse_result)
        let f = ListField(field, states, limit_check, widget)
        Error([f, ..error_items])
      }
    }
  }

  Form(items: updated_items, decode:, stub: next_form.stub)
}

fn state_from_parse_result(
  result: ListParsingResult(input_output),
) -> InputState {
  let ListParsingResult(value, requirement, output) = result
  case output {
    Ok(_) -> Valid(value, requirement)
    Error(error) -> Invalid(value, requirement, error)
  }
}

fn outputs_for_required_or_nonempty(
  states: List(ListParsingResult(output)),
) -> List(Result(output, String)) {
  list.filter_map(states, fn(result) {
    case result.value, result.requirement {
      "", Optional -> Error(Nil)
      _, _ -> Ok(result.output)
    }
  })
}

fn parse_list_state(
  state: InputState,
  parse: fn(String) -> Result(a, String),
  stub: a,
) -> ListParsingResult(a) {
  case state.value, state.requirement {
    "", Required -> parse(state.value)
    "", Optional -> Ok(stub)
    _, _ -> parse(state.value)
  }
  |> ListParsingResult(state.value, state.requirement, _)
}

/// Add a list field to a form, but with no limits on the number of values that
/// can be submitted. A list field is like a normal field except a consumer can
/// submit multiple values, and it will return a `List` of the parsed values.
///
/// The final argument is a callback that will be called when the form
/// is being... constructed to look for more fields; validated to check for
/// errors; and decoded to parse the input data.  **For this reason, the
/// callback should be a function without side effects.** It can be called any
/// number of times. Don't do anything but create the type with the data you
/// need!  If you need to do decoding that has side effects, you should use
/// `decode_then_try`.
pub fn list(
  field: field.Field,
  is definition: Definition(widget, required_output, _),
  next next: fn(List(required_output)) -> Form(widget, form_output),
) -> Form(widget, form_output) {
  limited_list(limit_at_most(1_000_000), field, definition, next)
}

fn add_prefix_to_item(item: Item(widget), prefix: String) -> Item(widget) {
  case item {
    Field(item_details, state, widget) -> {
      let name = prefix <> "." <> item_details.name
      Field(item_details |> field.set_name(name), state, widget)
    }
    ListField(item_details, states, limit_check, widget) -> {
      let name = prefix <> "." <> item_details.name
      ListField(
        item_details |> field.set_name(name),
        states,
        limit_check,
        widget,
      )
    }
    SubForm(item_details, sub_items) -> {
      let name = prefix <> "." <> item_details.name
      SubForm(item_details |> subform.set_name(name), sub_items)
    }
  }
}

/// Add a form as a subform.  This will essentially append the fields from the
/// subform to the current form, prefixing their names with the name of the
/// subform.  Form generators will still see the fields as a set though, so they
/// can be marked up as a group for accessibility reasons.
///
/// The final argument is a callback that will be called when the form
/// is being... constructed to look for more fields; validated to check for
/// errors; and decoded to parse the input data.  **For this reason, the
/// callback should be a function without side effects.** It can be called any
/// number of times. Don't do anything but create the type with the data you
/// need!  If you need to do decoding that has side effects, you should use
/// `decode_then_try`.
pub fn subform(
  subform: subform.SubForm,
  form: Form(widget, sub_output),
  next: fn(sub_output) -> Form(widget, form_output),
) -> Form(widget, form_output) {
  let next_form = next(form.stub)

  let sub_items = form.items |> list.map(add_prefix_to_item(_, subform.name))
  let subform = SubForm(subform, sub_items)
  let updated_items = [subform, ..next_form.items]

  let decode = fn(items: List(Item(widget))) {
    // pull out the latest version of this field to get latest input data
    let assert [SubForm(details, sub_items), ..next_items] = items

    let item_output = form.decode(sub_items)

    let next_form = next(item_output |> result.unwrap(form.stub))
    let form_output = next_form.decode(next_items)

    // ok, check which track we're on
    case form_output, item_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this sub form was good, so add it to the list
      // of items as is.
      Error(next_error_items), Ok(_) -> {
        let sub = SubForm(details, sub_items |> mark_all_fields_as_valid)
        Error([sub, ..next_error_items])
      }

      // form was good so far, but this sub form errored, so need to
      // hop on error track
      Ok(_), Error(error_items) -> {
        let sub = SubForm(details, error_items)
        Error([sub, ..mark_all_fields_as_valid(next_items)])
      }

      // form already has errors and this form errored, so add this field
      // to the list of errors
      Error(next_error_items), Error(error_items) -> {
        let sub = SubForm(details, error_items)
        Error([sub, ..next_error_items])
      }
    }
  }
  Form(updated_items, decode:, stub: next_form.stub)
}

/// Add input data to this form. This will set the raw string value of the fields.
/// It does not trigger any parsing or decoding, so you can also use this to set
/// default values (if you do it in your form generator function) or initial values
/// (if you do it before rendering a blank form).
///
/// The input data is a list of tuples, where the first element is the name of the
/// field and the second element is the value to set.  If the field does not exist
/// the data is ignored.
///
/// This resets the validation state of the fields that have data, so you'll need to
/// re-validate or decode the form after setting data.
pub fn data(
  form: Form(widget, output),
  input_data: List(#(String, String)),
) -> Form(widget, output) {
  let data = to_dict(input_data)
  let Form(items, decode, stub) = form
  Form(do_data(items, data), decode, stub)
}

fn do_data(
  items: List(Item(widget)),
  data: Dict(String, List(String)),
) -> List(Item(widget)) {
  list.map(items, fn(item) {
    let values = dict.get(data, get_item_name(item))
    case item, values {
      Field(detail, state, widget), Ok([_, ..] as values) -> {
        let assert Ok(last) = list.last(values)
        Field(detail, Unvalidated(last, state.requirement), widget)
      }
      ListField(detail, states, limit_check, widget), Ok(values) -> {
        let nonempty = list.filter(values, fn(v) { !string.is_empty(v) })
        let num_nonempty = list.length(nonempty)

        let additional_fields = limit_check(num_nonempty) |> result.unwrap([])
        let items =
          list.map2(states, nonempty, fn(s, v) { Unvalidated(v, s.requirement) })
          |> list.append(
            nonempty
            |> list.drop(list.length(states))
            |> list.map(fn(v) { Unvalidated(v, Optional) }),
          )
          |> list.append(additional_fields)

        ListField(detail, items, limit_check, widget)
      }
      SubForm(detail, items), _ -> SubForm(detail, do_data(items, data))
      _, _ -> item
    }
  })
}

fn to_dict(values: List(#(String, String))) -> Dict(String, List(String)) {
  list.fold_right(values, dict.new(), fn(acc, kv) {
    let #(key, value) = kv
    dict.upsert(acc, key, fn(opt) {
      case opt {
        None -> [value]
        Some(values) -> [value, ..values]
      }
    })
  })
}

/// Decode the form.  This means step through the fields one by one, parsing
/// them individually.  If any field fails to parse, the whole form is considered
/// invalid, however it will still continue parsing the rest of the fields to
/// collect all errors.  This is useful for showing all errors at once.  If no
/// fields fail to parse, the decoded value is returned, which is the value given
/// to `create_form`.
///
/// If you'd like to decode the form but not get the output, so you can give
/// feedback to a user in response to input, you can use `validate` or `validate_all`.
pub fn decode(
  form: Form(widget, output),
) -> Result(output, Form(widget, output)) {
  case form.decode(form.items) {
    Ok(output) -> Ok(output)
    Error(items) -> Error(Form(..form, items:))
  }
}

/// Decode the form, then apply a function to the output if it was successful.
/// This is a very thin wrapper around `decode` and `result.try`, but the
/// difference being it will pass the form along to the function as a second
/// argument in addition to the successful result.  This allows you to easily
/// update the form fields with errors or other information based on the output.
///
/// This is useful for situations where you can have errors in the form that
/// aren't easily checked in simple parsing functions.  Like, say, hitting a
/// db to check if a username is taken.
///
/// As a reminder, parse functions will be called multiple times for each field
/// when the form is being made, validated and parsed, and should not contain
/// side effects.  This function is the proper way to add errors to fields from
/// functions that have side effects.
///
/// ```gleam
/// make_form()
/// |> data(form_data)
/// |> decode_then_try(fn(username, form) {
///   case is_username_taken(username) {
///     Ok(false) -> Ok(form)
///     Ok(true) -> set_field_error(form, "username",  "Username is taken")
///   }
/// }
pub fn decode_then_try(
  form: Form(widget, output),
  apply fun: fn(Form(widget, output), output) -> Result(c, Form(widget, output)),
) -> Result(c, Form(widget, output)) {
  form
  |> decode
  |> result.try(fn(output) {
    let items = form.items |> mark_all_fields_as_valid
    fun(Form(..form, items:), output)
  })
}

fn mark_all_fields_as_valid(items: List(Item(widget))) -> List(Item(widget)) {
  list.map(items, fn(item) {
    case item {
      Field(field, state, widget) ->
        Field(field, Valid(state.value, state.requirement), widget)
      ListField(field, states, limit_check, widget) -> {
        let new_states =
          states
          |> list.map(fn(state) { Valid(state.value, state.requirement) })
        ListField(field, new_states, limit_check, widget)
      }
      SubForm(subform, items) ->
        SubForm(subform, mark_all_fields_as_valid(items))
    }
  })
}

/// Validate specific fields of the form.  This is similar to `decode`, but
/// instead of returning the decoded output if there are no errors, it returns
/// the valid form.  This is useful for if you want to be able to give feedback
/// to the user about whether certain fields are valid or not. For example, you
/// could just validate only fields that the user has interacted with.
pub fn validate(
  form: Form(widget, output),
  names: List(String),
) -> Form(widget, output) {
  case form.decode(form.items) {
    Ok(_) -> {
      let items =
        list.map(form.items, fn(parsed_item) {
          let item_name = get_item_name(parsed_item)
          case list.find(names, fn(name) { item_name == name }) {
            Ok(_) -> {
              let assert Ok(item) =
                [parsed_item] |> mark_all_fields_as_valid |> list.first
              item
            }
            Error(_) -> {
              let assert Ok(original_item) = get(form, item_name)
              original_item
            }
          }
        })
      Form(..form, items:)
    }
    Error(items) -> {
      let items =
        list.map(items, fn(parsed_item) {
          let item_name = get_item_name(parsed_item)
          case list.find(names, fn(name) { item_name == name }) {
            Ok(_) -> parsed_item
            Error(_) -> {
              let assert Ok(original_item) = get(form, item_name)
              original_item
            }
          }
        })
      Form(..form, items:)
    }
  }
}

/// Validate all the fields in the form.  This is similar to `decode`, but
/// instead of returning the decoded output if there are no errors, it returns
/// the valid form.  This is useful for if you want to be able to give feedback
/// to the user about whether certain fields are valid or not.
pub fn validate_all(form: Form(widget, output)) -> Form(widget, output) {
  form.items |> list.map(get_item_name) |> validate(form, _)
}

/// Get each [`Item`](https://hexdocs.pm/formz/formz.html#Item) added
/// to the form.  Any time a field, list field, or subform are added, a `Item`
/// is created.  Use this to loop through all the fields of your form and
/// generate HTML for them.
pub fn items(form: Form(widget, output)) -> List(Item(widget)) {
  form.items
}

/// Get the [`Item`](https://hexdocs.pm/formz/formz.html#Item) with the
/// given name.  If multiple items have the same name, the first one is returned.
pub fn get(
  form: Form(widget, output),
  name: String,
) -> Result(Item(widget), Nil) {
  list.find(form.items, fn(item) { name == get_item_name(item) })
}

/// Update the [`Item`](https://hexdocs.pm/formz/formz.html#Item) with
/// the given name using the provided function.  If multiple items have the same
/// name, it will be called on all of them.
pub fn update(
  form: Form(widget, output),
  name: String,
  fun: fn(Item(widget)) -> Item(widget),
) {
  let items = do_update(form.items, name, fun)
  Form(..form, items:)
}

fn do_update(
  items: List(Item(widget)),
  name: String,
  fun: fn(Item(widget)) -> Item(widget),
) -> List(Item(widget)) {
  list.map(items, fn(item) {
    case item {
      Field(detail, _, _) if detail.name == name -> fun(item)
      ListField(detail, _, _, _) if detail.name == name -> fun(item)
      SubForm(detail, items) -> {
        let sub = SubForm(detail, do_update(items, name, fun))
        case detail.name == name {
          True -> fun(sub)
          False -> sub
        }
      }
      _ -> item
    }
  })
}

/// Update the `Field` [details](https://hexdocs.pm/formz/formz/field.html) with
/// the given name using the provided function.  If multiple items have the same
/// name, it will be called on all of them.  If no items have the given name,
/// or an item with the given name exists but isn't a `Field`, this function
/// will do nothing.
///
/// ```gleam
/// let form = make_form()
/// update_field(form, "name", field.set_label(_, "Full Name"))
/// ```
pub fn update_field(
  form: Form(widget, output),
  name: String,
  fun: fn(field.Field) -> field.Field,
) -> Form(widget, output) {
  update(form, name, fn(item) {
    case item {
      Field(field, ..) -> Field(..item, detail: fun(field))
      _ -> item
    }
  })
}

/// Update the `ListField` [details]](https://hexdocs.pm/formz/formz/field.html) with
/// the given name using the provided function.  If multiple items have the same
/// name, it will be called on all of them.  If no items have the given name,
/// or an item with the given name exists but isn't a `ListField`, this function
/// will do nothing.
///
/// ```gleam
/// let form = make_form()
/// update(form, "name", field.set_label(_, "Full Name"))
/// ```
pub fn update_listfield(
  form: Form(widget, output),
  name: String,
  fun: fn(field.Field) -> field.Field,
) -> Form(widget, output) {
  update(form, name, fn(item) {
    case item {
      ListField(field, ..) -> ListField(..item, detail: fun(field))
      _ -> item
    }
  })
}

/// Update the [`SubForm`](https://hexdocs.pm/formz/formz/subform.html) with
/// the given name using the provided function.  If multiple subforms have the same
/// name, it will be called on all of them. If no items have the given name,
/// or an item with the given name exists but isn't a `SubForm`, this function
/// will do nothing.
///
/// ```gleam
/// let form = make_form()
/// update(form, "name", subform.set_help_text(_, "..."))
/// ```
pub fn update_subform(
  form: Form(widget, output),
  name: String,
  fun: fn(subform.SubForm) -> subform.SubForm,
) -> Form(widget, output) {
  update(form, name, fn(item) {
    case item {
      SubForm(subform, items) -> SubForm(fun(subform), items)
      _ -> item
    }
  })
}

/// Convenience function for setting the `InputState` of a field to
/// Invalid with a given error message.
///
/// ### Example
///
/// ```
/// set_field_error(form, "username",  "Username is taken")
/// ```
pub fn set_field_error(
  form: Form(widget, output),
  name: String,
  str: String,
) -> Form(widget, output) {
  update(form, name, fn(item) {
    case item {
      Field(field, state, widget) ->
        Field(field, Invalid(state.value, state.requirement, str), widget)
      _ -> item
    }
  })
}

/// Convenience function for setting the `InputState`s of a list field. This
/// takes a list of Results, where the Ok means the input is `Valid` and
/// `Error` means the input is `Invalid` with the given error message.
///
/// ### Example
///
/// ```
/// set_listfield_errors(form, "pet_names",  [Ok(Nil), Ok(Nil), Error("Must be a cat")])
/// ```
pub fn set_listfield_errors(
  form: Form(widget, output),
  name: String,
  errors: List(Result(Nil, String)),
) -> Form(widget, output) {
  update(form, name, fn(item) {
    case item {
      ListField(field, states, limit_check, widget) -> {
        let invalid_states =
          list.map2(states, errors, fn(state, err) {
            case err {
              Error(str) -> Invalid(state.value, state.requirement, str)
              Ok(Nil) -> state
            }
          })
        ListField(field, invalid_states, limit_check, widget)
      }
      _ -> item
    }
  })
}

fn get_item_name(item: Item(widget)) -> String {
  case item {
    Field(field, _, _) -> field.name
    ListField(field, _, _, _) -> field.name
    SubForm(subform, _) -> subform.name
  }
}

/// Create a simple `Definition` that is parsed as an `Option` if the field
/// is empty.  See [formz_string](https://hexdocs.pm/formz_string/formz_string/definitions.html)
/// for more examples of making widgets and definitions.
pub fn definition(
  widget widget: widget,
  parse parse: fn(String) -> Result(required, String),
  stub stub: required,
) {
  Definition(
    widget:,
    parse:,
    stub:,
    optional_parse: fn(fun, str) {
      case str {
        "" -> Ok(option.None)
        _ -> fun(str) |> result.map(option.Some)
      }
    },
    optional_stub: option.None,
  )
}

/// Create a `Definition` that can parse to any type if the field is optional.
/// This takes two functions.  The first, `parse`, is the "required"" parse
/// function, which takes the raw string value, and turns it into the required
/// type.  The second, `optional_parse`, is a function that takes the normal
/// parse function and the raw string value, and it is supposed to check the
/// input string: if it is empty, return an `Ok` with the `optional_stub`
/// value; and if it's not empty use the normal parse function.
///
/// See [formz_string](https://hexdocs.pm/formz_string/formz_string/definitions.html)
/// for more examples of making widgets and definitions.
pub fn definition_with_custom_optional(
  widget widget: widget,
  parse parse: fn(String) -> Result(required, String),
  stub stub: required,
  optional_parse optional_parse: fn(
    fn(String) -> Result(required, String),
    String,
  ) ->
    Result(optional, String),
  optional_stub optional_stub: optional,
) -> Definition(widget, required, optional) {
  Definition(widget:, parse:, stub:, optional_parse:, optional_stub:)
}

/// Chain additional validation onto the `parse` function.  This is
/// useful if you don't need to change the returned type, but might have
/// additional constraints.  Like say, requiring a `String` to be at least
/// a certain length, or that an Int must be positive.
///
/// ### Example
/// ```gleam
/// field
///   |> validate(fn(i) {
///     case i > 0 {
///       True -> Ok(i)
///       False -> Error("must be positive")
///     }
///   }),
/// ```
pub fn verify(
  def: Definition(widget, a, b),
  fun: fn(a) -> Result(a, String),
) -> Definition(widget, a, b) {
  Definition(..def, parse: fn(val) { val |> def.parse |> result.try(fun) })
}

// pub fn transform(
//   def: Definition(widget, old_required, old_optional),
//   transform: fn(old_required) -> Result(new_required, String),
//   stub: new_required,
// ) -> Definition(widget, new_required, option.Option(new_required)) {
//   let Definition(widget, parse, _, _, _) = def
//   Definition(
//     widget:,
//     parse: fn(val) { val |> parse |> result.try(transform) },
//     stub:,
//     optional_parse: fn(parse, str) {
//       case str {
//         "" -> Ok(option.None)
//         _ -> parse(str) |> result.map(option.Some)
//       }
//     },
//     optional_stub: option.None,
//   )
// }

// pub fn transform_with_custom_optional(
//   def: Definition(widget, old_required, old_optional),
//   transform: fn(old_required) -> Result(new_required, String),
//   stub: new_required,
//   optional_parse: fn(fn(String) -> Result(new_required, String), String) ->
//     Result(new_optional, String),
//   optional_stub: new_optional,
// ) -> Definition(widget, new_required, new_optional) {
//   let Definition(widget, parse, _, _, _) = def
//   Definition(
//     widget:,
//     parse: fn(val) { val |> parse |> result.try(transform) },
//     stub:,
//     optional_parse:,
//     optional_stub:,
//   )
// }

/// Update the widget of a definition.
pub fn widget(
  def: Definition(widget, a, b),
  widget: widget,
) -> Definition(widget, a, b) {
  Definition(..def, widget:)
}

@internal
pub fn get_parse(
  def: Definition(widget, a, b),
) -> fn(String) -> Result(a, String) {
  def.parse
}

@internal
pub fn get_optional_parse(
  def: Definition(widget, a, b),
) -> fn(fn(String) -> Result(a, String), String) -> Result(b, String) {
  def.optional_parse
}

@internal
pub fn get_states(form: Form(widget, output)) -> List(InputState) {
  form.items |> do_get_states |> list.reverse
}

fn do_get_states(items: List(Item(widget))) -> List(InputState) {
  list.fold(items, [], fn(acc, item) {
    case item {
      Field(_, state, _) -> [state, ..acc]
      ListField(_, states, _, _) -> list.append(states |> list.reverse, acc)
      SubForm(_, sub_items) -> list.flatten([do_get_states(sub_items), acc])
    }
  })
}
