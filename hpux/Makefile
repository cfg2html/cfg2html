# @(#) $Id: Makefile,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# -------------------------------------------------------------------------

product = cfg2html
psf_file = packaging/$(product).psf
depot_dir = /tmp/$(product).depot.dir

all: help

help:
	@echo "+-------------------------+"
	@echo "|    cfg2html Makefile    |"
	@echo "|    =================    |"
	@echo "|    build: \"make depot\"  |"
	@echo "+-------------------------+"

clean:
	@if [ `whoami` != "root" ]; then echo "Only root may remove packages"; exit 1; fi; \
	rm -rf $(depot_dir) ; \
	echo "Depot directory [$(depot_dir)] successfully removed"

lib-tmp:
	@if [ -d ./lib ]; then rm -rf lib-tmp; mkdir -m 755 lib-tmp; \
	cp lib/* lib-tmp/ ; fi

man: ../doc/cfg2html.8
	@if [ -f ../doc/cfg2html.8 ]; then cp ../doc/cfg2html.8 ../doc/cfg2html.8.txt; \
	compress ../doc/cfg2html.8 ; mv -f ../doc/cfg2html.8.Z ../doc/cfg2html.8 ; fi

depot: clean lib-tmp man
	@/usr/sbin/swpackage -vv -s $(psf_file) -x layout_version=1.0 -d $(depot_dir) ; \
	rel=`/usr/bin/grep 'number' $(psf_file) | awk '{print $$2}'` ; \
	ymd=`date +%Y%m%d` ; \
	depot_file="/tmp/$(product)_"$$rel"_"$$ymd".depot" ; \
	/opt/ignite/bin/make_bundles -b -i -n "CFG2HTML" -t "Config To HTML System Documentation Tool (cfg2html) for HP-UX" \
	-o /tmp/cfg2html_bundle.psf -r $$rel $(depot_dir) ; \
	/usr/sbin/swpackage -s /tmp/cfg2html_bundle.psf -xlayout_version=1.0 -xreinstall_files=true -d  $(depot_dir) ; \
	/usr/sbin/swpackage -vv -d $$depot_file  -x target_type=tape -s $(depot_dir) \* ; \
	echo "File depot location is $$depot_file" ; rm -rf lib-tmp ; \
	rm -f /tmp/cfg2html_bundle.psf ; \
	mv -f ../doc/cfg2html.8.txt ../doc/cfg2html.8 ; \
	echo "Done."

