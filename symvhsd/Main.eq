
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

public class Main : SympathyNetworkServiceApplication
{
	class MyNetworkService : NetworkService
	{
		property String socket_pattern;
		property int idle_timeout = 30;
		public NetworkServiceConnection create_connection() {
			IFDEF("target_posix") {
				return(new VirtualHostServerConnection()
					.set_idle_timeout(idle_timeout)
					.set_socket_pattern(socket_pattern));
			}
			ELSE {
				return(null);
			}
		}
	}

	property String socket_pattern;
	property int idle_timeout = 30;
	property int port = 80;

	public Main() {
		socket_pattern = "sympathy_vhost_%s";
	}

	public void add_services() {
		add_service(port, new MyNetworkService().set_socket_pattern(socket_pattern).set_idle_timeout(idle_timeout));
	}

	public bool on_command_line_option(String key, String value) {
		if("socket-pattern".equals(key)) {
			socket_pattern = value;
			return(true);
		}
		if("idle-timeout".equals(key)) {
			idle_timeout = Integer.as_integer(value);
			return(true);
		}
		if("port".equals(key)) {
			port = Integer.as_integer(value);
			return(true);
		}
		return(base.on_command_line_option(key, value));
	}

	public bool execute() {
		if(port < 0) {
			usage();
			log_error("Port number is required: Please specify with -port=[number]");
			return(false);
		}
		return(base.execute());
	}

	public void on_usage(UsageInfo ui) {
		base.on_usage(ui);
		ui.add_option("socket-pattern", "pattern", "Specify the pattern for socket file filenames (default `%s')".printf().add(socket_pattern).to_string());
		ui.add_option("idle-timeout", "seconds", "Specify the number of seconds to wait before disconnecting idle clients (default %d)".printf().add(idle_timeout).to_string());
		ui.add_option("port", "TCP port", "Specify TCP port to listen on");
	}
}
