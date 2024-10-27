import formz/field

pub type Widget(format) =
  fn(field.Field, Args) -> format

pub type Args {
  Args(id: String, labelled_by: LabelledBy)
}

pub type LabelledBy {
  LabelledByLabelFor
  LabelledByFieldValue
  LabelledByElementWithId(id: String)
}
