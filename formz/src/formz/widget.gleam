//// Input widgets, like `<input>` or `<select>` or `<textarea>` in HTML.
//// A widget is essentially just a function that takes the details of a field,
//// and any render time information that the form generator might need to pass
//// to an input.  e.g. HTML forms elements often need an `id`.
////
//// I've chosen to make the type of the Args here a specific type, rather than
//// something more generic and that any form generator could make.  That's mostly
//// to simplify this package a bit, but it would be easy to make it custom if
//// people need something more versatile without changing the UX experience much.
//// I just don't know if that's necessary. Let me know!

import formz/field

pub type Widget(format) =
  fn(field.Field, Args) -> format

pub type Args {
  Args(
    /// The id of the input element.
    id: String,
    /// Details of how the input is labelled. Some sort of label is required for accessibility.
    labelled_by: LabelledBy,
    /// Details of how the input is described. This is optional, but can be useful for accessibility.
    described_by: DescribedBy,
  )
}

pub type LabelledBy {
  /// The input is labelled by a `<label>` element with a `for` attribute
  /// pointing to this input's id. This has the best accessibility support
  /// and should be [preferred when possible](https://www.w3.org/WAI/tutorials/forms/labels/).
  LabelledByLabelFor
  /// The input should be labelled using the `Field`'s `label` field.
  LabelledByFieldValue
  /// The input is labelled by elements with the specified ids.
  LabelledByElementsWithIds(ids: List(String))
}

pub type DescribedBy {
  /// The input is described by elements with the specified ids. This is useful
  /// for additional instructions or error messages.
  DescribedByElementsWithIds(ids: List(String))
  DescribedByNone
}

/// helper function to create an Args with the minimum required fields
pub fn args(labelled_by labelled_by: LabelledBy) {
  Args(id: "", labelled_by: labelled_by, described_by: DescribedByNone)
}

pub fn id(args: Args, str: String) {
  Args(..args, id: str)
}

pub fn described_by(args: Args, db: DescribedBy) {
  Args(..args, described_by: db)
}
