import formz/formz_use as formz
import formz/string_generator/simple as simple_string
import formz_lustre/simple as simple_lustre
import formz_nakai/simple as simple_nakai
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import nakai
import nakai/html as nhtml
import wisp.{type Response}

pub fn build_page(
  name: String,
  code: String,
  post_data: option.Option(List(#(String, String))),
  errors_list: List(#(String, String)),
  output: option.Option(a),
  string_form: formz.Form(String, a),
  lustre_form: formz.Form(element.Element(msg), a),
  nakai_form: formz.Form(nhtml.Node, a),
  has_output_discrepancy: Bool,
  has_error_discrepancy: Bool,
) -> Response {
  let html =
    html([], [
      html.head([], [
        html.title([], "Gleam formz!"),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href("/static/stylesheet.css"),
        ]),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href(
            "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css",
          ),
        ]),
        html.script(
          [
            attribute.src(
              "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js",
            ),
          ],
          "",
        ),
        html.script([attribute.src("/static/highlight-gleam.mjs")], ""),
        html.script(
          [],
          "
          hljs.registerLanguage('gleam', gleam);
          hljs.highlightAll();
          ",
        ),
      ]),
      html.body([], [
        html.h1([], [
          html.a([attribute.href("/")], [html.text("Formz")]),
          html.text(": "),
          html.a([attribute.href("")], [html.text(name)]),
        ]),
        html.div([attribute.class("container")], [
          html.pre([attribute.class("code")], [
            html.code([attribute.class("langauge-gleam")], [
              html.text(code |> string.trim),
            ]),
          ]),
          post_data
            |> option.map(show_post(
              _,
              errors_list,
              output,
              has_output_discrepancy,
              has_error_discrepancy,
            ))
            |> option.unwrap(element.none()),
          show_forms(string_form, lustre_form, nakai_form),
        ]),
      ]),
    ])
    |> element.to_document_string_builder

  wisp.ok() |> wisp.html_body(html)
}

pub fn show_post(
  input_data: List(#(String, String)),
  errors: List(#(String, String)),
  output: option.Option(a),
  has_output_discrepancy: Bool,
  has_error_discrepancy: Bool,
) {
  let input_rows =
    element.fragment(
      input_data
      // |> list.reverse
      |> list.map(fn(t) {
        let #(key, value) = t
        let error = list.key_find(errors, key) |> result.unwrap("")
        html.tr([], [
          html.td([], [html.text(key)]),
          html.td([], [html.text(string.inspect(value))]),
          html.td([], [html.text(error)]),
        ])
      }),
    )

  let errors_no_post =
    errors
    |> list.filter_map(fn(t) {
      let #(key, _) = t
      case list.key_find(input_data, key) {
        Ok(_) -> Error(Nil)
        Error(_) -> Ok(t)
      }
    })

  let error_rows = case errors_no_post {
    [] -> element.none()
    _ ->
      element.fragment(
        list.map(errors_no_post, fn(t) {
          let #(key, value) = t
          html.tr([], [
            html.td([], [html.text(key)]),
            html.td([], [html.text("<EMPTY>")]),
            html.td([], [html.text(value)]),
          ])
        }),
      )
  }
  let output_row = case output {
    option.None -> ""
    option.Some(val) -> string.inspect(val)
  }

  html.div([attribute.class("post")], [
    html.div([], [
      html.h2([attribute.classes([#("discrepancy", has_error_discrepancy)])], [
        html.text("Post data"),
      ]),
      html.table([attribute.class("input_data")], [
        html.tr([], [
          html.th([], [html.text("Key")]),
          html.th([], [html.text("Input value")]),
          html.th([], [html.text("Error")]),
        ]),
        input_rows,
        error_rows,
      ]),
      html.h2([attribute.classes([#("discrepancy", has_output_discrepancy)])], [
        html.text("Output"),
      ]),
      html.div(
        [
          attribute.classes([
            #("success", option.is_some(output)),
            #("error", option.is_none(output)),
          ]),
        ],
        [html.text(output_row)],
      ),
    ]),
  ])
}

fn show_forms(
  string_form: formz.Form(String, j),
  lustre_form: formz.Form(element.Element(msg), j),
  nakai_form: formz.Form(nhtml.Node, j),
) -> element.Element(msg) {
  html.table([attribute.classes([#("forms", True)])], [
    html.tr([], [
      html.th([attribute.style([#("width", "33.3%")])], [html.text("String")]),
      html.th([attribute.style([#("width", "33.3%")])], [html.text("Lustre")]),
      html.th([attribute.style([#("width", "33.3%")])], [html.text("Nakai")]),
    ]),
    html.tr([], [
      html.td([], [
        html.form([attribute.method("POST")], [
          html.div(
            [
              attribute.attribute(
                "dangerous-unescaped-html",
                simple_string.generate_form(string_form),
              ),
            ],
            [],
          ),
          html.p([], [
            html.button([attribute.type_("submit")], [html.text("Submit")]),
          ]),
        ]),
      ]),
      html.td([], [
        html.form([attribute.method("POST")], [
          simple_lustre.generate_form(lustre_form),
          html.p([], [
            html.button([attribute.type_("submit")], [html.text("Submit")]),
          ]),
        ]),
      ]),
      html.td([], [
        html.form([attribute.method("POST")], [
          html.div(
            [
              attribute.attribute(
                "dangerous-unescaped-html",
                simple_nakai.generate_form(nakai_form) |> nakai.to_string,
              ),
            ],
            [],
          ),
          html.p([], [
            html.button([attribute.type_("submit")], [html.text("Submit")]),
          ]),
        ]),
      ]),
    ]),
  ])
}
