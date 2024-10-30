import formz/field.{type Field}
import formz/widget
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html

fn id_attr(id: String) -> attribute.Attribute(msg) {
  case id {
    "" -> attribute.none()
    _ -> attribute.id(id)
  }
}

fn name_attr(name: String) -> attribute.Attribute(msg) {
  case name {
    "" -> attribute.none()
    _ -> attribute.name(name)
  }
}

fn aria_label_attr(
  labelled_by: widget.LabelledBy,
  label: String,
) -> attribute.Attribute(msg) {
  case labelled_by {
    widget.LabelledByLabelFor -> attribute.none()
    widget.LabelledByElementsWithIds(ids) ->
      attribute.attribute("aria-labelledby", string.join(ids, " "))
    widget.LabelledByFieldValue ->
      case label {
        "" -> attribute.none()
        _ -> attribute.attribute("aria-label", label)
      }
  }
}

fn aria_describedby_attr(
  described_by: widget.DescribedBy,
) -> attribute.Attribute(msg) {
  case described_by {
    widget.DescribedByNone -> attribute.none()
    widget.DescribedByElementsWithIds(ids) ->
      attribute.attribute("aria-describedby", string.join(ids, " "))
  }
}

fn value_attr(value: String) -> attribute.Attribute(msg) {
  case value {
    "" -> attribute.none()
    _ -> attribute.value(value)
  }
}

fn required_attr(requried: Bool) -> attribute.Attribute(msg) {
  // case requried {
  //   True -> attribute.required(True)
  //   False -> attribute.none()
  // }
  attribute.required(requried)
}

fn step_size_attr(step_size: String) -> attribute.Attribute(msg) {
  case step_size {
    "" -> attribute.none()
    _ -> attribute.attribute("step", step_size)
  }
}

fn checked_attr(value: String) -> attribute.Attribute(msg) {
  case value {
    "on" -> attribute.checked(True)
    _ -> attribute.none()
  }
}

fn disabled_attr(disabled: Bool) -> attribute.Attribute(msg) {
  case disabled {
    True -> attribute.disabled(True)
    False -> attribute.none()
  }
}

// Create a checkbox widget (`<input type="checkbox">`). The checkbox is checked
// if the value is "on" (the browser default).
pub fn checkbox_widget() {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field |> field.set_raw_value(""), args, "checkbox", [
      checked_attr(field.value),
    ])
  }
}

pub fn number_widget(step_size: String) {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field, args, "number", [step_size_attr(step_size)])
  }
}

pub fn password_widget() {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field |> field.set_raw_value(""), args, "password", [])
  }
}

pub fn text_like_widget(type_: String) {
  fn(field: Field, args: widget.Args) {
    do_input_widget(field, args, type_, [])
  }
}

fn do_input_widget(
  field: Field,
  args: widget.Args,
  type_: String,
  extra_attrs: List(attribute.Attribute(msg)),
) {
  html.input(
    list.flatten([
      [
        attribute.type_(type_),
        name_attr(field.name),
        id_attr(args.id),
        required_attr(field.required),
        disabled_attr(field.disabled),
        value_attr(field.value),
        aria_label_attr(args.labelled_by, field.label),
        aria_describedby_attr(args.described_by),
      ],
      extra_attrs,
    ]),
  )
}

pub fn textarea_widget() {
  fn(field: Field, args: widget.Args) -> element.Element(msg) {
    html.textarea(
      [
        name_attr(field.name),
        id_attr(args.id),
        required_attr(field.required),
        aria_label_attr(args.labelled_by, field.label),
        aria_describedby_attr(args.described_by),
      ],
      field.value,
    )
  }
}

pub fn hidden_widget() {
  fn(field: Field, _args: widget.Args) -> element.Element(msg) {
    html.input([
      attribute.type_("hidden"),
      name_attr(field.name),
      value_attr(field.value),
    ])
  }
}

pub fn select_widget(variants: List(#(String, String))) {
  fn(field: Field, args: widget.Args) -> element.Element(msg) {
    html.select(
      [
        name_attr(field.name),
        id_attr(args.id),
        required_attr(field.required),
        aria_label_attr(args.labelled_by, field.label),
        aria_describedby_attr(args.described_by),
      ],
      list.flatten([
        [html.option([attribute.value("")], "Select..."), html.hr([])],
        list.map(variants, fn(variant) {
          let val = variant.1
          html.option(
            [attribute.value(val), attribute.selected(field.value == val)],
            variant.0,
          )
        }),
      ]),
    )
  }
}
