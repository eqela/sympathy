
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

interface ArticleEditorListener
{
	public void on_new_article_saved();
}

class ArticleEditorWidget : LayerWidget, EventReceiver
{
	property SympathyBlogAPIClient client;
	property ArticleEditorListener listener;
	property String id;
	TextInputControl title;
	TextAreaControl intro;
	TextAreaControl content;
	TextInputControl timestamp;
	CheckBoxWidget published;

	public void initialize() {
		base.initialize();
		set_size_request_override(px("125mm"), px("100mm"));
		var mainbox = BoxWidget.vertical();
		var menu = new Menu();
		menu.add(ActionItem.for_text("Save article").set_event("save"));
		menu.add(ActionItem.for_text("Close editor").set_event("close"));
		var header = LayerWidget.instance();
		header.set_draw_color(Color.white());
		header.add(CanvasWidget.for_color(Color.black()));
		header.add(BoxWidget.horizontal().set_margin(px("2mm")).set_spacing(px("1mm"))
			.add_box(1, LabelWidget.for_text("Article").modify_font("3mm bold"))
			.add_box(0, FramelessButtonWidget.for_widget(new BurgerIcon()).set_popup(MenuWidget.for_menu(menu)))
		);
		mainbox.add(header);

		var tabs = TabbedViewControl.instance();
		{
			var cbox = BoxWidget.vertical();
			cbox.add(LayerWidget.instance()
				.add(CanvasWidget.for_color(Color.white()))
				.add(LayerWidget.instance().set_margin(px("1mm"))
					.add(title = TextInputControl.instance().set_has_frame(false)
						.set_text_align(Alignment.CENTER)
						.set_placeholder("Article title")
					)
				)
			);
			intro = TextAreaControl.instance();
			if(intro != null) {
				intro.set_placeholder("Article introduction");
				var b2 = BoxWidget.vertical().set_margin(px("1mm"));
				b2.add_box(0, LabelControl.for_text("Article introduction").set_font_bold(true));
				b2.add_box(0, LabelControl.for_text("The introduction is a single paragraph that shortly introduces the article."));
				cbox.add(b2);
				cbox.add_box(1, intro);
			}
			tabs.add_page(cbox, "Intro");
		}
		content = TextAreaControl.instance();
		if(content != null) {
			content.set_placeholder("Article content");
			tabs.add_page(content, "Content");
		}
		{
			var props = BoxWidget.vertical();
			props.add(timestamp = TextInputControl.instance().set_placeholder("Timestamp"));
			props.add(published = CheckBoxWidget.for_string("Published"));
			tabs.add_page(props, "Properties");
		}
		mainbox.add_box(1, LayerWidget.instance()
			.add(CanvasWidget.for_color(Color.instance("#CCFFFF")))
			.add(tabs)
			.set_draw_color(Color.black())
		);
		add(mainbox);
	}

	public void cleanup() {
		base.cleanup();
		title = null;
		intro = null;
		content = null;
		timestamp = null;
		published = null;
	}

	public void first_start() {
		base.first_start();
		refresh();
		if(title != null) {
			title.grab_focus();
		}
	}

	class GetArticleDetailsListener : SympathyAPIOperationListener
	{
		property ArticleEditorWidget widget;
		property WaitDialog wdw;
		public void on_ended() {
			if(wdw != null) {
				wdw.hide();
				wdw = null;
			}
		}
		public void on_error(Error error) {
			ModalDialog.error(String.as_string(error));
		}
		public void on_success(Object data) {
			widget.update_from_record(data as HashTable);
		}
	}

	void refresh() {
		if(client == null || id == null) {
			return;
		}
		var wdw = WaitDialog.for_text("Retrieving article ..");
		wdw.show(get_frame());
		client.get_article_details(id, new GetArticleDetailsListener().set_widget(this).set_wdw(wdw));
	}

	public void update_from_record(HashTable record) {
		if(record == null) {
			return;
		}
		if(title != null) {
			title.set_text(record.get_string("title"));
		}
		if(content != null) {
			content.set_text(record.get_string("content"));
		}
		if(intro != null) {
			intro.set_text(record.get_string("intro"));
		}
		if(timestamp != null) {
			timestamp.set_text(record.get_string("timestamp"));
		}
		if(published != null) {
			if(record.get_int("published") == 1) {
				published.set_checked(true);
			}
			else {
				published.set_checked(false);
			}
		}
	}

	HashTable update_to_record() {
		var v = HashTable.create();
		if(title != null) {
			v.set("title", title.get_text());
		}
		if(content != null) {
			v.set("content", content.get_text());
		}
		if(intro != null) {
			v.set("intro", intro.get_text());
		}
		if(timestamp != null) {
			v.set("timestamp", timestamp.get_text());
		}
		if(published != null) {
			if(published.is_checked()) {
				v.set("published", "1");
			}
			else {
				v.set("published", "0");
			}
		}
		return(v);
	}

	class SaveArticleListener : SympathyAPIOperationListener
	{
		property ArticleEditorWidget widget;
		property WaitDialog wdw;
		public void on_ended() {
			if(wdw != null) {
				wdw.hide();
				wdw = null;
			}
		}
		public void on_error(Error error) {
			ModalDialog.error(String.as_string(error));
		}
		public void on_success(Object o) {
		}
	}

	class SaveNewArticleListener : SaveArticleListener
	{
		public void on_success(Object o) {
			get_widget().on_new_article_saved();
		}
	}

	public void on_new_article_saved() {
		close_frame();
		if(listener != null) {
			listener.on_new_article_saved();
		}
	}

	public void on_event(Object o) {
		if("close".equals(o)) {
			close_frame();
			return;
		}
		if("save".equals(o)) {
			var rr = update_to_record();
			Log.message("save: `%s'".printf().add(JSONEncoder.encode(rr)));
			var wdw = WaitDialog.for_text("Saving ..");
			wdw.show(get_frame());
			if(id == null) {
				client.add_article(rr, new SaveNewArticleListener().set_wdw(wdw).set_widget(this));
			}
			else {
				client.update_article(id, rr, new SaveArticleListener().set_wdw(wdw).set_widget(this));
			}
			return;
		}
	}
}
