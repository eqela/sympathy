
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

class CreateBlogAction : CommandLineApplicationAction
{
	File blogdir;
	HashTable details;

	public CreateBlogAction() {
		details = HashTable.create();
	}

	public bool on_command_line_flag(String flag) {
		return(false);
	}

	public bool on_command_line_option(String key, String value) {
		if(key != null && key.has_prefix("D")) {
			details.set(key.substring(1), value);
			return(true);
		}
		return(false);
	}

	public bool on_command_line_parameter(String param) {
		if(blogdir != null) {
			log_error("Only one directory name can be supplied.");
			return(false);
		}
		blogdir = File.for_native_path(param);
		return(true);
	}

	public void on_usage(UsageInfo ui) {
	}

	public bool execute() {
		if(blogdir == null) {
			log_error("You must supply a directory name.");
			usage();
			return(false);
		}
		if(blogdir.exists()) {
			log_error("File or directory already exists: `%s'".printf().add(blogdir));
			return(false);
		}
		print_header();
		println("Creating a new blog site in: `%s' ..".printf().add(blogdir));
		println();
		var dets = new KeyValueList();
		dets.append("title", "Blog name");
		dets.append("slogan", "Blog headline");
		dets.append("description", "Blog description");
		dets.append("copyright", "Blog copyright");
		dets.append("copyright_url", "Blog owner URL");
		dets.append("admin_user", "Administrator username");
		dets.append("admin_password", "Administrator password");
		foreach(KeyValuePair kvp in dets) {
			var key = kvp.get_key();
			var val = details.get_string(key);
			if(val != null) {
				println("%s [%s]: %s".printf().add(kvp.get_value()).add(key).add(val).to_string());
			}
			else {
				print("%s [%s]: ".printf().add(kvp.get_value()).add(key).to_string());
				details.set(key, readline());
			}
		}
		var err = new Error();
		var bm = new BlogMaker();
		bm.set_dir(blogdir);
		bm.set_details(details);
		if(bm.execute(err) == false) {
			log_error("Failed to create wiki: %s".printf().add(err));
			return(false);
		}
		return(true);
	}
}
