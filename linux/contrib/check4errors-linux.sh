# @(#) $Id: check4errors-linux.sh,v 6.16 2017/08/30 11:31:08 ralph Exp $
# --=---------------------------------------------------------------------=---
# Written and (c) 1997 - 2017 by Ralph Roth  -*- http://rose.rult.at -*-

# Like the check for error script for HP-UX, this script tries to detect some
# errors or system misconfiguration.

LANG=C

/usr/bin/last -xF | egrep "reboot|shutdown|runlevel|system"|tail

if [ -f /etc/sysconfig/kernel ] ; then

      echo "# Missing Kernel Modules"
      sed -e '/^#/d;/^$/d;/^[[:space:]]*$/d' /etc/sysconfig/kernel
      . /etc/sysconfig/kernel

      echo "# Kernel Modules not loaded"
      for i in $INITRD_MODULES $DOMU_INITRD_MODULES $MODULES_LOADED_ON_BOOT
      do
	if ! lsmod | grep"^$i[[:space:]]"&>/dev/null; then
	  echo $i
	fi
      done; echo

fi

# grep_error_patterns
# TODO: refine patterns
F=""multi.*path.*down" "bond.*link.*down" "lpfs.*err" "target.failure" "duplicate.VG" "duplicate.PV" "not.found" "ocfs2.*ERR" "ocfs2.*not.unmounted.cleanly" "reservation.conflict" "tainted" "ERROR""

if [ -r /var/log/messages ]
then
	## we need to fix this for systemd, e.g. SLES12
	for f in $F; do
		echo -n "$f = "
		grep $f /var/log/messages | wc -l
	done
fi

## process without an named owner?

ps -e -o ruser,pid,args | awk ' ($1+1) > 1 {print $0;} '		# changed 20131211 by Ralph Roth


# Linker Cache? # changed 20131219 by Ralph Roth
/sbin/ldconfig -p 2>&1 |grep -v  "/lib" | grep -v "libs found in cache"

# file fragmentation?
# # filefrag *| sort -nr -k 2

# 30.08.2017 - https://www.suse.com/de-de/support/kb/doc/?id=7014344
/sbin/lspci -nn | grep -qE '8086:(340[36].*rev 13|3405.*rev (12|13|22))' && echo "TID 7014344: Interrupt remapping is broken"

## ----------------------------------------------------------------------------- ##

exit 0
