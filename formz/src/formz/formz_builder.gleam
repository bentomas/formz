import formz.{type FormItem, Field, SubForm}
import formz/definition.{type Definition, Definition}
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

pub fn new() -> Form(format, a, a, NoDecoder) {
  Form([], fn(_, output) { Ok(output) }, None)
}

fn add(
  previous_form: Form(
    format,
    fn(decoder_step_input) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  widget: widget.Widget(format),
  parse_field: fn(String) -> Result(decoder_step_input, String),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
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

pub fn optional(
  previous_form: Form(
    format,
    fn(decoder_step_input) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  definition: Definition(format, _, decoder_step_input),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
  add(previous_form, field, definition.widget, definition.optional_parse(
    definition.parse,
    _,
  ))
}

pub fn require(
  previous_form: Form(
    format,
    fn(field_output) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  field: field.Field,
  definition: Definition(format, field_output, _),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
  add(
    previous_form,
    field |> field.set_required(True),
    definition.widget,
    definition.parse,
  )
}

pub fn subform(
  previous_form: Form(
    format,
    fn(sub_output) -> decoder_step_output,
    form_output,
    has_decoder,
  ),
  details: subform.SubForm,
  sub: Form(format, sub_output, sub_decoder, HasDecoder),
) -> Form(format, decoder_step_output, form_output, has_decoder) {
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

pub fn get_fields(
  form: Form(format, output, decoder, has_decoder),
) -> List(field.Field) {
  form.items |> do_get_fields
}

fn do_get_fields(items: List(FormItem(format))) -> List(field.Field) {
  list.fold(items, [], fn(acc, item) {
    case item {
      Field(f, _) -> [f, ..acc]
      SubForm(_, sub_items) -> list.flatten([do_get_fields(sub_items), acc])
    }
  })
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

pub fn data(
  form: Form(format, output, decoder, has_decoder),
  input_data: List(#(String, String)),
) -> Form(format, output, decoder, has_decoder) {
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

pub fn parse_then_try(
  form: Form(format, output, decoder, HasDecoder),
  apply fun: fn(Form(format, output, decoder, HasDecoder), output) ->
    Result(c, Form(format, output, decoder, HasDecoder)),
) -> Result(c, Form(format, output, decoder, HasDecoder)) {
  parse(form) |> result.try(fun(form, _))
}

pub fn validate(
  form: Form(format, output, decoder, HasDecoder),
  names: List(String),
) -> Form(format, output, decoder, HasDecoder) {
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

pub fn validate_all(
  form: Form(format, output, decoder, HasDecoder),
) -> Form(format, output, decoder, HasDecoder) {
  let names =
    form
    |> get_fields()
    |> list.map(fn(f) { f.name })

  validate(form, names)
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
      Field(i, _) if i.name == name -> True
      SubForm(s, _) if s.name == name -> True
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
      Field(i, _) if i.name == name -> fun(item)
      SubForm(s, _) if s.name == name -> fun(item)
      SubForm(s, items) -> SubForm(s, do_formitem_update(items, name, fun))
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
      Field(field, widget) -> Field(fun(field), widget)
      _ -> item
    }
  })
}

pub fn update_subform(
  form: Form(format, output, decoder, has_decoder),
  name: String,
  fun: fn(subform.SubForm) -> subform.SubForm,
) -> Form(format, output, decoder, has_decoder) {
  update(form, name, fn(item) {
    case item {
      SubForm(details, items) -> SubForm(fun(details), items)
      _ -> item
    }
  })
}
