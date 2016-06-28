
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

public class Main : MultiActionCommandLineApplication
{
	public CommandLineApplicationAction create_action(String name) {
		if("create-wiki".equals(name)) {
			return(new CreateWikiAction());
		}
		if("create-blog".equals(name)) {
			return(new CreateBlogAction());
		}
		/*
		if("list-users".equals(name)) {
		}
		if("add-user".equals(name)) {
		}
		*/
		return(base.create_action(name));
	}

	public void add_usage_actions(UsageInfo ui) {
		ui.add_parameter("create-wiki", "Create a new wiki data directory");
		ui.add_parameter("create-blog", "Create a new blog data directory");
		// ui.add_parameter("list-users", "List all current users");
		// ui.add_parameter("add-user", "Add a user");
	}
}