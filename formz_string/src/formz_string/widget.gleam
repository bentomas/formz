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

pub type Widget {
  Widget(fn(formz.Config, formz.InputState, Args) -> String)
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
  /// The input should be labelled using the `formz.Config`'s `label`.
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

pub fn sanitize_attr(str: String) -> String {
  str
  |> string.replace("\"", "&quot;")
  |> string.replace(">", "&gt;")
}

fn with_non_empty_strs(
  list: List(String),
  empty: j,
  fun: fn(List(String)) -> j,
) -> j {
  case list |> list.filter(fn(x) { !string.is_empty(x) }) {
    [] -> empty
    non_empty_ids -> fun(non_empty_ids)
  }
}

fn id_attr(id: String) -> String {
  case id {
    "" -> ""
    _ -> " id=\"" <> sanitize_attr(id) <> "\""
  }
}

fn name_attr(name: String) -> String {
  case name {
    "" -> ""
    _ -> " name=\"" <> sanitize_attr(name) <> "\""
  }
}

fn aria_label_attr(labelled_by: LabelledBy, label: String) -> String {
  // https://www.w3.org/WAI/tutorials/forms/labels/
  // https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-labelledby
  case labelled_by {
    // there should be a label with a for attribute pointing to this id
    LabelledByLabelFor -> ""

    // we have the id of the element that labels this input
    LabelledByElementsWithIds(ids) ->
      with_non_empty_strs(ids, "", fn(ids) {
        " aria-labelledby=\"" <> sanitize_attr(string.join(ids, " ")) <> "\""
      })

    // we'll use the label value as the aria-label
    LabelledByFieldValue -> {
      case label {
        "" -> ""
        _ -> " aria-label=\"" <> sanitize_attr(label) <> "\""
      }
    }
  }
}

fn aria_describedby_attr(described_by: DescribedBy) -> String {
  // https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-describedby
  case described_by {
    // there should be a label with a for attribute pointing to this id
    DescribedByNone -> ""

    // we have the id of the element that labels this input
    DescribedByElementsWithIds(ids) ->
      with_non_empty_strs(ids, "", fn(ids) {
        " aria-describedby=\"" <> sanitize_attr(string.join(ids, " ")) <> "\""
      })
  }
}

fn step_size_attr(step_size: String) -> String {
  case step_size {
    "" -> ""
    _ -> " step=\"" <> step_size <> "\""
  }
}

fn type_attr(type_: String) -> String {
  " type=\"" <> type_ <> "\""
}

fn value_attr(value: String) -> String {
  case value {
    "" -> ""
    _ -> " value=\"" <> sanitize_attr(value) <> "\""
  }
}

fn disabled_attr(disabled: Bool) -> String {
  case disabled {
    True -> " disabled"
    False -> ""
  }
}

fn required_attr(requirement: formz.Requirement) -> String {
  case requirement {
    formz.Required -> " required"
    formz.Optional -> ""
  }
}

fn checked_attr(value: String) -> String {
  case value {
    "on" -> " checked"
    _ -> ""
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
pub fn number_widget(step_size: String) -> Widget {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    do_input_widget(config, state, args, "number", [step_size_attr(step_size)])
  })
}

/// Create an `<input type="password">`. This will not output the value in the
/// generated HTML for privacy/security concerns.
pub fn password_widget() -> Widget {
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
pub fn input_widget(type_: String) -> Widget {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    do_input_widget(config, state, args, type_, [])
  })
}

fn do_input_widget(
  config: formz.Config,
  state: formz.InputState,
  args: Args,
  type_: String,
  extra_attrs: List(String),
) -> String {
  "<input"
  <> type_attr(type_)
  <> name_attr(config.name)
  <> id_attr(args.id)
  <> required_attr(state.requirement)
  <> disabled_attr(config.disabled)
  <> value_attr(state.value)
  <> aria_label_attr(args.labelled_by, config.label)
  <> aria_describedby_attr(args.described_by)
  <> extra_attrs |> string.join("")
  <> ">"
}

/// Create a `<textarea></textarea>`.
pub fn textarea_widget() -> Widget {
  Widget(
    fn(config: formz.Config, state: formz.InputState, args: Args) -> String {
      // https://chriscoyier.net/2023/09/29/css-solves-auto-expanding-textareas-probably-eventually/
      // https://til.simonwillison.net/css/resizing-textarea
      "<textarea"
      <> name_attr(config.name)
      <> id_attr(args.id)
      <> required_attr(state.requirement)
      <> disabled_attr(config.disabled)
      <> aria_label_attr(args.labelled_by, config.label)
      <> aria_describedby_attr(args.described_by)
      <> ">"
      <> state.value
      <> "</textarea>"
    },
  )
}

/// Create a `<input type="hidden">`. This is useful for if a field is just
/// passing data around and you don't want it to be visible to the user. Like
/// say, the ID of a record being edited.
pub fn hidden_widget() -> Widget {
  Hidden
}

/// Create a `<select></select>` with `<option>`s for each variant.  The list
/// of variants is a two-tuple, where the first item is the text to display and
/// the second item is the value.
pub fn select_widget(variants: List(#(String, String))) -> Widget {
  Widget(fn(config: formz.Config, state: formz.InputState, args: Args) {
    let choices =
      list.map(variants, fn(variant) {
        let val = variant.1
        let selected_attr = case state.value == val {
          True -> " selected"
          _ -> ""
        }
        { "<option" <> value_attr(val) <> selected_attr <> ">" }
        <> variant.0
        <> "</option>"
      })
      |> string.join("")

    {
      "<select"
      <> name_attr(config.name)
      <> id_attr(args.id)
      <> required_attr(state.requirement)
      <> disabled_attr(config.disabled)
      <> aria_label_attr(args.labelled_by, config.label)
      <> aria_describedby_attr(args.described_by)
      <> ">"
    }
    // TODO make this placeholder option not selectable? with disabled selected attributes
    // https://stackoverflow.com/questions/5805059/how-do-i-make-a-placeholder-for-a-select-box
    <> { "<option value>Select...</option>" }
    <> { "<hr>" }
    <> choices
    <> { "</select>" }
  })
}
