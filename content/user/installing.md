---
title: Installing
---

Installing
==========

An **autosetup**-enabled project will typically have an `install` target in the `Makefile`.
If the project follows the **autoconf** conventions, two settings may be used
to control where the build results are installed, `--prefix` and `$DESTDIR`.

Using `--prefix`
----------------

By default, the install prefix is set to `/usr/local`. This means that binaries
are installed to `/usr/local/bin`, manual pages to `/usr/local/man`, etc.

The `--prefix` option changes this install prefix. For example, `--prefix=/usr` will install
to `/usr`, while `--prefix=` will install to the root directory (`/bin`, `/man`, etc.)

Note that the given prefix may be used within the project to locate it's files at runtime,
so it should match the actual target destination.

Using `$DESTDIR` to stage installation
--------------------------------------

In addition to `--prefix`, the `$DESTDIR` environment variable controls the root of the tree
under which the build results are installed. This is an **install time** environment variable, not
a **configure time** environment variable. Consider:

=unix=
$ ./configure --prefix=/usr
$ make DESTDIR=/tmp/staging install
==

Here, the project is configured to install to `/usr` on the final target, but the files are copied
to `/tmp/staging/usr/bin`, etc. This can be used to stage installation to a temporary directory before
installation in the final location.

This is often done when cross compiling to build an installation filesystem, or when creating a binary
package for later installation.

Additional Installation Locations
---------------------------------

In addition to `--prefix`, **autosetup** supports the following **autoconf**-compatible options to override the installation
location of specific build results. Note that the project may or may not have support for these
options, and their use is discouraged.

~~~~~~~~~~~~
--includedir
--mandir
--infodir
--libexecdir
--sysconfdir
--localstatedir
~~~~~~~~~~~~
