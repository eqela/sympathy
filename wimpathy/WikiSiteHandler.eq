
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

public class WikiSiteHandler : PadgetSiteHandler
{
	property WikiBackend backend;
	property HashTable site_config;
	property WikiTheme theme;
	String css;

	public void get_css(StringBuffer sb) {
		sb.append(theme.get_css());
	}

	public override void get_html_header(StringBuffer sb) {
		sb.append(theme.get_document_header());
	}

	public override void initialize_data(HashTable data) {
		base.initialize_data(data);
		data.set("site", site_config);
	}

	public void execute_padget_request(HTTPRequest req, HashTable data) {
	}

	public void initialize() {
		base.initialize();
		add_padget(new WikiFramePadget().set_theme(theme));
	}

	public bool on_http_get(HTTPRequest req) {
		var res = backend.get_resource_for_path(req.get_url_path());
		if(res != null) {
			req.send_response(HTTPResponse.for_file(res));
			return(true);
		}
		return(base.on_http_get(req));
	}

	public void get_request_padgets(HTTPRequest req, Collection padgets) {
		if(req.is_for_directory() == false) {
			req.send_redirect_as_directory();
			return;
		}
		padgets.add(new WikiPageContentPadget()
			.set_theme(theme)
			.set_app_title(get_site_title())
			.set_path(req.get_url_path())
			.set_backend(backend));
	}
}
