# @(#) $Id: Makefile,v 6.13 2013/10/29 23:11:26 ralph Exp $
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4

# In some dists (e.g. Ubuntu) bash is not the default shell. Statements like
#   cp -a etc/cfg2html/{mappings,templates} ...
# assumes bash. So its better to set SHELL

SHELL=/bin/bash

DESTDIR =
OFFICIAL =

### Get version from Config 2 HTML itself
cfg2htmlbin = ../cfg2html
name = cfg2html
version := $(shell awk '/^CVS=/ { print $$3}' $(cfg2htmlbin))

### Get the branch information from git
ifeq ($(OFFICIAL),)
ifneq ($(shell which git),)
git_date := $(shell git log -n 1 --format="%ai")
git_ref := $(shell git symbolic-ref -q HEAD)
git_branch = $(lastword $(subst /, ,$(git_ref)))
endif
else
git_branch = cfg2html-$(version)
endif
#git_branch ?= master

date := $(shell date --date="$(git_date)" +%Y%m%d%H%M)
release_date := $(shell date --date="$(git_date)" +%Y-%m-%d)

prefix = /usr
sysconfdir = /etc
sbindir = $(prefix)/sbin
datadir = $(prefix)/share
mandir = $(datadir)/man
localstatedir = /var

specfile = packaging/rpm/$(name).spec
##dscfile = packaging/debian/$(name).dsc

distversion = $(version)
##debrelease = 0
rpmrelease = %nil
##obsproject = home:gdha
##obspackage = $(name)-$(version)
#ifeq ($(OFFICIAL),)
#    distversion = $(version)-git$(date)
##    debrelease = 0git$(date)
#    rpmrelease = .git$(date)
##    obsproject = home:gdha
##    obspackage = $(name)
#endif

.PHONY: doc

all:
	@echo "Nothing to build. Use \`make help' for more information."

help:
	@echo -e "Config 2 HTML make targets:\n\
\n\
  validate        - Check source code\n\
  install         - Install cfg2html (may replace files)\n\
  uninstall       - Uninstall cfg2html (may remove files)\n\
  dist            - Create tar file\n\
  rpm             - Create RPM package\n\
\n\
Config 2 HTML make variables (optional):\n\
\n\
  DESTDIR=        - Location to install/uninstall\n\
  OFFICIAL=       - Build an official release\n\
"

clean:
	rm -f ../$(name)-$(distversion).tar.gz
	rm -f build-stamp
#	make -C doc clean
	rm -rf ../$(name).cron

### You can call 'make validate' directly from your .git/hooks/pre-commit script
validate:
	@echo -e "\033[1m== Validating scripts and configuration ==\033[0;0m"
	find etc/  -name '*.conf' | xargs bash -n
	#find lib/ plugins/ -name '*.sh' | xargs bash -n
	find lib/ -name '*.sh' | xargs bash -n
	bash -n $(cfg2htmlbin)
	find . -name '*.sh' | xargs bash -n
### Fails to work on RHEL4
#	find -L . -type l

#man:
#	@echo -e "\033[1m== Prepare manual ==\033[0;0m"
#	make -C doc man

#doc:
#	@echo -e "\033[1m== Prepare documentation ==\033[0;0m"
#	make -C doc docs

#cron:
#	@echo -e "\033[1m== Make a cron file ==\033[0;0m"
#	echo "$$((RANDOM % 55)) $$((RANDOM % 5)) * * $$((RANDOM % 5)) root /usr/sbin/cfg2html -2\%Y\%m\%d > /dev/null 2>&1" \
#	> ../$(name).cron

ifneq ($(git_date),)
rewrite:
	@echo -e "\033[1m== Rewriting $(specfile), $(dscfile) and $(cfg2htmlbin) ==\033[0;0m"
	cp -f $(specfile) $(specfile).orig
	#cp -f $(dscfile) $(dscfile).orig
	cp -f $(cfg2htmlbin) $(cfg2htmlbin).orig
	sed -i.orig \
		-e 's#^Source:.*#Source: $(name)-$(distversion).tar.gz#' \
		-e 's#^Version:.*#Version: $(version)#' \
		-e 's#^%define rpmrelease.*#%define rpmrelease $(rpmrelease)#' \
		-e 's#^%setup.*#%setup -q -n $(name)-$(distversion)#' \
		$(specfile)
#	sed -i.orig \
#		-e 's#^Version:.*#Version: $(version)-$(debrelease)#' \
#		$(dscfile)
	sed -i.orig \
		-e 's#^VERSION=.*#VERSION=$(distversion)#' \
		-e 's#^RELEASE_DATE=.*#RELEASE_DATE="$(release_date)"#' \
		$(cfg2htmlbin)

restore:
	@echo -e "\033[1m== Restoring $(specfile), $(dscfile) and $(cfg2htmlbin) ==\033[0;0m"
	mv -f $(specfile).orig $(specfile)
	mv -f $(cfg2htmlbin).orig $(cfg2htmlbin)
else
rewrite:
	@echo "Nothing to do."

restore:
	@echo "Nothing to do."
endif

