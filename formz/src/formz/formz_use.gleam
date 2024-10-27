import formz/definition.{type Definition}
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

pub type FormItem(format) {
  Element(field.Field, widget: widget.Widget(format))
  Set(subform.SubForm, items: List(FormItem(format)))
}

pub fn create_form(thing: thing) -> Form(format, thing) {
  Form([], fn(_) { Ok(thing) }, thing)
}

pub fn with(
  field: field.Field,
  is definition: Definition(format, input_output),
  rest fun: fn(input_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  // we pass in our placeholder value, and we're going to throw away the
  // decoded result here, we just care about pulling out the fields
  // from the form.
  let next_form = fun(definition.placeholder)

  // prepend the new field to the items from the form we got in the
  // previous step.
  let updated_items = [Element(field, definition.widget), ..next_form.items]

  // now create the parse function. parse function accepts most recent
  // version of input list, since data can be added to it.  the list
  // above we just needed for the initial setup.
  let parse = fn(items: List(FormItem(format))) {
    // pull out the latest version of this field to get latest input data
    let assert Ok(#(Element(field, widget), pop_elements)) = pop_element(items)

    // transform the input data using the transform/validate/decode/etc function
    let input_output = definition.transform(field.value)

    // pass our transformed input data to the next function/form. if
    // we errored we still do this with our placeholder so we can continue
    // processing all the fields in the form.  if we're on the error track
    // we'll throw away the "output" made with this and just keep the error
    let next_form = fun(input_output |> result.unwrap(definition.placeholder))
    let form_output = next_form.parse(pop_elements)

    // ok, check which track we're on
    case form_output, input_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this field was good, so add it to the list
      // of fields as is.
      Error(items), Ok(_value) -> Error([Element(field, widget), ..items])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        field
        |> field.set_error(error)
        |> Element(widget)
        |> list.prepend(pop_elements, _)
        |> Error

      // form already has errors and this field errored, so add this field
      // to the list of errors
      Error(items), Error(error) ->
        field
        |> field.set_error(error)
        |> Element(widget)
        |> list.prepend(items, _)
        |> Error
    }
  }
  Form(items: updated_items, parse:, placeholder: next_form.placeholder)
}

pub fn with_form(
  subform: subform.SubForm,
  sub: Form(format, sub_output),
  fun: fn(sub_output) -> Form(format, form_output),
) -> Form(format, form_output) {
  let next_form = fun(sub.placeholder)

  let sub_items =
    sub.items
    |> map_fields(fn(field) {
      field |> field.set_name(subform.name <> "." <> field.name)
    })

  let updated_items = [Set(subform, sub_items), ..next_form.items]

  let parse = fn(items: List(FormItem(format))) {
    // pull out the latest version of this field to get latest input data
    let assert [Set(subform, sub_items), ..next_items] = items

    let sub_output = sub.parse(sub_items)

    let next_form = fun(sub_output |> result.unwrap(sub.placeholder))
    let form_output = next_form.parse(next_items)

    // ok, check which track we're on
    case form_output, sub_output {
      // everything is good!  pass along the output
      Ok(_), Ok(_) -> form_output

      // form has errors, but this sub form was good, so add it to the list
      // of items as is.
      Error(items), Ok(_value) -> Error([Set(subform, items), ..items])

      // form was good so far, but this sub form errored, so need to
      // hop on error track
      Ok(_), Error(error_fields) ->
        Error([Set(subform, error_fields), ..next_items])

      // form already has errors and this form errored, so add this field
      // to the list of errors
      Error(fields), Error(error_fields) ->
        Error(list.prepend(fields, Set(subform, error_fields)))
    }
  }
  Form(updated_items, parse: parse, placeholder: next_form.placeholder)
}

fn pop_element(
  items: List(FormItem(format)),
) -> Result(#(FormItem(format), List(FormItem(format))), Nil) {
  case items {
    [] -> Error(Nil)
    [only] -> Ok(#(only, []))
    [Element(..) as item, ..rest] -> Ok(#(item, rest))
    [Set(_, []), ..rest] -> pop_element(rest)
    [Set(s, [first, ..rest_1]), ..rest_2] ->
      pop_element(list.flatten([[first], [Set(s, rest_1)], rest_2]))
  }
}

fn map_fields(
  items: List(FormItem(format)),
  fun: fn(field.Field) -> field.Field,
) -> List(FormItem(format)) {
  list.map(items, fn(item) {
    case item {
      Element(field, widget) -> Element(fun(field), widget)
      Set(s, items) -> Set(s, map_fields(items, fun))
    }
  })
}

pub fn data(
  form: Form(format, output),
  input_data: List(#(String, String)),
) -> Form(format, output) {
  let data = dict.from_list(input_data)
  let Form(items, parse, placeholder) = form
  items
  |> map_fields(fn(field) {
    case dict.get(data, field.name) {
      Ok(value) -> field.set_string_value(field, value)
      Error(_) -> field
    }
  })
  |> Form(parse, placeholder)
}

pub fn parse(form: Form(format, output)) -> Result(output, Form(format, output)) {
  case form.parse(form.items) {
    Ok(output) -> Ok(output)
    Error(items) -> Error(Form(..form, items:))
  }
}

pub fn parse_try(
  form: Form(format, output),
  apply fun: fn(output, Form(format, output)) -> Result(c, Form(format, output)),
) -> Result(c, Form(format, output)) {
  parse(form) |> result.try(fun(_, form))
}

pub fn items(form: Form(format, output)) -> List(FormItem(format)) {
  form.items
}

pub fn get(
  form: Form(format, output),
  name: String,
) -> Result(FormItem(format), Nil) {
  form.items
  |> list.filter(fn(item) {
    case item {
      Element(i, _) if i.name == name -> True
      Set(s, _) if s.name == name -> True
      _ -> False
    }
  })
  |> list.first
}

pub fn update(
  form: Form(format, output),
  name: String,
  fun: fn(FormItem(format)) -> FormItem(format),
) {
  form.items
  |> do_formitem_update(name, fun)
  |> Form(form.parse, form.placeholder)
}

fn do_formitem_update(
  items: List(FormItem(format)),
  name: String,
  fun: fn(FormItem(format)) -> FormItem(format),
) -> List(FormItem(format)) {
  items
  |> list.map(fn(item) {
    case item {
      Element(i, _) if i.name == name -> fun(item)
      Set(s, _) if s.name == name -> fun(item)
      Set(s, items) -> Set(s, do_formitem_update(items, name, fun))
      _ -> item
    }
  })
}

pub fn update_field(
  form: Form(format, output),
  name: String,
  fun: fn(field.Field) -> field.Field,
) -> Form(format, output) {
  update(form, name, fn(item) {
    case item {
      Element(field, widget) -> Element(fun(field), widget)
      _ -> item
    }
  })
}

pub fn update_fieldset(
  form: Form(format, output),
  name: String,
  fun: fn(subform.SubForm) -> subform.SubForm,
) -> Form(format, output) {
  update(form, name, fn(item) {
    case item {
      Set(subform, items) -> Set(fun(subform), items)
      _ -> item
    }
  })
}
