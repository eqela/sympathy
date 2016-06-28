
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

public class Main : CommandLineApplication, ConsoleApplication
{
	StringBuffer command;
	bool background = true;

	public bool on_command_line_argument(String arg) {
		if(command == null && "-fg".equals(arg)) {
			background = false;
			return(true);
		}
		if(command == null) {
			command = StringBuffer.create();
		}
		if(command.count() > 0) {
			command.append_c(' ');
		}
		command.append(arg);
		return(true);
	}

	public void on_usage(UsageInfo ui) {
		ui.add_parameter("-fg", "Execute the given command as a foreground process");
		ui.add_parameter("[command / arguments]", "Specify the complete command to execute, along with any arguments / parameters");
	}

	bool exitflag;

	public void on_close() {
		Log.debug("Closing");
		exitflag = true;
	}

	public void on_refresh() {
	}

	public bool execute() {
		if(command == null || command.count() < 1) {
			usage();
			return(true);
		}
		if(background) {
			if(ProcessFork.fork() == false) {
				Log.error("Failed to fork process");
				return(false);
			}
		}
		var pw = new PersistentProcessManager().set_launcher(ProcessLauncher.for_string(command.to_string())).start();
		while(exitflag == false) {
			SystemEnvironment.sleep(60 * 60);
		}
		pw.stop();
		return(true);
	}
}
