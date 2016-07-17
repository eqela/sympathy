
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

public class WikiEditorAPIHandler : HTTPRequestHandlerAdapter
{
	public static WikiEditorAPIHandler for_directory(File dir) {
		return(new WikiEditorAPIHandler().set_dir(dir));
	}

	property File dir;

	File get_content_dir(HTTPRequest req) {
		if(dir == null) {
			return(null);
		}
		var pp = req.get_relative_resource_path();
		if(String.is_empty(pp)) {
			return(null);
		}
		var np = Path.normalize_path(pp);
		if(String.is_empty(np)) {
			return(null);
		}
		return(dir.entry(np));
	}

	public bool on_http_get(HTTPRequest req) {
		var dd = get_content_dir(req);
		if(dd == null) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to determine content directory"));
			return(true);
		}
		var markupfile = dd.entry("content.markup");
		if(markupfile.is_file() == false) {
			req.send_json_object(JSONResponse.for_not_found());
			return(true);
		}
		req.send_json_object(HashTable.create()
			.set("content", markupfile.get_contents_string())
		);
		return(true);
	}

	public bool on_http_post(HTTPRequest req) {
		var dd = get_content_dir(req);
		if(dd == null) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to determine content directory"));
			return(true);
		}
		var data = req.get_body_json_hashtable();
		if(data == null) {
			req.send_json_object(JSONResponse.for_invalid_request());
			return(true);
		}
		var content = data.get_string("content");
		if(content == null) {
			req.send_json_object(JSONResponse.for_missing_data("content"));
			return(true);
		}
		if(dd.exists() == false) {
			dd.mkdir_recursive();
		}
		if(dd.exists() == false) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to create directory"));
			return(true);
		}
		var markupfile = dd.entry("content.markup");
		if(markupfile.set_contents_string(content) == false) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to write content file"));
			return(true);
		}
		req.send_json_object(JSONResponse.for_ok());
		return(true);
	}

	public bool on_http_delete(HTTPRequest req) {
		var dd = get_content_dir(req);
		if(dd == null) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to determine content directory"));
			return(true);
		}
		if(dd.is_directory() == false) {
			req.send_json_object(JSONResponse.for_not_found());
			return(true);
		}
		if(dd.delete_recursive() == false) {
			req.send_json_object(JSONResponse.for_internal_error("Failed to delete"));
			return(true);
		}
		req.send_json_object(JSONResponse.for_ok());
		return(true);
	}
}