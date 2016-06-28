
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

class BlogManagerWidget : ResponsiveWidthWidget, EventReceiver
{
	class ButtonPanel : VBoxWidget
	{
		public void initialize() {
			base.initialize();
			set_spacing(px("2mm"));
			set_margin(px("1mm"));
			set_width_request_override(px("40mm"));
			add(ButtonWidget.for_string("Articles").set_color(Color.instance("#448888")).set_event("all_articles"));
			add(HSeparatorWidget.for_flat_color());
			add(ButtonWidget.for_string("Categories").set_color(Color.instance("#448888")).set_event("all_categories"));
			add(HSeparatorWidget.for_flat_color());
			add(ButtonWidget.for_string("Users").set_color(Color.instance("#448888")).set_event("all_users"));
			add(HSeparatorWidget.for_flat_color());
			add(ButtonWidget.for_string("Log out").set_color(Color.instance("#448888")).set_event("logout"));
		}
	}

	property SympathyBlogAPIClient client;
	ChangerWidget changer;
	NavigationWidget navigation;

	public void initialize_narrow() {
		base.initialize_narrow();
		add(navigation = new NavigationWidget().set_enable_visible_bar(false));
		navigation.set_default_push_effect(ChangerWidget.EFFECT_SCROLL_UP);
		navigation.set_default_pop_effect(ChangerWidget.EFFECT_SCROLL_DOWN);
		navigation.push_page(VScrollerWidget.for_widget(AlignWidget.for_widget(new ButtonPanel())));
	}

	public void initialize_wide() {
		base.initialize_wide();
		var sidebar = VScrollerWidget.for_widget(new ButtonPanel());
		var hb = BoxWidget.horizontal();
		hb.set_margin(px("1mm"));
		hb.set_spacing(px("1mm"));
		hb.add(sidebar);
		hb.add_box(1, changer = ChangerWidget.instance());
		add(hb);
	}

	public void cleanup() {
		base.cleanup();
		changer = null;
		navigation = null;
	}

	WaitDialog logout_dialog;

	void show_widget(Widget w) {
		if(navigation != null) {
			navigation.push_page(w);
		}
		else if(changer != null) {
			changer.replace_with(w, ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	class LogoutConfirmationListener : ModalDialogBooleanListener
	{
		property BlogManagerWidget widget;
		public void on_dialog_boolean_result(bool result) {
			if(result) {
				widget.do_logout();
			}
		}
	}

	public void do_logout() {
		if(logout_dialog != null) {
			return;
		}
		logout_dialog = WaitDialog.for_text("Logging out");
		logout_dialog.show(get_frame());
		client.logout(this);
	}

	public void on_event(Object o) {
		if("all_articles".equals(o)) {
			show_widget(new ArticleCollectionEditorPageWidget().set_client(client).set_is_narrow(is_narrow()));
			return;
		}
		if("all_categories".equals(o)) {
			show_widget(new CategoryCollectionEditorPageWidget().set_client(client).set_is_narrow(is_narrow()));
			return;
		}
		if("all_users".equals(o)) {
			show_widget(new UserCollectionEditorPageWidget().set_client(client).set_is_narrow(is_narrow()));
			return;
		}
		if("logout".equals(o)) {
			ModalDialog.yesno("Are you sure you wish to log out", "Confirmation",
				new LogoutConfirmationListener().set_widget(this), get_frame());
			return;
		}
		if("pop_page".equals(o)) {
			if(navigation != null) {
				navigation.pop_page();
			}
			return;
		}
		if(o is SympathyAPICallResult) {
			if(logout_dialog != null) {
				logout_dialog.hide();
				logout_dialog = null;
			}
			ApplicationState.save(HashTable.create());
			NavigationWidget.pop(this, ChangerWidget.EFFECT_SCROLL_RIGHT);
			return;
		}
	}
}
