
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

public class Main : LayerWidget
{
	class MyHeaderWidget : ResponsiveWidthWidget
	{
		public void initialize_narrow() {
			base.initialize_narrow();
			add(AlignWidget.for_widget(ImageWidget.for_image(IconCache.get("sympathy_shadow")).set_mode("fit").set_image_height(px("10mm"))).set_margin(px("3mm")));
		}
		public void initialize_wide() {
			base.initialize_wide();
			add(AlignWidget.for_widget(ImageWidget.for_image(IconCache.get("sympathy_shadow")).set_mode("fit").set_image_height(px("10mm")), -1, 0).set_margin(px("3mm")));
		}
	}

	class MyFooterWidget : ResponsiveWidthWidget
	{
		public void initialize_narrow() {
			base.initialize_narrow();
			add(AlignWidget.for_widget(LabelWidget.for_text(VALUE("copyright")).modify_font("1500um")).set_margin(px("1mm")));
		}
		public void initialize_wide() {
			base.initialize_wide();
			add(AlignWidget.for_widget(LabelWidget.for_text(VALUE("copyright")).modify_font("1500um"), -1, 0).set_margin(px("1mm")));
		}
	}

	NavigationWidget changer;

	public Main() {
		ControlEngine.initialize(DefaultControlEngine.instance());
	}

	public void initialize() {
		base.initialize();
		set_size_request_override(px("140mm"), px("110mm"));
		add(CanvasWidget.for_color(Color.white()));
		add(BoxWidget.vertical().add(CanvasWidget.for_colors(Color.instance("#AAEEEE"), Color.white())
			.set_height_request_override(px("20mm"))));
		var box = BoxWidget.vertical();
		box.add(new MyHeaderWidget());
		box.add_box(1, changer = new NavigationWidget().set_enable_visible_bar(false));
		box.add(HSeparatorWidget.for_flat_color());
		box.add(new MyFooterWidget());
		add(box);
	}

	public void first_start() {
		base.first_start();
		changer.push_page(new LoginWidget());
		String address;
		String username;
		String session;
		var state = ApplicationState.restore();
		if(state != null) {
			session = state.get_string("session");
			username = state.get_string("username");
			address = state.get_string("address");
		}
		if(String.is_empty(session) == false && String.is_empty(address) == false && String.is_empty(username) == false) {
			var client = new SympathyBlogAPIClient();
			client.set_server(address);
			client.set_manager(GUI.engine.get_background_task_manager());
			client.set_username(username);
			client.set_session(session);
			changer.push_page(new BlogManagerWidget().set_client(client));
		}
	}
}