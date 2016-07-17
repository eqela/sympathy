
/*
 * This file is part of Jkop
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public class WikiDirectoryBackend : WikiBackend
{
	public static WikiDirectoryBackend for_directory(File dir) {
		return(new WikiDirectoryBackend().set_dir(dir));
	}

	property File dir;
	property File theme_directory;
	HashTable cache;

	public WikiDirectoryBackend() {
		cache = HashTable.create();
	}

	public void clear_cache() {
		Log.message("Clearing the memory cache for directory `%s'".printf().add(dir));
		cache = HashTable.create();
	}

	public File get_resource_for_path(String path) {
		if(path == null || path.has_prefix("/") == false) {
			return(null);
		}
		var pp = Path.normalize_path(path);
		if(dir == null) {
			return(null);
		}
		var ff = dir.entry(pp.substring(1));
		if(ff.is_file() == false) {
			return(null);
		}
		return(ff);
	}

	public WikiDocument get_document_for_path(String path) {
		if(path == null || path.has_prefix("/") == false) {
			return(null);
		}
		var pp = Path.normalize_path(path);
		var doc = cache.get(pp) as WikiDirectoryDocument;
		if(doc != null) {
			if(doc.is_up_to_date()) {
				return(doc);
			}
			cache.set(pp, null);
		}
		if(dir == null) {
			return(null);
		}
		var ff = dir.entry(pp.substring(1));
		if(ff.is_directory() == false) {
			return(null);
		}
		var v = WikiDirectoryDocument.for_directory(ff, theme_directory, this);
		if(v == null) {
			return(null);
		}
		v.set_path(pp);
		cache.set(pp, v);
		return(v);
	}
}
