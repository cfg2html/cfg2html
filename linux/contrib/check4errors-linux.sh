# @(#) $Id: check4errors-linux.sh,v 1.7 2013/12/20 13:00:17 ralph Exp $
# --=---------------------------------------------------------------------=---
# Written and (c) 1997 - 2013 by Ralph Roth  -*- http://rose.rult.at -*-

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
for f in $F; do
        echo -n "$f = "
        grep $f /var/log/messages | wc -l
done

## process without an named owner?

ps -e -o ruser,pid,args | awk ' ($1+1) > 1 {print $0;} '		# changed 20131211 by Ralph Roth


# Linker Cache? # changed 20131219 by Ralph Roth
ldconfig -p 2>&1 |grep -v  "/lib" | grep -v "libs found in cache"


## ----------------------------------------------------------------------------- ##

exit 0
