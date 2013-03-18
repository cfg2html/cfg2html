#!/sbin/sh
# @(#) $Id: get_bootdisk.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# by Thomas Brix - works only with HPUX 11i v2 and above!!!
# not used in cfg2html yet!

lssf $(ls -l /dev/d*sk/* | grep $(echo "bootdev/x" | \
adb /stand/vmunix /dev/kmem | grep 0x | \
sed 's/0x..//') | head -1 | awk '{print $NF}') | \
awk '{print "This system last booted from " $NF " " $(NF-1)}'
