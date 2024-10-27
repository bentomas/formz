import justin

pub type SubForm {
  SubForm(name: String, label: String, disabled: Bool)
}

pub fn subform(name) {
  SubForm(name, justin.sentence_case(name), False)
}

pub fn set_name(fs: SubForm, name: String) -> SubForm {
  SubForm(..fs, name:)
}

pub fn set_label(fs: SubForm, label: String) -> SubForm {
  SubForm(..fs, label:)
}

pub fn make_disabled(fs: SubForm) -> SubForm {
  SubForm(..fs, disabled: True)
}

pub fn make_enabled(fs: SubForm) -> SubForm {
  SubForm(..fs, disabled: False)
}
