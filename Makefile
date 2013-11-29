# @(#) $Id: Makefile,v 6.12 2013/10/29 23:11:25 ralph Exp $ 

# Makefile to create HP-UX software depot or Linux .DEB and .RPM packages
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4 -*- coding: utf-8 -*- 


product = cfg2html

all: 
	i=`uname -s`; case $$i in HP-UX) make depot;; Linux) make rpm;; *) make help;; esac

help:
	@echo "+-------------------------+"
	@echo "|    cfg2html Makefile    |"
	@echo "|    =================    |"
	@echo "|    HP-UX: \"make depot\"  |"
	@echo "|    Linux: \"make rpm\"    |"
	@echo "|    Linux: \"make deb\"    |"
	@echo "+-------------------------+"

depot:
	gmake -C hpux depot

rpm:
	make -C linux rpm

deb:
	make -C linux deb

clean:
	i=`uname -s`; case $$i in HP-UX) gmake -C hpux clean;; Linux) make -C linux clean;; *) make help;; esac


