import formz/field
import formz/formz_use as formz
import formz/input
import formz/string_generator/fields as string_fields
import formz_demo/page
import formz_lustre/fields as lustre_fields
import formz_nakai/fields as nakai_fields
import gleam/http.{Get, Post}
import gleam/list
import gleam/option
import gleam/result
import wisp.{type Request, type Response}

pub fn handle(req: Request, make_forms) -> Response {
  case req.method {
    Get -> handle_get(make_forms)
    Post -> handle_post(req, make_forms)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}

fn handle_get(make_forms) {
  let #(code, string_form, lustre_form, nakai_form) = make_forms()
  page.build_page(
    "Hello World",
    code,
    [],
    [],
    option.None,
    string_form,
    lustre_form,
    nakai_form,
  )
}

fn handle_post(req: Request, make_forms) -> Response {
  use formdata <- wisp.require_form(req)

  let forms = make_forms()
  let #(code, string_form, lustre_form, nakai_form) = forms

  let generator =
    result.unwrap(list.key_find(formdata.values, "__generator"), "string")

  let input_data =
    formdata.values |> list.filter(fn(t) { t.0 != "__generator" })

  case generator {
    "lustre" -> {
      let #(lustre_form, output) = case
        lustre_form |> formz.data(input_data) |> formz.parse
      {
        Ok(r) -> #(lustre_form, option.Some(r))
        Error(f) -> #(f, option.None)
      }
      page.build_page(
        "Hello World",
        code,
        input_data,
        get_errors(lustre_form),
        output,
        string_form,
        lustre_form,
        nakai_form,
      )
    }
    "nakai" -> {
      let #(nakai_form, output) = case
        nakai_form |> formz.data(input_data) |> formz.parse
      {
        Ok(r) -> #(nakai_form, option.Some(r))
        Error(f) -> #(f, option.None)
      }
      page.build_page(
        "Hello World",
        code,
        input_data,
        get_errors(nakai_form),
        output,
        string_form,
        lustre_form,
        nakai_form,
      )
    }
    _ -> {
      let #(string_form, output) = case
        string_form |> formz.data(input_data) |> formz.parse
      {
        Ok(r) -> #(string_form, option.Some(r))
        Error(f) -> #(f, option.None)
      }
      page.build_page(
        "Hello World",
        code,
        input_data,
        get_errors(string_form),
        output,
        string_form,
        lustre_form,
        nakai_form,
      )
    }
  }
}

fn get_errors(form: formz.Form(format, a)) -> List(#(String, String)) {
  form
  |> formz.get_inputs
  |> list.filter_map(fn(f) {
    case f {
      input.Input(..) -> Error(Nil)
      input.InvalidInput(error:, ..) -> Ok(#(f.name, error))
    }
  })
}
