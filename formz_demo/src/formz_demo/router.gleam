import formz_demo/example/defaults
import formz_demo/example/run
import gleam/http/request
import gleam/list
import justin
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import wisp.{type Request, type Response}

import formz_demo/examples/all_the_inputs
import formz_demo/examples/custom_output
import formz_demo/examples/hello_world
import formz_demo/examples/labels
import formz_demo/examples/list_fields
import formz_demo/examples/login
import formz_demo/examples/require_all_the_inputs
import formz_demo/examples/sub_form

import formz_demo/web.{type Context}

fn get_examples() {
  [
    #("hello_world", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          hello_world.make_form,
          defaults.handle_get,
          defaults.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("all_the_inputs", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          all_the_inputs.make_form,
          defaults.handle_get,
          defaults.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("require_all_the_inputs", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          require_all_the_inputs.make_form,
          defaults.handle_get,
          defaults.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("labels", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          labels.make_form,
          defaults.handle_get,
          defaults.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("list_fields", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          list_fields.make_form,
          defaults.handle_get,
          defaults.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("login", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          login.make_form,
          defaults.handle_get,
          login.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("sub_form", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          sub_form.make_form,
          defaults.handle_get,
          defaults.handle_post,
          defaults.format_string_form,
          defaults.formatted_string_form_to_string,
        ),
      )
    }),
    #("custom_output", fn(req, dir) {
      run.handle(
        req,
        run.ExampleRun(
          dir,
          custom_output.make_form,
          defaults.handle_get,
          defaults.handle_post,
          custom_output.format_form,
          defaults.formatted_lustre_form_to_string,
        ),
      )
    }),
  ]
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case request.path_segments(req) {
    [] -> index()
    [dir] ->
      case list.key_find(get_examples(), dir) {
        Ok(make_example) -> make_example(req, dir)
        Error(_) -> wisp.not_found()
      }

    _ -> wisp.not_found()
  }
}

pub fn index() -> Response {
  let examples_lis =
    get_examples()
    |> list.map(fn(t) {
      let #(dir, _) = t
      let name = justin.sentence_case(dir)
      html.li([], [html.a([attribute.href("/" <> dir)], [html.text(name)])])
    })

  let html =
    html([], [
      html.head([], [
        html.link([
          attribute.rel("stylesheet"),
          attribute.href("/static/stylesheet.css"),
        ]),
        html.title([], "Gleam formz!"),
      ]),
      html.body([], [
        html.h1([], [html.text("Hey there, formz!")]),
        html.ul([], examples_lis),
      ]),
    ])
    |> element.to_document_string_builder

  wisp.ok() |> wisp.html_body(html)
}
