# @(#) $Id: Makefile,v 6.14 2014/10/08 10:41:05 ralph Exp $
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

man: doc/cfg2html.8
	@if [ -f doc/cfg2html.8 ]; then cp -p doc/cfg2html.8 doc/cfg2html.8.save; \
	compress doc/cfg2html.8 ; mv -f doc/cfg2html.8.Z doc/cfg2html.8 ; fi

rewrite: $(psf_file)
	@echo "Update the $(psf_file) file"
	ver=`/usr/bin/grep ^CVS ../cfg2html | awk '{print $$3}'` ; \
	cp -p $(psf_file) $(psf_file).save ; \
	sed -e 's#number.*#number C.0'$$ver'#' -e 's#revision.*#revision C.0'$$ver'#g' < $(psf_file).save >$(psf_file); \
	cp -p ../cfg2html ../cfg2html.save ; \
	sed -e 's#SHARE_DIR=.*#SHARE_DIR=/opt/$$PROGRAM#' < ../cfg2html.save > ../cfg2html
	
depot: clean lib-tmp man rewrite
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
	mv -f doc/cfg2html.8.save doc/cfg2html.8 ; \
	mv -f $(psf_file).save $(psf_file) ; \
	mv -f ../cfg2html.save ../cfg2html ; \
	echo "Done."

upload: 
	depot_file=`ls -lrt "/tmp/$(product)_"*".depot" | tail -1 | awk '{print $$9}'` ; \
	echo "File depot $$depot_file will be uploaded" ; \
	curl --netrc --upload-file $$depot_file --url ftp://apache07.hostbasket.com/wwwroot/projects/cfg2html/hpux/ ; \
	echo "Upload Done."
