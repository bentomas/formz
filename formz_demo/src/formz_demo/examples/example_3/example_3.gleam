import formz_demo/examples/example_3/lustre
import formz_demo/examples/example_3/nakai
import formz_demo/examples/example_3/strings

pub fn make_forms() {
  #(
    "example_3",
    "Labels",
    strings.make_form(),
    lustre.make_form(),
    nakai.make_form(),
  )
}
