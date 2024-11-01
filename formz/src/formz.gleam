//// This will eventually be the home of `formz_builder` or `formz_use`.

import formz/field
import formz/subform
import formz/widget

pub type FormItem(format) {
  Field(field.Field, widget: widget.Widget(format))
  SubForm(subform.SubForm, items: List(FormItem(format)))
}
