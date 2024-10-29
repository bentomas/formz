import formz/field.{type Field}
import formz/widget
import gleam/list
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
    widget.LabelledByElementWithId(id) ->
      attribute.attribute("aria-labelledby", id)
    widget.LabelledByFieldValue ->
      case label {
        "" -> attribute.none()
        _ -> attribute.attribute("aria-label", label)
      }
  }
}

fn value_attr(value: String) -> attribute.Attribute(msg) {
  case value {
    "" -> attribute.none()
    _ -> attribute.value(value)
  }
}

pub fn checkbox_widget() {
  fn(input: Field, args: widget.Args) -> element.Element(msg) {
    html.input([
      attribute.type_("checkbox"),
      name_attr(input.name),
      id_attr(args.id),
      attribute.checked(input.value == "on"),
      aria_label_attr(args.labelled_by, input.label),
    ])
  }
}

pub fn password_widget() {
  fn(input: Field, args: widget.Args) -> element.Element(msg) {
    html.input([
      attribute.type_("password"),
      name_attr(input.name),
      id_attr(args.id),
      // value_attr(input.value),
      aria_label_attr(args.labelled_by, input.label),
    ])
  }
}

pub fn text_widget() {
  text_like_widget("text")
}

pub fn text_like_widget(type_: String) {
  fn(input: Field, args: widget.Args) -> element.Element(msg) {
    html.input([
      attribute.type_(type_),
      name_attr(input.name),
      id_attr(args.id),
      value_attr(input.value),
      aria_label_attr(args.labelled_by, input.label),
    ])
  }
}

pub fn textarea_widget() {
  fn(input: Field, args: widget.Args) -> element.Element(msg) {
    html.textarea(
      [
        name_attr(input.name),
        id_attr(args.id),
        aria_label_attr(args.labelled_by, input.label),
      ],
      input.value,
    )
  }
}

pub fn hidden_widget() {
  fn(input: Field, _args: widget.Args) -> element.Element(msg) {
    html.input([
      attribute.type_("hidden"),
      name_attr(input.name),
      value_attr(input.value),
    ])
  }
}

pub fn select_widget(variants: List(#(String, String))) {
  fn(input: Field, args: widget.Args) -> element.Element(msg) {
    html.select(
      [
        name_attr(input.name),
        id_attr(args.id),
        aria_label_attr(args.labelled_by, input.label),
      ],
      list.flatten([
        [html.option([attribute.value("")], "Select..."), html.hr([])],
        list.map(variants, fn(variant) {
          let val = variant.1
          html.option(
            [attribute.value(val), attribute.selected(input.value == val)],
            variant.0,
          )
        }),
      ]),
    )
  }
}
