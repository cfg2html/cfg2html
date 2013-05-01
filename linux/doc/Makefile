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
	rm -f unconv.8 *.html *.xml

%.8.html: %.8.txt
	asciidoc -d manpage $<

%.8: %.8.xml
	xmlto man $<

%.html: %.txt
	asciidoc $<

%.8.xml: %.8.txt
	asciidoc -b docbook -d manpage $<
