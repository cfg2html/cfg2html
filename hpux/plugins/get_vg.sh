# get LVM for TGV by Ralph Roth
# @(#) $Id: get_vg.sh,v 5.13 2013-02-09 10:24:36 ralph Exp $
# --=-----------------------------------------------------------------------=---
# (c) 1997 - 2013 by Ralph Roth  -*- http://rose.rult.at -*-
#
# $Log: get_vg.sh,v $
# Revision 5.13  2013-02-09 10:24:36  ralph
# replaced defect come.to redirector with rose.rult.at
#
# Revision 5.12  2012-12-28 11:00:05  ralph
# (c) y2k13 by Ralph Roth
#
# Revision 5.11  2012-02-15 22:26:50  ralproth
# cfg5.25-32079: Forced commit by ./MakeRelease.sh for binary code distribution.
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.10.1.1  2003/03/11 09:20:52  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2003/03/11 09:20:52  ralproth
# Initial 3.x stream import
#
# Revision 2.3  2003/03/11 09:20:52  ralproth
# Added options -d, -t, -A, -b
#
# Revision 2.1.1.1  2003/01/21 10:33:33  ralproth
# Import from HPUX to cygwin
#
# Revision 1.2  2003/01/13 10:08:43  ralproth
# Added cvs keywords
#
#

# fixed, sr by wpj3140 <juhas@tesco.net> 
set TMP=/tmp

get_LVM()
{

    vgLIST=$TMP/vgLIST.$$
    lvLIST=$TMP/lvLIST.$$
    pvLIST=$TMP/pvLIST.$$
    LVMLIST=$TMP/LVMLIST.$$

    cp /dev/null $LVMLIST

    if [ -f /etc/lvmtab ]
    then
        vgdisplay -v|awk '$1 == "VG" && $2 == "Name" {print $3}'|sort -u > $vgLIST
        vgdisplay -v|awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u > $lvLIST
        vgdisplay -v|awk '$1 == "PV" && $2 == "Name" {print $3}'|sort -u > $pvLIST

            for i in "vg" "lv" "pv"
            do
                    for j in `eval cat '$'${i}LIST`
                    do
                    eval ${i}NAME=`echo $j`
                    echo "${i}display -v $j:$i`eval echo '$'${i}NAME`" >> $LVMLIST
                    done
            done
            while read i
            do
                    LVMCOMMAND=`echo $i|awk -F: '{print $1}'`
                    LVMNAME=`echo $i|awk -F: '{print $2}'`
                    echo "@@@@@@ START OF $LVMNAME"
                    echo ""
                    $LVMCOMMAND
                    echo ""
                    echo "###### END OF $LVMNAME"
                    echo ""
            done < $LVMLIST
    else
            echo "Not Installed on this System"
    fi

    rm $vgLIST $lvLIST $pvLIST

}

echo "The LVM/VG Layout is stored in this document as a comment, ready to be processed by the meanwhile distinct/obsolete TGV (LVM only, no HW)!\n<!-- "
get_LVM
echo "-->"

