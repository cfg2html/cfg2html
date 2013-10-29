# @(#) $Id: find_non_lvm_luns.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
#########################################################################
#
# This shell script finds LUNs on the XP that are not mapped using LVM, e.g.
# LUNs ready to be deleted or Command Devices.... No additional command line
# arguments are needed Caution, when you are NOT using SecureManager XP!
# REQUIRES xpinfo!

#########################################################################
#  for i in $( ./find_non_lvm_luns.sh | cut -f1 -d" ")
# do
#       pvcreate $i
# done
#########################################################################
# $Log: find_non_lvm_luns.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.14  2010-03-10 09:34:09  ralproth
#
# Modified Files:
# 	find_non_lvm_luns.sh
# Added Files:
# 	find_non_inq_luns.sh
#
# Revision 4.13  2010-03-03 15:48:58  ralproth
# cfg4.63-24046: mount//find xp luns
#
# Revision 4.12  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2007/07/11 15:14:00  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.14  2007/07/11 14:13:59  ralproth
# fixes for hpux11.31 mss
#
# Revision 3.10.1.1  2004/03/08 11:43:55  ralproth
# Initial 3.x stream import
#
# Revision 2.1  2004/03/08 11:43:55  ralproth
# ! small onsite enhancements
# + added find_non_xp_luns.sh
#
# Revision 1.1  2004/02/25 15:25:01  ralproth
# Initial revision
#########################################################################

PATH=$PATH:/usr/contrib/bin/		# here lives xpinfo
TMPFILELVM=$(mktemp -p lvm)
TMPFILEXPI=$(mktemp -p xpinfo)

# I am not sure if we use also /etc/lvmtab_p here? #  10.03.2010, Ralph Roth
strings /etc/lvmtab | grep -e "/dev/disk/" -e "/dev/dsk/" > $TMPFILELVM
xpinfo -i > $TMPFILEXPI

for i in $(awk '{ print $1; }' $TMPFILEXPI | cut -f4 -d/ | sort -u )
do          # if in a volume group then skip                 or     print it (means not mapped to LVM)
  grep -e /dsk/$i -e /disk/$i $TMPFILELVM > /dev/null || ( grep  -e /dsk/$i -e /disk/$i $TMPFILEXPI | awk '{ print $1,"\t", $4,  $5,  $6,  $8,"\t",$7;}' )
done

#ll $TMPFILELVM $TMPFILEXPI
rm -f $TMPFILELVM $TMPFILEXPI

