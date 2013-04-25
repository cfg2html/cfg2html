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

depot: clean
	@/usr/sbin/swpackage -vv -s $(psf_file) -x layout_version=1.0 -d $(depot_dir) ; \
	rel=`/usr/bin/grep 'number' $(psf_file) | awk '{print $$2}'` ; \
	ymd=`date +%Y%m%d` ; \
	depot_file=/tmp/$(product)_$$rel.depot ; \
	/usr/sbin/swpackage -vv -d $$depot_file  -x target_type=tape -s $(depot_dir) \* ; \
	echo "File depot location is $$depot_file" ; \
	echo "Done."

