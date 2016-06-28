
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

class RemoteRecordStoreEditorPageWidget : DataCollectionEditorWidget, EventReceiver
{
	class AddRecordEvent
	{
	}

	class DeleteRecordEvent
	{
		property HashTable record;
	}

	class EditRecordEvent
	{
		property HashTable record;
	}

	public virtual BackgroundTask execute_update_task(EventReceiver listener) {
		return(null);
	}

	public virtual ActionItem record_to_action_item(HashTable record) {
		return(null);
	}

	class RecordListWidget : DynamicListSelectorWidget
	{
		property RemoteRecordStoreEditorPageWidget widget;
		public void on_task_result(Object o) {
			var rs = o as SympathyAPICallResult;
			if(rs == null) {
				ModalDialog.error("Unknown error");
				set_items(null);
				return;
			}
			var err = rs.get_error();
			if(err != null) {
				set_items(null);
				ModalDialog.error(String.as_string(err));
				return;
			}
			var data = rs.get_data() as Collection;
			if(data == null) {
				set_items(null);
				return;
			}
			var items = LinkedList.create();
			items.add(ActionItem.for_text("Add a new record").set_icon(IconCache.get("add")).set_event(new AddRecordEvent()));
			foreach(HashTable record in data) {
				var ai = widget.record_to_action_item(record);
				if(ai != null) {
					var editevent = new EditRecordEvent().set_record(record);
					var menu = new Menu();
					menu.add(ActionItem.for_text("Edit record ..").set_event(editevent));
					menu.add(ActionItem.for_text("Delete record ..").set_event(new DeleteRecordEvent().set_record(record)));
					ai.set_menu(menu);
					ai.set_event(editevent);
					items.add(ai);
				}
			}
			set_items(items);
		}
		public BackgroundTask execute_update_task(EventReceiver listener) {
			return(widget.execute_update_task(listener));
		}
	}

	public Widget create_list_widget() {
		return(new RecordListWidget().set_widget(this));
	}

	class MyAPIOperationListener : SympathyAPIOperationListener
	{
		property WaitDialog wdw;
		property RemoteRecordStoreEditorPageWidget widget;
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
			widget.refresh();
		}
	}

	public virtual void add_record(HashTable data, EventReceiver listener) {
		EventReceiver.event(listener, null);
	}

	class AddRecordFormListener : PopupFormListener
	{
		property RemoteRecordStoreEditorPageWidget widget;
		public void on_form_data(HashTable data) {
			if(data == null) {
				return;
			}
			var wdw = WaitDialog.for_text("Adding ..");
			wdw.show(widget.get_frame());
			widget.add_record(data, new MyAPIOperationListener().set_widget(widget).set_wdw(wdw));
		}
	}

	public virtual void edit_record(HashTable record, HashTable newdata, EventReceiver listener) {
		EventReceiver.event(listener, null);
	}

	class EditRecordFormListener : PopupFormListener
	{
		property HashTable record;
		property RemoteRecordStoreEditorPageWidget widget;
		public void on_form_data(HashTable data) {
			if(data == null) {
				return;
			}
			var wdw = WaitDialog.for_text("Updating ..");
			wdw.show(widget.get_frame());
			widget.edit_record(record, data, new MyAPIOperationListener().set_widget(widget).set_wdw(wdw));
		}
	}

	public PopupFormListener create_editor_form_listener(HashTable record) {
		return(new EditRecordFormListener().set_widget(this).set_record(record));
	}

	public virtual FormValidator create_form_data_validator() {
		return(null);
	}

	public virtual Form create_add_form() {
		return(null);
	}

	public virtual Form create_edit_form() {
		return(null);
	}

	public virtual void delete_record(HashTable record, EventReceiver listener) {
		EventReceiver.event(listener, null);
	}

	public virtual void on_add_record() {
		var ff = create_add_form();
		if(ff == null) {
			return;
		}
		PopupForm.execute_ok_cancel(ff, null, create_form_data_validator(), get_frame(), new AddRecordFormListener().set_widget(this));
	}

	public virtual void on_edit_record(HashTable record) {
		var ff = create_edit_form();
		if(ff == null) {
			return;
		}
		PopupForm.execute_ok_cancel(ff, record, create_form_data_validator(), get_frame(),
			create_editor_form_listener(record));
	}

	class DeleteConfirmationListener : ModalDialogBooleanListener
	{
		property RemoteRecordStoreEditorPageWidget widget;
		property HashTable record;
		public void on_dialog_boolean_result(bool result) {
			if(result) {
				widget.on_delete_record_confirmed(record);
			}
		}
	}

	public virtual void on_delete_record_confirmed(HashTable record) {
		var wdw = WaitDialog.for_text("Deleting ..");
		wdw.show(get_frame());
		delete_record(record,  new MyAPIOperationListener().set_widget(this).set_wdw(wdw));
	}

	public virtual void on_delete_record(HashTable record) {
		ModalDialog.yesno("Are you sure you wish to delete this entry?", "Confirm deletion",
			new DeleteConfirmationListener().set_widget(this).set_record(record), get_frame());
	}

	public void on_event(Object o) {
		if(o is AddRecordEvent) {
			on_add_record();
			return;
		}
		if(o is EditRecordEvent) {
			on_edit_record(((EditRecordEvent)o).get_record());
			return;
		}
		if(o is DeleteRecordEvent) {
			on_delete_record(((DeleteRecordEvent)o).get_record());
			return;
		}
		forward_event(o);
	}
}
