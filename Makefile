# @(#) $Id: Makefile,v 6.25 2023/08/31 08:04:58 ralph Exp $
# Makefile to create HP-UX software depot, AIX, FreeBSD, SunOS or Linux .DEB and .RPM packages etc.
# -------------------------------------------------------------------------------------------------
# -*- coding: utf-8, LF/Unix -*-
#
# IMPORTANT: You need an annotated git tag on your local build system, else the build will fail
#            (at least using openSUSE).   Maybe a workaround could: git checkout master?

.PHONY: changelog tag verinc help depot Linux rpm deb clean sunos bsd aix-rpm aix-dist

product = cfg2html
#TODO:# release = shell (git describe --long) ??  ## 6.33-6-g48d4c01

all:
	i=`uname -s`; case $$i in HP-UX) make depot;; Linux) make Linux;; SunOS) echo "Run \"make sunos\"";; FreeBSD|OpenBSD|NetBSD) echo "Run \"make freebsd\"";;*) make help;; esac

help:
	@echo "+------------------------------------------+"
	@echo "|    cfg2html Makefile targets             |"
	@echo "|    =========================             |"
	@echo "|    HP-UX: \"make depot\"                   |"
	@echo "|    Linux: \"make Linux\"     (1)           |"
	@echo "|    Linux: \"make rpm\"       (2)           |"
	@echo "|    Linux: \"make deb\"                     |"
	@echo "|    SunOS: \"make sunos\"                   |"
	@echo "|    FreeBSD|OpenBSD|NetBSD: \"make bsd\"    |"
	@echo "|    AIX:   \"make aix-rpm\"                 |"
	@echo "|    AIX:   \"make aix-dist\"                |"
	@echo "|                                          |"
	@echo "|    changelog: build CHANGELOG-md         |"
	@echo "|    verinc: increment version in script   |"
	@echo "|    tag: create annotated git tag         |"
	@echo "|    dist: create source tarball (Linux)   |"
	@echo "|    release: perform full release process |"
	@echo "+------------------------------------------+"
	@echo ""
	@echo "IMPORTANT: You need an annotated git tag on your local build system"
	@echo " (1) tries to guess which package to build (RPM or DEB)"
	@echo " (2) Jenkins workaround:  git checkout master; make rpm ## see issue #155"
	@echo ""

depot:
	gmake -C hpux depot

Linux:
	make -C linux Linux

rpm:
	make -C linux rpm

.PHONY: dist
dist:
	$(MAKE) -C linux dist

deb:
# Stop if 'dh_testdir' is missing
	$(if $(shell command -v dh_testdir),,$(error WARNING dh_testdir not found, debhelper package probably not installed))
	make -C linux deb

clean:
	i=`uname -s`; case $$i in HP-UX) gmake -C hpux clean;; Linux) make -C linux clean;; FreeBSD) make -C freebsd clean;;*) make help;; esac

sunos: sunos/cfg2html-SunOS.sh
	cd sunos && make install

bsd: bsd/cfg2html-bsd.sh
	cd bsd && make install

aix-rpm:
	make -C aix rpm

aix-dist:
	make -C aix dist

# Extract version from the VERSION="X.Y.Z" line in the cfg2html script
VERSION := $(shell grep '^VERSION=' cfg2html | cut -d'"' -f2)
# Calculate the release suffix (e.g., 0-gaf1c3e8)
RELEASE := $(shell git describe --tags --long 2>/dev/null | cut -d'-' -f2,3 || echo "0-unknown")

.PHONY: changelog tag verinc release

# 1. Increment version in the script
verinc:
	@echo "Current version: $(VERSION)"
	verinc -v cfg2html

# 2. Update changelog and commit it
changelog:
	@echo "Generating changelog..."
	@# The '-' at the start tells make to continue even if gitchangelog returns an error
	-gitchangelog $(shell git describe --tags --abbrev=0)..HEAD > CHANGELOG.md
	@# Check if the file is empty; if so, add a placeholder so 'git commit' doesn't fail
	@[ ! -s CHANGELOG.md ] && echo "Internal maintenance and version bump." > CHANGELOG.md || true
	git add CHANGELOG.md cfg2html
	@V=$$(grep '^VERSION=' cfg2html | cut -d'"' -f2); \
	git commit -s -m "chg: Updated Changelog for Version $$V"

# 3. Tag that specific commit with the new version
tag:
	@# Re-read the version from the file to get the NEW value from verinc
	$(eval NEW_VERSION := $(shell grep '^VERSION=' cfg2html | cut -d'"' -f2))
	@echo "Tagging new version $(NEW_VERSION)..."
	@if git rev-parse $(NEW_VERSION) >/dev/null 2>&1; then \
		git tag -d $(NEW_VERSION); \
		git push origin :refs/tags/$(NEW_VERSION); \
	fi
	git tag -a $(NEW_VERSION) -m "Release version $(NEW_VERSION)"
	git push origin $(NEW_VERSION) --force
# 	@echo "Detected Version in script: $(VERSION)"
# 	@if git rev-parse $(VERSION) >/dev/null 2>&1; then \
# 		echo "Tag $(VERSION) already exists locally. Replacing..."; \
# 		git tag -d $(VERSION); \
# 	fi
# 	@echo "Creating annotated tag: $(VERSION)"
# 	git tag -a $(VERSION) -m "Release version $(VERSION)"
# 	@echo "Force-pushing tag to origin..."
# 	git push origin $(VERSION) --force


# 4. Do everything in one go
release: verinc changelog dist tag
	@V=$$(grep '^VERSION=' cfg2html | cut -d'"' -f2); \
	echo "Release process completed. New version: $$V"
