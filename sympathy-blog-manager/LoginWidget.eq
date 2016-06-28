
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

class LoginWidget : AlignWidget, EventReceiver
{
	TextInputControl address;
	TextInputControl username;
	TextInputControl password;

	public void initialize() {
		base.initialize();
		var box = BoxWidget.vertical();
		box.set_width_request_override(px("70mm"));
		box.set_margin(px("5mm"));
		box.set_spacing(px("2mm"));
		box.add(LabelControl.for_text("Sympathy Blog Login").set_font_bold(true)
			.set_text_align(Alignment.CENTER));
		box.add(address = TextInputControl.instance().set_placeholder("Blog address / hostname"));
		box.add(username = TextInputControl.instance().set_placeholder("Username"));
		box.add(password = TextInputControl.instance().set_placeholder("Password"));
		box.add(BoxWidget.horizontal()
			.add_box(1, new Widget())
			.add_box(0, ButtonControl.for_text("Continue").set_event("continue"))
		);
		add(VScrollerWidget.for_widget(box));
	}

	public void start() {
		base.start();
		if(address != null) {
			address.set_text("");
		}
		if(username != null) {
			username.set_text("");
		}
		if(password != null) {
			password.set_text("");
		}
	}

	public void cleanup() {
		base.cleanup();
		address = null;
		username = null;
		password = null;
	}

	WaitDialog login_dialog;
	String login_address;
	String login_username;
	String login_password;

	public void on_event(Object o) {
		if("continue".equals(o)) {
			if(login_dialog != null) {
				return;
			}
			login_address = address.get_text();
			login_username = username.get_text();
			login_password = password.get_text();
			var client = new SympathyBlogAPIClient();
			client.set_server(login_address);
			client.set_manager(GUI.engine.get_background_task_manager());
			login_dialog = WaitDialog.for_text("Logging in ..");
			login_dialog.show(get_frame());
			client.login(login_username, login_password, this);
			return;
		}
		if(o is SympathyAPICallResult) {
			var resp = (SympathyAPICallResult)o;
			if(login_dialog != null) {
				login_dialog.hide();
				login_dialog = null;
			}
			if(resp.get_error() != null) {
				ModalDialog.error(String.as_string(resp.get_error()));
				return;
			}
			var data = resp.get_data() as HashTable;
			if(data == null) {
				ModalDialog.error("No data in server response");
				return;
			}
			var session = data.get_string("session");
			if(String.is_empty(session)) {
				ModalDialog.error("No session in server response");
				return;
			}
			var client = new SympathyBlogAPIClient();
			client.set_server(login_address);
			client.set_manager(GUI.engine.get_background_task_manager());
			client.set_username(login_username);
			client.set_session(session);
			ApplicationState.save(HashTable.create()
				.set("address", login_address)
				.set("username", login_username)
				.set("session", session)
			);
			NavigationWidget.push(this, new BlogManagerWidget().set_client(client), ChangerWidget.EFFECT_SCROLL_LEFT);
			return;
		}
	}
}
