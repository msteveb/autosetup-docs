---
title: System-wide Install
---

Using a system-wide **autosetup**
=========================================

Introduction
------------

As explained in [Developing with autosetup](/developer/), one deployment option for autosetup since version 0.6.7
is to use a system-wide install.

This guide explains how to install and use such a system-wide installation.

System Install
--------------

A system-wide install can only be done from a development tree, not a locally installed or previous system-wide installation,
so first you will need to [Download](/download/) autosetup.

=unix=
$ git clone git://github.com/msteveb/autosetup.git
...
$ cd autosetup
==

Now do a system-wide install to a location expected to be in the `PATH`.

=unix=
$ ./autosetup --sysinstall=/usr/local
Installed system autosetup v0.6.7 to /usr/local/bin/autosetup
==

Note that autosetup, along with some companion scripts, is installed to the `bin` directory
underneath the given target directory. This is the directory that should be in the `PATH`.

=unix=
$ /bin/ls -1 /usr/local/bin/autosetup*
/usr/local/bin/autosetup
/usr/local/bin/autosetup-config.guess
/usr/local/bin/autosetup-config.sub
/usr/local/bin/autosetup-find-tclsh
/usr/local/bin/autosetup-test-tclsh
==

Project Install
---------------

Once autosetup is installed, a project install may be performed.
For example, here is the installation to a new project.

=unix=
$ mkdir myproject
$ cd myproject
$ autosetup --install
autosetup v0.6.7 creating configure to use system-installed autosetup
I don't see configure, so I will create it.
Creating autosetup/README.autosetup
$ find . -type f
./autosetup/README.autosetup
./configure
==

As we can see, autosetup has created only two files.
The `configure` wrapper script simply redirects to `autosetup`, which must be in the `PATH`

The directory `autosetup/` contains the file `README.autosetup`. This directory can be used
to install local modules, just like a full project install of autosetup.

Project Initialisation
----------------------

Now the project can be configured in the usual way.

=unix=
$ ./configure --init=make
Initialising make: Simple "make" build system

I don't see auto.def, so I will create it.
Note: I don't see Makefile.in. You will probably need to create one.
==

See [Developing with autosetup](/developer/) for further details.

Considerations for a System-Wide Install
----------------------------------------

Using a system-wide install brings some specific considerations.

###  Preinstalled Jim or Tcl Required

Either jimsh (Jim Tcl) or tclsh (Tcl 8.5 or 8.6) must be available in the path.
This is a reasonable requirement in that Jim Tcl and Tcl are easily installable on
systems supported by autosetup.

###  Compatible autosetup Version

The biggest potential problem is if multiple projects on the same system require different
versions of autosetup. As autosetup continues to evolve, this is certainly possible, and
is a downside of this approach.

It is **strongly** recommended that the new `autosetup-require-version` command is used to
ensure that an older version of autosetup is not used.

=autosetup=
# This will given an error if the current autosetup version is < 0.6.7
autosetup-require-version 0.6.7

use cc

# Add any user options here
options {
}
...
==

autosetup is not installed by version (e.g. autosetup0.6.7) to avoid a proliferation of
multiple slightly different versions. However if necessary, autosetup can be renamed
and the configure wrapper updated accordingly.

=unix=
$ cat configure
#!/bin/sh
# Explicitly use the renamed autosetup0.6.7
WRAPPER="-"; "autosetup0.6.7" "$@"
==
