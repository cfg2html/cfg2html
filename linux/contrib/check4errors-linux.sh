# @(#) $Id: check4errors-linux.sh,v 6.10.1.1 2013-09-12 16:13:19 ralph Exp $
# --=---------------------------------------------------------------------=---
# (c) 1997 - 2013 by Ralph Roth  -*- http://rose.rult.at -*-

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

