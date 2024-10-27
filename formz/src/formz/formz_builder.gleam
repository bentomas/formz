import formz/definition.{type Definition}
import formz/field
import formz/subform
import formz/widget

import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type HasDecoder

pub type NoDecoder

pub opaque type Form(format, output, decoder, has_decoder) {
  Form(
    items: List(FormItem(format)),
    parse_with: fn(List(FormItem(format)), decoder) ->
      Result(output, List(FormItem(format))),
    decoder: Option(decoder),
  )
}

pub type FormItem(format) {
  Element(field.Field, widget: widget.Widget(format))
  Set(subform.SubForm, items: List(FormItem(format)))
}

pub fn new() -> Form(format, a, a, NoDecoder) {
  Form([], fn(_, output) { Ok(output) }, None)
}

pub fn add(
  previous_form: Form(
    format,
    fn(decoder_step_input) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  definition: Definition(format, decoder_step_input),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
  let updated_items = [Element(field, definition.widget), ..previous_form.items]

  let parse_with = fn(items, decoder: form_output) {
    // can do let assert because we know there's at least one field since
    // we just added one
    let assert Ok(#(Element(field, widget), rest)) = pop_element(items)

    let input_output = definition.transform(field.value)

    let previous_form_output = previous_form.parse_with(rest, decoder)
    case previous_form_output, input_output {
      // the form we've already parsed has no errors and the field
      // we just parsed has no errors.  so we can move on to the next
      Ok(next), Ok(value) -> Ok(next(value))

      // the form already has errors even though this one succeeded.
      // so add this to the list and stop anymore parsing
      Error(items), Ok(_value) -> Error([Element(field, widget), ..items])

      // form was good so far, but this field errored, so need to
      // mark this field as invalid and return all the fields we've got
      // so far
      Ok(_), Error(error) ->
        field
        |> field.set_error(error)
        |> Element(widget)
        |> list.prepend(rest, _)
        |> Error

      // form already has errors and this field errored, so add this field
      // to the list
      Error(items), Error(error) ->
        field
        |> field.set_error(error)
        |> Element(widget)
        |> list.prepend(items, _)
        |> Error
    }
  }

  Form(items: updated_items, parse_with:, decoder: previous_form.decoder)
}

pub fn add_form(
  previous_form: Form(
    format,
    fn(sub_output) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  subform: subform.SubForm,
  sub: Form(format, sub_output, sub_decoder, HasDecoder),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
  let sub_items =
    sub.items
    |> map_fields(fn(field) {
      field |> field.set_name(subform.name <> "." <> field.name)
    })

  let updated_items = [Set(subform, sub_items), ..previous_form.items]

  let parse_with = fn(items, decoder: form_output) {
    // can do let assert because we know there's at least one field since
    // we just added one
    let assert Ok(#(Set(subform, sub_items), rest)) = pop_element(items)

    let assert Form(_, sub_parse_with, Some(sub_decoder)) = sub
    let form_output = sub_parse_with(sub_items, sub_decoder)

    let previous_form_output = previous_form.parse_with(rest, decoder)
    case previous_form_output, form_output {
      // everything is good!  pass along the output
      Ok(next), Ok(value) -> Ok(next(value))

      // form has errors, but this sub form was good, so add it to the list
      // of items as is.
      Error(items), Ok(_value) -> Error([Set(subform, items), ..items])

      // form was good so far, but this sub form errored, so need to
      // hop on error track
      Ok(_), Error(error_fields) -> Error([Set(subform, error_fields), ..rest])

      // form already has errors and this form errored, so add this field
      // to the list of errors
      Error(fields), Error(error_fields) ->
        Error(list.prepend(fields, Set(subform, error_fields)))
    }
  }
  Form(items: updated_items, parse_with:, decoder: previous_form.decoder)
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
  form: Form(format, output, decoder, has_decoder),
  input_data: List(#(String, String)),
) -> Form(format, output, decoder, has_decoder) {
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

pub fn decodes(
  form: Form(format, output, decoder, has_decoder),
  decoder: decoder,
) -> Form(format, output, decoder, HasDecoder) {
  let Form(fields, parse_with, _) = form
  Form(fields, parse_with, Some(decoder))
}

// pub fn remove_decoder(
//   form: Form(format, output1, decoder2, has_decoder),
// ) -> Form(format, decoder2, decoder2, NoDecoder) {
//   let Form(fields, parse_with, _) = form
//   let parse_with = fn(items: List(FormItem(format)), decoder) {
//     parse_with(items, decoder)
//   }
//   Form(fields, parse_with, None)
// }

pub fn parse(
  form: Form(format, output, decoder, HasDecoder),
) -> Result(output, Form(format, output, decoder, HasDecoder)) {
  // we've tagged that we have a decoder with our has_decoder phantom type
  // so we can get away with let assert here
  let assert Form(items, parse_with, Some(decoder)) = form
  case parse_with(items, decoder) {
    Ok(output) -> Ok(output)
    Error(items) -> Error(Form(items, parse_with, Some(decoder)))
  }
}

pub fn parse_try(
  form: Form(format, output, decoder, HasDecoder),
  apply fun: fn(output, Form(format, output, decoder, HasDecoder)) ->
    Result(c, Form(format, output, decoder, HasDecoder)),
) -> Result(c, Form(format, output, decoder, HasDecoder)) {
  parse(form) |> result.try(fun(_, form))
}

pub fn items(form: Form(format, a, b, has_decoder)) -> List(FormItem(format)) {
  form.items |> list.reverse
}

pub fn get(
  form: Form(format, output, decoder, has_decoder),
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
  form: Form(format, output, decoder, has_decoder),
  name: String,
  fun: fn(FormItem(format)) -> FormItem(format),
) {
  form.items
  |> do_formitem_update(name, fun)
  |> Form(form.parse_with, form.decoder)
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
  form: Form(format, output, decoder, has_decoder),
  name: String,
  fun: fn(field.Field) -> field.Field,
) -> Form(format, output, decoder, has_decoder) {
  update(form, name, fn(item) {
    case item {
      Element(field, widget) -> Element(fun(field), widget)
      _ -> item
    }
  })
}

pub fn update_fieldset(
  form: Form(format, output, decoder, has_decoder),
  name: String,
  fun: fn(subform.SubForm) -> subform.SubForm,
) -> Form(format, output, decoder, has_decoder) {
  update(form, name, fn(item) {
    case item {
      Set(subform, items) -> Set(fun(subform), items)
      _ -> item
    }
  })
}
