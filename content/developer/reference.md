---
title: Command Reference
---

autosetup v0.7.1 -- Command Reference
=====================================

Introduction
------------

See [http://msteveb.github.com/autosetup/](http://msteveb.github.com/autosetup/) for the online documentation for **`autosetup`**. This documentation can also be accessed locally with `autosetup --ref`.

**`autosetup`** provides a number of built-in commands which are documented below. These may be used from **`auto.def`** to test for features, define variables, create files from templates and other similar actions.

Core Commands
-------------

Option Handling
---------------

### `opt-bool ?-nodefault? option ...`

Check each of the named, boolean options and if any have been explicitly enabled or disabled by the user, return 1 or 0 accordingly.

If the option was specified more than once, the last value wins. e.g. With **`--enable-foo --disable-foo`**, **`[opt-bool foo]`** will return 0

If no value was specified by the user, returns the default value for the first option. If **`-nodefault`** is given, this behaviour changes and -1 is returned instead.

### `opt-val optionlist ?default=""?`

Returns a list containing all the values given for the non-boolean options in **`$optionlist`**. There will be one entry in the list for each option given by the user, including if the same option was used multiple times.

If no options were set, **`$default`** is returned (exactly, not as a list).

Note: For most use cases, **`opt-str`** should be preferred.

### `opt-str optionlist varname ?default?`

Sets **`$varname`** in the callers scope to the value for one of the given options.

For the list of options given in **`$optionlist`**, if any value is set for any option, the option value is taken to be the *last* value of the last option (in the order given).

If no option was given, and a default was specified with **`options-defaults`**, that value is used.

If no **`options-defaults`** value was given and **`$default`** was given, it is used.

If none of the above provided a value, no value is set.

The return value depends on whether **`$default`** was specified. If it was, the option value is returned. If it was not, 1 is returns if a value was set, or 0 if not.

Typical usage is as follows:

~~~~~~~~~~~~
if {[opt-str {myopt altname} o]} {
    do something with $o
}
~~~~~~~~~~~~

Or:

~~~~~~~~~~~~
define myname [opt-str {myopt altname} o "/usr/local"]
~~~~~~~~~~~~

### `module-options optionlist`

Deprecated. Simply use **`options`** from within a module.

### `options optionspec`

Specifies configuration-time options which may be selected by the user and checked with **`opt-str`** and **`opt-bool`**. **`$optionspec`** contains a series of options specifications separated by newlines, as follows:

A boolean option is of the form:

~~~~~~~~~~~~
name[=0|1]  => "Description of this boolean option"
~~~~~~~~~~~~

The default is **`name=0`**, meaning that the option is disabled by default. If **`name=1`** is used to make the option enabled by default, the description should reflect that with text like "Disable support for ...".

An argument option (one which takes a parameter) is of one of the following forms:

~~~~~~~~~~~~
name:value         => "Description of this option"
name:value=default => "Description of this option with a default value"
name:=value        => "Description of this option with an optional value"
~~~~~~~~~~~~

If the **`name:value`** form is used, the value must be provided with the option (as **`--name=myvalue`**). If the **`name:value=default`** form is used, the option has the given default value even if not specified by the user. If the **`name:=value`** form is used, the value is optional and the given value is used if it is not provided.

The description may contain **`@default@`**, in which case it will be replaced with the default value for the option (taking into account defaults specified with **`options-defaults`**.

Undocumented options are also supported by omitting the **`=> description`**. These options are not displayed with **`--help`** and can be useful for internal options or as aliases.

For example, **`--disable-lfs`** is an alias for **`--disable=largefile`**:

~~~~~~~~~~~~
lfs=1 largefile=1 => "Disable large file support"
~~~~~~~~~~~~

### `options-defaults dictionary`

Specifies a dictionary of options and a new default value for each of those options. Use before any **`use`** statements in **`auto.def`** to change the defaults for subsequently included modules.

Variable Definitions (defines)
------------------------------

### `define name ?value=1?`

Defines the named variable to the given value. These (name, value) pairs represent the results of the configuration check and are available to be subsequently checked, modified and substituted.

### `define-push {name ...} script`

Save the values of the given defines, evaluation the script, then restore. For example, to avoid updating AS_FLAGS and AS_CXXFLAGS:

~~~~~~~~~~~~
define-push {AS_CFLAGS AS_CXXFLAGS} {
  cc-check-flags -Wno-error
}
~~~~~~~~~~~~

### `undefine name`

Undefine the named variable.

### `define-append name value ...`

Appends the given value(s) to the given "defined" variable. If the variable is not defined or empty, it is set to **`$value`**. Otherwise the value is appended, separated by a space. Any extra values are similarly appended. If any value is already contained in the variable (as a substring) it is omitted.

### `get-define name ?default=0?`

Returns the current value of the "defined" variable, or **`$default`** if not set.

### `is-defined name`

Returns 1 if the given variable is defined.

### `is-define-set name`

Returns 1 if the given variable is defined and is set to a value other than "" or 0

### `all-defines`

Returns a dictionary (name, value list) of all defined variables.

This is suitable for use with **`dict`**, **`array set`** or **`foreach`** and allows for arbitrary processing of the defined variables.

Environment/Helpers
-------------------

### `get-env name default`

If **`$name`** was specified on the command line, return it. Otherwise if **`$name`** was set in the environment, return it. Otherwise return **`$default`**.

### `env-is-set name`

Returns 1 if **`$name`** was specified on the command line or in the environment. Note that an empty environment variable is not considered to be set.

### `readfile filename ?default=""?`

Return the contents of the file, without the trailing newline. If the file doesn't exist or can't be read, returns **`$default`**.

### `writefile filename value`

Creates the given file containing **`$value`**. Does not add an extra newline.

### `list-non-empty list`

Returns a copy of the given list with empty elements removed

Paths, Searching
----------------

### `find-executable-path name`

Searches the path for an executable with the given name. Note that the name may include some parameters, e.g. **`cc -mbig-endian`**, in which case the parameters are ignored. The full path to the executable if found, or "" if not found. Returns 1 if found, or 0 if not.

### `find-executable name`

Searches the path for an executable with the given name. Note that the name may include some parameters, e.g. **`cc -mbig-endian`**, in which case the parameters are ignored. Returns 1 if found, or 0 if not.

### `find-an-executable ?-required? name ...`

Given a list of possible executable names, searches for one of these on the path.

Returns the name found, or "" if none found. If the first parameter is **`-required`**, an error is generated if no executable is found.

Logging, Messages and Errors
----------------------------

### `configlog msg`

Writes the given message to the configuration log, **`config.log`**.

### `msg-checking msg`

Writes the message with no newline to stdout.

### `msg-result msg`

Writes the message to stdout.

### `msg-quiet command ...`

**`msg-quiet`** evaluates it's arguments as a command with output from **`msg-checking`** and **`msg-result`** suppressed.

This is useful if a check needs to run a subcheck which isn't of interest to the user.

### `user-error msg`

Indicate incorrect usage to the user, including if required components or features are not found. **`autosetup`** exits with a non-zero return code.

### `user-notice msg`

Output the given message to stderr.

### `autosetup-require-version required`

Checks the current version of **`autosetup`** against **`$required`**. A fatal error is generated if the current version is less than that required.

Modules Support
---------------

### `use module ...`

Load the given library modules. e.g. **`use cc cc-shared`**

Note that module **`X`** is implemented in either **`autosetup/X.tcl`** or **`autosetup/X/init.tcl`**

The latter form is useful for a complex module which requires additional support file. In this form, **`$::usedir`** is set to the module directory when it is loaded.

Utilities
---------

### `compare-versions version1 version2`

Versions are of the form **`a.b.c`** (may be any number of numeric components)

Compares the two versions and returns:

~~~~~~~~~~~~
-1 if v1 < v2
 0 if v1 == v2
 1 if v1 > v2
~~~~~~~~~~~~

If one version has fewer components than the other, 0 is substituted to the right. e.g.

~~~~~~~~~~~~
0.2   <  0.3
0.2.5 >  0.2
1.1   == 1.1.0
~~~~~~~~~~~~

### `suffix suf list`

Takes a list and returns a new list with **`$suf`** appended to each element

~~~~~~~~~~~~
suffix .c {a b c} => {a.c b.c c.c}
~~~~~~~~~~~~

### `prefix pre list`

Takes a list and returns a new list with **`$pre`** prepended to each element

~~~~~~~~~~~~
prefix jim- {a.c b.c} => {jim-a.c jim-b.c}
~~~~~~~~~~~~

### `lpop list`

Removes the last entry from the given list and returns it.

Module: cc
----------

The **`cc`** module supports checking various **`features`** of the C or C++ compiler/linker environment. Common commands are **`cc-check-includes`**, **`cc-check-types`**, **`cc-check-functions`**, **`cc-with`**, **`make-config-header`** and **`make-template`**.

The following environment variables are used if set:

~~~~~~~~~~~~
CC       - C compiler
CXX      - C++ compiler
CPP      - C preprocessor
CCACHE   - Set to "none" to disable automatic use of ccache
CPPFLAGS  - Additional C preprocessor compiler flags (C and C++), before CFLAGS, CXXFLAGS
CFLAGS   - Additional C compiler flags
CXXFLAGS - Additional C++ compiler flags
LDFLAGS  - Additional compiler flags during linking
LINKFLAGS - ?How is this different from LDFLAGS?
LIBS     - Additional libraries to use (for all tests)
CROSS    - Tool prefix for cross compilation
~~~~~~~~~~~~

The following variables are defined from the corresponding environment variables if set.

~~~~~~~~~~~~
CC_FOR_BUILD
LD
~~~~~~~~~~~~

### `cc-check-sizeof type ...`

Checks the size of the given types (between 1 and 32, inclusive). Defines a variable with the size determined, or **`unknown`** otherwise. e.g. for type **`long long`**, defines **`SIZEOF_LONG_LONG`**. Returns the size of the last type.

### `cc-check-includes includes ...`

Checks that the given include files can be used.

### `cc-include-needs include required ...`

Ensures that when checking for **`$include`**, a check is first made for each **`$required`** file, and if found, it is included with **`#include`**.

### `cc-check-types type ...`

Checks that the types exist.

### `cc-check-defines define ...`

Checks that the given preprocessor symbols are defined.

### `cc-check-decls name ...`

Checks that each given name is either a preprocessor symbol or rvalue such as an enum. Note that the define used is **`HAVE_DECL_xxx`** rather than **`HAVE_xxx`**.

### `cc-check-functions function ...`

Checks that the given functions exist (can be linked).

### `cc-check-members type.member ...`

Checks that the given type/structure members exist. A structure member is of the form **`struct stat.st_mtime`**.

### `cc-check-function-in-lib function libs ?otherlibs?`

Checks that the given function can be found in one of the libs.

First checks for no library required, then checks each of the libraries in turn.

If the function is found, the feature is defined and **`lib_$function`** is defined to **`-l$lib`** where the function was found, or "" if no library required. In addition, **`-l$lib`** is prepended to the **`LIBS`** define.

If additional libraries may be needed for linking, they should be specified with **`$extralibs`** as **`-lotherlib1 -lotherlib2`**. These libraries are not automatically added to **`LIBS`**.

Returns 1 if found or 0 if not.

### `cc-check-tools tool ...`

Checks for existence of the given compiler tools, taking into account any cross compilation prefix.

For example, when checking for **`ar`**, first **`AR`** is checked on the command line and then in the environment. If not found, **`${host}-ar`** or simply **`ar`** is assumed depending upon whether cross compiling. The path is searched for this executable, and if found **`AR`** is defined to the executable name. Note that even when cross compiling, the simple **`ar`** is used as a fallback, but a warning is generated. This is necessary for some toolchains.

It is an error if the executable is not found.

### `cc-check-progs prog ...`

Checks for existence of the given executables on the path.

For example, when checking for **`grep`**, the path is searched for the executable, **`grep`**, and if found **`GREP`** is defined as **`grep`**.

If the executable is not found, the variable is defined as **`false`**. Returns 1 if all programs were found, or 0 otherwise.

### `cc-path-progs prog ...`

Like cc-check-progs, but sets the define to the full path rather than just the program name.

### `cc-with settings ?{ script }?`

Sets the given **`cctest`** settings and then runs the tests in **`$script`**. Note that settings such as **`-lang`** replace the current setting, while those such as **`-includes`** are appended to the existing setting.

If no script is given, the settings become the default for the remainder of the **`auto.def`** file.

~~~~~~~~~~~~
cc-with {-lang c++} {
  # This will check with the C++ compiler
  cc-check-types bool
  cc-with {-includes signal.h} {
    # This will check with the C++ compiler, signal.h and any existing includes.
    ...
  }
  # back to just the C++ compiler
}
~~~~~~~~~~~~

The **`-libs`** setting is special in that newer values are added *before* earlier ones.

~~~~~~~~~~~~
cc-with {-libs {-lc -lm}} {
  cc-with {-libs -ldl} {
    cctest -libs -lsocket ...
    # libs will be in this order: -lsocket -ldl -lc -lm
  }
}
~~~~~~~~~~~~

If you wish to invoke something like cc-check-flags but not have -cflags updated, use the following idiom:

~~~~~~~~~~~~
cc-with {} {
  cc-check-flags ...
}
~~~~~~~~~~~~

### `cctest ?settings?`

Low level C/C++ compiler checker. Compiles and or links a small C program according to the arguments and returns 1 if OK, or 0 if not.

Supported settings are:

~~~~~~~~~~~~
-cflags cflags      A list of flags to pass to the compiler
-includes list      A list of includes, e.g. {stdlib.h stdio.h}
-declare code       Code to declare before main()
-link 1             Don't just compile, link too
-lang c|c++         Use the C (default) or C++ compiler
-libs liblist       List of libraries to link, e.g. {-ldl -lm}
-code code          Code to compile in the body of main()
-source code        Compile a complete program. Ignore -includes, -declare and -code
-sourcefile file    Shorthand for -source [readfile [get-define srcdir]/$file]
-nooutput 1         Treat any compiler output (e.g. a warning) as an error
~~~~~~~~~~~~

Unless **`-source`** or **`-sourcefile`** is specified, the C program looks like:

~~~~~~~~~~~~
#include <firstinclude>   /* same for remaining includes in the list */
declare-code              /* any code in -declare, verbatim */
int main(void) {
  code                    /* any code in -code, verbatim */
  return 0;
}
~~~~~~~~~~~~

And the command line looks like:

~~~~~~~~~~~~
CC -cflags CFLAGS CPPFLAGS conftest.c -o conftest.o
CXX -cflags CXXFLAGS CPPFLAGS conftest.cpp -o conftest.o
~~~~~~~~~~~~

And if linking:

~~~~~~~~~~~~
CC LDFLAGS -cflags CFLAGS conftest.c -o conftest -libs LIBS
CXX LDFLAGS -cflags CXXFLAGS conftest.c -o conftest -libs LIBS
~~~~~~~~~~~~

Any failures are recorded in **`config.log`**

### `make-autoconf-h outfile ?auto-patterns=HAVE_*? ?bare-patterns=SIZEOF_*?`

Deprecated - see **`make-config-header`**

### `make-config-header outfile ?-auto patternlist? ?-bare patternlist? ?-none patternlist? ?-str patternlist? ...`

Examines all defined variables which match the given patterns and writes an include file, **`$file`**, which defines each of these. Variables which match **`-auto`** are output as follows:

* defines which have the value **`0`** are ignored.
* defines which have integer values are defined as the integer value.
* any other value is defined as a string, e.g. **`"value"`**

Variables which match **`-bare`** are defined as-is. Variables which match **`-str`** are defined as a string, e.g. **`"value"`** Variables which match **`-none`** are omitted.

Note that order is important. The first pattern that matches is selected. Default behaviour is:

~~~~~~~~~~~~
 -bare {SIZEOF_* HAVE_DECL_*} -auto HAVE_* -none *
~~~~~~~~~~~~

If the file would be unchanged, it is not written.

Module: cc-db
-------------

The **`cc-db`** module provides a knowledge-base of system idiosyncrasies. In general, this module can always be included.

Module: cc-lib
--------------

Provides a library of common tests on top of the **`cc`** module.

### `cc-check-lfs`

The equivalent of the **`AC_SYS_LARGEFILE`** macro.

defines **`HAVE_LFS`** if LFS is available, and defines **`_FILE_OFFSET_BITS=64`** if necessary

Returns 1 if **`LFS`** is available or 0 otherwise

### `cc-check-endian`

The equivalent of the **`AC_C_BIGENDIAN`** macro.

defines **`HAVE_BIG_ENDIAN`** if endian is known to be big, or **`HAVE_LITTLE_ENDIAN`** if endian is known to be little.

Returns 1 if determined, or 0 if not.

### `cc-check-flags flag ?...?`

Checks whether the given C/C++ compiler flags can be used. Defines feature names prefixed with **`HAVE_CFLAG`** and **`HAVE_CXXFLAG`** respectively, and appends working flags to **`-cflags`** and **`AS_CFLAGS`** or **`AS_CXXFLAGS`**.

### `cc-check-standards ver ?...?`

Checks whether the C/C++ compiler accepts one of the specified **`-std=$ver`** options, and appends the first working one to **`-cflags`** and **`AS_CFLAGS`** or **`AS_CXXFLAGS`**.

### `cc-check-c11`

Checks for several C11/C++11 extensions and their alternatives. Currently checks for **`_Static_assert`**, **`_Alignof`**, **`__alignof__`**, **`__alignof`**.

### `cc-check-alloca`

The equivalent of the **`AC_FUNC_ALLOCA`** macro.

Checks for the existence of **`alloca`** defines **`HAVE_ALLOCA`** and returns 1 if it exists.

### `cc-signal-return-type`

The equivalent of the **`AC_TYPE_SIGNAL`** macro.

defines **`RETSIGTYPE`** to **`int`** or **`void`**.

Module: cc-shared
-----------------

The **`cc-shared`** module provides support for shared libraries and shared objects. It defines the following variables:

~~~~~~~~~~~~
SH_CFLAGS         Flags to use compiling sources destined for a shared library
SH_LDFLAGS        Flags to use linking (creating) a shared library
SH_SOPREFIX       Prefix to use to set the soname when creating a shared library
SH_SOFULLPATH     Set to 1 if the shared library soname should include the full install path
SH_SOEXT          Extension for shared libs
SH_SOEXTVER       Format for versioned shared libs - %s = version
SHOBJ_CFLAGS      Flags to use compiling sources destined for a shared object
SHOBJ_LDFLAGS     Flags to use linking a shared object, undefined symbols allowed
SHOBJ_LDFLAGS_R   - as above, but all symbols must be resolved
SH_LINKRPATH      Format for setting the rpath when linking an executable, %s = path
SH_LINKFLAGS      Flags to use linking an executable which will load shared objects
LD_LIBRARY_PATH   Environment variable which specifies path to shared libraries
STRIPLIBFLAGS     Arguments to strip a dynamic library
~~~~~~~~~~~~

Module: pkg-config
------------------

The **`pkg-config`** module allows package information to be found via **`pkg-config`**.

If not cross-compiling, the package path should be determined automatically by **`pkg-config`**. If cross-compiling, the default package path is the compiler sysroot. If the C compiler doesn't support **`-print-sysroot`**, the path can be supplied by the **`--sysroot`** option or by defining **`SYSROOT`**.

**`PKG_CONFIG`** may be set to use an alternative to **`pkg-config`**.

### `pkg-config-init ?required?`

Initialises the **`pkg-config`** system. Unless **`$required`** is set to 0, it is a fatal error if a usable **`pkg-config`** is not found .

This command will normally be called automatically as required, but it may be invoked explicitly if lack of **`pkg-config`** is acceptable.

Returns 1 if ok, or 0 if **`pkg-config`** not found/usable (only if **`$required`** is 0).

### `pkg-config module ?requirements?`

Use **`pkg-config`** to find the given module meeting the given requirements. e.g.

~~~~~~~~~~~~
pkg-config pango >= 1.37.0
~~~~~~~~~~~~

If found, returns 1 and sets **`HAVE_PKG_PANGO`** to 1 along with:

~~~~~~~~~~~~
PKG_PANGO_VERSION to the found version
PKG_PANGO_LIBS    to the required libs (--libs-only-l)
PKG_PANGO_LDFLAGS to the required linker flags (--libs-only-L)
PKG_PANGO_CFLAGS  to the required compiler flags (--cflags)
~~~~~~~~~~~~

If not found, returns 0.

### `pkg-config-get module setting`

Convenience access to the results of **`pkg-config`**.

For example, **`[pkg-config-get pango CFLAGS]`** returns the value of **`PKG_PANGO_CFLAGS`**, or **`""`** if not defined.

### `pkg-config-get-var module variable`

Return the value of the given variable from the given pkg-config module. The module must already have been successfully detected with pkg-config. e.g.

~~~~~~~~~~~~
if {[pkg-config harfbuzz >= 2.5]} {
  define harfbuzz_libdir [pkg-config-get-var harfbuzz libdir]
}
~~~~~~~~~~~~

Returns the empty string if the variable isn't defined.

Module: system
--------------

This module supports common system interrogation and options such as **`--host`**, **`--build`**, **`--prefix`**, and setting **`srcdir`**, **`builddir`**, and **`EXEEXT`**.

It also support the "feature" naming convention, where searching for a feature such as **`sys/type.h`** defines **`HAVE_SYS_TYPES_H`**.

It defines the following variables, based on **`--prefix`** unless overridden by the user:

~~~~~~~~~~~~
datadir
sysconfdir
sharedstatedir
localstatedir
infodir
mandir
includedir
~~~~~~~~~~~~

If **`--prefix`** is not supplied, it defaults to **`/usr/local`** unless **`options-defaults { prefix ... }`** is used *before* including the **`system`** module.

### `check-feature name { script }`

defines feature **`$name`** to the return value of **`$script`**, which should be 1 if found or 0 if not found.

e.g. the following will define **`HAVE_CONST`** to 0 or 1.

~~~~~~~~~~~~
check-feature const {
    cctest -code {const int _x = 0;}
}
~~~~~~~~~~~~

### `have-feature name ?default=0?`

Returns the value of feature **`$name`** if defined, or **`$default`** if not.

See **`feature-define-name`** for how the "feature" name is translated into the "define" name.

### `define-feature name ?value=1?`

Sets the feature **`define`** to **`$value`**.

See **`feature-define-name`** for how the "feature" name is translated into the "define" name.

### `feature-checked name`

Returns 1 if feature **`$name`** has been checked, whether true or not.

### `feature-define-name name ?prefix=HAVE_?`

Converts a "feature" name to the corresponding "define", e.g. **`sys/stat.h`** becomes **`HAVE_SYS_STAT_H`**.

Converts **`*`** to **`P`** and all non-alphanumeric to underscore.

### `write-if-changed filename contents ?script?`

If **`$filename`** doesn't exist, or it's contents are different to **`$contents`**, the file is written and **`$script`** is evaluated.

Otherwise a "file is unchanged" message is displayed.

### `include-file infile mapping`

The core of make-template, called recursively for each @include directive found within that template so that this proc's result is the fully-expanded template.

The mapping parameter is how we expand @varname@ within the template. We do that inline within this step only for @include directives which can have variables in the filename arg. A separate substitution pass happens when this recursive function returns, expanding the rest of the variables.

### `make-template template ?outfile?`

Reads the input file **`<srcdir>/$template`** and writes the output file **`$outfile`** (unless unchanged). If **`$outfile`** is blank/omitted, **`$template`** should end with **`.in`** which is removed to create the output file name.

Each pattern of the form **`@define@`** is replaced with the corresponding "define", if it exists, or left unchanged if not.

The special value **`@srcdir@`** is substituted with the relative path to the source directory from the directory where the output file is created, while the special value **`@top_srcdir@`** is substituted with the relative path to the top level source directory.

Conditional sections may be specified as follows:

~~~~~~~~~~~~
@if NAME eq "value"
lines
@else
lines
@endif
~~~~~~~~~~~~

Where **`NAME`** is a defined variable name and **`@else`** is optional. Note that variables names *must* start with an uppercase letter. If the expression does not match, all lines through **`@endif`** are ignored.

The alternative forms may also be used:

~~~~~~~~~~~~
@if NAME  (true if the variable is defined, but not empty and not "0")
@if !NAME  (opposite of the form above)
@if <general-tcl-expression>
~~~~~~~~~~~~

In the general Tcl expression, any words beginning with an uppercase letter are translated into [get-define NAME]

Expressions may be nested

Module: tmake
-------------

The **`tmake`** module makes it easy to support the tmake build system.

The following variables are set:

~~~~~~~~~~~~
CONFIGURED  - to indicate that the project is configured
~~~~~~~~~~~~

### `make-tmake-settings outfile patterns ...`

Examines all defined variables which match the given patterns (defaults to **`*`**) and writes a tmake-compatible .conf file defining those variables. For example, if **`ABC`** is **`"3 monkeys"`** and **`ABC`** matches a pattern, then the file will include:

~~~~~~~~~~~~
define ABC {3 monkeys}
~~~~~~~~~~~~

If the file would be unchanged, it is not written.

Typical usage is:

~~~~~~~~~~~~
make-tmake-settings [get-env BUILDDIR objdir]/settings.conf {[A-Z]*}
~~~~~~~~~~~~

