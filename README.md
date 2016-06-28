Sympathy: A high performance dynamic web service platform
=========================================================

The Sympathy project provides a web server / service platform implementation
that lets the web server and service logic run in a single process, with the entire
functionality (including the HTTP server itself) compiled to a single language,
which can be processor native machine language for maximum performance and
optimized memory use. Running Sympathy based web services requires no particular
installation or configuration tasks aside from running the actual executable.
Sympathy supports Windows, OS X and Linux as execution platforms, with a very
fast epoll-based implementation on Linux for production deployments.

Sympathy is fully developed in the EQ programming language (http://eqdn.tech/eq),
and relies heavily on Jkop libraries (www.jkop.org), specifically Jkop EQ, as the
underlying application framework.

Please also visit http://sympathy.ws for more information.

---

Components
----------

Sympathy includes the following sub-components:

*presspathy* - A blog engine server that can be used to implement a blog site,
news site, or something similar.

*symadmin* - Administration tool that can be used to create an empty skeleton
for a blog or a wiki site.

*symfiles* - A traditional web server implementation that can be used to serve
static files.

*symmanager* - A background service manager that runs other processes in the
background and keeps them running even in cases of crashes.

*symvhsd* - A Virtual Host Server implementation that enables several sites to
be serviced on a single server computer, dividing the traffic to different server
processes based on the requested service / hostname.

*wimpathy* - A wiki engine server that can be used to implement a "wiki-like"
website that hosts dynamic, editable content.

*sympathy-blog-manager* - A management tool for presspathy, used to manage
and write blog posts and other content on the site (work in progress).

---

Compiling
---------

To compile Sympathy, you will need to get the latest Jkop EQ libraries from
www.jkop.org and save the source tree on your filesystem. You will also need
an EQ compiler, which you can download from: www.eqela.com/download

To compile all of the above-mentioned components, use the release.sh script:

```
sh release.sh <target-platform> <path-to-jkop-eq-src>
```

The "target-platform" should match your current running system, which would
be one of "osx", "linuxx86" (32 bit Linux), "linuxx64" (64 bit Linux),
"win7m32" (Windows 7 or higher, 32 bit) or "win7m64" (Windows 7 or higher, 64 bit).

The "path-to-jkop-eq-src" represents the "src" subdirectory of the Jkop EQ
libraries that you have downloaded. For example:

```
sh release.sh linuxx64 ../jkop-eq/src 
```

This is assuming your eqc (EQ compiler) is in PATH. If not, you can specify the
path to eqc via an environment variable:

```
EQC=../edk_3.1.x.20150512/eqc sh release.sh linuxx64 ../jkop-eq/src
```

You may also compile individual components, for example:

```
eqc -platform=../jkop-eq/src wimpathy
```

(Note that you will need to specify the location to the Jkop EQ libraries
as part of the compilation command, as shown above)

---

Sympathy is part of the Eqela technology stack. For more information, please
visit www.eqela.com
