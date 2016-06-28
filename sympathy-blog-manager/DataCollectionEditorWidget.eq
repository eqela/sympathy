
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

class DataCollectionEditorWidget : VBoxWidget
{
	property String title;
	property bool is_narrow = false;
	Widget list;

	public virtual Widget create_list_widget() {
		return(null);
	}

	public void initialize() {
		base.initialize();
		set_spacing(px("1mm"));
		if(is_narrow) {
			add(LayerWidget.instance()
				.add(LabelWidget.for_text(title).modify_font("4mm bold").set_text_align(LabelWidget.CENTER))
				.add(AlignWidget.for_widget(FramelessButtonWidget.for_image(IconCache.get("close_window")).set_event("pop_page"), 1, 0))
			);
		}
		else {
			add(LabelWidget.for_text(title).modify_font("4mm bold").set_text_align(LabelWidget.LEFT));
		}
		add(HSeparatorWidget.for_flat_color());
		var w = create_list_widget();
		if(w != null) {
			add_box(1, w);
		}
		list = w;
	}

	public void cleanup() {
		base.cleanup();
		list = null;
	}

	public void refresh() {
		var dl = list as DynamicListSelectorWidget;
		if(dl != null) {
			dl.refresh();
		}
	}
}
