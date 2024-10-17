import formz_demo/examples/example_1/lustre
import formz_demo/examples/example_1/nakai
import formz_demo/examples/example_1/strings

pub fn make_forms() {
  #(
    "example_1",
    "Hello world",
    strings.make_form(),
    lustre.make_form(),
    nakai.make_form(),
  )
}
