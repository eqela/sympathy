
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

class UserCollectionEditorPageWidget : DataCollectionEditorWidget, EventReceiver
{
	class AddUserEvent
	{
	}

	class DeleteUserEvent
	{
		property String username;
	}

	class EditUserEvent
	{
		property String username;
	}

	class UserListWidget : DynamicListSelectorWidget
	{
		property SympathyBlogAPIClient client;
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
			items.add(ActionItem.for_text("Add a new user").set_icon(IconCache.get("add")).set_event(new AddUserEvent()));
			foreach(String str in data) {
				var menu = new Menu();
				var editevent = new EditUserEvent().set_username(str);
				menu.add(ActionItem.for_text("Edit user ..").set_event(editevent));
				menu.add(ActionItem.for_text("Delete user ..").set_event(new DeleteUserEvent().set_username(str)));
				items.add(ActionItem.for_text(str).set_icon(IconCache.get("user")).set_event(editevent).set_menu(menu));
			}
			set_items(items);
		}
		public BackgroundTask execute_update_task(EventReceiver listener) {
			return(client.get_users(listener));
		}
	}

	public UserCollectionEditorPageWidget() {
		set_title("Users");
	}

	public Widget create_list_widget() {
		return(new UserListWidget().set_client(get_client()));
	}

	class AddUserFormListener : PopupFormListener
	{
		property UserCollectionEditorPageWidget widget;
		public void on_form_data(HashTable data) {
			if(data == null) {
				return;
			}
			widget.do_add_user(data.get_string("username"), data.get_string("password"));
		}
	}

	class EditUserFormListener : PopupFormListener
	{
		property String username;
		property UserCollectionEditorPageWidget widget;
		public void on_form_data(HashTable data) {
			if(data == null) {
				return;
			}
			data.remove("password2");
			widget.do_edit_user(username, data);
		}
	}

	class UserOperationListener : EventReceiver
	{
		property UserCollectionEditorPageWidget widget;
		property WaitDialog wdw;
		public void on_event(Object o) {
Log.message("user operation listener 1");
			var rs = o as SympathyAPICallResult;
			if(rs == null) {
Log.message("user operation listener 2");
				return;
			}
Log.message("user operation listener 3");
			if(wdw != null) {
Log.message("user operation listener 4");
				wdw.hide();
Log.message("user operation listener 5");
				wdw = null;
Log.message("user operation listener 6");
			}
Log.message("user operation listener 7");
			var err = rs.get_error();
			if(err != null) {
				ModalDialog.error(String.as_string(err));
			}
			else {
				widget.refresh();
			}
Log.message("user operation listener 8");
			return;
		}
	}

	class UserDataValidator : FormValidator
	{
		public Error validate(HashTable data) {
			if(data == null) {
				return(Error.for_message("No data"));
			}
			var un = data.get_string("username");
			if(String.is_empty(un)) {
				return(Error.for_message("Username is empty"));
			}
			var pw1 = data.get_string("password");
			var pw2 = data.get_string("password2");
			if(String.is_empty(pw1)) {
				return(Error.for_message("Password is empty"));
			}
			if(pw1.equals(pw2) == false) {
				return(Error.for_message("Passwords do not match"));
			}
			return(null);
		}
	}

	property SympathyBlogAPIClient client;

	public void do_add_user(String username, String password) {
		var client = get_client();
		var wdw = WaitDialog.for_text("Adding ..");
		wdw.show(get_frame());
		client.add_user(username, password, new UserOperationListener().set_widget(this).set_wdw(wdw));
	}

	public void do_edit_user(String username, HashTable data) {
		var client = get_client();
		var wdw = WaitDialog.for_text("Updating ..");
		wdw.show(get_frame());
		client.update_user(username, data, new UserOperationListener().set_widget(this).set_wdw(wdw));
	}

	public void on_event(Object o) {
		if(o is AddUserEvent) {
			var ff = Form.parse(TEXTFILE("EditUser.form"));
			if(ff == null) {
				return;
			}
			ff.set_title("Add a new user");
			PopupForm.execute_ok_cancel(ff, null, new UserDataValidator(), get_frame(), new AddUserFormListener().set_widget(this));
			return;
		}
		if(o is EditUserEvent) {
			var ff = Form.parse(TEXTFILE("EditUser.form"));
			if(ff == null) {
				return;
			}
			ff.set_title("Edit user");
			var un = ((EditUserEvent)o).get_username();
			PopupForm.execute_ok_cancel(ff, HashTable.create().set("username", un),
				new UserDataValidator(), get_frame(), new EditUserFormListener().set_widget(this).set_username(un));
			return;
		}
		if(o is DeleteUserEvent) {
			var client = get_client();
			var wdw = WaitDialog.for_text("Deleting ..");
			wdw.show(get_frame());
			client.delete_user(((DeleteUserEvent)o).get_username(), new UserOperationListener().set_widget(this).set_wdw(wdw));
		}
		forward_event(o);
	}
}
