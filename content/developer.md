---
title: Developing with autosetup
label: Developing
seealso: [ '/developer/reference/', '/developer/examples/',  '/developer/autoconf/', '/developer/advanced/', '/developer/sysinstall/' ]
---

Adding **autosetup** support to a project
=========================================

Introduction
------------

This guide explains how to add **autosetup** support to a project. Be sure to read the [user-level documentation](/user/)
first, including the [download instructions](/download/). The [examples](/developer/examples/) can also be very helpful.

Project-Local or System-Wide Install?
-------------------------------------

Before version 0.6.7 of autosetup, the only options to install autosetup as part of a project.
As explained below, this has the advantage of allowing your project to configure without requiring
any additional tools. It also solves the version problems since your project ships with exactly the
version of autosetup it requires.

Since version 0.6.7, as autosetup has stabilised, a system-wide installation of autosetup is now supported.
While this has the advantage of not requiring a copy of autosetup to be shipped with each project, open-source,
standalone projects are still encouraged to include a project-local copy of autosetup.

See [Using a system-wide install](/developer/sysinstall/) for further details. The remainder of this page
assumes a project-local install.

The Moving Parts
----------------

**autosetup** is deployed directly into the source tree of a project.
(This approach was inspired by [waf](http://waf.io/),
and means that there are no dependency issues with different versions
of autosetup since an appropriate version is part of the project.)

Within a project, autosetup consists of three main parts
at the top of the tree.

1. The `autosetup/` directory
2. The `auto.def` file
3. The `configure` wrapper script

These are all created by `autosetup --install --init=make`. Here are the files
in a typical installation.

~~~~~~~~~~~~
auto.def
configure
autosetup/LICENSE
autosetup/README.autosetup
autosetup/autosetup
autosetup/autosetup-config.guess
autosetup/autosetup-config.sub
autosetup/autosetup-find-tclsh
autosetup/autosetup-test-tclsh
autosetup/cc-db.tcl
autosetup/cc-lib.tcl
autosetup/cc-shared.tcl
autosetup/cc.tcl
autosetup/default.auto
autosetup/jimsh0.c
autosetup/pkg-config.tcl
autosetup/system.tcl
autosetup/tmake.auto
autosetup/tmake.tcl
~~~~~~~~~~~~

### The auto.def file

This file controls the configuration process. A trivial version is created by `autosetup --install`,
which must be edited to add the options and tests required for the project.

### The `configure` script

This tiny wrapper script is created by `autosetup --install` and does not need to be modified.

### The autosetup/ directory

This directory contains **autosetup**. Normally nothing needs to be modified in this directory,
however it is possible to add custom modules if necessary as: `autosetup/<modulename>.tcl`

The core of **autosetup** is the Tcl script `autosetup/autosetup` with the remaining files
as support files.

Note that a single-file version of a Tcl interpreter, `autosetup/jimsh0.c`
is included and automatically used in case no suitable interpreter
is found.

Configuration Description --- auto.def
---------------------------------------

The configuration process is controlled by the `auto.def` file.
This file consists of the following sections.

* module `use` declarations (must be first)
* user `options` declaration (must be second)
* checks for features and options
* output file generation based on checks, including template-based generation

A typical, simple auto.def file is:

=autosetup=
use cc

options {
    shared => "build a shared library"
    lineedit=1 => "disable line editing"
    utf8 => "enabled UTF-8 support"
    with-regexp regexp => "use regexp"
}

cc-check-types "long long"
cc-check-includes sys/un.h dlfcn.h
cc-check-functions ualarm sysinfo lstat fork vfork
cc-check-function-in-lib sqlite3_open sqlite3

if {[opt-bool utf8] && [have-feature fork]} {
    msg-result "Enabling UTF-8"
    define JIM_UTF8
}
make-config-header config.h
make-template Makefile.in
==

The `auto.def` file is written in **Tcl**. See [Tcl Scripting](/developer/tcl/)
for more information on the syntax and language features of **Tcl**.

### module use

**autosetup** contains some core configuration support, but support
for additional features is provided by optional modules. Some modules
such as `system`, `cc` and `cc-shared` are very common and will
almost always be included, while additional modules may be included
as required. See [Modules](/developer/modules/) for more information on how
modules can be created.

A typical `use` declaration is:

=autosetup=
# The C/C++ compiler will be used and shared libraries may be needed
use cc cc-shared
==

Note that the `system` module is automatically included by the `cc` module.

### options declaration

Options allow the user to provide control of the build. Options may be used to specify:
* where the build is installed
* the toolchain to use
* features to enable or disable
* the location of required external components
* and anything else which may affect how the build is performed

**Note**: Every auto.def *must* have an `options` declaration
immediately after any `use` declarations, even if it is empty.  This
ensures that `configure --help` behaves correctly.

Options are declared as follows.

=autosetup=
options {
    boolopt            => "a boolean option which defaults to disabled"
    boolopt2=1         => "a boolean option which defaults to enabled"
    stringopt:         => "an option which takes an argument, e.g. --stringopt=value"
    stringopt2:=value  => "an option where the argument is optional and defaults to 'value'"
    optalias booltopt3 => "a boolean with a hidden alias. --optalias is not shown in --help"
    boolopt4 => {
        Multi-line description for this option
        which is carefully formatted.
    }
}
==

The `=>` syntax is used to indicate the help description for the
option. If an option is not followed by `=>`, the option is not
displayed in `--help` but is still available.

If the first character of the help description is a newline (as for
`boolopt4`), the description will not be reformatted.

String options can be specified multiple times by the user, and all given values
are available. If there is no default value, the value must be
specified.

Within `auto.def`, options can be checked with the commands `opt-bool` and `opt-val`.

`configure --help` automatically displays appropriately formatted help for the declared options.
The example above gives.

=unix=
$ ./configure --help
...standard help...
  Local Options:
  --boolopt             a boolean option which defaults to disabled
  --disable-boolopt2    a boolean option which defaults to enabled
  --stringopt=          an option which takes an argument, e.g. --stringopt=value
  --stringopt2?=value?  an option where the argument is optional and defaults to 'value'
  --booltopt3           a boolean with a hidden alias. --optalias is not shown in --help
  --boolopt4
        Multi-line description for this option
        which is carefully formatted.
==

See [Options](/user/#options) for how options are specified on the `autosetup` command line.

### Testing Features and Options

**autosetup** maintains a single set of name/value pairs (*defines*) which represent the build
environment. Some of these values are set automatically by **autosetup**, some are set
by modules, some are set based on feature tests and others are set explicitly in `auto.def`.
Some example values are:

~~~~~~~~~~
srcdir=.
target=x86_64-apple-darwin10.7.0
HAVE_STDLIB_H=1
CC=arm-linux-gcc
SIZEOF_LONG_LONG=8
~~~~~~~~~~

These **defines**, or *configuration variables* fall into three broad categories:

1. Standard system **defines** are lower case, such as `srcdir`, `host_alias` and `prefix`
2. Commands, libraries and flags which would typically be substituted in a Makefile are
   uppercase, such as `CC`, `LIBS` and `CFLAGS`
3. *Feature* tests are boolean values in uppercase, always start with HAVE_ and have the value 0 or 1.
   For example, `HAVE_STDLIB_H`, `HAVE_REGCOMP` and `HAVE_LONG_LONG`. Note that a standard naming
   convention is used such that a test for `stdlib.h` sets `HAVE_STDLIB_H`, a test for the function `regcomp`
   sets `HAVE_REGCOMP` and a test for the type `long long` defines `HAVE_LONG_LONG`

In addition, `cc-check-sizeof` sets a numeric value and uses the SIZEOF_ prefix rather than the HAVE_ prefix.

The goal of the testing section of `auto.def` is to set **defines** based on the
development environment and the user options. **autosetup** provides a number of convenient commands
for setting **defines** (see the command reference for full details).

#### Direct Definition

The `define` and `define-feature` commands directly define a value. Note that `define-feature`
automatically applies the *feature* naming convention.

=autosetup=
define VERSION 1.1.3
if {[opt-bool utf8]} {
    define USE_UTF8
}
define-feature regcomp
==

These definitions are often made based on user options, which may
be checked with `opt-bool` and `opt-val`.

#### Feature Test Commands

The `cc-xxx` commands run the C or C++ compiler and define *features* based on the results.

=autosetup=
cc-check-types "long long"
cc-check-includes sys/un.h dlfcn.h
cc-check-functions ualarm sysinfo lstat fork vfork
cc-check-tools ar ranlib strip
cc-with {-includes sys/socket.h} {
    cc-check-members "struct msghdr.msg_control"
}
==

#### User Specified Variables

Any **name=value** parameters specified on the `configure` command line are automatically
set as configuration variables.

### Output File Generation

In order for the feature and option checks to be useful, output files
must be created to control the build. **autosetup** provides support
for two common mechanisms.

#### 1. Template Substitution --- make-template

The `make-template` command creates a file from a template by
applying substitutions based on the *configuration variables*.  For
example, any instance of `@CC@` is replaced with the value of `CC`
(e.g. `arm-linux-gcc`) in the output file.

This approach is ideal for creating a Makefile from a template, Makefile.in.

#### 2. Header File Generation --- make-config-header

The `make-config-header` command creates a C/C++ header file based on the *configuration variables*.
By default, every true feature test is defined in the generated header file. It is also possible
to output only a subset of the configuration variables, and also to include string variables
in addition to boolean variables.

A typical generated header file is:

~~~~~~~~~~~~~~
#ifndef _AUTOCONF_H
#define _AUTOCONF_H
#define HAVE_BACKTRACE 1
#define HAVE_DLFCN_H 1
#define HAVE_DLOPEN 1
#define HAVE_FORK 1
#define HAVE_GETADDRINFO 1
#define HAVE_GETEUID 1
#define HAVE_INET_NTOP 1
#define HAVE_LONG_LONG 1
/* #undef HAVE_SYSINFO */
#define HAVE_SYSLOG 1
#define TCL_PLATFORM_OS "Darwin"
#define TCL_PLATFORM_PLATFORM "unix"
#define SIZEOF_LONG_LONG 8
#endif
~~~~~~~~~~~~~~

It is also easy to create other file formats based on configuration
variables. For example, to produce configuration files in the Linux
**kconfig** format. It is also possible to output configuration
variables in Makefile format.

Related Topics
--------------

<%= show_related_topics(item) %>
