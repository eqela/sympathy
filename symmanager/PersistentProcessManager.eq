
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

public class PersistentProcessManager : LoggerObject, Runnable
{
	property ProcessLauncher launcher;
	property bool exitflag;
	property int very_quick_exit = 5;
	property int quick_exit_delay = 15;
	bool running;
	Process child;

	public virtual void on_start(ProcessLauncher launcher, Process child) {
	}

	public virtual void on_end(ProcessLauncher launcher, Process child) {
	}

	public void run() {
		log_debug("PersistentProcessManager: Starting process monitor for `%s'".printf().add(launcher));
		running = true;
		exitflag = false;
		while(exitflag == false) {
			var before = SystemClock.seconds();
			log_debug("PersistentProcessManager: Executing `%s' ..".printf().add(launcher));
			int r;
			child = launcher.start(get_logger());
			on_start(launcher, child);
			if(child != null) {
				r = child.wait_for_exit();
			}
			else {
				r = -1;
			}
			log_debug("PersistentProcessManager: `%s' ended.".printf().add(launcher));
			on_end(launcher, child);
			child = null;
			if(r != 0) {
				log_warning("PersistentProcessManager: `%s' returned error status %d".printf().add(launcher).add(r));
			}
			if(SystemClock.seconds() - before < very_quick_exit && exitflag == false) {
				log_debug("PersistentProcessManager: Process `%s' exited very quickly. Pausing for %d seconds before restarting.".printf().add(launcher)
					.add(quick_exit_delay));
				SystemEnvironment.sleep(quick_exit_delay);
			}
		}
		running = false;
		log_debug("PersistentProcessManager: Process monitor for `%s' ended".printf().add(launcher));
	}

	public PersistentProcessManager start() {
		if(Thread.start(this) == false) {
			return(null);
		}
		return(this);
	}

	public void stop() {
		exitflag = true;
		if(child != null) {
			var cc = child;
			cc.kill();
		}
	}

	public bool is_running() {
		return(running);
	}
}
