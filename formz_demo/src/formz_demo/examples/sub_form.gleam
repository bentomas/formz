import formz/field.{field}
import formz/form_details.{form_details}
import formz/formz_use as formz
import formz_string/definitions

pub fn make_form() {
  use billing_address <- formz.with_form(
    form_details("billing"),
    address_form(),
  )
  use shipping_address <- formz.with_form(
    form_details("shipping"),
    address_form(),
  )

  formz.create_form(#(billing_address, shipping_address))
}

fn address_form() {
  use street <- formz.with(field("street"), definitions.text_field())
  use city <- formz.with(field("city"), definitions.text_field())
  use state <- formz.with(field("state"), definitions.list_field(states_list()))
  use postal_code <- formz.with(
    field.field("postal_code"),
    definitions.text_field(),
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
