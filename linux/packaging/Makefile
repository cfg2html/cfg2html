# @(#) $Id: Makefile,v 6.13 2018/01/02 16:27:18 ralph Exp $
# -----------------------------------------------------------------------------------------
# (c) 1997-2023 by Ralph Roth  -*- http://rose.rult.at -*-

# $Header: /home/cvs/cfg2html/cfg2html_git/linux/packaging/Makefile,v 6.13 2018/01/02 16:27:18 ralph Exp $
# A simple Debian makefile for cfg2html-linux

# DESTDIR modified by Jacques MENGUY, have to check it first :)
DESTDIR = /root/cfg2html
ARCH =

PREFIX = $(DESTDIR)/usr
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man8
CONFDIR= $(DESTDIR)/etc/cfg2html

all:
	# nothing to do

clean:
	rm -f *~

install:
	install cfg2html-linux $(BINDIR)
	install cfg2html $(BINDIR)
	install cfg2html-linux.8 $(MANDIR)
	install -d $(CONFDIR)
	install -m 644 files $(CONFDIR)
	install -m 644 systeminfo $(CONFDIR)
	install -m 644 plugins $(CONFDIR)

.PHONY: all clean install
