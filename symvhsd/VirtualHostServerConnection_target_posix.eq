
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

class VirtualHostServerConnection : NetworkServiceConnection, EventLoopReadListener
{
	FileDescriptor sfd;
	long ctime;
	String reply;
	EventLoopEntry ee;
	property int idle_timeout = 30;
	property String socket_pattern;

	embed "c" {{{
		#include <sys/types.h>
		#include <sys/socket.h>
	}}}

	public void on_maintenance_timer(long now) {
		base.on_maintenance_timer(now);
		if(get_ctime() < now - idle_timeout) {
			log_debug("Closing an idle connection");
			close();
		}
	}

	public bool initialize(NetworkService service, TCPSocket socket) {
		if(base.initialize(service, socket) == false) {
			return(false);
		}
		this.sfd = socket as FileDescriptor;
		if(service == null) {
			log_error("VirtualHostServerConnection: No service supplied.");
			return(false);
		}
		if(sfd == null) {
			log_error("VirtualHostServerConnection: Socket is not a file descriptor. Cannot sensibly continue.");
			return(false);
		}
		ctime = SystemClock.seconds();
		var el = service.get_eventloop();
		if(el == null) {
			log_error("VirtualHostServerConnection: No event loop");
			return(false);
		}
		var ee = el.entry_for_object(socket);
		if(ee == null) {
			log_error("VirtualHostServerConnection: Unable to add new socket to event loop");
			return(false);
		}
		ee.set_read_listener(this);
		this.ee = ee;
		return(true);
	}

	public long get_ctime() {
		return(ctime);
	}

	public void on_redirect_301(String url) {
		reply = "HTTP/1.1 301 Moved Permanentlyl\r\nServer: Sympathy VHS %s\r\nLocation: %s\r\n\r\n"
			.printf().add(VALUE("version")).add(url).to_string();
	}

	public void on_error_404() {
		reply = "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nServer: Sympathy VHS %s\r\nContent-Length: 11\r\nConnection: close\r\n\r\nNot Found\r\n"
			.printf().add(VALUE("version")).to_string();
	}

	public void on_error_500() {
		reply = "HTTP/1.1 500 Internal Server Error\r\nContent-Type: text/plain\r\nServer: Sympathy VHS %s\r\nContent-Length: 7\r\nConnection: close\r\n\r\nError\r\n"
			.printf().add(VALUE("version")).to_string();
	}

	public void close() {
		log_debug("VirtualHostServerConnection closing");
		if(ee != null) {
			ee.remove();
			ee = null;
		}
		base.close();
	}

	private bool send_socket_fd(LocalSocket sock) {
		var lsfd = sock as FileDescriptor;
		if(lsfd == null) {
			log_error("Local socket is not a file descriptor!");
			return(false);
		}
		var sockfdo = get_socket() as FileDescriptor;
		if(sockfdo == null) {
			log_error("TCP socket is not a file descriptor!");
			return(false);
		}
		var sockfd = sockfdo.get_fd();
		if(sockfd < 1) {
		log_error("Invalid file descriptor for tcp socket");
			return(false);
		}
		var fd = lsfd.get_fd();
		if(fd < 1) {
			log_error("Invalid file descriptor for local socket");
			return(false);
		}
		int r;
		embed "c" {{{
			int lwm = 1;
			setsockopt(sockfd, SOL_SOCKET, SO_RCVLOWAT, &lwm, sizeof(lwm));
			struct msghdr msg;
			struct iovec iov[1];
			union {
				struct cmsghdr cm;
				char control[CMSG_SPACE(sizeof(int))];
			} control_un;
			struct cmsghdr* cmptr;
			msg.msg_control = control_un.control;
			msg.msg_controllen = sizeof(control_un.control);
			cmptr = CMSG_FIRSTHDR(&msg);
			cmptr->cmsg_len = CMSG_LEN(sizeof(int));
			cmptr->cmsg_level = SOL_SOCKET;
			cmptr->cmsg_type = SCM_RIGHTS;
			*((int*)CMSG_DATA(cmptr)) = sockfd;
			msg.msg_name = NULL;
			msg.msg_namelen = 0;
			iov[0].iov_base = "FD";
			iov[0].iov_len = 2;
			msg.msg_iov = iov;
			msg.msg_iovlen = 1;
			r = sendmsg(fd, &msg, 0);
		}}}
		if(r < 0) {
			log_error("sendmsg() failed when sending file descriptor.");
			return(false);
		}
		return(true);
	}

