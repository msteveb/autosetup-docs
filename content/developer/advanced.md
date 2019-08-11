---
title: Advanced Concepts
---

Troubleshooting
---------------
If **autosetup** does not produce the expected results, the `--debug` option may
be given to help troubleshoot the problem. Modules are expected to write additional
details to the log, `config.log`, when this setting is enabled.

This code snippet is from the `cc` module.

=autosetup=
if {$::autosetup(debug)} {
    configlog "Compiled OK: [join $cmdline]"
}
==

In addition, all configuration variables are dumped at the end of configuration.

Selecting the Language: C or C++
--------------------------------

The `cc` module provides low level `cctest` commands provides the `-lang` option to
select the language to use for tests. This can be used in conjunction
with `cc-with` to set the language for a series of tests.

=autosetup=
cc-with {-lang c++} {
    # All tests now use the C++ compiler -- $(CXX) and $(CXXFLAGS)
    cc-check-types bool
}
# Or just set it for the rest of the file
cc-with {-lang c++}
...
==

Supporting Standard Installation
--------------------------------

**autosetup** facilitates use of both configure-time installation location
and install-time installation location through the autoconf-standard `--prefix` and `$DESTDIR`.
See </user/installing/> for details.

In order to support `$DESTDIR` with `make`, the following should be included in `Makefile.in`

=makefile=
prefix = @prefix@
...
install: all
    @echo Installing from @srcdir@ and @builddir@ to $(DESTDIR)$(prefix)
==

If the project requires the installation directory, an appropriate `define` can be created.
e.g.

=autosetup=
define TCL_LIBRARY [get-define prefix]/lib/jim
==

A "standard" Makefile.in
------------------------

If autosetup is being used to control a make-based build system,
the use of a `Makefile.in` with a standard structure will
provide behaviour similar to that provided by **autoconf**/**automake**
systems. **autosetup** provides a typical `Makefile.in` in
`examples/typical/Makefile.in`. This example provides the
following:

* Use `CC`, `AR`, `RANLIB` as determined by cross compiler settings or user overrides
* Install appropriately considers `--prefix` and `$DESTDIR`
* Use VPATH to support out-of-tree builds
* Dummy **automake** targets to allow for use as a subproject with **automake**
* Automatically reconfigure if `auto.def` changes

=makefile=
# Example of a typical Makefile template for autosetup

# Tools. CC is standard. The rest are via cc-check-tools
CC = @CC@
RANLIB = @RANLIB@
AR = @AR@
STRIP = @STRIP@

# FLAGS/LIBS
CFLAGS = @CFLAGS@
LDFLAGS = @LDFLAGS@
LDLIBS += @LIBS@

# Install destination
prefix = @prefix@
exec_prefix = @exec_prefix@
DESTDIR = $(prefix)

# Project-specific CFLAGS
CPPFLAGS += -D_GNU_SOURCE -Wall -Werror -I.

# VPATH support for out-of-tree build
ifneq (@srcdir@,.)
CPPFLAGS += -I@srcdir@
VPATH := @srcdir@
endif

APPOBJS := main.o
LIBOBJS := funcs.o

APP := app@EXEEXT@

all: $(APP)

# shared vs. static library
ifeq (@shared@,1)
# Shared library support from cc-shared
LIB = libtest.so
# All objects destined for the shared library need these flags
CPPFLAGS += @SH_CFLAGS@

$(LIB): $(LIBOBJS)
    $(CC) $(CFLAGS) $(LDFLAGS) @SH_LDFLAGS@ -o $@ $^ $(LDLIBS)

else
LIB = libtest.a

$(LIB): $(LIBOBJS)
    $(AR) cr $@ $^
    $(RANLIB) $@
endif

$(APP): $(APPOBJS) $(LIB)
    $(CC) $(CFLAGS) $(LDFLAGS) @SH_LINKFLAGS@ -o $@ $(APPOBJS) $(LIB) $(LDLIBS)

install: all
    @echo Installing from @srcdir@ and `pwd` to $(DESTDIR)

clean:
    rm -f *.o *.so lib*.a $(APP) conftest.*

distclean: clean
    rm -f config.h Makefile config.log

# automake compatibility. do nothing for all these targets
EMPTY_AUTOMAKE_TARGETS := dvi pdf ps info html tags ctags mostlyclean maintainer-clean check installcheck installdirs \
 install-pdf install-ps install-info install-html -install-dvi uninstall install-exec install-data distdir
.PHONY: $(EMPTY_AUTOMAKE_TARGETS)
$(EMPTY_AUTOMAKE_TARGETS):

# Reconfigure if needed
ifeq ($(findstring clean,$(MAKECMDGOALS)),)
Makefile: @AUTODEPS@ @srcdir@/Makefile.in
    @@AUTOREMAKE@
endif

# Or on demand
reconfig:
    @AUTOREMAKE@
==

Automatic Reconfiguration
-------------------------

It is convenient for `configure` to be re-run automatically with if any
of the input files change (e.g. `auto.def` or any of the
template files). This can be achieved by adding the following to
Makefile.in.

=makefile=
ifeq ($(findstring clean,$(MAKECMDGOALS)),)
Makefile: @AUTODEPS@ @srcdir@/Makefile.in
        @@AUTOREMAKE@
endif
==

It may also be convenient to add a target to force reconfiguring with the same options.

=makefile=
reconfig:
        @AUTOREMAKE@
==

Extending autosetup
-----------------------

Local modules can be added directly to the autosetup directory and loaded with the `use` command.

A module is simply a Tcl script (with a `.tcl` extension) in the `autosetup/` directory
which follows some conventions.

1. The module should include a synopsis for documentation purposes.
2. `module-options` should be the first statement
3. Public commands should be documented with '# @cmdname ...'
4. The module can also include private commands and globals

The following is a bare-bones example module.

=autosetup=
# @synopsis:
#
# Documentation for this module. Environment variables should be documented here.

module-options {
    modopt => "A boolean option"
}

# @check-erlang-feature name expression
#
# Runs the erlang code 'expression' and defines the
# given feature if the code succeeds (returns 0).
#
# See 'feature-define-name' for how the feature name
# is translated into the define name.
#
proc check-erlang-feature {name expression} {
    define [feature-define-name $name] [erlang-run $expression]
}

msg-result "Erlang module loaded"
==

Future Features/Changes
-----------------------

Some features are not yet implemented, but are candidates for
including in an existing module, or adding to a new module. Others
may require changes to the core **autosetup**.

* pkg-config support (although pkg-config has poor support for cross compiling)
* More fully-featured shared library support (`cc-shared` module), possibly with support for `libtool`
* Support for additional languages
* Subdirectory support. Need to resolve how options are parsed, and how variables interact between subdirectories.

