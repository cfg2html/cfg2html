# @(#) $Id: Makefile,v 1.1 2014/05/18 04:59:40 dusan Exp dusan $
# -------------------------------------------------------------------------

product = cfg2html
BASEDIR = /usr/share/cfg2html
OWNER = root:root
PERMSD = 755 
PERMSF = 644 
depot_dir = /tmp/$(product).depot.dir

all: help

help:
	@echo "+---------------------------------------+"
	@echo "|  cfg2html Makefile for SunOS/Solaris  |"
	@echo "|                                       |"
	@echo "|  help|clean|lib-tmp|install|archive   |"
	@echo "+---------------------------------------+"

clean:
	@if [ `whoami` != "root" ]; then echo "Only root may remove packages"; exit 1; fi; \
	rm -rf $(depot_dir) ; \
	echo "Depot directory [$(depot_dir)] successfully removed"

lib-tmp:
	@if [ -d ./lib ]; then rm -rf lib-tmp; mkdir -m ${PERMS}lib-tmp; \
	cp lib/* lib-tmp/ ; fi

install: cfg2html-SunOS.sh
	@if [ ! -d ${BASEDIR} ]; then mkdir -p ${BASEDIR}; chmod ${PERMSD} ${BASEDIR}; \
        chown ${OWNER} ${BASEDIR}; fi 
	@if [ -f ../cfg2html ]; then cp -p ../cfg2html /usr/sbin;\
        chmod ${PERMSD} /usr/sbin/cfg2html; chown ${OWNER} /usr/sbin/cfg2html; fi
	@if [ -f cfg2html-SunOS.sh ]; then cp -p cfg2html-SunOS.sh ${BASEDIR}; fi
	@if [ -d ./lib ]; then cp -pr ./lib ${BASEDIR}; \
        chmod ${PERMSF} ${BASEDIR}/lib/*; chown ${OWNER} ${BASEDIR}/lib/*; fi
	@if [ -d ./etc ]; then cp -pr ./etc ${BASEDIR}; \
        chmod ${PERMSF} ${BASEDIR}/etc/*; chown ${OWNER} ${BASEDIR}/etc/*; fi
	@if [ -d ./plugins ]; then cp -pr ./plugins ${BASEDIR}; \
        chmod ${PERMSD} ${BASEDIR}/plugins/*; chown ${OWNER} ${BASEDIR}/plugins/*; fi
	echo "Installation done."

archive: 
	tar cvf /tmp/cfg2html-SunOS.tar sunos  && gzip /tmp/cfg2html-SunOS.tar
	echo "cfg2html GZIP archive created in /tmp directory"
