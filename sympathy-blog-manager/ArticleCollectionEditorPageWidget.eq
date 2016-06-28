
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

class ArticleCollectionEditorPageWidget : RemoteRecordStoreEditorPageWidget, ArticleEditorListener
{
	class MyDataValidator : FormValidator
	{
		public Error validate(HashTable data) {
			if(data == null) {
				return(Error.for_message("No data"));
			}
			// FIXME
			return(null);
		}
	}

	property SympathyBlogAPIClient client;

	public ArticleCollectionEditorPageWidget() {
		set_title("Articles");
	}

	public void on_new_article_saved() {
		refresh();
	}

	public BackgroundTask execute_update_task(EventReceiver listener) {
		return(client.get_articles(listener));
	}

	public ActionItem record_to_action_item(HashTable record) {
		var v = ActionItem.for_text(record.get_string("title"));
		v.set_icon(IconCache.get("article"));
		return(v);
	}

	public FormValidator create_form_data_validator() {
		return(new MyDataValidator());
	}

	public void add_record(HashTable data, EventReceiver listener) {
		client.add_article(data, listener);
	}

	public void delete_record(HashTable record, EventReceiver listener) {
		client.delete_article(record.get_string("id"), listener);
	}

	public void on_add_record() {
		Frame.open(WidgetEngine.for_widget(new ArticleEditorWidget().set_client(client).set_listener(this)));
	}

	public void on_edit_record(HashTable record) {
		if(record == null) {
			return;
		}
		Frame.open(WidgetEngine.for_widget(new ArticleEditorWidget()
			.set_id(record.get_string("id"))
			.set_client(client)));
	}
}
