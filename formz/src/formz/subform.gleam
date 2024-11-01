import justin

pub type SubForm {
  SubForm(name: String, label: String, help_text: String)
}

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
