# @(#) $Id: Makefile,v 6.12 2013/12/02 08:48:42 ralph Exp $
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4 -*- coding: utf-8 -*- http://rose.rult.at/ - Ralph Roth

prefix = /usr
datadir = $(prefix)/share
mandir = $(datadir)/man

txttargets = $(shell echo *.txt)
htmltargets = $(patsubst %.txt, %.html, $(txttargets))

all: docs

dist: docs

man: cfg2html.8

docs: cfg2html.8 $(htmltargets)

install: cfg2html.8
	install -Dp -m0644 cfg2html.8 $(DESTDIR)$(mandir)/man8/cfg2html.8

clean:
	rm -f unconv.8 *.xml

%.8.html: %.8.txt
	asciidoc -d manpage $<

%.8: %.8.xml
	xmlto man $<

%.html: %.txt
	asciidoc $<

%.8.xml: %.8.txt
	asciidoc -b docbook -d manpage $<
