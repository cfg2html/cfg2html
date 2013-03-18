# @(#) $Id: crontab_collect.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# Jeff Mikaelian - LBDIS Beoing
# crontab for cfg2html (HPUX), Ralph Roth
#
# $Log: crontab_collect.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2004/11/17 11:39:42  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2004/11/17 11:39:41  ralproth
# Initial 3.x stream import
#
# Revision 2.2  2004/11/17 11:39:41  ralproth
# Enhanced cron collector
#
# Revision 2.1.1.1  2003/01/21 10:33:32  ralproth
# Import from HPUX to cygwin
#
# Revision 1.5  2002/11/20 11:44:04  ralproth
# Changes for proper WinCVS function
#
# Revision 1.4  2001/08/23 15:09:38  root
# added AT scheduler, removed lines with remarks from the crontab
#
# Revision 1.3  2001/08/23  14:58:27  14:58:27  root (Guru Ralph)
# workaround for HPUX 10.xx (10.20)
# 
# Revision 1.2  2001/04/18  14:49:30  14:49:30  root (Guru Ralph)
# working (initial) version for cfg2html
# 

CRON_PATH=/var/spool/cron/crontabs
for i in `ls $CRON_PATH`; do

     echo "\n-=[ Crontab entry for user $i ]=-\n"
     # crontab -l $i	# does not work with HPUX 10.xx
     cat $CRON_PATH/$i | grep -v ^#

done ; 

echo '\nCurrently with at scheduled jobs\n';
at -l


echo "\nLast crontab logs:"
tail /var/adm/cron/log

echo "\nCron allow:"
cat /var/adm/cron/cron.allow
echo "\nAt allow:"
cat /var/adm/cron/at.allow
