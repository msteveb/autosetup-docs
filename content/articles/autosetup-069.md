---
title: autosetup 0.6.9
date: 2019-06-21
---

**autosetup** v0.6.9 has been released.

As there has been no release notes for a while, here are the changes since v0.6.2

Major improvements:

* make-template: Support nesting, better conditionals, @define and @include
* Make it possible to use a system-installed autosetup.  e.g. autosetup --sysinstall=/usr/local
* Add initial pkg-config support
* Add an extensible init system with autosetup --init=\<type\>

Minor changes and bug fixes:

* define-append now ignores empty values
* define-append: improved check for duplicates
* cc-shared: always use -fPIC
* cc-shared: Add support for RPATH
* cc-shared: Add $STRIPLIBFLAGS
* system: add support for --runstatedir
* system: add abs_top_srcdir and abs_top_builddir
* options-defaults provides a way to change the default options from auto.def
* Never honor prefix for /var, honor only if != /usr for /etc
* make-template: Don't write file if unchanged
* Allow $autosetup_tclsh to select the preferred tclsh
* Add cc-path-progs
* cc: drop empty -cflags, -includes, -libs
* cc: tests should use LIBS and LDFLAGS
* opt-bool: allow boolean options multiple times
* opt-bool: accepts -nodefault option
* cc-lib: add cc-check-alloca and cc-signal-return-type
* Fix cc-check-members for members of structs
* Set srcdir to a fully qualified path
* Add support for undefine
* Allow --init and --install to be combined
* Update config.{sub,guess} from automake-1.15
* Add 'cctest -nooutput 1' to consider any compiler output as an error

Incompatibilities introduced:

* Syntax of @if statements has changed in make-template
* Remove --with-xxx and --without-xxx synonyms
* opt-val now returns a list
