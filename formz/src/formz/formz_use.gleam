///////   field related functions

import formz/field.{type Field}
import formz/input.{type Input, Input}
import gleam/dict
import gleam/list
import gleam/result

pub opaque type Form(format, output) {
  Form(
    inputs: List(FormItem(format)),
    parse: fn(List(FormItem(format))) -> Result(output, List(FormItem(format))),
    default: output,
  )
}

pub type FormItem(format) {
  Item(Input(format))
  Fieldset(String, List(FormItem(format)))
}

pub fn with(
  field: Field(format, input_output),
  fun: fn(input_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  // we pass in our default value, and we're going to throw away the
  // decoded result here, we just care about pulling out the fields
  // from the form.
  let next = fun(field.default)

  // prepend the new input to the inputs from the form we got in the
  // previous step.
  let updated_inputs = [Item(field.input), ..next.inputs]

  // now create the parse function. parse function accepts most recent
  // version of input list, since data can be added to it.  the list
  // above we just needed for the initial setup.
  let parse = fn(inputs: List(FormItem(format))) {
    // pull out the latest version of this field to get latest input data
    let assert Ok(#(Item(input), next_inputs)) = next_item(inputs)

    // transform the input data using the transform/validate/decode/etc function
    let input_output = field.transform(input.value)

    // pass our transformed input data to the next function/form. if
    // we errored we still do this with our default so we can continue
    // processing all the fields in the form.  we will return a form
    // with an error, so if we're on the error track we'll throw away
    // the "output" made with this and just keep the errors.
    let next_form = fun(input_output |> result.unwrap(field.default))
    let form_output = next_form.parse(next_inputs)

    // ok, check which track we're on
    case form_output, input_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so add it to the list
      // of fields as is.
      Error(inputs), Ok(_value) -> Error([Item(input), ..inputs])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        input
        |> input.set_error(error)
        |> Item
        |> list.prepend(next_inputs, _)
        |> Error

      // form already has errors and this field errored, so add this field
      // to the list of errors
      Error(fields), Error(error) ->
        input
        |> input.set_error(error)
        |> Item
        |> list.prepend(fields, _)
        |> Error
    }
  }
  Form(updated_inputs, parse: parse, default: next.default)
}

pub fn sub_form(
  prefix: String,
  name: String,
  sub: Form(format, sub_output),
  fun: fn(sub_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  let next = fun(sub.default)

  let sub_inputs =
    sub.inputs
    |> map_items(fn(item) { item |> input.set_name(prefix <> "." <> item.name) })

  let updated_inputs = [Fieldset(name, sub_inputs), ..next.inputs]

  let parse = fn(inputs: List(FormItem(format))) {
    // pull out the latest version of this field to get latest input data
    let assert [Fieldset(name, items), ..next_inputs] = inputs

    let sub_output = sub.parse(items)

    let next_form = fun(sub_output |> result.unwrap(sub.default))
    let form_output = next_form.parse(next_inputs)

    // ok, check which track we're on
    case form_output, sub_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this sub form was good, so add it to the list
      // of items as is.
      Error(inputs), Ok(_value) -> Error([Fieldset(name, items), ..inputs])

      // form was good so far, but this sub form errored, so need to
      // hop on error track
      Ok(_), Error(error_fields) ->
        Error([Fieldset(name, error_fields), ..next_inputs])

      // form already has errors and this form errored, so add this field
      // to the list of errors
      Error(fields), Error(error_fields) ->
        Error(list.prepend(fields, Fieldset(name, error_fields)))
    }
  }
  Form(updated_inputs, parse: parse, default: next.default)
}

pub fn next_item(
  items: List(FormItem(format)),
) -> Result(#(FormItem(format), List(FormItem(format))), Nil) {
  case items {
    [] -> Error(Nil)
    [only] -> Ok(#(only, []))
    [Item(input), ..rest] -> Ok(#(Item(input), rest))
    [Fieldset(_, []), ..rest] -> next_item(rest)
    [Fieldset(name, [first, ..rest_1]), ..rest_2] ->
      next_item(list.flatten([[first], [Fieldset(name, rest_1)], rest_2]))
  }
}

fn map_items(
  items: List(FormItem(format)),
  fun: fn(Input(format)) -> Input(format),
) -> List(FormItem(format)) {
  list.map(items, fn(item) {
    case item {
      Item(input) -> Item(fun(input))
      Fieldset(name, items) -> Fieldset(name, map_items(items, fun))
    }
  })
}

pub fn get_inputs(form: Form(format, ouput)) {
  form.inputs |> do_get_inputs([]) |> list.reverse
}

fn do_get_inputs(items: List(FormItem(format)), acc) {
  case items {
    [] -> acc
    [Item(input), ..rest] -> do_get_inputs(rest, [input, ..acc])
    [Fieldset(_, items), ..rest] ->
      do_get_inputs(list.flatten([items, rest]), acc)
  }
}

pub fn data(
  form: Form(format, output),
  input_data: List(#(String, String)),
) -> Form(format, output) {
  let data = dict.from_list(input_data)
  let Form(inputs, parse, default) = form
  inputs
  |> map_items(fn(input) {
    case dict.get(data, input.name) {
      Ok(value) -> input.set_value(input, value)
      Error(_) -> input
    }
  })
  |> Form(parse, default)
}

pub fn create_form(thing: thing) -> Form(format, thing) {
  Form([], fn(_) { Ok(thing) }, thing)
}

pub fn parse(form: Form(format, output)) -> Result(output, Form(format, output)) {
  // we've tagged that we have a decoder with out has_decoder phantom type
  // so we can get away with let assert here
  let Form(fields, parse, default) = form
  case parse(fields) {
    Ok(output) -> Ok(output)
    Error(fields) -> Error(Form(fields, parse, default))
  }
}

pub fn parse_and_try(
  form: Form(format, output),
  apply fun: fn(output, Form(format, output)) -> Result(c, Form(format, output)),
) -> Result(c, Form(format, output)) {
  parse(form) |> result.try(fun(_, form))
}

pub fn get_items(form: Form(format, ouput)) -> List(FormItem(format)) {
  form.inputs
}

pub fn get_input(
  form: Form(format, output),
  name: String,
) -> Result(Input(format), Nil) {
  form
  |> get_inputs
  |> list.filter(fn(input) { input.name == name })
  |> list.first
}

pub fn update_input(
  form: Form(format, output),
  name: String,
  fun: fn(Input(format)) -> Input(format),
) -> Form(format, output) {
  form.inputs
  |> map_items(fn(field) {
    case field.name == name {
      True -> fun(field)
      False -> field
    }
  })
  |> Form(form.parse, form.default)
}
