Sympathy Web Services
=====================

Overview
--------

The Sympathy project develops a generic cross platform web application framework and
ready-made microservices catering towards development of modern, robust web applications.
Sympathy aims to provide easily usable and ready-to-use components to make the development
of applications easier and faster.

Sympathy is fully implemented in the Sling programming language (http://eqdn.tech/sling/).
Because of Sling, the code is cross platform by nature, and has been used on different
platforms in its history, including C, Java, C#, .NET, Lua and JavaScript/Node.JS. Currently
the primary target platform is Node.JS and JavaScript running on Linux, but other platforms
are equally possible, and future adaptations obviously available as necessary.

Compiling Sympathy
------------------

The Sling compiler is distributed in Javascript format through NPM. To compile Sympathy,
you will therefore need to install Node.JS (v16 or higher), which includes NPM. Then
run the following commands:

```
npm install
npm run build
```

This performs a full build of all modules of Sympathy and produces Javascript code as
the output. The compiled version of the library is then found in the "dist"
subdirectory.

Sympathy uses the Jkop library, which is automatically downloaded by the Sling compiler
during build. For more information about Jkop: https://github.com/eqela/jkop
