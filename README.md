autosetup documentation sources
===============================

This repository contains the source code for the autosetup documentation

Installation
------------

In order to build the documentation you will need:

* [nanoc v4.11](https://nanoc.ws) static website generator
* ruby v2.7 or later

I have:

```
$ nanoc --version
Nanoc 4.12.7 © 2007–2022 Denis Defreyne.
Running ruby 2.7.0 (2019-12-25) on x86_64-darwin20 with RubyGems 3.3.20.
```

See the nanoc installation documentation for installation with **gem**.
gem should install all the required dependencies, but for reference, I have the
following installed:

```
$ gem list --local
adsf (1.4.3)
kramdown (2.3.0)
nanoc (4.11.19)
nanoc-checking (1.0.0)
nanoc-cli (4.11.19)
nanoc-core (4.11.19)
nanoc-deploying (1.0.0)
nokogiri (1.10.1)
nokogumbo (2.0.2)
ref (2.0.0)
zeitwerk (2.4.1)
```

Building
--------

To build, simply run:

```
$ make
```

To update the developer reference, you will need to have an autosetup
git repository somewhere and run (note that `AUTOSETUP` is a path to the
actual autosetup script):

```
$ make AUTOSETUP=<path-to-autosetup-git>/autosetup
```

To update the github pages, checkout the autosetup git repository somewhere
on branch **gh-pages** and run:

```
$ make PUBLISH_URL=<path-to-autosetup-gh-pages-git>
```

The commit the changes on the gh-pages branch.

Testing
-------

To test your changes, run:

```
$ make all test
```

And navigate your browser to [http://localhost:3000/](http://localhost:3000/)

Authoring
---------

Generally, follow the nanoc documentation on how to add/modify content.
Articles can be added under content/articles/.
Remember to add a title and date to the header.
