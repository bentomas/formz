import formz/field.{field}
import formz/formz_use as formz
import formz_string/fields

pub fn make_form() {
  use billing_address <- formz.sub_form(
    "billing",
    "Billing Address",
    address_form(),
  )
  use shipping_address <- formz.sub_form(
    "shipping",
    "Shipping Address",
    address_form(),
  )

  formz.create_form(#(billing_address, shipping_address))
}

fn address_form() {
  use street <- formz.with(field("street"), fields.text_field())
  use city <- formz.with(field("city"), fields.text_field())
  use state <- formz.with(field("state"), fields.list_field(states_list()))
  use postal_code <- formz.with(field.field("postal_code"), fields.text_field())

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
