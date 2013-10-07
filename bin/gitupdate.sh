#!/bin/bash
#
# @(#) $Id: gitupdate.sh,v 6.10.1.1 2013-09-12 16:13:19 ralph Exp $
# --=----------------------------------------------------------------=---
#
# 

cd ..  # cfg2html home
	git fetch
	git pull
	
exit $?

#########################

for i in *
do
  if [ -d $i ]
  then
	echo -e  "---= $i \t \t \c"
	cd $i
	# git pull # this is dangerous, try fetch first
	git fetch
	git pull
	cd ..
  fi

done

