
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
	BlogSiteHandler bloghandler;
	BlogRSSHandler rsshandler;
	HashTable site_config;

	public Main() {
		site_config = HashTable.create();
		set_require_datadir(true);
		bloghandler = new BlogSiteHandler();
		rsshandler = new BlogRSSHandler();
	}

	public override void on_site_config_entry(String key, String value) {
		site_config.set(key, value);
		base.on_site_config_entry(key, value);
	}

	public void on_site_config_file_updated() {
		bloghandler.set_site_title(get_site_title());
		bloghandler.set_site_slogan(get_site_slogan());
		bloghandler.set_site_copyright(get_site_copyright());
		bloghandler.set_site_copyright_url(get_site_copyright_url());
		bloghandler.set_site_description(get_site_description());
		bloghandler.set_site_url(get_site_url());
		bloghandler.set_google_analytics_id(get_google_analytics_id());
		bloghandler.set_site_config(site_config);
		rsshandler.set_site_title(get_site_title());
		rsshandler.set_site_slogan(get_site_slogan());
		rsshandler.set_site_url(get_site_url());
	}

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		var err = new Error();
		var blogdb = BlogDatabase.for_db(SQLiteDatabase.for_file(get_datadir_file("blog.sqlite"), false, get_logger()), err);
		if(blogdb == null) {
			log_error("Blog database file was not found in data directory `%s'. Use symblogadmin to initialize a blog.".printf().add(get_datadir()));
			return(false);
		}
		var apihandler = new HTTPRequestHandlerContainer();
		apihandler.set_root_handler(StaticContentHandler.for_response(HTTPResponse.for_html_string("API")));
		apihandler.set_default_handler(StaticContentHandler.for_response(HTTPResponse.for_html_string("API: Not found")));
		apihandler.set_request_handler("categories",
			UserDatabaseHeaderSessionManager.for_handler(RecordStoreRequestHandler.for_record_store(blogdb.get_category_store()))
				.set_userdb(get_userdb())
				.set_require_authentication(true));
		apihandler.set_request_handler("articles",
			UserDatabaseHeaderSessionManager.for_handler(RecordStoreRequestHandler.for_record_store(blogdb.get_article_store()).set_list_fields(blogdb.get_article_list_fields()))
				.set_userdb(get_userdb())
				.set_require_authentication(true));
		apihandler.set_request_handler("users",
			UserDatabaseHeaderSessionManager.for_handler(UserDatabaseAdminAPIHandler.for_db(get_userdb()))
				.set_userdb(get_userdb())
				.set_require_authentication(true)
				.set_allowed_users(get_admin_users()));
		apihandler.set_request_handler("sessions", UserDatabaseSessionAPIHandler.for_db(get_userdb()));
		bloghandler.set_db(blogdb);
		rsshandler.set_db(blogdb);
		set_request_handler(new HTTPRequestHandlerContainer()
			.set_default_handler(bloghandler)
			.set_request_handler("api", apihandler)
			.set_request_handler("rss", rsshandler)
			.set_request_handler("public", DirectoryContentHandler.for_content_dir(get_datadir_file("public")))
		);
		return(true);
	}
}
