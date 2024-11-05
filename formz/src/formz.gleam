//// This will eventually be the home of `formz_builder` or `formz_use`.

import formz/field
import formz/subform

pub type FormItem(widget) {
  Field(field.Field, widget: widget)
  SubForm(subform.SubForm, items: List(FormItem(widget)))
}
