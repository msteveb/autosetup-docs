---
title: Automatic autoconf migration tool
date: 2011-07-19
---

Although **autosetup** configurations are generally easy to create,
developers moving a complex project from **autoconf** to autosetup
may still find it tedious to create the **auto.def** configuration
file.

To simplify migration from autoconf, autosetup includes a migration
tool which will automatically convert a **configure.in** or **configure.ac**
file to an auto.def file.

Consider the following migration of [tinytcl](http://tinytcl.sourceforge.net/):

=unix=
$ cd tinytcl
$ ~/src/autosetup.git/migrate-autoconf
Migrating configure.ac to auto.def
Created auto.def. Now edit to resolve items marked XXX
$ ~/src/autosetup.git/autosetup --install
Installed autosetup v0.6.2 to autosetup/
I see configure, but not created by autosetup, so I won't overwrite it.
Use autosetup --init --force to overwrite.
$ ./autosetup/autosetup --init --force
I will overwrite the existing configure because you used --force.
==

Now the migrated auto.def can be edited. Before editing it looks something like this:

=autosetup=
# Created by migrate-autoconf - fix items marked XXX

use cc cc-lib

options {
    shared=0         =>  {Build a shared library}
    history=0        =>  {Enable history support}
    debug=0          =>  {Enable debugging command: cmdtrace}
    fork=1           =>  {Do not use fork (no exec, etc.)}
    syslog=0         =>  {Build the syslog extension}
}

#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.


# XXX autosetup automatically substitutes all define'd values
#     In general, simply 'define' the value rather than using a shell
#     variable and AC_SUBST.
#
# XXX AC_SUBST TARGET_PLATFORM $ac_cv_host

# Checks for programs.

# XXX TINYTCL_IS_STATIC=1
if {[opt-bool shared]} {
    # XXX if test "x$enableval" = "xyes" ; then
    msg-result "* creating shared library"
    # XXX TINYTCL_IS_STATIC=
    # XXX fi
}
# XXX AC_SUBST TINYTCL_IS_STATIC $TINYTCL_IS_STATIC
...
==

After editing, *auto.def* looks more like:

=autosetup=
...
define TARGET_PLATFORM [get-define host]

define TINYTCL_IS_STATIC 1
if {[opt-bool shared]} {
    msg-result "* creating shared library"
    define TINYTCL_IS_STATIC 0
}
...
==

The final edited version is available at in the autosetup repository
as [auto.def.edited](https://github.com/msteveb/autosetup/blob/master/examples/migration/tinytcl/auto.def.edited)
along with additional examples.

Note that **migrate-autoconf** only understands a common subset of autoconf macros and
uses various heuristics to perform the migration. Nonetheless, migrate-autoconf can 
significantly speed up migration from autoconf.
