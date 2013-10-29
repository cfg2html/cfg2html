#!/usr/bin/ksh
# @(#) $Id: check_elroy.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# must run as root if on live system; if run with "-c", just need
# access to crash dump, which is assumed to be in current directory
#
# $Log: check_elroy.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.11  2012-06-01 18:13:56  ralph
# small typo fixes adn code cleanup, CVS cleanup, added comments etc.
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.12  2008/11/13 20:22:56  ralproth
# cfg4.13: fixes for mywhat utility
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2004/07/15 13:13:44  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2004/07/15 12:13:44  ralproth
# Initial 3.x stream import
#
# Revision 2.2  2004/07/15 12:13:44  ralproth
# more fixes for hpux 10.20
#
# Revision 2.1  2004/03/18 14:23:35  ralproth
# ! Initial Import
# + CheckElroy by MK
#
# ----------------------------------------------------------------------------

# Check, if N or L-Class. martin kalmbach, 2004/03/09

MODEL=`model | cut -c 10`
if [ "$MODEL" = "N" ] || [ "$MODEL" = "L" ]
then
  echo "############################################################### "
  echo "### $MODEL - Class detected : Checking Elroy Revisions ..."
  echo "### `date \"+%d.%m.%Y %H:%M:%S\" ` running on `hostname` (`model`)"
  echo "############################################################### "
else
  echo "### This machine is not an L-Class nor an N-Class."
  echo "### Elroy version check is unnecessary and will be skipped."
  exit 1
fi

arg=""
kern="/stand/vmunix"
core="/dev/kmem"


rel=`uname -r`
if [ "X$rel" = "XB.11.11" ]
then
	typeset -i off=284
elif [ "X$rel" = "XB.11.00" ]
then
	typeset -i off=284
else
	echo "unknown release"
	exit 1
fi

if [ $# -eq 1 ]
then
	if [ $1 = "-c" ]
	then
		arg="-m"
		kern="vmunix"
		core="."
	fi
fi

typeset -i x=`echo gh2p_bridges/2D | adb $arg $kern $core | grep gh2 | awk 'END {print $NF}'`



print ""
print "Elroy Revisions"
print "Elroy Addr  Slot #     Revision"
print "__________  ______     ________"
print ""

while (( x != 0))
do
	y=`echo "0d$x+0d16/2X" | adb $arg $kern $core | grep 0x | awk 'END {print $NF}'`
	print -n "$y  "

	if [ $MODEL = "N" ]
        then
           case "$y" in
		"0xBFFE0000")	print -n "Core IO 0 " ;;
		"0xBFFE2000")	print -n "Core IO 1 " ;;
		"0xBFFEA000")	print -n "Slot 1    " ;;
		"0xBFFE8000")	print -n "Slot 2    " ;;
		"0xBFFF8000")	print -n "Slot 3    " ;;
		"0xBFFF0000")	print -n "Slot 4    " ;;
		"0xBFFF4000")	print -n "Slot 5    " ;;
		"0xBFFE4000")	print -n "Slot 6    " ;;
		"0xFECF8000")  	print -n "Slot 7    " ;;
		"0xFECF4000")   print -n "Slot 8    " ;;
		"0xFECE8000")	print -n "Slot 9    " ;;
		"0xFECE4000")	print -n "Slot 10   " ;;
		"0xFECF0000")	print -n "Slot 11   " ;;
		"0xFECE0000")	print -n "Slot 12   " ;;
		"*")		print -n "Unknown Elroy Version"
				break;;
	   esac
	else
	   case "$y" in
                "0xFED30000")   print -n "Slots 1-2 " ;;
                "0xFED32000")   print -n "Slots 3-6 " ;;
                "0xFED34000")   print -n "Slot 8    " ;;
                "0xFED36000")   print -n "Slot 10   " ;;
                "0xFED38000")   print -n "Slot 12   " ;;
                "0xFED3A000")   print -n "Slot 7    " ;;
                "0xFED3C000")   print -n "Slot 9    " ;;
                "0xFED3E000")   print -n "Slot 11   " ;;
                "*")            print -n "Unknown Elroy Version"
                                break;;
           esac
	fi

        z=`echo "0d$x+0d$off/D" | adb $arg $kern $core | grep ':	' | awk 'END {print $NF}'`
	case $z in
		0)		print "   1.0";;
		1)		print "   2.0";;
		2)		print "   2.1";;
		3)		print "   2.2";;
		4)		print "   3.0";;
		5)		print "   4.0";;
		*)		print "Unknown elroy version";;
	esac
	y=`echo "0d$x/2D" | adb $arg $kern $core | grep '	0	' | awk 'END {print $NF}'`
	x=y
done

  echo "###############################################################"
  echo "### Done checking Elroy Revisions."
  echo "###############################################################"
exit 0

