---
title: Build Out-of-Tree
---

Building Out-of-Tree
====================

While it is common to build a project in-place, many projects
will also support building out-of-tree. That is, generated files
such as object files and executables are created in a tree outside
the project source code. This approach can be useful when building
multiple versions of a project with different options.

Building out-of-tree simply involves invoking `configure` from
an empty directory other than the top of the source tree.

For example, to create a debug build in the `build-debug` directory:

=unix=
$ mkdir build-debug
$ cd build-debug
$ ../configure CFLAGS="-g -O0"
$ make
$ cd ..
==

And to create a release build in the `build-release` directory:

=unix=
$ mkdir build-release
$ cd build-release
$ ../configure CFLAGS="-O2"
$ make
$ cd ..
==

Notes:

* The project must be enabled for out-of-tree builds, typically with the
  user of `VPATH` if using `make`
* The source tree should be clean (i.e. no build should be done in the
  original source directory), otherwise it will confuse `make`
