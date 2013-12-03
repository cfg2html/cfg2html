#!/usr/bin/ksh
# @(#) $Id: pvgfilter.sh,v 6.13 2013/12/03 16:08:35 ralph Exp $
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4 -*- coding: utf-8 -*- http://rose.rult.at/ - Ralph Roth
# Part of the cfg2html 6.xx/HPUX package

# pvgfilter.sh replaces the two executables pnfgfilter.[hppa|ia64]

for vgname in $(/usr/sbin/vgdisplay 2>/dev/null | grep "^VG Name" | awk '{print $3}')
do
    echo "Volumegroup: $vgname"
    set -A PriDsks
    set -A AltDsks    # we re-use the array for each new VG in our list
    i=0           # counter for PriDsks
    j=0           # counter for AltDsks
    /usr/sbin/vgdisplay -v $vgname 2>/dev/null | awk '/Physical volumes/,/Physical volume groups/' | grep "PV Name" |\
    while read LINE
    do
        fields=$(echo $LINE | awk '{ total = total + NF }; END { print total+0 }') # 3: pri; 5: alt
        if [ $fields -eq 3 ]; then
            PriDsks[$i]="$(echo $LINE | awk '/PV Name/ && NF == 3 { print $NF }')"
	    #echo "${PriDsks[$i]}"
	    i=$((i+1))
        else
            AltDsks[$j]="$(echo $LINE | awk '{ print $3 }')"
	    #echo "${AltDsks[$j]}"
	    j=$((j+1))
        fi
    done
    echo "Pri: \c"
    echo "${PriDsks[@]}"
    if [ $j -gt 0 ]; then
        echo "Alt: \c"
        echo "${AltDsks[@]}"
    fi
    echo
done
