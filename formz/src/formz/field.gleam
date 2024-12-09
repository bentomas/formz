//// A `Field` is the first argument needed to add a field to a form. It contains
//// information about this specific field, like it's name, label, or (optional)
//// help_text. There is a convenience function to create a field with just a name,
//// and then you can use the rest of the functions to set just the values you
//// need to change.
////
//// ```gleam
//// field("name") |> set_label("Full Name")
//// ```
////
//// ```gleam
//// field("name")
//// |> set_label("Full Name")
//// |> set_help_text("You can make one up if you'd like.")
//// ```

import justin

pub type Field {
  Field(
    /// The name of the field. The only truly required information for a field.
    /// This is used to identify the field in the form. It should be unique for
    /// each form, and is untested with any values other than strings solely
    /// consisting of alphanumeric characters and underscores.
    name: String,
    /// This library thinks of a label as required, but will make one for you from
    /// the name if you don't provide one via the `field` function. For
    /// accessibility reasons, a field should always provide a label and all
    /// the maintained form generators will output one.
    label: String,
    /// Optional help text for the field. This is used to provide additional
    /// instructions or context for the field.  It is up to the form generator
    /// to decide if and how to display this text.
    help_text: String,
    /// Whether the field is disabled. A disabled field is not editable in
    /// the browser.  However, there is nothing stopping a user from changing
    /// the value or submitting a different value via other means, so (presently)
    /// this doesn't mean the value cannot be tampered with.
    disabled: Bool,
  )
}

/// Create a field with the given name. It uses [justin.sentence_case](https://hexdocs.pm/justin/justin.html#sentence_case)
/// to create a label. You can override the label with the `set_label` function.
///
/// ```gleam
/// field("name")
/// |> set_label("Full Name")
/// ```
pub fn field(named name: String) -> Field {
  Field(
    name: name,
    label: justin.sentence_case(name),
    help_text: "",
    disabled: False,
  )
}

pub fn set_name(field: Field, name: String) -> Field {
  Field(..field, name:)
}

pub fn set_label(field: Field, label: String) -> Field {
  Field(..field, label:)
}

pub fn set_help_text(field: Field, help_text: String) -> Field {
  Field(..field, help_text:)
}

pub fn set_disabled(field: Field, disabled: Bool) -> Field {
  Field(..field, disabled:)
}

pub fn make_disabled(field: Field) -> Field {
  set_disabled(field, True)
}
