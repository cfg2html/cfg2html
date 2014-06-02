# @(#) $Id: Makefile,v 1.1 2014/06/01 04:59:40 dusan Exp dusan $
# -------------------------------------------------------------------------

product = cfg2html
BASEDIR = /usr/share/cfg2html
ETCDIR = /etc/cfg2html
OWNER = root:wheel
PERMSD = 755 
PERMSF = 644 
depot_dir = /tmp/$(product).depot.dir

all: help

help:
	@echo "+------------------------------------------------+"
	@echo "|  cfg2html Makefile for FreeBSD|OpenBSD|NetBSD  |"
	@echo "|                                                |"
	@echo "|  help|clean|lib-tmp|install|archive            |"
	@echo "+------------------------------------------------+"

clean:
	@if [ `whoami` != "root" ]; then echo "Only root may remove packages"; exit 1; fi; \
	rm -rf $(depot_dir) ; \
	echo "Depot directory [$(depot_dir)] successfully removed"

lib-tmp:
	@if [ -d ./lib ]; then rm -rf lib-tmp; mkdir -m ${PERMS}lib-tmp; \
	cp lib/* lib-tmp/ ; fi

install: cfg2html-bsd.sh
	@if [ ! -d ${ETCDIR} ]; then mkdir -p ${ETCDIR}; chmod ${PERMSD} ${ETCDIR}; chown ${OWNER} ${ETCDIR}; fi
	@if [ ! -d ${BASEDIR} ]; then mkdir -p ${BASEDIR}; chmod ${PERMSD} ${BASEDIR}; \
        chown ${OWNER} ${BASEDIR}; fi 
	@if [ -f ../cfg2html ]; then cp -p ../cfg2html /usr/sbin;\
        chmod ${PERMSD} /usr/sbin/cfg2html; chown ${OWNER} /usr/sbin/cfg2html; fi
	@if [ -f cfg2html-bsd.sh ]; then cp -p cfg2html-bsd.sh ${BASEDIR}; fi
	@if [ -d ./lib ]; then cp -pr ./lib ${BASEDIR}; \
        chmod ${PERMSF} ${BASEDIR}/lib/*; chown ${OWNER} ${BASEDIR}/lib/*; fi
	@if [ -d ./etc ]; then cp -pr ./etc ${BASEDIR}; \
        chmod ${PERMSF} ${BASEDIR}/etc/*; chown ${OWNER} ${BASEDIR}/etc/*; fi
	@if [ -d ./plugins ]; then cp -pr ./plugins ${BASEDIR}; \
        chmod ${PERMSD} ${BASEDIR}/plugins/*; chown ${OWNER} ${BASEDIR}/plugins/*; fi
	@if [ -f doc/cfg2html.8 ]; then cp -p doc/cfg2html.8 /usr/share/man/man8;\
        chmod ${PERMSF} /usr/share/man/man8/cfg2html.8; chown ${OWNER} /usr/share/man/man8/cfg2html.8; fi
	echo "Installation done."

archive: 
	tar cvf /tmp/cfg2html-bsd.tar sunos  && gzip /tmp/cfg2html-bsd.tar
	echo "cfg2html GZIP archive created in /tmp directory"