	private void on_host_found(String host) {
		log_debug("Host found: `%s'".printf().add(host));
		var ls = LocalSocket.create();
		if(ls == null) {
			log_error("No local socket!");
			on_error_500();
			return;
		}
		var sp = get_socket_pattern();
		if(sp == null || sp.get_length() < 1) {
			log_error("Empty socket pattern!");
			on_error_500();
			return;
		}
		var v = ls.connect(sp.printf().add(host).to_string());
		if(v == false) {
			if(host.has_suffix(":80")) {
				v = ls.connect(sp.printf().add(host.substring(0, host.get_length()-3)).to_string());
			}
		}
		if(v == false) {
			if(host.has_prefix("www.") == false) {
				if(ls.connect(sp.printf().add("www.".append(host)).to_string())) {
					on_redirect_301("http://www.".append(host));
					return;
				}
			}
		}
		if(v == false) {
			log_debug("Unavailable virtual host requested: `%s'".printf().add(host));
			on_error_404();
			return;
		}
		if(send_socket_fd(ls) == false) {
			on_error_500();
			return;
		}
		// SUCCESS!
		close();
	}

	public void on_read_ready() {
		embed "c" {{{
			unsigned char ptr[32769];
		}}}
		int fd = sfd.get_fd();
		if(fd < 1) {
			close();
			return;
		}
		int empty = 0;
		int first = 1;
		int http09 = 0;
		strptr host = null;
		int r;
		embed "c" {{{
			r = recv(fd, ptr, 32768, MSG_PEEK);
		}}}
		if(r < 1) {
			close();
			return;
		}
		embed "c" {{{
			ptr[r] = 0; // ensure that there is a zero in the end
			int n;
			for(n=0; n<r; n++) {
				if(ptr[n] == '\n' && n > 0 && first == 1) {
					int x = n;
					if(ptr[x-1] == '\r') {
						x --;
					}
					if(x < 8 || strncmp((const char*)&ptr[x-8], "HTTP/1.", 7)) {
						http09 = 1;
					}
					first = 0;
				}
				if(ptr[n] == 'H' && n > 0 && ptr[n-1] == '\n' && n+6 < r &&
					ptr[n+1] == 'o' && ptr[n+2] == 's' && ptr[n+3] == 't' && ptr[n+4] == ':' &&
					ptr[n+5] == ' ') {
					n += 6;
					int m;
					for(m=n; m<r; m++) {
						if(ptr[m] == '\n' || ptr[m] == '\r') {
							ptr[m] = 0;
							break;
						}
					}
					host = (char*)(ptr + n);
				}
				if(ptr[n] == '\n' && ptr[n+1] == '\n') {
					empty = 1;
				}
				if(ptr[n] == '\n' && ptr[n+1] == '\r' && ptr[n+2] == '\n') {
					empty = 1;
				}
			}
			r++;
			setsockopt(fd, SOL_SOCKET, SO_RCVLOWAT, &r, sizeof(r));
		}}}
		if(reply == null) {
			if(host != null) {
				on_host_found(String.for_strptr(host));
			}
			else if(empty == 1) {
				on_host_found("default");
			}
			else if(http09 == 1) {
				on_host_found("default");
			}
		}
		var socket = get_socket();
		if(socket != null && (empty == 1 || http09 == 1)) {
			if(reply != null) {
				var os = OutputStream.create(socket);
				if(os != null) {
					os.print(reply);
				}
			}
			close();
		}
	}
}
