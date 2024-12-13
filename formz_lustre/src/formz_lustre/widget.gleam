//// The goal of a "widget" in `formz` is to produce an HTML input like
//// `<input>`, `<select>`, or `<textarea>`. In a [`Definition`](https://hexdocs.pm/formz/formz/definition.html),
//// a widget can be any Gleam type, and it's up to the form generator being
//// used to know the exact type you need.
////
//// That said, in the bundled form generators a widget is a function that
//// takes the details of a field and some render time arguments that the form
//// generator needs to construct an input.  This module is for those form
//// generators, and it's use is optional if you have different needs.

import formz
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html

pub type Widget(msg) {
  Widget(fn(formz.Config, formz.InputState, Args) -> element.Element(msg))
  Hidden
}

pub type Args {
  Args(
    /// The id of the input element.
    id: String,
    /// Details of how the input is labelled. Some sort of label is required for accessibility.
    labelled_by: LabelledBy,
    /// Details of how the input is described. This is optional, but can be useful for accessibility.
    described_by: DescribedBy,
  )
}

pub type LabelledBy {
  /// The input is labelled by a `<label>` element with a `for` attribute
  /// pointing to this input's id. This has the best accessibility support
  /// and should be [preferred when possible](https://www.w3.org/WAI/tutorials/forms/labels/).
  LabelledByLabelFor
  /// The input should be labelled using the `formz.Config`'s `label` field.
  LabelledByFieldValue
  /// The input is labelled by elements with the specified ids.
  LabelledByElementsWithIds(ids: List(String))
}

pub type DescribedBy {
  /// The input is described by elements with the specified ids. This is useful
  /// for additional instructions or error messages.
  DescribedByElementsWithIds(ids: List(String))
  DescribedByNone
}

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
  labelled_by: LabelledBy,
  label: String,
) -> attribute.Attribute(msg) {
  case labelled_by {
    LabelledByLabelFor -> attribute.none()
    LabelledByElementsWithIds(ids) ->
      attribute.attribute("aria-labelledby", string.join(ids, " "))
    LabelledByFieldValue ->
      case label {
        "" -> attribute.none()
        _ -> attribute.attribute("aria-label", label)
      }
  }
}

fn aria_describedby_attr(described_by: DescribedBy) -> attribute.Attribute(msg) {
  case described_by {
    DescribedByNone -> attribute.none()
    DescribedByElementsWithIds(ids) -> {
      case ids |> list.filter(fn(x) { !string.is_empty(x) }) {
        [] -> attribute.none()
        non_empty_ids ->
          attribute.attribute(
            "aria-describedby",
            string.join(non_empty_ids, " "),
          )
      }
    }
  }
}

fn value_attr(value: String) -> attribute.Attribute(msg) {
  case value {
    "" -> attribute.none()
    _ -> attribute.value(value)
  }
}

fn required_attr(requirement: formz.Requirement) -> attribute.Attribute(msg) {
  case requirement {
    formz.Required -> attribute.required(True)
    formz.Optional -> attribute.none()
  }
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

/// Create an `<input type="checkbox">`. The checkbox is checked
/// if the value is "on" (the browser default).
pub fn checkbox_widget() {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    let value = state.value
    let state = case state {
      formz.Unvalidated(_, requirement) -> formz.Unvalidated("", requirement)
      formz.Valid(_, requirement) -> formz.Valid("", requirement)
      formz.Invalid(_, requirement, e) -> formz.Invalid("", requirement, e)
    }
    do_input_widget(config, state, args, "checkbox", [checked_attr(value)])
  })
}

/// Create a `<input type="number">`.  Normally browsers only allow whole numbers,
/// unless a decimal step size is provided.  The step size here is a string that
/// will be put straight into the `step-size` attribute.  Doing non-whole numbers
/// this way does mean that a user can only input numbers up to the precision of
/// the step size.  If you truly need any float, then a `type="text"` input might be a
/// better choice.
pub fn number_widget(step_size: String) {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    do_input_widget(config, state, args, "number", [step_size_attr(step_size)])
  })
}

/// Create an `<input type="password">`. This will not output the value in the
/// generated HTML for privacy/security concerns.
pub fn password_widget() {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    let state = case state {
      formz.Unvalidated(_, requirement) -> formz.Unvalidated("", requirement)
      formz.Valid(_, requirement) -> formz.Valid("", requirement)
      formz.Invalid(_, requirement, e) -> formz.Invalid("", requirement, e)
    }
    do_input_widget(config, state, args, "password", [])
  })
}

/// Generate any `<input>` like `type="text"`, `type="email"` or
/// `type="url"`.
pub fn input_widget(type_: String) {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    do_input_widget(config, state, args, type_, [])
  })
}

fn do_input_widget(
  config: formz.Config,
  state: formz.InputState,
  args: Args,
  type_: String,
  extra_attrs: List(attribute.Attribute(msg)),
) {
  html.input(
    list.flatten([
      [
        attribute.type_(type_),
        name_attr(config.name),
        id_attr(args.id),
        required_attr(state.requirement),
        disabled_attr(config.disabled),
        value_attr(state.value),
        aria_label_attr(args.labelled_by, config.label),
        aria_describedby_attr(args.described_by),
      ],
      extra_attrs,
    ]),
  )
}

/// Create a `<textarea></textarea>`.
pub fn textarea_widget() {
  Widget(
    fn(config: formz.Config, state: formz.InputState, args: Args) -> element.Element(
      msg,
    ) {
      html.textarea(
        [
          name_attr(config.name),
          id_attr(args.id),
          required_attr(state.requirement),
          aria_label_attr(args.labelled_by, config.label),
          aria_describedby_attr(args.described_by),
        ],
        state.value,
      )
    },
  )
}

/// Create a `<input type="hidden">`. This is useful for if a field is just
/// passing data around and you don't want it to be visible to the user. Like
/// say, the ID of a record being edited.
pub fn hidden_widget() {
  Hidden
}

/// Create a `<select></select>` with `<option>`s for each variant.  The list
/// of variants is a two-tuple, where the first item is the text to display and
/// the second item is the value.
pub fn select_widget(variants: List(#(String, String))) {
  Widget(
    fn(config: formz.Config, state: formz.InputState, args: Args) -> element.Element(
      msg,
    ) {
      html.select(
        [
          name_attr(config.name),
          id_attr(args.id),
          required_attr(state.requirement),
          aria_label_attr(args.labelled_by, config.label),
          aria_describedby_attr(args.described_by),
        ],
        list.flatten([
          [html.option([attribute.value("")], "Select..."), html.hr([])],
          list.map(variants, fn(variant) {
            let val = variant.1
            html.option(
              [attribute.value(val), attribute.selected(state.value == val)],
              variant.0,
            )
          }),
        ]),
      )
    },
  )
}
