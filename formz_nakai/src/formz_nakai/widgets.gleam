import formz
import formz/field.{type Field}
import formz_nakai/widget
import gleam/string

import gleam/list
import nakai/attr
import nakai/html

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

fn aria_label_attr(
  labelled_by: widget.LabelledBy,
  label: String,
) -> List(attr.Attr) {
  case labelled_by {
    widget.LabelledByLabelFor -> []
    widget.LabelledByElementsWithIds(ids) -> [
      attr.aria_labelledby(string.join(ids, " ")),
    ]
    widget.LabelledByFieldValue ->
      case label {
        "" -> []
        _ -> [attr.aria_label(label)]
      }
  }
}

fn aria_describedby_attr(described_by: widget.DescribedBy) -> List(attr.Attr) {
  case described_by {
    widget.DescribedByNone -> []
    widget.DescribedByElementsWithIds(ids) ->
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

fn required_attr(presence: formz.FieldPresence) -> List(attr.Attr) {
  case presence {
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
pub fn checkbox_widget() {
  fn(field: Field, state: formz.FieldState, args: widget.Args) {
    let value = state.value
    let state = case state {
      formz.Unvalidated(_, presence) -> formz.Unvalidated("", presence)
      formz.Valid(_, presence) -> formz.Valid("", presence)
      formz.Invalid(_, presence, e) -> formz.Invalid("", presence, e)
    }
    do_input_widget(field, state, args, "checkbox", [checked_attr(value)])
  }
}

/// Create a `<input type="number">`.  Normally browsers only allow whole numbers,
/// unless a decimal step size is provided.  The step size here is a string that
/// will be put straight into the `step-size` attribute.  Doing non-whole numbers
/// this way does mean that a user can only input numbers up to the precision of
/// the step size.  If you truly need any float, then a `type="text"` input might be a
/// better choice.
pub fn number_widget(step_size: String) {
  fn(field: Field, state: formz.FieldState, args: widget.Args) {
    do_input_widget(field, state, args, "number", [step_size_attr(step_size)])
  }
}

/// Create an `<input type="password">`. This will not output the value in the
/// generated HTML for privacy/security concerns.
pub fn password_widget() {
  fn(field: Field, state: formz.FieldState, args: widget.Args) {
    let state = case state {
      formz.Unvalidated(_, presence) -> formz.Unvalidated("", presence)
      formz.Valid(_, presence) -> formz.Valid("", presence)
      formz.Invalid(_, presence, e) -> formz.Invalid("", presence, e)
    }
    do_input_widget(field, state, args, "password", [])
  }
}

/// Generate any `<input>` like `type="text"`, `type="email"` or
/// `type="url"`.
pub fn input_widget(type_: String) {
  fn(field: Field, state: formz.FieldState, args: widget.Args) {
    do_input_widget(field, state, args, type_, [])
  }
}

fn do_input_widget(
  field: Field,
  state: formz.FieldState,
  args: widget.Args,
  type_: String,
  extra_attrs: List(List(attr.Attr)),
) {
  html.input(
    list.flatten([
      type_attr(type_),
      name_attr(field.name),
      id_attr(args.id),
      required_attr(state.presence),
      value_attr(state.value),
      disabled_attr(field.disabled),
      aria_describedby_attr(args.described_by),
      aria_label_attr(args.labelled_by, field.label),
      extra_attrs |> list.flatten,
    ]),
  )
}

/// Create a `<textarea></textarea>`.
pub fn textarea_widget() {
  fn(field: Field, state: formz.FieldState, args: widget.Args) -> html.Node {
    html.textarea(
      list.flatten([
        name_attr(field.name),
        id_attr(args.id),
        required_attr(state.presence),
        aria_label_attr(args.labelled_by, field.label),
      ]),
      [html.Text(state.value)],
    )
  }
}

/// Create a `<input type="hidden">`. This is useful for if a field is just
/// passing data around and you don't want it to be visible to the user. Like
/// say, the ID of a record being edited.
pub fn hidden_widget() {
  fn(field: Field, state: formz.FieldState, _) -> html.Node {
    html.input(
      list.flatten([
        type_attr("hidden"),
        name_attr(field.name),
        value_attr(state.value),
      ]),
    )
  }
}

/// Create a `<select></select>` with `<option>`s for each variant.  The list
/// of variants is a two-tuple, where the first item is the text to display and
/// the second item is the value.
pub fn select_widget(variants: List(#(String, String))) {
  fn(field: Field, state: formz.FieldState, args: widget.Args) -> html.Node {
    html.select(
      list.flatten([
        name_attr(field.name),
        id_attr(args.id),
        required_attr(state.presence),
        aria_label_attr(args.labelled_by, field.label),
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
  }
}
