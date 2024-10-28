import formz/field

pub type Widget(format) =
  fn(field.Field, Args) -> format

pub type Args {
  Args(id: String, labelled_by: LabelledBy, described_by: DescribedBy)
}

pub type LabelledBy {
  LabelledByLabelFor
  LabelledByFieldValue
  LabelledByElementWithId(id: String)
}

pub type DescribedBy {
  DescribedByElementWithId(id: String)
  DescribedByNone
}
