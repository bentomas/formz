//// The goal of a "widget" in `formz` is to produce an HTML input like
//// `<input>`, `<select>`, or `<textarea>`. In a [`Definition`](https://hexdocs.pm/formz/formz/definition.html),
//// a widget can be any Gleam type, and it's up to the form generator being
//// used to know the exact type you need.
////
//// That said, in the bundled form generators a widget is a function that
//// takes the details of a field and some render time arguments that the form
//// generator needs to construct an input.  This module is for those form
//// generators, and it's use is optional if you have different needs.

import formz
import formz/field
import nakai/html

pub type Widget =
  fn(field.Field, formz.FieldState, Args) -> html.Node

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
