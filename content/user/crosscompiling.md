---
title: Cross Compiling
seealso: [ '/user/installing/', '/user/outoftree/' ]
---

Cross Compiling
===============

**autosetup** is designed to make cross compiling very easy.
If you have a toolchain installed with the *standard* GNU naming
convention, cross compiling should *"just work"*.

For example, if you have `arm-linux-cc`, `arm-linux-ar`, etc.
then building with this toolchain is as simple as:

=unix=
$ ./configure --host=arm-linux
==

If specific options need to be passed to the compiler, they
can be set by overriding `CC`. e.g.

=unix=
$ ./configure --host=arm-linux CC="arm-linux-gcc -mbig-endian"
==

Note that this approach is preferred rather than setting `CFLAGS`
as it allows the user to override `CFLAGS` at build time.

Overriding the cross compiler prefix
------------------------------------

In general, `--host` should be used to specify the toolchain prefix.
However it may be desirable to override the toolchain prefix. This is
possible with the `CROSS` environment variable. For example:

=unix=
$ ./configure --host=arm-linux CROSS=my-
==

This will use the C compiler, `my-cc` or `my-gcc`, the archive tool, `my-ar`, etc.

Additional Topics
-----------------
* CC_FOR_BUILD
* \--build

Related Topics
--------------

<%= show_related_topics(item) %>
