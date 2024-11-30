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
  Valid(
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
    /// Whether the field is required. This field is not functional, but is purely
    /// for whether or not the form generator should indicate to the user that the
    /// field is required.  Add the field to the form with either `optional` or
    /// `required` methods to control this functionally.  Those methods will make
    /// sure this field is set correctly.
    required: Bool,
    /// Whether the field is hidden. A hidden field is not displayed in the browser.
    hidden: Bool,
    /// The value of the field. This is normally set from via the `data` function on
    /// the form, but this can be set manually if you need default or initial values
    /// for a particular field.
    value: String,
  )
  Invalid(
    name: String,
    label: String,
    help_text: String,
    disabled: Bool,
    required: Bool,
    hidden: Bool,
    value: String,
    /// An error message for the field. This is set if a parser function from a
    /// definition fails for a field.  You can also set it yourself if you have
    /// an error that isn't related to parsing, but is with the actual data
    /// itself.
    error: String,
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
  Valid(
    name: name,
    label: justin.sentence_case(name),
    help_text: "",
    disabled: False,
    required: False,
    hidden: False,
    value: "",
  )
}

pub fn set_name(field: Field, name: String) -> Field {
  case field {
    Valid(..) -> Valid(..field, name:)
    Invalid(..) -> Invalid(..field, name:)
  }
}

pub fn set_label(field: Field, label: String) -> Field {
  case field {
    Valid(..) -> Valid(..field, label:)
    Invalid(..) -> Invalid(..field, label:)
  }
}

pub fn set_help_text(field: Field, help_text: String) -> Field {
  case field {
    Valid(..) -> Valid(..field, help_text:)
    Invalid(..) -> Invalid(..field, help_text:)
  }
}

pub fn set_hidden(field: Field, hidden: Bool) -> Field {
  case field {
    Valid(..) -> Valid(..field, hidden:)
    Invalid(..) -> Invalid(..field, hidden:)
  }
}

@internal
pub fn set_required(field: Field, required: Bool) -> Field {
  case field {
    Valid(..) -> Valid(..field, required:)
    Invalid(..) -> Invalid(..field, required:)
  }
}

pub fn make_hidden(field: Field) -> Field {
  set_hidden(field, True)
}

pub fn set_disabled(field: Field, disabled: Bool) -> Field {
  case field {
    Valid(..) -> Valid(..field, disabled:)
    Invalid(..) -> Invalid(..field, disabled:)
  }
}

pub fn make_disabled(field: Field) -> Field {
  set_disabled(field, True)
}

pub fn set_raw_value(field: Field, value: String) -> Field {
  case field {
    Valid(..) -> Valid(..field, value:)
    Invalid(..) -> Invalid(..field, value:)
  }
}

pub fn set_error(field: Field, error: String) -> Field {
  case field {
    Valid(name:, label:, help_text:, hidden:, value:, disabled:, required:) ->
      Invalid(
        name:,
        label:,
        help_text:,
        hidden:,
        value:,
        disabled:,
        required:,
        error:,
      )
    Invalid(..) -> Invalid(..field, error:)
  }
}
