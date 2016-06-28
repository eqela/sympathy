
/*
 * This file is part of Sympathy
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

public class PopupForm
{
	class MyPopupWidget : VBoxWidget, EventReceiver
	{
		property String title;
		property FormWidget form;
		property PopupFormListener listener;
		property FormValidator validator;

		public void initialize() {
			base.initialize();
			var header = LayerWidget.instance();
			header.set_draw_color(Color.white());
			header.add(CanvasWidget.for_color(Color.black()));
			header.add(BoxWidget.horizontal().set_margin(px("2mm")).set_spacing(px("1mm"))
				.add_box(1, LabelWidget.for_text(title).modify_font("4mm bold"))
			);
			add(header);
			add_box(1, LayerWidget.instance()
				.add(CanvasWidget.for_color(Color.instance("#CCFFFF")))
				.add(VScrollerWidget.for_widget(LayerWidget.for_widget(form).set_margin(px("2mm"))))
				.set_draw_color(Color.black())
			);
			var buttons = BoxWidget.horizontal();
			buttons.add_box(1, ButtonWidget.for_text("OK").set_rounded(false).set_draw_outline(false).set_color_gradient(false).set_color(Color.instance("lightgreen")).set_event("ok"));
			buttons.add_box(1, ButtonWidget.for_text("Cancel").set_rounded(false).set_draw_outline(false).set_color_gradient(false).set_color(Color.instance("lightred")).set_event("cancel"));
			add(buttons);
		}

		public void cleanup() {
			base.cleanup();
		}

		public void on_event(Object o) {
			if("ok".equals(o)) {
				var data = form.data_to_hash_table();
				if(validator != null) {
					var err = validator.validate(data);
					if(err != null) {
						ModalDialog.error(String.as_string(err));
						return;
					}
				}
				if(listener != null) {
					listener.on_form_data(data);
				}
				close_frame();
				return;
			}
			if("cancel".equals(o)) {
				if(listener != null) {
					listener.on_form_data(null);
				}
				close_frame();
				return;
			}
		}
	}

	public static void execute_ok_cancel(Form form, HashTable data, FormValidator validator, Frame frame, PopupFormListener listener) {
		if(form == null) {
			if(listener != null) {
				listener.on_form_data(null);
			}
			return;
		}
		var widget = FormWidget.for_form(form);
		if(data != null) {
			widget.data_from_hash_table(data);
		}
		var pw = new MyPopupWidget();
		pw.set_form(widget);
		pw.set_title(form.get_title());
		pw.set_validator(validator);
		pw.set_listener(listener);
		Frame.open_as_popup(WidgetEngine.for_widget(pw), frame);
	}
}
