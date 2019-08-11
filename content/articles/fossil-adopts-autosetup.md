---
title: Fossil adopts autosetup
date: 2011-07-14
---

Recently the [Fossil SCM](http://fossil-scm.org/) has been adopted
by [Tcl/Tk](http://wiki.tcl.tk/) as a replacement for CVS.  Now the
Tcl-based [autosetup](http://msteveb.github.com/autosetup/) has
been adopted as the development configuration system for
[Fossil](http://www.fossil-scm.org/).

Fossil is similar to many open source projects that are required
to support a number of different platforms. The obvious approach
is to use autoconf and possibly automake, but [many people](http://identi.ca/group/fossil#notice-76160895)
find that approach [frustrating](http://www.mail-archive.com/fossil-users@lists.fossil-scm.org/msg04899.html).

Some of the immediate benefits of autosetup are support for cross compilation
and easily allowing Fossil to be build with different options.
