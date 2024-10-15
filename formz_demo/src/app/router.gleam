import app/example
import gleam/http/request
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import wisp.{type Request, type Response}

import app/examples/example_1

import app/web.{type Context}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case request.path_segments(req) {
    [] -> index()
    ["example-1"] -> example.handle(req, example_1.make_forms)
    _ -> wisp.not_found()
  }
}

pub fn index() -> Response {
  let html =
    html([], [
      html.head([], [html.title([], "Gleam formz!")]),
      html.body([], [
        html.h1([], [html.text("Hey there, formz!")]),
        html.ul([], [
          html.li([], [
            html.a([attribute.href("/example-1")], [html.text("Example 1")]),
          ]),
        ]),
      ]),
    ])
    |> element.to_document_string_builder

  wisp.ok() |> wisp.html_body(html)
}
