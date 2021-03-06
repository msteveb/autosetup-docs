---
title: Examples
---

Examples of auto.def files
==========================

Simple Example
--------------

This is a typical example of an `auto.def` file.

=autosetup=
use cc cc-shared

options {
    shared -> "Build a shared library rather than a static library"
    utf8=1 -> "Disable UTF-8 support"
}

define PACKAGE_NAME "testpackage"
define PACKAGE_VERSION 1.0

if {[cc-check-types "long long"]} {
    cc-check-sizeof "long long"
}
cc-check-sizeof "void *"

cc-check-includes sys/un.h

cc-check-functions regcomp waitpid sigaction sys_signame sys_siglist
cc-check-functions syslog opendir readlink sleep usleep pipe inet_ntop getaddrinfo

# Find some tools
cc-check-tools ar ranlib strip

set extra_objs {}

if {[opt-bool utf8]} {
    msg-result "Enabling UTF-8"
    define ENABLE_UTF8
}
if {[opt-bool shared]} {
    msg-result "Building shared library"
    define shared 1
} else {
    msg-result "Building static library"
    define shared ""
}

make-autoconf-h config.h {HAVE_* SIZEOF_* ENABLE_* PACKAGE_*}
make-template Makefile.in
==

redis
-----

The following example is from [redis](http://redis.io/)

=autosetup=
use cc

# Add any user options here
options {
    tcmalloc => "Use the tcmalloc allocator"
}

# Headers we may need
cc-check-includes AvailabilityMacros.h

# Libraries we may need
if {![cc-check-function-in-lib pthread_create pthread]} {
    user-error "Sorry, pthreads are needed for redis-server"
}
cc-check-function-in-lib sin m
cc-check-function-in-lib gethostbyaddr nsl
cc-check-function-in-lib socket socket
cc-check-function-in-lib dlopen dl

define EXTRA_CFLAGS ""

switch -glob -- [lindex [split [get-define host] -] end] {
    darwin* { define host_os darwin }
    sunos* { define host_os sunos }
    qnx* {
        define host_os qnx
        define-append EXTRA_CFLAGS -D_QNX_SOURCE -Du_int32_t=int
    }
    default { define host_os other }
}

cc-check-tools ar ranlib

define HAVE_TCMALLOC 0
if {[opt-bool tcmalloc]} {
    if {[cc-check-function-in-lib tc_malloc tcmalloc]} {
        define-append EXTRA_CFLAGS -DUSE_TCMALLOC
        cc-check-function-in-lib tc_malloc_size tcmalloc
    } else {
        user-error "I can't find tcmalloc"
    }
} else {
    cc-check-includes malloc/malloc.h
    cc-check-functions malloc_size
}

# We always set _FILE_OFFSET_BITS=64
# If that doesn't make off_t 64 bits, it is an error

cc-check-includes sys/types.h
msg-checking "Checking for LFS..."
if {[msg-quiet cc-with {-includes sys/types.h -cflags -D_FILE_OFFSET_BITS=64} \
	{cc-check-sizeof off_t}] == 8} {

    define _FILE_OFFSET_BITS 64
    msg-result yes
} else {
    user-error "LFS not available"
}

# Functions we may need
cc-check-functions fdatasync kqueue epoll backtrace task_info

make-autoconf-h src/autoconf.h {HAVE_* USE*}
make-template Makefile.in
make-template src/Makefile.in
make-template deps/linenoise/Makefile.in
make-template deps/hiredis/Makefile.in
==

Jim Tcl
-------

This is the `auto.def` file from the [Jim Tcl Project](http://jim.tcl.tk/).
In this example, the option handling is quite complex. Nonetheless, it is far
simpler to implement in Tcl rather than shell script.

Also note that two header files are generated, one for internal use and one
for external use.

=autosetup=
# Note: modules which support options *must* be included before 'options'
use cc cc-shared

options {
    utf8            => "include support for utf8-encoded strings"
    lineedit=1      => "disable line editing"
    references=1    => "disable support for references"
    math            => "include support for math functions"
    ipv6            => "include ipv6 support in the aio extension"
    maintainer      => {enable the [debug] command and JimPanic}
    with-jim-shared shared => "build a shared library instead of a static library"
    jim-regexp      => "use the built-in regexp, even if POSIX regex is available"
    with-jim-ext: {with-ext:"ext1 ext2 ..."} => {
        Specify additional jim extensions to include.
        These are enabled by default:

        aio       - ANSI I/O, including open and socket
        eventloop - after, vwait, update
        array     - Tcl-compatible array command
        clock     - Tcl-compatible clock command
        exec      - Tcl-compatible exec command
        file      - Tcl-compatible file command
        glob      - Tcl-compatible glob command
        readdir   - Required for glob
        package   - Package management with the package command
        load      - Load binary extensions at runtime with load or package
        posix     - Posix APIs including os.fork, os.wait, pid
        regexp    - Tcl-compatible regexp, regsub commands
        signal    - Signal handling
        stdlib    - Built-in commands including lassign, lambda, alias
        syslog    - System logging with syslog
        tclcompat - Tcl compatible read, gets, puts, parray, case, ...

        These are disabled by default:

        nvp       - Name-value pairs C-only API
        oo        - Jim OO extension
        tree      - OO tree structure, similar to tcllib ::struct::tree
        binary    - Tcl-compatible 'binary' command
        readline  - Interface to libreadline
        rlprompt  - Tcl wrapper around the readline extension
        sqlite    - Interface to sqlite
        sqlite3   - Interface to sqlite3
        win32     - Interface to win32
    }
    with-out-jim-ext: {without-ext:"default|ext1 ext2 ..."} => {
        Specify jim extensions to exclude.
        If 'default' is given, the default extensions will not be added.
    }
    with-jim-extmod: {with-mod:"ext1 ext2 ..."} => {
        Specify jim extensions to build as separate modules (either C or Tcl).
        Note that not all extensions can be built as loadable modules.
    }
}

cc-check-types "long long"

cc-check-includes sys/un.h dlfcn.h unistd.h crt_externs.h

cc-check-functions ualarm sysinfo lstat fork vfork
cc-check-functions backtrace geteuid mkstemp realpath strptime
cc-check-functions regcomp waitpid sigaction sys_signame sys_siglist
cc-check-functions syslog opendir readlink sleep usleep pipe inet_ntop getaddrinfo

switch -glob -- [get-define host] {
    *-*-ming* {
        # We provide our own implementation of dlopen for mingw32
        define-feature dlopen-compat
    }
}

# Find some tools
cc-check-tools ar ranlib strip
define tclsh [info nameofexecutable]

if {![cc-check-functions _NSGetEnviron]} {
    msg-checking "Checking environ declared in unistd.h..."
    if {[cctest -cflags -D_GNU_SOURCE -includes unistd.h -code {char **ep = environ;}]} {
        define NO_ENVIRON_EXTERN
        msg-result "yes"
    } else {
        msg-result "no"
    }
}

set extra_objs {}
set jimregexp 0

if {[opt-bool utf8]} {
    msg-result "Enabling UTF-8"
    define JIM_UTF8
    incr jimregexp
}
if {[opt-bool maintainer]} {
    msg-result "Enabling maintainer settings"
    define JIM_MAINTAINER
}
if {[opt-bool math]} {
    msg-result "Enabling math functions"
    define JIM_MATH_FUNCTIONS
    define-append LIBS -lm
}
if {[opt-bool ipv6]} {
    msg-result "Enabling IPv6"
    define JIM_IPV6
}
if {[opt-bool lineedit] && [cc-check-includes termios.h]} {
    msg-result "Enabling line editing"
    define USE_LINENOISE
    lappend extra_objs linenoise.o
}
if {[opt-bool references]} {
    msg-result "Enabling references"
    define JIM_REFERENCES
}
if {[opt-bool shared with-jim-shared]} {
    msg-result "Building shared library"
    define JIM_LIBTYPE shared
} else {
    msg-result "Building static library"
    define JIM_LIBTYPE static
}

# Note: Extension handling is mapped directly from the configure.ac
# implementation

set without [join [opt-val {without-ext with-out-jim-ext}]]
set withext [join [opt-val {with-ext with-jim-ext}]]
set withmod [join [opt-val {with-mod with-jim-extmod}]]

# Tcl extensions
set ext_tcl "stdlib glob tclcompat tree rlprompt oo binary"
# C extensions
set ext_c {load package readdir array clock exec file posix regexp
    signal aio eventloop pack syslog nvp readline sqlite sqlite3 win32
}

# Tcl extensions which can be modules
set ext_tcl_mod "glob tree rlprompt oo binary"
# C extensions which can be modules
set ext_c_mod {readdir array clock file posix regexp syslog readline pack
    sqlite sqlite3 win32
}

# All extensions
set ext_all [concat $ext_c $ext_tcl]

# Default static extensions
set ext_default {stdlib load package readdir glob array clock exec file posix
    regexp signal tclcompat aio eventloop syslog
}

if {$without eq "default"} {
    set ext_default stdlib
    set without {}
}

# Check valid extension names
foreach i [concat $withext $without $withmod] {
    if {$i ni $ext_all} {
        user-error "Unknown extension: $i"
    }
}

# needs(xxx) {expression} means that the expr must eval to 1 to select the extension
# dep(xxx) {yyy zzz} means that if xxx is selected, so is yyy and zzz
set dep(glob) readdir
set dep(rlprompt) readline
set dep(tree) oo
set dep(binary) pack

set needs(aio) {expr {[cc-check-function-in-lib socket socket] || 1}}
set needs(exec) {have-feature vfork}
set needs(load) {expr {[have-feature dlopen-compat] || [cc-check-function-in-lib dlopen dl]}}
set needs(posix) {have-feature waitpid}
set needs(readdir) {have-feature opendir}
set needs(readline) {cc-check-function-in-lib readline readline}
set needs(signal) {expr {[have-feature sigaction] && [have-feature vfork]}}
set needs(sqlite) {cc-check-function-in-lib sqlite_open sqlite}
set needs(sqlite3) {cc-check-function-in-lib sqlite3_open sqlite3}
set needs(syslog) {have-feature syslog}
set needs(win32) {have-feature windows}

# First handle dependencies. If an extension is enabled, also enable its dependency
foreach i [concat $ext_default $withext] {
    if {$i in $without} {
        continue
    }
    if {[info exists dep($i)]} {
        lappend withext {*}$dep($i)
    }
}

foreach i $withmod {
    if {[info exists dep($i)]} {
        # Theoretically, a mod could depend upon something which must be static
        # If already configured static, don't make it a module
        foreach d $dep($i) {
            if {$d ni $withext} {
                lappend withmod $d
            }
        }
    }
}

# Now that we know what the platform supports:

# For all known extensions:
# - If it is disabled, remove it
# - Otherwise, check to see if it's pre-requisites are met
# -   If yes, add it if it is enabled or is a default
# -   If no, error if it is enabled, or do nothing otherwise
# - Modules may be either C or Tcl

set extmodtcl {}
set extmod {}
set ext {}

foreach i [lsort $ext_all] {
    # First discard the extension if disabled or not enabled
    if {$i in $without} {
        msg-result "Extension $i...disabled"
        continue
    }
    if {$i ni [concat $withext $withmod $ext_default]} {
        msg-result "Extension $i...not enabled"
        continue
    }

    # Check dependencies
    set met 1
    if {[info exists needs($i)]} {
        set met [eval $needs($i)]
    }

    msg-checking "Extension $i..."

    # Selected as a module?
    if {$i in $withmod} {
        if {$i in $ext_tcl_mod} {
            # Easy, a Tcl module
            msg-result "tcl"
            lappend extmodtcl $i
            continue
        }
        if {$i ni $ext_c_mod} {
            user-error "not a module"
        }
        if {!$met} {
            user-error "dependencies not met"
        }
        msg-result "module"
        lappend extmod $i
        continue
    }

    # Selected as a static extension?
    if {$i in $withext} {
        if {!$met} {
            user-error "dependencies not met"
        }
        msg-result "enabled"
        lappend ext $i
        continue
    }

    # Enabled by default?
    if {$i in $ext_default} {
        if {!$met} {
            msg-result "disabled (dependencies)"
            continue
        }
        msg-result "enabled (default)"
        lappend ext $i
        continue
    }
}

if {[have-feature windows]} {
    if {"aio" in "$ext $extmod"} {
        define-append LIBS -lwsock32
    }
    lappend extra_objs jim-win32compat.o

    if {$extmod ne "" && [get-define JIM_LIBTYPE] eq "static"} {
        user-error "cygwin/mingw require --shared for dynamic modules"
    }
}

if {"regexp" in "$ext $extmod"} {
    # No regcomp means we need to use the built-in version
    if {![have-feature regcomp]} {
        incr jimregexp
    }
}

if {$jimregexp || [opt-bool jim-regexp]} {
    msg-result "Using built-in regexp"
    define JIM_REGEXP

    # If the built-in regexp overrides the system regcomp, etc.
    # jim must be built shared so that the correct symbols are found
    if {[have-feature regcomp]} {
        if {"regexp" in $extmod && [get-define JIM_LIBTYPE] eq "static"} {
            user-error "Must use --shared with regexp module and built-in regexp"
        }
    }
}
if {"load" ni $ext} {
    # If we don't have load, no need to support shared objects
    define SH_LINKFLAGS ""
}

msg-result "Jim static extensions: [lsort $ext]"
if {$extmodtcl ne ""} {
    msg-result "Jim Tcl extensions: [lsort $extmodtcl]"
}
if {$extmod ne ""} {
    msg-result "Jim dynamic extensions: [lsort $extmod]"
}

define JIM_EXTENSIONS $ext
define JIM_TCL_EXTENSIONS $extmodtcl
define JIM_MOD_EXTENSIONS $extmod
foreach i $ext {
    define jim_ext_$i
}

define EXTRA_OBJS $extra_objs

define TCL_LIBRARY [get-define prefix]/lib/jim
define TCL_PLATFORM_OS [exec uname -s]
define TCL_PLATFORM_PLATFORM unix

make-autoconf-h jim-config.h {HAVE_LONG_LONG* JIM_UTF8}
make-autoconf-h jimautoconf.h {HAVE_* jim_ext_* TCL_PLATFORM_* TCL_LIBRARY USE_* JIM_*}
make-template Makefile.in
==
