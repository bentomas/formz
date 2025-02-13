//// The goal of a "widget" in `formz` is to produce an HTML input like
//// `<input>`, `<select>`, or `<textarea>`. In a formz `Definition`
//// a widget can be any Gleam type, and it's up to the form generator being
//// used to know the exact type you need.
////
//// In this generator, the widget is either a function that takes the details
//// and state of a field, or a special value for a hidden field.

import formz
import gleam/list
import gleam/string
import nakai/attr
import nakai/html

pub type Widget {
  Widget(fn(formz.Config, formz.InputState, Args) -> html.Node)
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
  LabelledByLabelElement
  /// The input should be labelled using the `formz.Config`'s `label`.
  LabelledByConfigValue
  /// The input is labelled by elements with the specified ids.
  LabelledByElementsWithIds(ids: List(String))
}

pub type DescribedBy {
  /// The input is described by elements with the specified ids. This is useful
  /// for additional instructions or error messages.
  DescribedByElementsWithIds(ids: List(String))
  DescribedByNone
}

fn id_attr(id: String) -> List(attr.Attr) {
  case id {
    "" -> []
    _ -> [attr.id(id)]
  }
}

fn name_attr(name: String) -> List(attr.Attr) {
  case name {
    "" -> []
    _ -> [attr.name(name)]
  }
}

fn aria_label_attr(labelled_by: LabelledBy, label: String) -> List(attr.Attr) {
  case labelled_by {
    LabelledByLabelElement -> []
    LabelledByElementsWithIds(ids) -> [
      attr.aria_labelledby(string.join(ids, " ")),
    ]
    LabelledByConfigValue ->
      case label {
        "" -> []
        _ -> [attr.aria_label(label)]
      }
  }
}

fn aria_describedby_attr(described_by: DescribedBy) -> List(attr.Attr) {
  case described_by {
    DescribedByNone -> []
    DescribedByElementsWithIds(ids) ->
      case ids |> list.filter(fn(x) { !string.is_empty(x) }) {
        [] -> []
        non_empty_ids -> [
          attr.Attr("aria-describedby", string.join(non_empty_ids, " ")),
        ]
      }
  }
}

fn type_attr(type_: String) -> List(attr.Attr) {
  [attr.type_(type_)]
}

fn value_attr(value: String) -> List(attr.Attr) {
  case value {
    "" -> []
    _ -> [attr.value(value)]
  }
}

fn required_attr(requirement: formz.Requirement) -> List(attr.Attr) {
  case requirement {
    formz.Required -> [attr.required("")]
    formz.Optional -> []
  }
}

fn checked_attr(value: String) -> List(attr.Attr) {
  case value {
    "on" -> [attr.checked()]
    _ -> []
  }
}

fn disabled_attr(disabled: Bool) -> List(attr.Attr) {
  case disabled {
    True -> [attr.disabled()]
    False -> []
  }
}

fn step_size_attr(step_size: String) -> List(attr.Attr) {
  case step_size {
    "" -> []
    _ -> [attr.Attr("step", step_size)]
  }
}

/// Create an `<input type="checkbox">`. The checkbox is checked
/// if the value is "on" (the browser default).
pub fn checkbox_widget() -> Widget {
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
  extra_attrs: List(List(attr.Attr)),
) {
  html.input(
    list.flatten([
      type_attr(type_),
      name_attr(config.name),
      id_attr(args.id),
      required_attr(state.requirement),
      value_attr(state.value),
      disabled_attr(config.disabled),
      aria_label_attr(args.labelled_by, config.label),
      aria_describedby_attr(args.described_by),
      extra_attrs |> list.flatten,
    ]),
  )
}

/// Create a `<textarea></textarea>`.
pub fn textarea_widget() {
  Widget(
    fn(config: formz.Config, state: formz.InputState, args: Args) -> html.Node {
      html.textarea(
        list.flatten([
          name_attr(config.name),
          id_attr(args.id),
          required_attr(state.requirement),
          aria_label_attr(args.labelled_by, config.label),
        ]),
        [html.Text(state.value)],
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
    fn(config: formz.Config, state: formz.InputState, args: Args) -> html.Node {
      html.select(
        list.flatten([
          name_attr(config.name),
          id_attr(args.id),
          required_attr(state.requirement),
          aria_label_attr(args.labelled_by, config.label),
        ]),
        list.flatten([
          [html.option([attr.value("")], [html.Text("Select...")]), html.hr([])],
          list.map(variants, fn(variant) {
            let val = variant.1
            let selected_attr = case state.value == val {
              True -> [attr.selected()]
              _ -> []
            }
            html.option(list.flatten([value_attr(val), selected_attr]), [
              html.Text(variant.0),
            ])
          }),
        ]),
      )
    },
  )
}
