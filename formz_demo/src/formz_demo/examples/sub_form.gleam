import formz
import formz_string/definition

pub fn make_form() {
  use billing_address <- formz.subform(formz.named("billing"), address_form())
  use shipping_address <- formz.subform(formz.named("shipping"), address_form())

  formz.create_form(#(billing_address, shipping_address))
}

fn address_form() {
  use street <- formz.required_field(
    formz.named("street"),
    definition.text_field(),
  )
  use city <- formz.required_field(formz.named("city"), definition.text_field())
  use state <- formz.required_field(
    formz.named("state"),
    definition.list_field(states_list()),
  )
  use postal_code <- formz.required_field(
    formz.named("postal_code"),
    definition.text_field(),
  )

  formz.create_form(Address(street:, city:, state:, postal_code:))
}

pub type Address {
  Address(street: String, city: String, state: String, postal_code: String)
}

fn states_list() {
  [
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
    "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine",
    "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi",
    "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
    "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
    "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
    "Washington", "West Virginia", "Wisconsin", "Wyoming",
  ]
}
