---
title: Get autosetup
label: Download
---

Get It
------

If your project is **autosetup**-enabled, it already includes a copy of **autosetup**.
Otherwise, the latest version of **autosetup** is available from the git repository at
<https://github.com/msteveb/autosetup>

=unix=
$ git clone git://github.com/msteveb/autosetup.git
Initialized empty Git repository in /Users/steveb/autosetup/.git/
remote: Counting objects: 311, done.
remote: Compressing objects: 100% (299/299), done.
remote: Total 311 (delta 179), reused 0 (delta 0)
Receiving objects: 100% (311/311), 311.07 KiB | 26 KiB/s, done.
Resolving deltas: 100% (179/179), done.
==

Try It
------

**autosetup** includes a number of samples which can be used for testing.

### Configure

=unix=
$ cd autosetup/examples/typical
$ ./configure
Host System...x86_64-apple-darwin10.7.0
Build System...x86_64-apple-darwin10.7.0
C compiler...ccache cc -g -O2
C++ compiler...ccache c++ -g -O2
Checking for stdlib.h...ok
Checking for long long...ok
Checking for sizeof long long...8
Checking for sizeof void *...8
Checking for sys/un.h...ok
Checking for regcomp...ok
...etc...
Enabling UTF-8
Building static library
Created config.h
Created Makefile from Makefile.in
==

### Build

=unix=
$ make
cc -g -O2 -D_GNU_SOURCE -Wall -Werror -I.  -c -o main.o main.c
cc -g -O2 -D_GNU_SOURCE -Wall -Werror -I.  -c -o funcs.o funcs.c
ar cr libtest.a funcs.o
ranlib libtest.a
cc -g -O2   -o app main.o libtest.a
==

Install It
----------

To add **autosetup** to a project, change directory to the project and install.

=unix=
$ cd ~/src/myproject
$ ~/src/autosetup/autosetup --install --init=make
Installed local autosetup v0.6.7 to autosetup
Initialising make: Simple "make" build system

I see auto.def already exists.
Note: I don't see Makefile.in. You will probably need to create one.
==

Now edit `auto.def` as required, create Makefile.in if necessary, and use `./configure`
