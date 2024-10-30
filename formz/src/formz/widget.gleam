import formz/field

pub type Widget(format) =
  fn(field.Field, Args) -> format

pub type Args {
  Args(id: String, labelled_by: LabelledBy, described_by: DescribedBy)
}

pub type LabelledBy {
  LabelledByLabelFor
  LabelledByFieldValue
  LabelledByElementsWithIds(ids: List(String))
}

pub type DescribedBy {
  DescribedByElementsWithIds(ids: List(String))
  DescribedByNone
}

pub fn args(labelled_by labelled_by: LabelledBy) {
  Args(id: "", labelled_by: labelled_by, described_by: DescribedByNone)
}

pub fn id(args: Args, str: String) {
  Args(..args, id: str)
}

pub fn described_by(args: Args, db: DescribedBy) {
  Args(..args, described_by: db)
}
