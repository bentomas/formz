import formz_demo/examples/example_2/lustre
import formz_demo/examples/example_2/nakai
import formz_demo/examples/example_2/strings

pub fn make_forms() {
  #(
    "example_2",
    "All the inputs",
    strings.make_form(),
    lustre.make_form(),
    nakai.make_form(),
  )
}
