# @(#) $Id: get_hpvm.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# Martin Kalmbach, 29.10.2008
# ---------------------------------------------------------------------------
# hpvm.sh lists all VMs
# hpvm.sh <VMNames> lists only the specified VMs


PATH=$PATH:/opt/hpvm/bin
TMPDIR=/tmp
VMS=$*
if [ "a.$VMS" = a. ] ; then  VMS=`hpvmstatus   | grep -v -e "Virtual Machine" -e "=====" | awk '{print $1}'`; fi
for i in $VMS
do
  echo "================================================================================"
  hpvmstatus | head -2 | tail -1
  hpvmstatus | grep $i
  echo "Autorun=`hpvmstatus -P $i -V | grep \"Start type\" | awk '{print $4}'`"
  hpvmstatus -P $i    > $TMPDIR/$i.thisboot
  hpvmstatus -P $i -D > $TMPDIR/$i.nextboot
  if (diff $TMPDIR/$i.thisboot $TMPDIR/$i.nextboot >/dev/null 2>&1)
  then
    tu=nix
  else
    echo "  * Parameter Change at next Boot: `diff $TMPDIR/$i.thisboot $TMPDIR/$i.nextboot | grep \>`"
  fi
  rm $TMPDIR/$i.thisboot $TMPDIR/$i.nextboot >/dev/null 2>&1
  hpvmstatus -P $i -d | grep -e network -e disk
done

# ---------------------------------------------------------------------------
# $Log: get_hpvm.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.3  2010-08-17 03:57:57  ralproth
# cfg4.84-24814: added Logs cvs keyword
#
