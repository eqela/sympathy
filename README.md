Sympathy Web Services
=====================

Overview
--------

The Sympathy project provides applications that can be used to implement and
provide web-based services on the Internet. Sympathy is fully implemented
in the Sling programming language (http://eqdn.tech/sling/), and is intended to
primarily be executed using the .NET platform (either Mono or Microsoft .NET).
For more information about Sympathy, please visit the Sympathy pages on EQDN:

http://eqdn.tech/sympathy/

The following components are currently delivered as part of Sympathy:

*artsy* - The "Article Server", provides functionality to run a website based
on HTML and/or JSON that is implemented around the concept of "articles" that
make up the bulk of the content. In practice, this could mean a blog site,
a wiki, a news site, or a combination or hybrid of any of those.

*artsc* - The "Article Server Compiler", used to verify, preprocess and index
articles that are served by the article server.

*filesy* - A common web server that can serve any static files of any type from
a directory specified by the user.

*keepalive* - A service watchdog that can execute a server program, restarting the
program if ever it dies (making sure servers will stay running).

As per the Sympathy naming convention, all server program names end with the
letter "y" (much like traditional Unix server program names end with the letter
"d").

Downloads
---------

For precompiled executables, please download from the Sympathy website:

http://sympathy.ws

Source code of Sympathy is available on Github:

https://github.com/eqela/sympathy

Usage
-----

To share a directory over HTTP with filesy:

```
filesy -OcontentDirectory=directoryToShare
```

By default, all Sympathy servers use port 8080 for HTTP communications. This can be
overridden with the listenPort directive:

```
filesy -OcontentDirectory=directoryToShare -OlistenPort=8081
```

Use keepalive to keep the server running in the background:

```
keepalive -bg filesy -OcontentDirectory=directoryToShare -OlistenPort=8081
```

For further information and deeper explanations, please see the complete
Sympathy documentation on EQDN:

http://eqdn.tech/sympathy/

Compiling the server-side components
------------------------------------

To compile the Sympathy source code, you will need to get the latest Jkop libraries
(from http://www.jkop.org). You will also need the SAM Sling compiler in order to
compile the Sling code: http://eqdn.tech/sling/

To compile all of the above-mentioned components, use the build script:

```
./build-services.sh <sam-command> [path-to-jkop]
```

A working BASH shell is required to execute the script. The "sam-command"
parameter specifies the command you would use (with any path components, if
needed) to execute the sam compiler (eg. just "samce", if the command is in your
PATH). The Jkop parameter is optional, as sam will use a default Jkop
installation if none is specified.

---

Sympathy is part of the Eqela technology stack. For more information, please
visit http://www.eqela.com
