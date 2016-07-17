
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

public class Main : SympathyWebSiteApplicationWithUserDatabase
{
	WikiDirectoryBackend backend;
	UserDatabase userdb;
	WikiSiteHandler wikihandler;
	HashTable site_config;

	public Main() {
		site_config = HashTable.create();
		set_require_datadir(true);
		wikihandler = new WikiSiteHandler();
	}

	public override void on_site_config_entry(String key, String value) {
		site_config.set(key, value);
		base.on_site_config_entry(key, value);
	}

	public void on_site_config_file_updated() {
		wikihandler.set_site_title(get_site_title());
		wikihandler.set_site_slogan(get_site_slogan());
		wikihandler.set_site_copyright(get_site_copyright());
		wikihandler.set_site_copyright_url(get_site_copyright_url());
		wikihandler.set_site_description(get_site_description());
		wikihandler.set_google_analytics_id(get_google_analytics_id());
		wikihandler.set_site_config(site_config);
	}

	public void on_maintenance() {
		base.on_maintenance();
		if(userdb != null) {
			userdb.on_maintenance();
		}
	}

	public void on_refresh() {
		base.on_refresh();
		if(backend != null) {
			backend.clear_cache();
		}
	}

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		var themedir = get_datadir_file("theme");
		var theme = WikiTheme.read(themedir, get_logger());
		if(theme == null) {
			log_warning("Failed to read wiki theme in directory: `%s'. Your site will not look good.".printf().add(themedir));
			theme = new WikiTheme();
		}
		wikihandler.set_theme(theme);
		backend = WikiDirectoryBackend.for_directory(get_datadir_file("wiki"));
		backend.set_theme_directory(themedir);
		userdb = UserDatabase.for_db(SQLiteDatabase.for_file(get_datadir_file("users.sqlite"), false, get_logger()));
		if(userdb == null) {
			log_warning("No user database `users' found in data directory `%s'. Disabling API features.".printf().add(get_datadir()));
		}
		var cc = new HTTPRequestHandlerContainer();
		cc.set_default_handler(wikihandler);
		if(userdb != null) {
			var apihandler = new HTTPRequestHandlerContainer();
			apihandler.set_root_handler(StaticContentHandler.for_response(HTTPResponse.for_html_string("API")));
			apihandler.set_default_handler(StaticContentHandler.for_response(HTTPResponse.for_html_string("API: Not found")));
			apihandler.set_request_handler("content",
			UserDatabaseHeaderSessionManager.for_handler(WikiEditorAPIHandler.for_directory(get_datadir_file("wiki")))
				.set_require_authentication(true));
			apihandler.set_request_handler("users",
				UserDatabaseHeaderSessionManager.for_handler(UserDatabaseAdminAPIHandler.for_db(userdb))
					.set_userdb(userdb)
					.set_require_authentication(true)
					.set_allowed_users(get_admin_users()));
			apihandler.set_request_handler("sessions", UserDatabaseSessionAPIHandler.for_db(userdb));
			cc.set_request_handler("api", apihandler);
		}
		wikihandler.set_backend(backend);
		wikihandler.add_resource_dir(themedir);
		wikihandler.add_resource_dir(get_datadir_file("public"));
		set_request_handler(cc);
		return(true);
	}
}
