# @(#) $Id: find_non_inq_luns.sh,v 5.14 2013-02-09 10:24:36 ralph Exp $
# ---------------------------------------------------------------------------
# (c) 2008- 2013 by Ralph Roth, http://rose.rult.at

PATH=$PATH:/usr/contrib/bin/		# here lives INQ
which inq > /dev/null || exit 1

TMPFILELVM=$(mktemp -p lvm)     # temp. /etc/lvmtab*
TMPFILEINQ=$(mktemp -p inq)     # temp INQ output

strings /etc/lvmtab* | grep -e "/dev/disk/" -e "/dev/dsk/" | grep -v -e "_p[13] " -e "s[13] " | sort -u > $TMPFILELVM

inq -f_emc -no_dots -et  | grep ^/dev/rd | grep -v -E "Virtual Disk| ----- :" | sort -u > $TMPFILEINQ

for j in $(awk '{ print $1; }' $TMPFILEINQ )
do          
  # echo $i
  i=$(echo $j| cut -f4 -d/)
  USAGE_EXT=""
  if [ -x /usr/sbin/diskowner ]
  then
        USAGE_EXT="("$(/usr/sbin/diskowner -FA $j | awk -F ":owner=" ' { print $2; } ')")"
  fi 
  LINE="bug!"
  # if in a volume group then skip    or     print it (means not mapped to LVM)
  grep sk/$i  $TMPFILELVM > /dev/null || ( LINE=$(grep  sk/$i $TMPFILEINQ); echo $LINE" "$USAGE_EXT ) 
done

rm -f $TMPFILELVM $TMPFILEINQ
 
# ---------------------------------------------------------------------------
# $Log: find_non_inq_luns.sh,v $
# Revision 5.14  2013-02-09 10:24:36  ralph
# replaced defect come.to redirector with rose.rult.at
#
# Revision 5.13  2012-12-28 11:00:04  ralph
# (c) y2k13 by Ralph Roth
#
# Revision 5.12  2011-12-28 09:41:36  ralproth
# cfg5.23-32068: Consolidated the (C)opyright messages to one common format, y2k12 header
#
# Revision 5.11  2011-12-28 09:33:48  ralproth
# cfg5.22-32061: y2k11 - changed the copyright
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.3  2010-12-22 21:36:59  ralproth
# cfg4.89-25250: Changed y2k10 to y2k11 :-)
#
# Revision 4.2  2010-06-09 15:10:45  ralproth
# cfg4.73-24174: Wrong CVS keyword
#
# Revision 4.1  2010-03-10 09:34:09  ralproth
#
# Modified Files:
# 	find_non_lvm_luns.sh
# Added Files:
# 	find_non_inq_luns.sh
#
