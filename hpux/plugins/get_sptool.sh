#!/sbin/sh
# @(#) $Id: get_sptool.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
########################################################################
# Martin Kalmbach, HP
# Version 1.0, 2003-08-14  (sptool.sh)
# Discoverd 13.02.2004 by Ralph on Martin's EVA CD and renamed to get_sptools.sh
########################################################################
# $Log: get_sptool.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.12  2008/11/13 19:53:44  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2004/02/16 09:33:50  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2004/02/16 09:33:50  ralproth
# Initial 3.x stream import
#
# Revision 2.1  2004/02/16 09:33:50  ralproth
# Added new files...
#
#

NUMBEREVAS=`spmgr display -r | grep Storage | wc -l`
NUMBERHBAS=`spmgr display -a -v |grep -e td -e fc | wc -l`
EVA=`spmgr display -r | grep Storage  |awk '{print $2}' `
LOADBALANCING=`spmgr display -r -v | grep Balance |awk '{print $3}'`
CONTROLLER1=`spmgr display -c -v | grep Controller |awk '{print $2}' | head -1`
CONTROLLER2=`spmgr display -c -v | grep Controller |awk '{print $2}' | tail -1`
HBA1=`spmgr display -a -v |grep -e td -e fc |awk '{print $1}' | head -1`
HBA2=`spmgr display -a -v |grep -e td -e fc |awk '{print $1}' | tail -1`

echo "# Number of EVAs : $NUMBEREVAS"
echo "# Number of HBAs : $NUMBERHBAS"
echo "# EVA WWN        : $EVA"
echo "# Controller 1   : $CONTROLLER1"
echo "# Controller 2   : $CONTROLLER2"
echo "# Loadbalancing  : $LOADBALANCING"

i=1
for SPDEVICE in `spmgr display -d -v | grep Device |awk '{print $2}'`
do
case $i in
   1)
    ACTIVE_CONTROLLER=$CONTROLLER1
    ACTIVE_HBA=$HBA1
   ;;

   2)
    ACTIVE_CONTROLLER=$CONTROLLER2
    ACTIVE_HBA=$HBA1
   ;;

   3)
    ACTIVE_CONTROLLER=$CONTROLLER1
    ACTIVE_HBA=$HBA2
   ;;

   4)
    ACTIVE_CONTROLLER=$CONTROLLER2
    ACTIVE_HBA=$HBA2
    i=0
   ;;

esac

case $1 in
   mix)
       echo "# $SPDEVICE $i is set to active Controller $ACTIVE_CONTROLLER on HBA $ACTIVE_HBA."
       spmgr select -c $ACTIVE_CONTROLLER -d $SPDEVICE
       spmgr select -a $ACTIVE_HBA -d $SPDEVICE
   ;;

   *)
       echo "# $SPDEVICE $i would be set to active Controller $ACTIVE_CONTROLLER on HBA $ACTIVE_HBA."
   ;;
esac

  ((i=i+1))

done

echo "# Don't forget to run spmgr update if changes were made."
