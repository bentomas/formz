import formz
import formz_lustre/simple as lustre_simple
import formz_nakai/simple as nakai_simple
import formz_string/simple
import lustre/element
import nakai
import nakai/html
import wisp

pub fn handle_get(
  form: formz.Form(format, output),
) -> formz.Form(format, output) {
  form
}

pub fn handle_post(
  formdata: wisp.FormData,
  form: formz.Form(format, output),
) -> Result(output, formz.Form(format, output)) {
  form
  |> formz.data(formdata.values)
  |> formz.decode()
}

pub fn format_string_form(form) -> String {
  simple.generate(form)
}

pub fn format_lustre_form(form) -> element.Element(msg) {
  lustre_simple.generate(form)
}

pub fn format_nakai_form(form) -> html.Node {
  nakai_simple.generate(form)
}

pub fn formatted_string_form_to_string(str) -> String {
  str
}

pub fn formatted_lustre_form_to_string(element: element.Element(msg)) -> String {
  element.to_string(element)
}

pub fn formatted_nakai_form_to_string(node: html.Node) -> String {
  nakai.to_inline_string(node)
}
