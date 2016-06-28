
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

public class ProcessFork
{
	IFDEF("target_posix") {
		embed "c" {{{
			#include <stdio.h>
			#include <unistd.h>
		}}}

		public static bool fork() {
			int pid;
			embed "c" {{{
				pid = fork();
			}}}
			if(pid < 0) {
				return(false);
			}
			if(pid > 0) {
				embed "c" {{{
					exit(0);
				}}}
			}
			embed "c" {{{
				freopen("/dev/null", "r", stdin);
				freopen("/dev/null", "r", stdout);
				freopen("/dev/null", "r", stderr);
			}}}
			return(true);
		}
	}

	ELSE {
		public static bool fork() {
			return(false);
		}
	}
}
