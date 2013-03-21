#!/bin/bash
#
# @(#) $Id:$
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

