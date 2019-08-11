---
title: autoconf Comparison
---

Tips on moving from autoconf
============================

From a user perspective, **autosetup** is highly compatible with an **autoconf**-generated `configure` script.


User-level Differences
----------------------

### No --target, --build is

In **autoconf**, `--target` identifies the final target of a cross-compilation tool, while
`--build` identifies the current build system.

To illustrate, if the build runs on architecture **B** to produce a tool which runs on architecture **H**
which in turn produces executables witch run on architecture **T**, the relationship is:

* `--build  =>` **B**
* `--host   =>` **H**
* `--target =>` **T**

**autosetup** guesses the build architecture by running `config.guess`, but in any case the build architecture
is almost never necessary.

The target architecture is only necessary where the project builds a cross-compilation tool.
**autosetup** has no explicit support for this. Instead, such projects can implement the `--target` option explicitly.

The host architecture *is* supported with the `--host` option, and defaults to the build architecture if not specified.

### No override of tests

**autoconf** allows individual tests to be overridden by setting the corresponding environment
variable directly. e.g.

=unix=
$ ac_cv_func_malloc_0_nonnull=yes ./configure
==

**autosetup** does not allow tests to be overridden. If settings cannot be detected reliably, developers
should provide explicit options to specify the result. e.g.

=unix=
$ ./configure --malloc-zero-nonnull
==

Developer-level Differences
---------------------------

Note: See [autoconf migration](/articles/autoconf-migration/) for information on using the automatic migration tool.

### Single variable namespace

All variables defined with `define` and `define-feature` use a
single namespace. This essentially means that AC_SUBST and AC_DEFINE
are equivalent, which simplifies configuration in practice.

### No autoheader

autosetup has no need for `autoheader` since a configuration header
file can simply be generated directly (see `make-autoconf-h`) without
a template.

### No subdirectory support

autoconf supports configuring subdirectories with AC_CONFIG_SUBDIRS.
autosetup has no explicit support for this feature.

### No automake

autosetup is not designed to be used with automake. autosetup is
flexible enough to be used with plain `make`, or other builds
systems.

### No AC_TRY_RUN

autosetup has no equivalent of AC_TRY_RUN which attempts to run a
test program. This feature is often used unnecessarily, and is
useless when cross compiling, which is a core feature of autosetup.

Developers are encouraged to provide common defaults, with user-settable options
for these features.

### Modern Platform Assumption

autoconf includes support for many old and obsolete platforms. Most
of these are no longer relevant. autosetup assumes that the build
environment is somewhat POSIX compliant. This includes both cygwin
and mingw on Windows.

Thus, there is no need to check for standard headers such as stdlib.h, string.h, etc.

### Checking for programs

The equivalent of AC_PROG_xxxx is the flexible `cc-check-progs`

=autosetup=
if {![cc-check-progs grep]} {
    user-error "You don't have grep, but we need it"
}
foreach prog {gawk mawk nawk awk false} {
    if {[cc-check-progs $prog]} {
        define AWK $prog
        break
    }
}
# If not found, AWK is defined as false
==

### Checking for functions

The equivalent of AC_FUNC_xxx is the flexible `cc-check-functions`

### No special commands to use replacement functions

Instead consider something like the following.

=autosetup=
# auto.def: Check all functions
cc-check-functions strtod backtrace

/* replacements.c */
#include "config.h"
#ifndef HAVE_STRTOD
double strtod(...) { /* implementation */ }
#endif
==

Alternatively, implement each missing function in it's own file.

=autosetup=
define EXTRA_OBJS ""
foreach f {strtod backtrace} {
    if {![cc-check-functions $f]} {
        define-append EXTRA_OBJS $f.o
    }
}
==

### Default checks do not use any include files.

autoconf normally adds certain include files to every test build,
such as stdio.h. This can cause problems where declarations in these
standard includes conflict with the code being tested. For this
reason, autosetup compile tests use no standard includes. If includes
are required, they should be added explicitly.

=autosetup=
cc-check-includes sys/socket.h sys/stat.h
cc-with {-includes sys/socket.h} {
    cc-check-members "struct msghdr.msg_control"
}
cc-with {-includes sys/stat.h} {
    cc-check-members "struct stat.st_mtime" "struct stat.st_atime" "struct stat.st_size"
}
==

### Checking for include files

When adding include files to a test, `cctest` will automatically omit
any include files which have been checked and do not exist. If any
includes have been specified but not checked, a warning is given.

=autosetup=
cc-with {-includes sys/socket.h} {
    cc-check-members "struct msghdr.msg_control"
}
==

=unix=
$ ./configure
Warning: using #include <sys/socket.h> which has not been checked -- ignoring
==
