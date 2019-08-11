---
title: Running autosetup
seealso: [ '/user/outoftree/', '/user/crosscompiling/', '/user/installing/' ]
---

Building an autosetup-enabled Project
=====================================

Introduction
------------

The purpose of **autosetup** is to adapt a project build to
the local development environment, including compilers, libraries,
and selected user options.

Building an **autosetup**-enabled project is almost identical to building
an **autoconf**-enabled project except it is faster and simpler.

Your project will include an **autosetup** wrapper, `configure`, and
an **autosetup** control file, `auto.def` at the top level. **autosetup** is invoked
via the `configure` script.

=unix=
$ ./configure
==

A more complex example might be:

=unix=
$ ./configure --host=arm-linux --utf8 --with-ext="regexp tree" --prefix=/usr CFLAGS="-g -Os"
==

Configuring
-----------

**autosetup**-enabled projects support various command-line options to
control the configuration process. These options include both
standard **autosetup** options and project-specific options.

Use `configure --help` for a full list of the supported options.

~~~~~~~~~~
Usage: configure [options] [settings]

   This is autosetup, a faster, better alternative to autoconf.
   Use the --manual option for the full autosetup manual.

  --help?=local?       display help and options. Optionally specify a module name, such
                       as --help=system
  --version            display the version of autosetup
  --manual?=text?      display the autosetup manual. Other formats: 'wiki', 'asciidoc',
                       'markdown'
  --debug              display debugging output as autosetup runs
  --install            install autosetup to the current directory (in the 'autosetup/'
                       subdirectory)
  --init               create an initial 'configure' script if none exists
  --host=host-alias    a complete or partial cpu-vendor-opsys for the system where the
                       application will run (defaults to the same value as --build)
  --build=build-alias  a complete or partial cpu-vendor-opsys for the system where the
                       application will be built (defaults to the result of running
                       config.guess)
  --prefix=dir         the target directory for the build (defaults to /usr/local)
  Local Options:
  --shared             Create a shared library
  --disable-utf8       Disable utf8 support
  --disable-largefile  Disable large file support
~~~~~~~~~~

In many cases, `configure` can be run without any arguments to select the default
options. Once the configuration process is complete, `make` is typically used to build
the project. Thus the typical configuration and build process is:

=unix=
$ ./configure
...output...
$ make
...output...
==

Note that `configure` need only be run once unless the compiler or environment changes,
or different options need to be selected.

Options
-------
There two types of options, **boolean** options and **string** options. **boolean** options simply
enable or disable a feature, while **string** options take an additional parameter.

### Boolean Options

Boolean options are either enabled or disabled by default. The following output from
`configure --help` shows two boolean options.

~~~~~~~~~
--shared             Create a shared library
--disable-utf8       Disable utf8 support
~~~~~~~~~

Here, `shared` is an option which is disabled by default, while `utf8` is an option
which is enabled by default.

For convenience, boolean options may be enabled or disabled in various ways.
To **enable** an option:

~~~~~~~~~~~~
--boolopt
--enable-boolopt
--boolopt=1
--boolopt=yes
~~~~~~~~~~~~

To **disable** an option:

~~~~~~~~~~~~
--disable-boolopt
--boolopt=0
--boolopt=no
~~~~~~~~~~~~

### String Options

String options take a parameter, however a default value *may* be provided for the the parameter.
The following output from `configure --help` shows two string options.

~~~~~~~~~~~~
--manual?=text?      display the autosetup manual. Other formats: 'wiki', 'asciidoc',
                     'markdown'
--host=host-alias    a complete or partial cpu-vendor-opsys for the system where the
                     application will run (defaults to the same value as --build)
~~~~~~~~~~~~

Here, `manual` is a string option with a default parameter value
(**text**), while `host` is a string option which requires a
parameter.

Environment Variables
---------------------
The `configure` command line may specify additional environment
variable settings after any options.

From example, consider the following:

=unix=
$ ./configure --utf8 CFLAGS="-Os"
==

In this case, the setting for CFLAGS overrides the default (-g -O2).

Environment variables are checked in the following priority order:

1. Values specified on the command line
2. Values from the environment
3. System defaults, possibly derived from other settings

In addition to project-specific environment variables (which should be documented
with the project), some modules have environment variables which can be changed.
For example, from the **cc** module reference:

~~~~~~~~~~~~
The following environment variables are used if set:

CC       - C compiler
CXX      - C++ compiler
CCACHE   - Set to "none" to disable automatic use of ccache
CFLAGS   - Additional C compiler flags
CXXFLAGS - Additional C++ compiler flags
LDFLAGS  - Additional compiler flags during linking
LIBS     - Additional libraries to use (for all tests)
CROSS    - Tool prefix for cross compilation

The following variables are defined from the corresponding
environment variables if set.

CPPFLAGS
LINKFLAGS
CC_FOR_BUILD
LD
~~~~~~~~~~~~

Related Topics
--------------

<%= show_related_topics(item) %>
