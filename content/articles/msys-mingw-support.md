---
title: MSYS/MinGW support
date: 2011-07-08
---

Apparently there is considerable interest in supporting builds
within [MSYS/MinGW](http://www.mingw.org/wiki/MSYS) for Windows
rather than cygwin or cross compiling MinGW from (e.g.) Linux.

The main difficulty in supporting this platform is that MinGW
doesn't support fork/exec (or actually vfork/exec) and thus `exec`
support in the bootstrap jimsh is limited.

Fortunately, autosetup has few requirements of `exec` and these
limitations can be worked around, along with other differences
such as the use of backlashes in paths.

**autosetup running under the MSYS bash shell**

=unix=
$ cd examples/typical
$ ./configure
No installed jimsh or tclsh, building local bootstrap jimsh0
Host System...i686-pc-mingw32
Build System...i686-pc-mingw32
C compiler... gcc -g -O2
C++ compiler... c++ -g -O2
Checking for stdlib.h...ok
Checking for long long...ok
Checking for sizeof long long...8
Checking for sizeof void *...4
Checking for sys/un.h...not found
Checking for regcomp...not found
Checking for waitpid...not found
Checking for sigaction...not found
Checking for sys_signame...not found
Checking for sys_siglist...not found
Checking for syslog...not found
Checking for opendir...ok
Checking for readlink...not found
Checking for sleep...not found
Checking for usleep...ok
Checking for pipe...not found
Checking for inet_ntop...not found
Checking for getaddrinfo...not found
Enabling UTF-8
Building static library
Created config.h
Created Makefile from Makefile.in
==
