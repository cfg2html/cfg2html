product = cfg2html

all: help

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
