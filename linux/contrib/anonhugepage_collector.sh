# @(#) $Id: anonhugepage_collector.sh,v 6.2 2018/03/02 06:17:45 ralph Exp $
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4
# atom:set fileencoding=utf8 fileformat=unix filetype=shell tabstop=2 expandtab:
# -*- coding: utf-8 -*- http://rose.rult.at/ - Ralph Roth

# Collector that shows all processes that had allocated anon huge pages

echo "THP/Huge Pages Overview (/proc/meminfo)"
grep Huge /proc/meminfo
echo ""
echo "THP/Huge Pages Overview - Status"
cat /sys/kernel/mm/transparent_hugepage/enabled

echo ""
echo "Processes that uses anon huge pages:"
echo "kb  (PID)  program + command line"

for FILE in /proc/*/smaps
do
  if [ -r $FILE ]
  then
    # we must sum them up, for each memory region
    KBAM=$(grep AnonHugePages $FILE| awk '{ sum += $2; } END { if (sum > 0) {printf ("%d", sum+0);} }' );
    PID=$(echo $FILE|cut -f3 -d/)

    # maybe /proc/$PID/numa_maps is useful for further details??
    if [ "$KBAM" != "" ]
    then
      echo $KBAM"  ("$PID") " $(cat /proc/$PID/cmdline)
    fi
  fi # vanished meanwhile?
done | sort -nr | awk ' { sum += $1; print $0; } END { printf "\n%d kb total anon huge pages\n", sum } '
# the sum calculated with awk and the one from meminfo should be EQUAL!

# on a SLES11SP3/64 box this looks like:
#
# THP/Huge Pages Overview (/proc/meminfo)
# AnonHugePages:    280576 kB
# HugePages_Total:       0
# HugePages_Free:        0
# HugePages_Rsvd:        0
# HugePages_Surp:        0
# Hugepagesize:       2048 kB
#
# Processes that uses anon huge pages:
# 202752  (10265)  /usr/lib64/firefox/firefox
# 38912  (8950)  /usr/sbin/mysqld--basedir=/usr--datadir=/var/lib/mysql--plugin-dir=/usr/lib64/mysql/plugin--user=mysql--log-error=/var/log/mysql/mysqld.log--pid-file=/var/run/mysql/mysqld.pid--socket=/var/lib/mysql/mysql.sock--port=3306
# 32768  (8034)  /usr/bin/X:0-br-verbose-auth/var/run/gdm/auth-for-gdm-v1f5Th/database-nolistentcpvt7
# 4096  (9318)  python/usr/lib64/python2.6/site-packages/system-config-printer/applet.py
# 2048  (6228)  /sbin/haveged-w1024-v1
#
# 280576 kb total anon huge pages
