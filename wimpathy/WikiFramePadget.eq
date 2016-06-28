
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

class WikiFramePadget : Padget
{
	String css;
	String header;
	String footer;

	public override void get_html_header(StringBuffer sb) {
		sb.append("<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css\">\n");
		sb.append("<link href=\"https://fonts.googleapis.com/css?family=Ubuntu\" rel=\"stylesheet\" type=\"text/css\">\n");
		sb.append("<link href=\"https://fonts.googleapis.com/css?family=Open+Sans\" rel=\"stylesheet\" type=\"text/css\">\n");
		sb.append("<link href=\"https://fonts.googleapis.com/css?family=Raleway:300\" rel=\"stylesheet\" type='text/css'>\n");
	}

	public void get_css(StringBuffer sb) {
		if(css == null) {
			css = TEXTFILE("WikiFrame.css");
		}
		sb.append(css);
	}

	public void get_html_page_header(StringBuffer sb) {
		if(header == null) {
			header = TEXTFILE("WikiFrameHeader.html");
		}
		sb.append(header);
	}

	public void get_html_page_footer(StringBuffer sb) {
		if(footer == null) {
			footer = TEXTFILE("WikiFrameFooter.html");
		}
		sb.append(footer);
	}
}
