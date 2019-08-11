# Point RSYNC_PUBLISH_URL to the gh-pages branch of autosetup.git
PUBLISH_URL ?= ../gh-pages/
# Point AUTOSETUP the autosetup script in the main branch of autosetup.git.
# Used for generating the developer reference
AUTOSETUP ?= $(HOME)/src/autosetup/autosetup

all:
	nanoc compile

publish: all
	rsync -rltDzvO --exclude=.DS_Store output/ $(PUBLISH_URL)

test:
	nanoc view

# Build reference.md from autosetup --reference=markdown
# This needs to be done manually
ref:
	( cat reference.hdr; $(AUTOSETUP) --reference=markdown ) >content/developer/reference.md
	nanoc compile

clean:
	rm -rf output/*
