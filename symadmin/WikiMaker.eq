
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

class WikiMaker
{
	property File dir;
	property HashTable details;

	String details_to_string(HashTable details) {
		var sb = StringBuffer.create();
		if(details != null) {
			foreach(String key in details.iterate_keys()) {
				if(key.has_prefix("admin_")) {
					continue;
				}
				sb.append("%s: %s\n".printf().add(key).add(details.get_string(key)).to_string());
			}
		}
		return(sb.to_string());
	}

	public bool execute(Error err) {
		if(dir == null || details == null) {
			Error.set_error_message(err, "Invalid parameters");
			return(false);
		}
		dir.mkdir_recursive();
		if(dir.is_directory() == false) {
			Error.set_error_message(err, "Failed to create directory: `%s'".printf().add(dir).to_string());
			return(false);
		}
		var publicdir = dir.entry("public");
		var wikidir = dir.entry("wiki");
		publicdir.mkdir_recursive();
		wikidir.mkdir_recursive();
		var config = dir.entry("site.config");
		if(config.set_contents_string(details_to_string(details)) == false) {
			Error.set_error_message(err, "Failed to write file: `%s'".printf().add(config).to_string());
			return(false);
		}
		var title = details.get_string("title");
		if(String.is_empty(title)) {
			title = "Sympathy wiki";
		}
		var maindoc = "= %s =\n\nWelcome to Sympathy Wiki\n".printf().add(title).to_string();
		var content = wikidir.entry("content.markup");
		if(content.set_contents_string(maindoc) == false) {
			Error.set_error_message(err, "Failed to write file: `%s'".printf().add(content).to_string());
			return(false);
		}
		var dbfile = dir.entry("users.sqlite");
		var sqldb = SQLiteDatabase.for_file(dbfile, true);
		if(sqldb == null) {
			Error.set_error_message(err, "Failed to create SQLite database: `%s'".printf().add(dbfile).to_string());
			return(false);
		}
		var userdb = UserDatabase.for_db(sqldb);
		if(userdb == null) {
			Error.set_error_message(err, "Unable to initialize user database: `%s'".printf().add(dbfile).to_string());
			return(false);
		}
		var username = details.get_string("admin_user");
		var password = details.get_string("admin_password");
		if(String.is_empty(username) == false) {
			if(password == null) {
				password = "";
			}
			if(userdb.add_user(username, password) == false) {
				Error.set_error_message(err, "Failed to create user: `%s'".printf().add(username).to_string());
				return(false);
			}
		}
		return(true);
	}
}
