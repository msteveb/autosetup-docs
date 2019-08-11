---
title: autosetup Modules
---

Creating autosetup modules
==========================

Introduction
------------

**Note:** This page is still be completed.

In the meantime, here is the information from the developer reference manual:

----

Note that module X is implemented in either autosetup/X.tcl or
autosetup/X/init.tcl

The latter form is useful for a complex module which requires additional
support file. In this form, $::usedir is set to the module directory when it
is loaded.

-----
