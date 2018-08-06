Sympathy Web Services
=====================

Overview
--------

The Sympathy project develops server-side applications that can be used to implement
and provide web-based services on the Internet. Sympathy is fully implemented
in the Sling programming language (http://eqdn.tech/sling/), and is intended to
primarily be used on servers running either Linux, Windows or Mac OS, executing under
the Eqela Runtime environment. For more information about Sympathy, please also visit
the Sympathy pages on EQDN:

http://eqdn.tech/sympathy/

According to the Sympathy naming convention, all server program names end with the
letter "y" (much like traditional Unix server program names end with the letter
"d").

Downloads
---------

For installation and usage of readily compiled binaries, please proceed to the Sympathy website:

http://sympathy.ws

Source code of Sympathy is available on Github:

https://github.com/eqela/sympathy

Usage
-----

To share the current directory over HTTP with filesy:

```
filesy .
```

By default, all Sympathy servers use port 8080 for HTTP communications. This can be
overridden with the -listen command line option:

```
filesy . -listen=8081
```

For further information and deeper explanations, please visit the Sympathy pages on EQDN:

http://eqdn.tech/sympathy/

Compiling the server-side components
------------------------------------

To compile the Sympathy source code, you will need to have the Eqela Runtime environment
installed (get it from http://eqdn.tech/eqela-cli/). Once you then compile with Eqela tools,
the appropriate compiler and library versions will be automatically downloaded. Simply compile
with the following command (execute in the sympathy source code directory where build.qx is):"

```
eqela .
```

---

Sympathy is part of the Eqela technology stack. For more information, please
visit http://www.eqela.com
