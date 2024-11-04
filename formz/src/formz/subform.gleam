//// Detials about a subform being added to a form. There is a convenience
//// function to create a field with just a name, and then you can use the rest
//// of the functions to set just the values you need to change.

import justin

pub type SubForm {
  SubForm(
    /// The name of the subform. This is used to prefix all the fields of the
    /// subform, so it should be unique for each subform added to aform.
    /// It is untested with any values other than strings consisting solely
    /// of alphanumeric characters and underscores.
    name: String,
    /// The label of the subform. This is completely optional, but if the
    /// subform is rendered inside a `<fieldset>` then it is [recommended](https://www.w3.org/WAI/tutorials/forms/grouping/)
    /// to have a `<legend>` with this label.
    label: String,
    /// Help text for the subform.  There is less of a standard for this, but
    /// again, if rendered in a `<fieldset>` then `area-describedby` can be used
    /// to point to an element with this help text.
    help_text: String,
  )
}

/// Create a subform with the given name. It uses [justin.sentence_case](https://hexdocs.pm/justin/justin.html#sentence_case)
/// to create a label. You can override the label with the `set_label` function.
///
/// ```gleam
/// subform("address")
/// |> set_label("Shipping Address")
/// ```
pub fn subform(name) {
  SubForm(name, justin.sentence_case(name), "")
}

pub fn set_name(sub: SubForm, name: String) -> SubForm {
  SubForm(..sub, name:)
}

pub fn set_label(sub: SubForm, label: String) -> SubForm {
  SubForm(..sub, label:)
}

pub fn set_help_text(sub: SubForm, help_text: String) -> SubForm {
  SubForm(..sub, help_text:)
}
