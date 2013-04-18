##############################################################################
# @(#) $Id: get_fc.sh,v 5.11 2012-06-01 18:13:56 ralph Exp $
##############################################################################
#
# one more suggestion ;-). HPVM 4.3 and vPar 6.1 have new feature – NPIV.
# Virtual HBAs are not handled by fcmsutil command but gvsmgr which looks like
# this:
#
# root@ignt2# gvsdmgr get_info -D  /dev/gvsd0
# PCI Vendor ID                                      : 0x103c
# PCI Device ID                                      : 0x1403
# State of HBA                                       : ONLINE
# Hardware Path                                      : 0/0/2/0
# Max. IO size                                       : 1048576
# Virtual Port WWN                                   : 0x50014c2000000002
# Virtual Node WWN                                   : 0x50014c2800000002
# root@ignt2#
#
# Please consider if the support for NPIV could be included in some future version of cfg2html.
# ----------------------------------------------------------------------------

PATH=$PATH:/opt/fcms/bin        #  13.12.2007, 10:10 modified by Ralph Roth

count=0
# get_fc.sh, Martin Kalmbach / 2003-07-19
if [ `ls /dev/td* /dev/fcd* /dev/fcms* 2>/dev/null | wc -l` != 0 ]
then
  echo "Hardware       Device      N_Port Port"
  echo "Path           File        World Wide Name     State   Topology       Type                Disk-Instances"
  echo "--------------------------------------------------------------------------------------------------------"
else
  echo "No fibrechannel interfaces found"
  exit
fi

for FCDEV in `ls /dev/td* /dev/fcms* /dev/fcd*  2>/dev/null`
do                      # not found
 if [ -r $FCDEV ] && [ `fcmsutil $FCDEV 2>/dev/null |grep -i topo | wc -l` != 0 ]
 then
  TOPOLOGY=`fcmsutil $FCDEV | grep Topology | awk '{ print $3 }'`
  WWN=`fcmsutil $FCDEV | grep "Port World" |grep "N_Port"| awk '{ print $7 }'`
  STATE=`fcmsutil $FCDEV | grep "Driver state" | awk '{ print $4 }'`
  HWPATH=`fcmsutil $FCDEV | grep "Hardware Path" | awk '{ print $5 }'`
  if [ "$HWPATH" = "" ]
     then  # must be an old Tachyon HBA
        FCMSINST=`echo $FCDEV | cut -c 10,11`
        HWPATH=`ioscan -fkClan -I $FCMSINST | head -3 | tail -1 | awk '{ print $3 }' | cut -d "." -f 1`
        TYPE=`ioscan -fkClan -I $FCMSINST | head -3 | tail -1 | awk '{ print $7 "-" $8 "-" $9 }'`
     else  TYPE=`ioscan -fkH $HWPATH | head -3 | tail -1 | awk '{ print $7 "-" $8 "-" $9 }' `
  fi

  DEVINST=""
  for i in `ioscan -fkH$HWPATH | grep ^ext_bus | awk '{ print $2 }'`
  do
    DEVINST="$DEVINST,c$i"
  done
  DEVINST=`echo $DEVINST | cut -c 2-48`
  printf "%-15s%-12s%-20s%-8s%-15s%-20s%-32s\n" \
          $HWPATH $FCDEV $WWN $STATE $TOPOLOGY $TYPE $DEVINST
  count=`expr $count + 1`
 fi
done
echo "# FC Cards: "$count"\n"

##### add here new stuff, e.g. vpd
for FCDEV in `ls /dev/td*  /dev/fcd*   2>/dev/null`
do
   if [ -r $FCDEV ]
   then
	echo "\nAdapter $FCDEV"
	fcmsutil $FCDEV vpd | grep -v ^$
	echo ""
   fi
done

printf "\n"	#  05.04.2005, 16:27 modified by Ralph.Roth 
 
############################################################################
# $Log: get_fc.sh,v $
# Revision 5.11  2012-06-01 18:13:56  ralph
# small typo fixes adn code cleanup, CVS cleanup, added comments etc.
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.12  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2007/12/14 13:16:48  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.13  2007/12/14 13:16:48  ralproth
# 3.52: fixes for HP-UX 11.23/IA64, typo fixes
#
# Revision 3.12  2007/08/02 11:09:10  ralproth
# 3.45: changes for big Superdomes
#
# Revision 3.11  2005/09/23 09:12:21  ralproth
# fixes for ugly warnings
#
# Revision 3.10.1.1  2005/07/14 15:34:27  ralproth
# Initial 3.x stream import
#
# Revision 2.8  2005/07/14 15:34:27  ralproth
# onsite fixes for /dev/fcd* FC devices
#
# Revision 2.6  2005/06/27 06:47:54  ralproth
# fcmsutil vpd (request)
#
# Revision 2.4  2005/03/30 18:58:06  ralproth
# fc/td onsite enhancements
#
# Revision 2.3  2004/10/19 14:10:39  ralproth
# Fixes by Marc Heinrich for new FC cards
#
# Revision 2.2  2003/07/25 12:04:45  ralproth
# Bug fixes by martin
#
# Revision 2.1  2003/07/25 08:42:34  ralproth
# New+updated collectors by Martin Kalmbach
#
############################################################################

