---
title: autosetup 0.7.0
date: 2020-09-23
---

**autosetup** v0.7.0 has been released.

Changes since v0.6.9

Major improvements:

* options: improved option handling, consistency and documentation

Minor changes and bug fixes:

* Avoid adding duplicates to $CONFIGURE_OPTS and $AUTO_REMAKE
* pkg-config: Improve cross compiling support, identify dependency issues, pkg-config-get-var
* cc: $CXX is set to the empty string if not found rather than false
* Add support for Tcl 8.7
