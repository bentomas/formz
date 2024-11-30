import formz
import formz/widget.{type Widget}
import formz_demo/example/page
import gleam/http.{Get, Post}
import gleam/option
import simplifile
import wisp.{type Request, type Response}

pub type ExampleRun(format, output, output2, msg) {
  ExampleRun(
    dir: String,
    make_form: fn() -> formz.Form(Widget(format), output),
    get_handler: fn(formz.Form(Widget(format), output)) ->
      formz.Form(Widget(format), output),
    post_handler: fn(wisp.FormData, formz.Form(Widget(format), output)) ->
      Result(output2, formz.Form(Widget(format), output)),
    format_form: fn(formz.Form(Widget(format), output)) -> format,
    formatted_form_to_string: fn(format) -> String,
  )
}

pub fn handle(
  req: Request,
  example: ExampleRun(format, output, output2, msg),
) -> Response {
  case req.method {
    Get -> handle_get(example)
    Post -> handle_post(req, example)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}

fn get_code(key: String) {
  let assert Ok(form_code) =
    simplifile.read("./src/formz_demo/examples/" <> key <> ".gleam")
  form_code
}

fn handle_get(example: ExampleRun(format, output, output2, msg)) {
  let form = example.make_form() |> example.get_handler

  page.build_page(
    example.dir,
    get_code(example.dir),
    option.None,
    option.None,
    form,
    form
      |> example.format_form
      |> example.formatted_form_to_string,
  )
}

fn handle_post(
  req: Request,
  example: ExampleRun(format, output, output2, msg),
) -> Response {
  use formdata <- wisp.require_form(req)

  let form =
    example.make_form()
    |> example.post_handler(formdata, _)

  let #(form, form_output) = case form {
    Ok(r) -> #(
      example.make_form() |> formz.data(formdata.values),
      option.Some(r),
    )
    Error(form_with_errors) -> #(form_with_errors, option.None)
  }

  page.build_page(
    example.dir,
    get_code(example.dir),
    option.Some(formdata.values),
    form_output,
    form,
    form
      |> example.format_form
      |> example.formatted_form_to_string,
  )
}
