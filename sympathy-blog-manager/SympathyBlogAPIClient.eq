
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

public class SympathyBlogAPIClient : SympathyAPIClient
{
	// User API

	public BackgroundTask get_users(EventReceiver listener) {
		return(get("/api/users", listener));
	}
	public BackgroundTask add_user(String username, String password, EventReceiver listener) {
		return(post("/api/users", HashTable.create().set("username", username)
			.set("password", password), listener));
	}
	public BackgroundTask update_user(String username, HashTable data, EventReceiver listener) {
		return(put("/api/users/".append(username), data, listener));
	}
	public BackgroundTask delete_user(String username, EventReceiver listener) {
		return(delete("/api/users/".append(username), listener));
	}

	// Category API

	public BackgroundTask get_categories(EventReceiver listener) {
		return(get("/api/categories", listener));
	}
	public BackgroundTask add_category(HashTable data, EventReceiver listener) {
		return(post("/api/categories", data, listener));
	}
	public BackgroundTask update_category(String id, HashTable data, EventReceiver listener) {
		return(put("/api/categories/id:".append(id), data, listener));
	}
	public BackgroundTask delete_category(String id, EventReceiver listener) {
		return(delete("/api/categories/id:".append(id), listener));
	}

	// Article API

	public BackgroundTask get_article_details(String id, EventReceiver listener) {
		return(get("/api/articles/id:".append(id), listener));
	}
	public BackgroundTask get_articles(EventReceiver listener) {
		return(get("/api/articles", listener));
	}
	public BackgroundTask add_article(HashTable data, EventReceiver listener) {
		return(post("/api/articles", data, listener));
	}
	public BackgroundTask update_article(String id, HashTable data, EventReceiver listener) {
		return(put("/api/articles/id:".append(id), data, listener));
	}
	public BackgroundTask delete_article(String id, EventReceiver listener) {
		return(delete("/api/articles/id:".append(id), listener));
	}

	// Session API

	public BackgroundTask login(String username, String password, EventReceiver listener) {
		var data = HashTable.create()
			.set("username", username)
			.set("password", password);
		return(post("/api/sessions", data, listener));
	}

	public BackgroundTask logout(EventReceiver listener) {
		return(delete("/api/sessions/%s/%s".printf().add(get_username()).add(get_session()).to_string(), listener));
	}
}
