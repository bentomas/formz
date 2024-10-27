import formz/field.{field}
import formz/formz_use as formz
import formz/subform.{subform}
import formz_lustre/definitions
import formz_lustre/simple
import gleam/list
import lustre/attribute
import lustre/element/html

pub fn make_form() {
  use billing_address <- formz.with_form(subform("billing"), address_form())
  use shipping_address <- formz.with_form(subform("shipping"), address_form())

  formz.create_form(#(billing_address, shipping_address))
}

fn address_form() {
  use street <- formz.with(field("street"), definitions.text_field())
  use city <- formz.with(field("city"), definitions.text_field())
  use state <- formz.with(field("state"), definitions.list_field(states_list()))
  use postal_code <- formz.with(field("postal_code"), definitions.text_field())

  formz.create_form(Address(street:, city:, state:, postal_code:))
}

pub fn format_form(form) {
  let assert Ok(formz.Set(_, billing_inputs)) = formz.get(form, "billing")
  html.div(
    [
      attribute.role("group"),
      attribute.attribute("aria-labelledby", "h2"),
      attribute.disabled(True),
    ],
    [
      html.h2([attribute.id("h2")], [html.text("Billing Address")]),
      ..list.map(billing_inputs, simple.generate_item)
    ],
  )
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