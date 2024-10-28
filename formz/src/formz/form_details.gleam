import justin

pub type FormDetails {
  FormDetails(name: String, label: String, help_text: String, disabled: Bool)
}

pub fn form_details(name) {
  FormDetails(name, justin.sentence_case(name), "", False)
}

pub fn set_name(sub: FormDetails, name: String) -> FormDetails {
  FormDetails(..sub, name:)
}

pub fn set_label(sub: FormDetails, label: String) -> FormDetails {
  FormDetails(..sub, label:)
}

pub fn set_help_text(sub: FormDetails, help_text: String) -> FormDetails {
  FormDetails(..sub, help_text:)
}

pub fn make_disabled(sub: FormDetails) -> FormDetails {
  FormDetails(..sub, disabled: True)
}

pub fn make_enabled(sub: FormDetails) -> FormDetails {
  FormDetails(..sub, disabled: False)
}