install-config:
	@echo -e "\033[1m== Installing configuration ==\033[0;0m"
	install -d -m0700 $(DESTDIR)$(sysconfdir)/cfg2html/
	-[[ ! -e $(DESTDIR)$(datadir)/cfg2html/etc/default.conf ]] && \
		install -Dp -m0600 etc/default.conf $(DESTDIR)$(datadir)/cfg2html/etc/default.conf
	-[[ ! -e $(DESTDIR)$(sysconfdir)/cfg2html/local.conf ]] && \
		install -Dp -m0600 etc/local.conf $(DESTDIR)$(sysconfdir)/cfg2html/local.conf
	-[[ ! -e $(DESTDIR)$(sysconfdir)/cfg2html/plugins ]] && \
		install -Dp -m0600 plugins $(DESTDIR)$(sysconfdir)/cfg2html/plugins
	-[[ ! -e $(DESTDIR)$(sysconfdir)/cfg2html/systeminfo ]] && \
		install -Dp -m0600 systeminfo $(DESTDIR)$(sysconfdir)/cfg2html/systeminfo
	-[[ ! -e $(DESTDIR)$(sysconfdir)/cfg2html/files ]] && \
		install -Dp -m0600 files $(DESTDIR)$(sysconfdir)/cfg2html/files
	-find $(DESTDIR)$(sysconfdir)/cfg2html/ -name '.gitignore' -exec rm -rf {} \; &>/dev/null

install-bin:
	@echo -e "\033[1m== Installing binary ==\033[0;0m"
	install -Dp -m0755 $(cfg2htmlbin) $(DESTDIR)$(sbindir)/cfg2html
	sed -i -e 's,^CONFIG_DIR=.*,CONFIG_DIR="$(sysconfdir)/cfg2html",' \
		-e 's,^SHARE_DIR=.*,SHARE_DIR="$(datadir)/cfg2html",' \
		-e 's,^VAR_DIR=.*,VAR_DIR="$(localstatedir)/log/cfg2html",' \
		$(DESTDIR)$(sbindir)/cfg2html

install-data:
	@echo -e "\033[1m== Installing scripts ==\033[0;0m"
	install -d -m0755 $(DESTDIR)$(datadir)/cfg2html/
	cp -a cfg2html-aix.sh $(DESTDIR)$(datadir)/cfg2html/
	cp -aLr lib $(DESTDIR)$(datadir)/cfg2html/
	cp -a plugins $(DESTDIR)$(datadir)/cfg2html/
	-find $(DESTDIR)$(datadir)/cfg2html/ -name '.gitignore' -exec rm -rf {} \; &>/dev/null

install-var:
	@echo -e "\033[1m== Installing working directory ==\033[0;0m"
	install -d -m0755 $(DESTDIR)$(localstatedir)/log/cfg2html/

#install-doc:
#	@echo -e "\033[1m== Installing documentation ==\033[0;0m"
#	make -C doc install
#	sed -i -e 's,/etc,$(sysconfdir),' \
#		-e 's,/usr/sbin,$(sbindir),' \
#		-e 's,/usr/share,$(datadir),' \
#		-e 's,/usr/share/doc/packages,$(datadir)/doc,' \
#		$(DESTDIR)$(mandir)/man8/cfg2html.8

#install-cron: cron
#	echo -e "\033[1m== Installing cron ==\033[0;0m"
#	install -Dp -m0644 ../$(name).cron $(DESTDIR)$(sysconfdir)/cron.d/$(name)
#	rm -f ../$(name).cron

#install: validate man install-config rewrite install-bin restore install-data install-var install-doc install-cron
install: validate install-config rewrite install-bin restore install-data install-var 

uninstall:
	@echo -e "\033[1m== Uninstalling Config 2 HTML ==\033[0;0m"
	-rm -v $(DESTDIR)$(sbindir)/cfg2html
	-rm -v $(DESTDIR)$(mandir)/man8/cfg2html.8
	-rm -rv $(DESTDIR)$(datadir)/cfg2html/
#	rm -rv $(DESTDIR)$(sysconfdir)/cfg2html/
#	rm -rv $(DESTDIR)$(localstatedir)/lib/cfg2html/

#dist: clean validate man rewrite $(name)-$(distversion).tar.gz restore
dist: clean validate rewrite $(name)-$(distversion).tar.gz restore

$(name)-$(distversion).tar.gz:
	@echo -e "\033[1m== Building archive $(name)-$(distversion) ==\033[0;0m"
	cd .. ; \
	git checkout $(git_branch) ; \
	git ls-tree -r --name-only --full-tree $(git_branch) | grep -v -E '(^bin|^hpux|^doc|^linux|^sunos|^bsd)' | \
		tar -czf $(name)-$(distversion).tar.gz --transform='s,^,$(name)-$(distversion)/,S' --files-from=-

rpm: dist
	@echo -e "\033[1m== Building RPM package $(name)-$(distversion) ==\033[0;0m"
	cd .. ; \
	rpmbuild -tb  \
		--define "_rpmfilename %%{NAME}-%%{VERSION}-aix.rpm" \
		--define "_rpmdir %(pwd)" $(name)-$(distversion).tar.gz

