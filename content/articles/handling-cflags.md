---
title: Handling CFLAGS
date: 2022-08-17
---

One question that comes up quite often is, "What is the right way of handling
CFLAGS within [autosetup](/) (also autoconf, automake, etc.) and the Makefiles for
the best user experience?" -- [stack overflow](https://stackoverflow.com/questions/51606653/allowing-users-to-override-cflags-cxxflags-and-friends).
[automake](https://www.gnu.org/software/automake/) spends some time on this --
[26.6 Flag Variables Ordering](https://www.gnu.org/software/automake/manual/html_node/Flag-Variables-Ordering.html)
however it doesn't answer all the questions that we might want answered.
Below is my attempt to untangle the confusion and provide a canonical best
way to handle CFLAGS with autosetup and make (or similar).

One fundamental consideration is that CFLAGS (and CPPFLAGS, CXXFLAGS)
are all user-specified and the user's wishes should be respected above all else.
This means that overwriting the user's settings by changing CFLAGS or adding
additional flags after the user's settings is not acceptable. With this in mind,
let's look at all the points where flags to the C compiler could be specified.

First the user can provide flags in the environment or on the command
line to `configure` that we will name (1) and (2).

=unix=
$ CFLAGS=-Dd1 ./configure CFLAGS=-Dd2
==

Next the user can provide flags in the environment or on the commandline to make or equivalent
that we will name (3) and (4).

=unix=
$ CFLAGS=-Dd3 make CFLAGS=-Dd4
==

Finally if no explicit CFLAGS are provided by the user, use `-g -O2`, which we will name (0).

In addition, `configure` may wish to add additional flags based on `configure` tests or user
options, but these should not affect CFLAGS.

=autosetup=
# If supported, add this flag to compiler flags
cc-check-flags -std=c99
==

And also we may we wish to add to CFLAGS within the makefile based on settings.
(This example could have been done in auto.def instead - it is just indicative).
Simlarly this should not affect the user's CFLAGS settings.

=unix=
ifeq(@SHARED@,1)
# Except we don't want to append to CFLAGS
CFLAGS += -dynamic
endif
==

Now what behaviour provides the best user experience? It is reasonable for (2) to override (1), especially
as CFLAGS may simply be set in the environment, so the explicit setting on the command line
should take precedence. Similarly, (4) should override (3) for similar reasons. It is also clear that
(4) should take precedence over (1) and (2) as this is a later phase. One thing that is not entirely
clear is whether (3) should override (2). For simplicity we will say it should as otherwise we would
need to distiguish beteen (1) and (2) in the Makefile. Finally, for CFLAGS all of (1) - (4) should
override (0). Now as we said that the user's selection is the highest precedence, our command line
should clearly be.

=makefile=
cc &lt;other-flags&gt; $CFLAGS -c ... -o ...
==

With the user's selection last, overriding other flags that we will discuss shortly, and
where CFLAGS is defined as below, where the notation means that the first value that is set
is chosen.
=unix=
CFLAGS := (4) || (3) || (2) || (1) || (0)
==

Note that CPPFLAGS can be specified by the user in all the same ways, except that there is no
default if not specified. The ordering between CFLAGS and CPPFLAGS is not clear, but we may as well follow
the gnu make approach:
=makefile=
# default
COMPILE.c = $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
==

So then we have:
=makefile=
cc &lt;other-flags&gt; $CFLAGS $CPPFLAGS -c ... -o ...
==

Now we only need to decide how configure-derived flags are set and made available to make.
While most autosetup checks don't do anything with CFLAGS by default (it is up to the auto.def
developer to make the flags available), `cc-check-flags` unfortunately (as of autosetup 0.7.0) 
modifieds CFLAGS. This is not OK as CFLAGS is a user value, and should not be touched by autosetup.
Therefore, as of autosetup 0.7.1, `cc-check-flags` now adds to AS_CFLAGS instead (autosetup CFLAGS).
This makes the recommendation of how to handle CFLAGS in auto.def simple. All flags are added to AS_CFLAGS
(or AS_CPPFLAGS or AS_CXXFLAGS). e.g.

=autosetup=
# Adds to AS_CFLAGS
cc-check-flags -std=c99
# Add profiling if selected
if {[opt-bool profiling]} {
	define-append AS_CFLAGS -pg
}
==

And finally we need to determine how flags can be added in the Makefile.
It is simplest if we use the same AS_CFLAGS as autosetup. e.g.

=makefile=
ifeq(@SHARED@,1)
AS_CFLAGS += -dynamic
endif
==

Now the only remaining challenge is to ensure that the Makefile implements
our desired command line:

=makefile=
cc $(AS_CFLAGS) $(AS_CPPFLAGS) $CFLAGS $CPPFLAGS -c ... -o ...
==

We *could* start by trying this:

=makefile=
CFLAGS += @AS_CFLAGS@ @AS_CPPFLAGS@ @CFLAGS@ @CPPFLAGS@
==

However this does not work as these will take precedence over the user flags.
As there is no way to prepend flags, we could try the cumbersome:

=makefile=
override CFLAGS := @AS_CFLAGS@ @AS_CPPFLAGS@ $(CFLAGS)
==

But my preference is for the simpler solution to either take over
the implicit rule entirely, or replace the compile line. Therefore in gnu
make we can do:
=makefile=
# Use configure versions if not set during make
CFLAGS ?= @CFLAGS@
CPPFLAGS ?= @CPPFLAGS@
CFlAG
# ensure we get the ordering we need
COMPILE.c = $(CC) @AS_CFLAGS@ @AS_CPPFLAGS@ $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
==

(Note that we could changed to `CFLAGS = @CFLAGS@` if we wanted to ignore (3))

Alternatively replace the rule entirely:

=makefile=
# This may be gnu make only
%.o: %.c
        $(CC) @AS_CFLAGS@ @AS_CPPFLAGS@ $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c $< -o $@

# This may work better for bsd make
.c.o:
        $(CC) @AS_CFLAGS@ @AS_CPPFLAGS@ $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c $< -o $@
==

This is implemented in [examples/typical/Makefile.in](https://github.com/msteveb/autosetup/blob/master/examples/typical/Makefile.in)
If you have a suggestion why one Makefile approach is better than the others, please
make a comment on this page.
