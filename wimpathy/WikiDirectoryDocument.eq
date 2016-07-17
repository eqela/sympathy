
/*
 * This file is part of Jkop
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public class WikiDirectoryDocument : WikiDocument
{
	class MyReferenceResolver : RichTextDocumentReferenceResolver
	{
		property WikiBackend backend;
		property String path;
		property File theme_directory;

		String to_absolute_ref(String refid) {
			if(refid == null) {
				return(null);
			}
			if(refid.has_prefix("/")) {
				return(refid);
			}
			var sb = StringBuffer.create();
			sb.append(path);
			if(path != null && path.has_suffix("/") == false) {
				sb.append_c((int)'/');
			}
			sb.append(refid);
			sb.append_c((int)'/');
			return(sb.to_string());
		}

		public String get_reference_href(String refid) {
			return(to_absolute_ref(refid));
		}

		public String get_reference_title(String arefid) {
			var refid = to_absolute_ref(arefid);
			if(backend == null) {
				return(refid);
			}
			var doc = backend.get_document_for_path(refid);
			if(doc == null) {
				return(refid);
			}
			var tit = doc.get_title();
			if(String.is_empty(tit)) {
				return(refid);
			}
			return(tit);
		}

		public String get_content_string(String acid) {
			var cid = acid;
			if(theme_directory == null || cid == null) {
				return(null);
			}
			if(cid.chr('/') >= 0) {
				var sb = StringBuffer.create();
				var it = cid.iterate();
				int c;
				while((c = it.next_char()) > 0) {
					if(c != '/') {
						sb.append_c(c);
					}
				}
				cid = sb.to_string();
			}
			return(theme_directory.entry("content").entry(cid.append(".html")).get_contents_string());
		}
	}

	public static WikiDirectoryDocument for_directory(File dir, File themedir, WikiBackend backend) {
		var v = new WikiDirectoryDocument();
		v.set_backend(backend);
		v.set_theme_directory(themedir);
		if(v.initialize(dir) == false) {
			v = null;
		}
		return(v);
	}

	property WikiBackend backend;
	property File theme_directory;
	property String path;
	property bool cache_html = true;
	File dir;
	File markupfile;
	String markup;
	RichTextDocument doc;
	int timestamp;
	Array _cached_html;

	void process_document(RichTextDocument doc) {
		var pars = doc.get_paragraphs();
		if(pars == null) {
			return;
		}
		var p0 = pars.get(0) as RichTextStyledParagraph;
		if(p0 == null || p0.get_heading() != 1) {
			return;
		}
		var tc = p0.get_text_content();
		if(String.is_empty(tc)) {
			return;
		}
		if(tc.equals(doc.get_title()) == false) {
			return;
		}
		pars.remove_first();
	}

	public bool initialize(File dir) {
		if(dir == null) {
			return(false);
		}
		var ff = dir.entry("content.markup");
		var st = ff.stat();
		if(st == null) {
			return(false);
		}
		Log.debug("Processing file: `%s' ..".printf().add(ff));
		var str = ff.get_contents_string();
		if(str == null) {
			return(false);
		}
		var doc = RichTextDocument.for_wiki_markup_string(str);
		if(doc == null) {
			return(false);
		}
		process_document(doc);
		this.dir = dir;
		this.markupfile = ff;
		this.markup = str;
		this.doc = doc;
		this.timestamp = st.get_modify_time();
		return(true);
	}

	public bool is_up_to_date() {
		if(markupfile == null) {
			return(false);
		}
		var st = markupfile.stat();
		if(st == null) {
			return(false);
		}
		if(st.get_modify_time() <= timestamp) {
			return(true);
		}
		return(false);
	}

	public String get_title() {
		if(doc == null) {
			return(null);
		}
		return(doc.get_title());
	}

	public String get_author() {
		if(doc == null) {
			return(null);
		}
		return(doc.get_metadata("author"));
	}

	public String get_date() {
		if(doc == null) {
			return(null);
		}
		return(doc.get_metadata("date"));
	}

	public String get_slogan() {
		if(doc == null) {
			return(null);
		}
		return(doc.get_metadata("slogan"));
	}

	public String get_intro() {
		if(doc == null) {
			return(null);
		}
		return(doc.get_metadata("intro"));
	}

	public String get_banner_name() {
		if(doc == null) {
			return(null);
		}
		return(doc.get_metadata("banner"));
	}

	public Array get_markup_strings() {
		var v = Array.create();
		v.add(markup);
		return(v);
	}

	public Array get_html_strings() {
		if(_cached_html != null) {
			return(_cached_html);
		}
		if(doc == null) {
			return(null);
		}
		var hx = doc.to_html(new MyReferenceResolver().set_path(path).set_theme_directory(theme_directory).set_backend(backend));
		Array html;
		if(hx != null) {
			html = Array.create();
			html.add(hx);
		}
		if(cache_html) {
			_cached_html = html;
		}
		return(html);
	}

	public Collection get_attachment_headers() {
		return(null); // FIXME
	}

	public Reader get_attachment(String name) {
		return(null); // FIXME
	}
}
