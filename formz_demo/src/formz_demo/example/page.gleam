import formz/field
import formz/formz_use as formz
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import justin
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import pprint
import wisp.{type Response}

pub fn build_page(
  name: String,
  code: String,
  post_data: option.Option(List(#(String, String))),
  output: option.Option(a),
  formyyyy: formz.Form(format, b),
  formatted_form: String,
) -> Response {
  let html =
    html([], [
      html.head([], [
        html.title([], "Gleam formz!"),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href("/static/stylesheet.css"),
        ]),
      ]),
      html.body([], [
        html.h1([], [
          html.a([attribute.href("/")], [html.text("Formz")]),
          html.text(": "),
          html.a([attribute.href("")], [html.text(justin.sentence_case(name))]),
        ]),
        html.div([attribute.class("container")], [
          show_post(post_data, output, formyyyy),
          show_form(formatted_form),
          show_code(code),
        ]),
      ]),
    ])
    |> element.to_document_string_builder

  wisp.ok() |> wisp.html_body(html)
}

fn get_inputs(form: formz.Form(format, ouput)) {
  form |> formz.get_items |> do_get_inputs([]) |> list.reverse
}

fn do_get_inputs(items: List(formz.FormItem(format)), acc) {
  case items {
    [] -> acc
    [formz.Item(input), ..rest] -> do_get_inputs(rest, [input, ..acc])
    [formz.Set(_, items), ..rest] ->
      do_get_inputs(list.flatten([items, rest]), acc)
  }
}

pub fn show_post(
  input_data: option.Option(List(#(String, String))),
  output: option.Option(a),
  form: formz.Form(format, b),
) {
  case input_data {
    option.None -> element.none()
    option.Some(input_data) -> {
      let fields_no_post =
        form
        |> get_inputs
        |> list.map(fn(i) {
          html.tr([], [
            html.td([], [html.text(i.name)]),
            html.td([], [
              html.text(
                list.key_find(input_data, i.name)
                |> result.map(string.inspect)
                |> result.unwrap("<EMPTY>"),
              ),
            ]),
            html.td([], [
              html.text(case i {
                field.Valid(..) -> ""
                field.Invalid(error:, ..) -> error
              }),
            ]),
          ])
        })
        |> element.fragment

      let output_row = case output {
        option.None -> ""
        option.Some(val) -> {
          let str = string.inspect(val)
          case string.length(str) {
            x if x < 50 -> str
            _ -> pprint.format(val)
          }
        }
      }

      html.div([attribute.class("post")], [
        html.div([], [
          html.h2([], [html.text("Post data")]),
          html.table([attribute.class("input_data")], [
            html.tr([], [
              html.th([], [html.text("Key")]),
              html.th([], [html.text("Input value")]),
              html.th([], [html.text("Error")]),
            ]),
            // input_rows,
            fields_no_post,
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
}

fn show_form(formatted_from: String) -> element.Element(msg) {
  html.form([attribute.method("POST"), attribute.class("form")], [
    html.div(
      [attribute.attribute("dangerous-unescaped-html", formatted_from)],
      [],
    ),
    html.p([], [html.button([attribute.type_("submit")], [html.text("Submit")])]),
  ])
}

fn show_code(code: String) -> element.Element(msg) {
  html.div([attribute.class("code")], [
    html.pre([], [
      html.code([attribute.class("langauge-gleam hljs")], [
        html.text(code |> string.trim),
      ]),
    ]),
  ])
}
