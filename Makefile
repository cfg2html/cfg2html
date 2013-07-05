product = cfg2html

all: 
	i=`uname -s`; case $$i in HP-UX) make depot;; Linux) make rpm;; *) make help;; esac

help:
	@echo "+-------------------------+"
	@echo "|    cfg2html Makefile    |"
	@echo "|    =================    |"
	@echo "|    HP-UX: \"make depot\"  |"
	@echo "|    Linux: \"make rpm\"    |"
	@echo "+-------------------------+"

depot:
	gmake -C hpux depot

rpm:
	make -C linux rpm

clean:
	i=`uname -s`; case $$i in HP-UX) gmake -C hpux clean;; Linux) make -C linux clean;; *) make help;; esac
	
