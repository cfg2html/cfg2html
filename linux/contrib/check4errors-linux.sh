# @(#) $Id: check4errors-linux.sh,v 6.19 2021/03/17 13:50:33 ralph Exp $
# $Header: /home/cvs/cfg2html/cfg2html_git/linux/contrib/check4errors-linux.sh,v 6.19 2021/03/17 13:50:33 ralph Exp $
# --=---------------------------------------------------------------------=---
# Written and (c) 1997 - 2021 by Ralph Roth  -*- http://rose.rult.at -*-

# Like the "check for error" script for HP-UX, this script tries to detect some
# errors or system misconfiguration. Must be run as root of course!

LANG=C

## ----------------------------------------------------------------------------- ##
/usr/bin/last -xF | egrep "reboot|shutdown|runlevel|system"|tail

## ----------------------------------------------------------------------------- ##
if [ -f /etc/sysconfig/kernel ]
then
    echo "## Missing Kernel Modules"
    sed -e '/^#/d;/^$/d;/^[[:space:]]*$/d' /etc/sysconfig/kernel
    . /etc/sysconfig/kernel

    echo "## Kernel Modules not loaded"
    for i in $INITRD_MODULES $DOMU_INITRD_MODULES $MODULES_LOADED_ON_BOOT
    do
        if ! lsmod | grep"^$i[[:space:]]"&>/dev/null; then
            echo $i
        fi
    done; echo

fi
echo "## Kernel Modules, out of tree?"
cat /proc/modules |
while read module rest
do
    if [[ $(od -A n /sys/module/$module/taint) != " 000012" ]] ; then
        echo $module":"$(cat /sys/module/$module/taint)
    fi
done

echo "## Grep Patterns"

## ----------------------------------------------------------------------------- ##
# grep_error_patterns
# TODO: refine patterns, new patterns

F=""multi.*path.*down" "bond.*link.*down" "lpfs.*err" "target.failure" "duplicate.VG" "duplicate.PV" \
    "kernel:" "traps:" "not.found" "ocfs2.*ERR" "ocfs2.*not.unmounted.cleanly" "reservation.conflict" \
    " is invalid$" \
    "segfault.at" "deprecated" "not.supported" "systemd.dumpcore" "unavailable" "tainted" "ERROR""

# we could here do also a zgrep - but this signitficantly slows down the script. Your thoughts?

if [ -r /var/log/messages ]
then
  ## we need to fix this for systemd, e.g. SLES12
  for f in ${F}; do
    echo -n "${f} = "
    grep -hi ${f} /var/log/messages /var/log/warn | sort -u | wc -l
  done | grep -v " = 0$"
fi

echo "## Misc./Other Stuff"
## ----------------------------------------------------------------------------- ##
## process without an named owner?
ps -e -o ruser,pid,args | awk ' ($1+1) > 1 {print $0;} '		# changed 20131211 by Ralph Roth

## ----------------------------------------------------------------------------- ##
# Linker Cache? # changed 20131219 by Ralph Roth
/sbin/ldconfig -p 2>&1 |grep -v  "/lib" | grep -v "libs found in cache"

# file fragmentation?
# filefrag *  2>/dev/null  | sort -nr -k 2 | grep -v ": 0 extents found"
## ----------------------------------------------------------------------------- ##
# 30.08.2017 - https://www.suse.com/de-de/support/kb/doc/?id=7014344
/sbin/lspci -nn | grep -qE '8086:(340[36].*rev 13|3405.*rev (12|13|22))' && echo "TID 7014344: Interrupt remapping is broken"

### Debian System and Aptitude installed?
if [ -x /usr/bin/aptitude ]
then
    /usr/bin/aptitude search '~i(!~ODebian)'
fi
echo "## User, Groups"
## ----------------------------------------------------------------------------- ##
## Read-Only group and user checks
pwck -r
grpck -r
## ----------------------------------------------------------------------------- ##

exit 0
