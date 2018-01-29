# @(#) $Id: Makefile,v 6.17 2015/11/26 21:00:44 ralph Exp $

# Makefile to create HP-UX software depot, AIX, FreeBSD, SunOS or Linux .DEB and .RPM packages etc.
# -------------------------------------------------------------------------------------------------
# -*- coding: utf-8, LF/Unix -*-


product = cfg2html

all:
	i=`uname -s`; case $$i in HP-UX) make depot;; Linux) make rpm;; SunOS) echo "Run \"make sunos\"";; FreeBSD|OpenBSD|NetBSD) echo "Run \"make freebsd\"";;*) make help;; esac

help:
	@echo "+------------------------------------------+"
	@echo "|    cfg2html Makefile targets             |"
	@echo "|    =========================             |"
	@echo "|    HP-UX: \"make depot\"                   |"
	@echo "|    Linux: \"make rpm\"                     |"
	@echo "|    Linux: \"make deb\"                     |"
	@echo "|    SunOS: \"make sunos\"                   |"
	@echo "|    FreeBSD|OpenBSD|NetBSD: \"make bsd\"    |"
	@echo "|    AIX:   \"make aix-rpm\"                 |"
	@echo "|    AIX:   \"make aix-dist\"                |"
	@echo "+------------------------------------------+"

depot:
	gmake -C hpux depot

rpm:
	make -C linux rpm

deb:
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
