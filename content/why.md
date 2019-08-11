---
title: Why autosetup?
label: Motivation
---

Motivation
----------

autoconf does the job and supports many platforms, but it suffers from at least the following problems:

* Requires configuration descriptions in a combination of m4 and shell scripts
* Creates 10,000 line shell scripts which are slow to run and impossible to debug
* Requires a multi-stage process of aclocal => autoheader => autoconf => configure => Makefile + config.h

autosetup attempts to address these issues as follows by directly parsing a simple **`auto.def`** file, written in Tcl, and directly generating output files such as config.h and Makefile.

autosetup runs under either Tcl 8.5, which is available on almost any modern system, or Jim Tcl which can automatically bootstrap with
just a C compiler.

References
----------

* [http://freshmeat.net/articles/stop-the-autoconf-insanity-why-we-need-a-new-build-system](http://freshmeat.net/articles/stop-the-autoconf-insanity-why-we-need-a-new-build-system)
* [http://www.varnish-cache.org/docs/2.1/phk/autocrap.html](http://www.varnish-cache.org/docs/2.1/phk/autocrap.html)
* [http://wiki.tcl.tk/27197](http://wiki.tcl.tk/27197)
* [http://jim.tcl.tk/](http://jim.tcl.tk/)
* [http://www.gnu.org/software/hello/manual/autoconf/index.html](http://www.gnu.org/software/hello/manual/autoconf/index.html)
* [http://www.flameeyes.eu/autotools-mythbuster/index.html](http://www.flameeyes.eu/autotools-mythbuster/index.html)

### Comments on autoconf

* [http://news.ycombinator.com/item?id=1499738](http://news.ycombinator.com/item?id=1499738)
* [http://developers.slashdot.org/article.pl?sid=04/05/21/0154219](http://developers.slashdot.org/article.pl?sid=04/05/21/0154219)
* [http://www.airs.com/blog/archives/95](http://www.airs.com/blog/archives/95)

### Alternative autoconf Alternatives

* [http://pmk.sourceforge.net/faq.php](http://pmk.sourceforge.net/faq.php) - PMK
* [https://e-reports-ext.llnl.gov/pdf/315457.pdf](https://e-reports-ext.llnl.gov/pdf/315457.pdf) - autokonf

