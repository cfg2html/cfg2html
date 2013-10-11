# Provided 27-Feb-2003 by Martin Kalmbach
# @(#) $Id: list_filesystems.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# ----------------------------------------------------------------------------
# $Log: list_filesystems.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.11  2012-06-01 18:13:56  ralph
# small typo fixes adn code cleanup, CVS cleanup, added comments etc.
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.10.1.1  2006/03/13 09:18:34  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.11  2006/03/13 09:11:38  ralproth
# small fix provided by mk
#
# Revision 3.10.1.1  2004/03/08 11:43:55  ralproth
# Initial 3.x stream import
#
# Revision 2.4  2003/07/11 07:01:58  ralproth
# Modified list_filesystems by Martin Kalmbach
#
# Revision 2.3  2003/03/11 09:20:52  ralproth
# Added options -d, -t, -A, -b
#
# Revision 2.2  2003/03/11 08:09:47  ralproth
# Fixes from Martin Kalmbach
#
# Revision 2.1  2003/03/11 07:59:46  ralproth
# Initial import from Martin's sources
#



# Martin Kalmbach - 10. Juli 2003
echo "LVM/Filesystem Overview. Can be opened and edited by MS Excel."
echo "You can choose then columns:lvname;mountpoint;lvsize;fsoptions(optinal)"
echo "save it as a .csv file and use this file to work with the lvm.sh Script"
echo "by Martin Kalmbach to create a bunch of LVs"
echo "Created on `hostname` / `model` at `date`"
echo "Volume Group ; Logical Volume ; Mountpoint ; LV Capacity/MB ; Filesystem used space/MB"
for LV in `vgdisplay -v 2>/dev/null |awk '$1 == "LV" && $2 == "Name" {print $3}'|sort -u `
do
  VGNAME=`echo $LV | cut -d "/" -f 3 `
  LVNAME=`echo $LV | cut -d "/" -f 4 `
  LVSIZE=`lvdisplay $LV | grep Mbytes |awk '{print $4}'`
  MOUNTP=`mount -v | grep "$LV " | awk '{print $3;}'`
         if [ "$MOUNTP" = "" ] ; then MOUNTP=$(fstyp /dev/$VGNAME/r$LVNAME 2> /dev/null) ; fi
         if [ `swapinfo | grep $LV | wc -l ` = "1" ] ; then MOUNTP="swap" ; fi
         if [ "$MOUNTP" = "" ] ; then MOUNTP="raw" ; fi
  USEDMB=`bdf -l $LV 2>/dev/null|grep -v -e byte |grep \% |grep ^/    |awk '{printf "%d", ($3+1023) / 1024 }'; \
          bdf -l $LV 2>/dev/null|grep -v -e byte |grep \% |grep -v ^/ |awk '{printf "%d", ($2+1023) / 1024 }'`

  #echo "\"$VGNAME\";\"$LVNAME\";\"$MOUNTP\";$LVSIZE;$USEDMB"
  echo "$VGNAME;$LVNAME;$MOUNTP;$LVSIZE;$USEDMB"
done
