
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

class WikiPageContentPadget : Padget
{
	property String path;
	property String app_title;
	property WikiBackend backend;
	property WikiTheme theme;
	Array htmls;

	public void execute(HTTPRequest req, HashTable data) {
		WikiDocument doc;
		var rp = path;
		if(rp != null) {
			doc = backend.get_document_for_path(rp);
		}
		if(doc != null) {
			htmls = doc.get_html_strings();
			var tit = doc.get_title();
			var pdoc = HashTable.create();
			if(String.is_empty(tit) == false && tit.equals(app_title) == false) {
				data.set("page_title", "%s | %s".printf().add(tit).add(app_title).to_string());
				pdoc.set("title", tit);
			}
			else {
				pdoc.set("title", app_title);
			}
			pdoc.set("slogan", doc.get_slogan());
			pdoc.set("intro", doc.get_intro());
			pdoc.set("author", doc.get_author());
			pdoc.set("date", doc.get_date());
			pdoc.set("banner", doc.get_banner_name());
			data.set("document", pdoc);
		}
		else {
			htmls = Array.create();
			htmls.add("<h1>Document not found</h1><p>No such document.</p><p><a href=\"/\">Return to main page</a></p>");
		}
	}

	public void get_html_content(StringBuffer sb) {
		sb.append(theme.get_article_header());
		foreach(String html in htmls) {
			sb.append("<div class=\"wikidocument\">");
			sb.append(html);
			sb.append("</div>");
		}
		sb.append(theme.get_article_footer());
	}
}
