import formz/formz_use as formz
import formz/input
import formz_demo/example/page
import gleam/http.{Get, Post}
import gleam/list
import gleam/option
import simplifile
import wisp.{type Request, type Response}

pub fn handle(req: Request, make_forms) -> Response {
  case req.method {
    Get -> handle_get(make_forms)
    Post -> handle_post(req, make_forms)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}

fn handle_get(make_forms) {
  let #(dir, name, string_form, lustre_form, nakai_form) = make_forms()
  let assert Ok(code) =
    simplifile.read("./src/formz_demo/examples/" <> dir <> "/strings.gleam")
  page.build_page(
    name,
    code,
    option.None,
    [],
    option.None,
    string_form,
    lustre_form,
    nakai_form,
    True,
    True,
  )
}

fn handle_post(req: Request, make_forms) -> Response {
  use formdata <- wisp.require_form(req)

  let #(dir, name, string_form, lustre_form, nakai_form) = make_forms()

  let assert Ok(code) =
    simplifile.read("./src/formz_demo/examples/" <> dir <> "/strings.gleam")

  let input_data = formdata.values

  let #(string_form, string_output, string_errors) = case
    string_form |> formz.data(input_data) |> formz.parse
  {
    Ok(r) -> #(string_form |> formz.data(input_data), option.Some(r), [])
    Error(f) -> #(f, option.None, get_errors(f))
  }
  let #(lustre_form, lustre_output, lustre_errors) = case
    lustre_form |> formz.data(input_data) |> formz.parse
  {
    Ok(r) -> #(lustre_form |> formz.data(input_data), option.Some(r), [])
    Error(f) -> #(f, option.None, get_errors(f))
  }
  let #(nakai_form, nakai_output, nakai_errors) = case
    nakai_form |> formz.data(input_data) |> formz.parse
  {
    Ok(r) -> #(nakai_form |> formz.data(input_data), option.Some(r), [])
    Error(f) -> #(f, option.None, get_errors(f))
  }

  let has_output_discrepancy = case string_output, lustre_output, nakai_output {
    a, b, c if a == b && a == c -> False
    _, _, _ -> True
  }
  let has_error_discrepancy = case string_errors, lustre_errors, nakai_errors {
    a, b, c if a == b && a == c -> False
    _, _, _ -> True
  }

  page.build_page(
    name,
    code,
    option.Some(input_data),
    get_errors(string_form),
    string_output,
    string_form,
    lustre_form,
    nakai_form,
    has_output_discrepancy,
    has_error_discrepancy,
  )
}

fn get_errors(
  form: formz.Form(format, widget_args, a),
) -> List(#(String, String)) {
  form
  |> formz.get_inputs
  |> list.filter_map(fn(f) {
    case f {
      input.Input(..) -> Error(Nil)
      input.InvalidInput(error:, ..) -> Ok(#(f.name, error))
    }
  })
}
