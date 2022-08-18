---
title: autosetup 0.7.1
date: 2022-08-18
---

**autosetup** v0.7.1 has been released.

Changes since v0.7.0

Major improvements:

* improve handling of CFLAGS, etc. See [CFLAGS Handling](/articles/handling-cflags/)

Minor changes and bug fixes:

* autosetup-find-tclsh will now build jimsh0 in the current directory
* pkg-config: invocation of -print-sysroot is now correct
* config.guess, config.sub: update to 2021-06-03
* cc-check-tools: fix when command includes args
* define-push: simplifies define management
