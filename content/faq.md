---
title: Frequently Asked Questions
---

Frequently Asked Questions
==========================

1. How fast is **autosetup**?
---------------------------

**autosetup** is very fast. A typical project involves invocation of
the C compiler a few dozen times which can be done in a few seconds.
Here is a comparison with `autoconf` on some different platforms.

~~~~~~~~~~~~
              autoconf     autosetup
              ---------    ---------
Linux            4.1s         1.3s
Mac OS X         6.4s         2.8s
cygwin          91.5s         9.9s
~~~~~~~~~~~~

Also note that there is **no** separate step needed to generate
a `configure` script or header templates.

2. Why is it faster?
--------------------

`autoconf` attempts to work with a minimal set of native tools
(**Bourne shell**, `awk`, `sed`, `tr`).  As such it invokes *many*
subprocesses to perform simple string manipulation in a
platform-independent manner.

By comparison, **autosetup** uses a full-featured scripting language and does
all string manipulation in a single process. This approach dramatically speeds
up configuration as the only time of significance is the invocation of the compiler.


3. What are the prerequisites for **autosetup**?
----------------------------------------------

**autosetup** requires **one** of:

* Tcl 8.5 (tclsh8.5)
* Tcl 8.6 (tclsh8.6)
* [jimsh](http://jim.tcl.tk/) (version >= 0.70)
* A C compiler (cc)

In addition, the `configure` wrapper script requires a Bourne-compatible
shell and the `dirname` command.

4. Do I need to install **autosetup**?
------------------------------------

No. The **autosetup** distribution is included directly as part of the
project. This approach means that the project is completely self-contained.
In addition, the version of **autosetup** which ships with the project
is the version which has been tested.
