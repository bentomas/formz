import formz/field.{type Field, type WidgetArgs, WidgetArgs}
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
  labelled_by: field.InputLabelled,
  label: String,
) -> attribute.Attribute(msg) {
  case labelled_by {
    field.Element -> attribute.none()
    field.Id(id) -> attribute.attribute("aria-labelledby", id)
    field.Value ->
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
  field.widget(
    fn(input: Field(element.Element(msg)), args: WidgetArgs) -> element.Element(
      msg,
    ) {
      html.input([
        attribute.type_("checkbox"),
        name_attr(input.name),
        id_attr(args.id),
        attribute.checked(input.value == "on"),
        aria_label_attr(args.labelled_by, input.label),
      ])
    },
  )
}

pub fn password_widget() {
  field.widget(
    fn(input: Field(element.Element(msg)), args: WidgetArgs) -> element.Element(
      msg,
    ) {
      html.input([
        attribute.type_("password"),
        name_attr(input.name),
        id_attr(args.id),
        // value_attr(input.value),
        aria_label_attr(args.labelled_by, input.label),
      ])
    },
  )
}

pub fn text_widget() {
  text_like_widget("text")
}

pub fn text_like_widget(type_: String) {
  field.widget(
    fn(input: Field(element.Element(msg)), args: WidgetArgs) -> element.Element(
      msg,
    ) {
      html.input([
        attribute.type_(type_),
        name_attr(input.name),
        id_attr(args.id),
        value_attr(input.value),
        aria_label_attr(args.labelled_by, input.label),
      ])
    },
  )
}

pub fn textarea_widget() {
  field.widget(
    fn(input: Field(element.Element(msg)), args: WidgetArgs) -> element.Element(
      msg,
    ) {
      html.textarea(
        [
          name_attr(input.name),
          id_attr(args.id),
          aria_label_attr(args.labelled_by, input.label),
        ],
        input.value,
      )
    },
  )
}

pub fn hidden_widget() {
  field.widget(
    fn(input: Field(element.Element(msg)), _args: WidgetArgs) -> element.Element(
      msg,
    ) {
      html.input([
        attribute.type_("hidden"),
        name_attr(input.name),
        value_attr(input.value),
      ])
    },
  )
}

pub fn select_widget(variants: List(#(String, value))) {
  field.widget(
    fn(input: Field(element.Element(msg)), args: WidgetArgs) -> element.Element(
      msg,
    ) {
      html.select(
        [attribute.name(input.name)],
        list.map(variants, fn(variant) {
          let val = string.inspect(variant.1)
          html.option(
            [attribute.value(val), attribute.selected(input.value == val)],
            variant.0,
          )
        }),
      )

      html.select(
        [
          name_attr(input.name),
          id_attr(args.id),
          aria_label_attr(args.labelled_by, input.label),
        ],
        list.flatten([
          [html.option([attribute.value("")], "Select..."), html.hr([])],
          list.map(variants, fn(variant) {
            let val = string.inspect(variant.1)
            html.option(
              [value_attr(val), attribute.selected(input.value == val)],
              variant.0,
            )
          }),
        ]),
      )
    },
  )
}
