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
  input_data: List(#(String, String)),
  errors_list: List(#(String, String)),
  output: option.Option(a),
  string_form: formz.Form(String, a),
  lustre_form: formz.Form(element.Element(msg), a),
  nakai_form: formz.Form(nhtml.Node, a),
) -> Response {
  let html =
    html([], [
      html.head([], [
        html.title([], "Gleam formz!"),
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
        html.style(
          [],
          "
      body { font-family: sans-serif; }

      h1 {
        margin: 10px;
        font-size: 1.5em;
      }

      .container {
        display: grid;
        grid-template-columns: auto minmax(300px, 600px);
        grid-template-rows: auto;
        grid-template-areas:
            \"code post\"
            \"forms forms\";
        width: 100%;
      }

      .code {
        grid-area: code;
        float;
        white-space: pre;
        margin: 0 7px 20px;

        code {
          font-family: ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, Consolas, 'DejaVu Sans Mono', monospace;
          font-weight: normal;
          font-size: 1.1em;
        }
      }

      .post {
        > div {
          margin: 0 7px 20px;
          grid-area: post;

          > div {
            font-family: ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, Consolas, 'DejaVu Sans Mono', monospace;
            min-height: 18px;
          }

          > div.success {
            padding: 10px;
            background: #90EE90;
          }

          > div.error {
            padding: 10px;
            background: #FF5733;
          }

          h2 {
            background: #444;
            color: #fafafa;
            padding: 5px;
            margin: 0;
            font-size: 12px;
            text-transform: uppercase;
            font-weight: normal;
          }
        }
      }

      table.input_data {
        border-spacing: 0;
        border-collapse: collapse;
        width: 100%;

        th {
          text-align: left;
          font-weight: normal;
          background: #bbb;
          padding: 10px;
        }

        td:nth-child(1), td:nth-child(2) {
          font-family: ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, Consolas, 'DejaVu Sans Mono', monospace;
        }
        td {
          background: #eee;
          padding: 10px;
        }
      }

      table.forms {
        width: 100%;
        border-spacing: 7px 0;
        grid-area: forms;

        th {
          text-align: left;
          font-weight: normal;
          background: #bbb;
          padding: 10px;
        }

        td {
          background: #eee;
          padding: 10px;
        }
      }
      ",
        ),
      ]),
      html.body([], [
        html.h1([], [html.text(name)]),
        html.div([attribute.class("container")], [
          html.pre([attribute.class("code")], [
            html.code([attribute.class("langauge-gleam")], [
              html.text(code |> string.trim),
            ]),
          ]),
          show_post(input_data, errors_list, output),
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
) {
  let input_rows =
    element.fragment(
      list.map(input_data, fn(t) {
        let #(key, value) = t
        let error = list.key_find(errors, key) |> result.unwrap("")
        html.tr([], [
          html.td([], [html.text(key)]),
          html.td([], [html.text(string.inspect(value))]),
          html.td([], [html.text(error)]),
        ])
      }),
    )

  let output_row = case output {
    option.None -> ""
    option.Some(val) -> string.inspect(val)
  }

  case input_data {
    [] -> element.none()
    _ ->
      html.div([attribute.class("post")], [
        html.div([], [
          html.h2([], [html.text("Post data")]),
          html.table([attribute.class("input_data")], [
            html.tr([], [
              html.th([], [html.text("Key")]),
              html.th([], [html.text("Value")]),
              html.th([], [html.text("Error")]),
            ]),
            input_rows,
          ]),
          html.h2([], [html.text("Output")]),
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
          html.input([
            attribute.type_("hidden"),
            attribute.value("string"),
            attribute.name("__generator"),
          ]),
        ]),
      ]),
      html.td([], [
        html.form([attribute.method("POST")], [
          simple_lustre.generate_form(lustre_form),
          html.input([
            attribute.type_("hidden"),
            attribute.value("lustre"),
            attribute.name("__generator"),
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
          html.input([
            attribute.type_("hidden"),
            attribute.value("nakai"),
            attribute.name("__generator"),
          ]),
        ]),
      ]),
    ]),
  ])
}
