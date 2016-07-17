
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

class WikiTheme
{
	static String read_file(File dir, String filename, Logger logger) {
		var ff = dir.entry(filename);
		if(ff.is_file() == false) {
			Log.warning("WikiTheme file does not exist: `%s'".printf().add(ff));
			return(null);
		}
		var v = ff.get_contents_string();
		if(v == null) {
			Log.warning("Failed to read WikiTheme file: `%s'".printf().add(ff));
		}
		return(v);
	}

	public static WikiTheme read(File dir, Logger logger) {
		if(dir == null) {
			Log.error("No directory specified for WikiTheme", logger);
			return(null);
		}
		if(dir.is_directory() == false) {
			Log.error("WikiTheme directory does not exist: `%s'".printf().add(dir), logger);
			return(null);
		}
		var v = new WikiTheme();
		v.set_css(read_file(dir, "style.css", logger));
		v.set_document_header(read_file(dir, "document_header.html", logger));
		v.set_frame_header(read_file(dir, "frame_header.html", logger));
		v.set_frame_footer(read_file(dir, "frame_footer.html", logger));
		v.set_article_header(read_file(dir, "article_header.html", logger));
		v.set_article_footer(read_file(dir, "article_footer.html", logger));
		return(v);
	}

	property String css;
	property String document_header;
	property String frame_header;
	property String frame_footer;
	property String article_header;
	property String article_footer;
}
