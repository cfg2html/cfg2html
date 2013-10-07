#!/usr/bin/sh
# on HP-UX this is /usr/bin/sh  not /bin/sh
# set -vx
###############################################################################
# HP-UX security script, checks if some systems areas have warnings/errors
# should NOT print any warning if everything is fine on your system.
# Written to quick check the health of your systems.
# (c) by Ralph Roth // http://rose.rult.at
###############################################################################
# @(#) $Id: check_errors_hpux.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# svn.446/624 backport
###############################################################################
# $Log: check_errors_hpux.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.16  2013-02-09 10:24:35  ralph
# replaced defect come.to redirector with rose.rult.at
#
# Revision 5.15  2012-02-15 09:11:02  ralproth
# cfg5.25-32078: CRLF/DOS fix, shebang=/usr/bin/sh fix
#
# Revision 5.14  2011-12-28 09:33:26  ralproth
# Fix for buggy? (e)grep on HPUX
#
# Revision 5.13  2011-11-24 13:21:44  ralproth
# cfg5.22-32061: fix4lvmpvg
#
# Revision 5.12  2011-11-22 16:11:11  ralproth
# cfg5.21-32059: LVM & Ignite/UX problems/checks
#
# Revision 5.10.1.1  2011-02-15 14:29:04  ralproth
# Initial 5.xx import
# ---------------------------------------------------------------------------
# Revision 4.53  2011-02-03 08:54:23  ralproth
# Revision 4.30  2009-08-03 14:19:42  ralproth
# Revision 4.11  2008/11/13 13:27:51  ralproth
# ---------------------------------------------------------------------------
# Revision 3.34  2008/10/14 14:12:37  ralproth
# Revision 3.16  2007/04/20 08:13:35  ralproth
# Revision 3.10  2004/09/13 11:32:00  ralproth
# ---------------------------------------------------------------------------
# Revision 2.10  2004/09/13 11:32:00  ralproth
# ---------------------------------------------------------------------------
# Revision 1.10  2002/12/04 14:23:32  ralproth
# Revision 1.3   2001/09/25 15:28:41  ralproth,  hpux 10.xx
# ---------------------------------------------------------------------------

PATH=$PATH:/usr/contrib/bin/    ## show_patches

line()
{
        echo "#####  "$1"  ##########################################################################" | cut -c1-77
}

echo "# Check4Errors: \$Id: check_errors_hpux.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $"

[ $(id -u) -ne 0 ] && (echo YOU are not ROOT!; exit 1) # root-check

logger -t check4err"["$$"]"  "Start of shell script: \$Id: check_errors_hpux.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $"
MAD=$(ps -ef | grep mad | grep -v grep) ## runs the mad daemon at all?
if [ -n "$MAD" ]
then
        echo "# \c"
        [ -x /opt/hpservices/RemoteSupport/bin/iseeConnectivityTest.sh ] && /opt/hpservices/RemoteSupport/bin/iseeConnectivityTest.sh	#  06.03.2007, 14:11 modified by Ralph Roth
        echo "\n"
else
        # [ -x /etc/opt/resmon/lbin/send_test_event ] && /etc/opt/resmon/lbin/send_test_event -v disk_em  2> /dev/null      # 06. Apr. 2009 - 10:55
        :
fi

# Check if SFMIndicationProvider ist working properly, send a test event with
# /opt/sfm/bin/sfmconfig -t -m
# /opt/sfm/bin/sfmconfig -t -p

echo "# -------------------------------------------------------------------------"
echo "# When running this utility you shouldn't get any output below this line!"
echo "# You should only see lines with hashes, if not carefully check the output" 
echo "# and fix it! This script needs several minutes to perform it checks, so"
echo "# don't get nervous :)"
echo "# You can filter the output of this script with the command:"
echo "#    $0 | grep -v -E '^#|^$'"
echo "# -------------------------------------------------------------------------"
echo "# "$(uname -a)
echo "# "$(uptime)
# This setting is for a ME10/CAD/Samba fileserver
# set -A MONITOR_PROCESSES pdmserver oninit smbd MEls flexlm nfsd diagmond

# big hpux 11i server, also ripped from HP OVO monitor :)
# bootpd 
# mad => 11.31 not default installed.... already check by ISEE check.
set -A MONITOR_PROCESSES "envd nfsd registrar diagmond diaglogd cron rpcd inetd midaemon vxfsd lvmkd swagentd syslogd" # smbd
export CHECK_MAIL=1		# set to ZERO to disable checking for email


echo "# "$(hostname)": number of installed patches = "$(show_patches | grep "^  PH" | wc -l)

###############################################################################
# Function: monitor_processes
#
# Monitor the processes by making sure that all required processes are
# running.
###############################################################################
#
# Seems that monitor_process doesn't work under HPUX 11i! HPUX 10.20/11.00
# works without any problems.

monitor_processes()		# removed function, rar 29.11.01
{
    typeset -i n=0
    
    for i in ${MONITOR_PROCESSES[@]}
    do
        MONITOR_PROCESSES_PID[$n]=`ps -ef | grep -v grep| awk '/'${i}'/{ print $2 }'`
        if [[ ${MONITOR_PROCESSES_PID[$n]} = "" ]]
        then
            print "*** Monitored process = ${i} has failed  ***"
        fi
        (( n = n + 1 ))
    done
}

### Check Hardware for defects if parstatus is available ####
### Example output: nPar status: cabinet:0:4cellslot:21/0/N+:6/0/N+:5/1/N+:-:Active

Check_ParStatus()
{
    if [ -x /usr/sbin/parstatus ]
    then if [ -r /opt/wbem/lib/libpegclient.1 ] # fix for /hzd_admin/admin/check_errors_hpux.sh[4]: 6092 Killed
                                                # swlist -l file | grep libpegclient.1
                                                # WBEMServices.WBEM-CORE: /opt/wbem/lib/libpegclient.1
    then
        /usr/sbin/parstatus -s 2> /dev/null    
        if [ $? -eq 0 ]
        then
            PARST="nPar status: "$(/usr/sbin/parstatus -BM|tr -d " ") ## tr fix for B.11.11.01.04.01.01 nPartition Provider - HP-UX
            echo $PARST|grep -v "/0/"
            echo $PARST|grep -e "/N-" -e "/1/" -e "/2/"
        fi        
    fi
    fi
}
######################################################### monitor #######

line "processes"
monitor_processes


for i in crlog cron syslogd swagentd prole      # some stuff is customer specific :-)
do
      if  [ -r /sbin/init.d/$i ] 
      then 
        [ -x /sbin/init.d/$i ] || echo "MP:  RC script /sbin/init.d/$i is NOT executable!"
        RUN=$(ps -ef | grep $i | grep -v grep)
        if [ -z "$RUN" ] 
        then 
                echo "Monitor Processes:  Process $i is NOT running - started via RC from /sbin/init.d"
        fi        
      fi  
done

######################################################### LVM/VG/Disk ###

line "LVM"
(vgdisplay -v | grep stale ) 2> /dev/null	# added 23.07.2003 by Ralph Roth
# | grep -v -e "Volume group not activated" -e "Cannot display volume group"

lvg=$(vgdisplay -v 2> /dev/null |grep "LV Name"| awk '{ print $3; }')
for i in $lvg
do
	lvdisplay $i | grep -e stale -e PX_NOPV	| uniq | head	# PHKL_30697++/11.11 -> PHKL_35970
done

for ptab in /etc/lvmtab*
do
    echo "# $ptab"
    for i in $(strings $ptab  |grep ^/dev/d)          # lvmtab_p = HPUX 11.31!
    do
            pvdisplay $i  2> /dev/null  | grep stale | uniq | head
    done
done
# Hints for Trouble Shooting
# 
# /root # pvdisplay -v /dev/dsk/c4t6d0| grep stale | wc -l
# 3241
# lvsnyc -> OK? -> vgsync

## LVM & Ignite/UX problems/checks, #  22.11.2011, 17:09 modified by Ralph Roth #* rar *#
[ -r /etc/lvmpvg ] && grep -E "/rdsk|/rdisk" /etc/lvmpvg
[ -x /opt/ignite/lbin/list_expander ] && /opt/ignite/lbin/list_expander > /dev/null

######################################################### syslogd #######

line syslogd
#### SYSLOG.LOG ####
grep -e "POWERFAIL" -e "vx_nospace" -e "file system full" -e Detached \
     -e PX_NOVG -e "file system error" -e "marked bad" -e Wrong \
     -e "vmunix: WARNING:" -e "vmunix: NFS server" -e "SCSI: Reset"  \
     -e "NFS fsstat failed" -e "ERROR:" -e "Error:" -e failure \
     -e "EMS Event Notification" -e "syntax error" -e "vulnerable"  \
     -e "daemon crash" -e "critical" -e "FAILURE" -e "Dead" \
     -e "loss of power would not" -e "Recovered Path" -e faulty \
     -e "POSSIBLE BREAK-IN ATTEMPT" -e Unlicensed -e UNCLAIMED \
     -e "DIAGNOSTIC SYSTEM WARNING"  -e Failure -e Failed \
     -e "out of usable memory" -e "Wrong Disk" -e OVERTEMP_ -e FANFAIL_ \
	/var/adm/syslog/syslog.log | \
   grep -v -e "Authentication failed for " -e "/storage/events/tapes/SCSI_tape/" \
        -e "driver atdd" -e "pam_authenticate" | sort -u

## catch all Veritas errors from the syslog
grep msgcnt /var/adm/syslog/syslog.log | grep "V-2-" | grep vxfs | grep -v vx_nospace | sort -u 	## -e "I/O error"

# -> #4616044269 
# grep the syslog for corrupted class/Target entries

grep vmunix: /var/adm/syslog/syslog.log | grep -v -E "Target|assigned|configuration|instance|class|device|Synchronous" \
 | grep -v "vmunix: $" | grep -e "c.*l.*a.*s.*s.*:" -e "T.*a.*r.*g.*e.*t.*:" 

line "ioscan, hardware"
## unclaimed hardware? #  17.04.2007, 12:34 modified by Ralph Roth
#  The result of software binding.
# 
#                           CLAIMED        software bound successfully
#                           UNCLAIMED      no associated software found
#                           SUSPENDED      associated software and hardware is
#                                          in suspended state
#                           DIFF_HW        software found does not match the
#                                          associated software
#                           NO_HW          the hardware at this address is no
#                                          longer responding
#                           ERROR          the hardware at this address is
#                                          responding but is in an error state
#                           SCAN           node locked, try again later

# on SD vcn/vcs can have NO_HW
ioscan -f|tail +4 |grep -v " CLAIMED" |grep -v "Virtual Console"  #  12.07.2007, 18:21 modified by Ralph Roth

# unhealth stuff? suggested by thomas brix #  22.7.2010, 15:28  Ralph Roth
ioscan -P health 2> /dev/null | grep -v -e N/A -e online -e ^Class | grep / |sort -u  |grep -v standby  # only 11.31 #  01.02.2011, 18:21 modified by Ralph Roth
# lan         12  0/0/14/1/0/6/1  offline
# lunpath    294  0/0/12/1/0/4/0.0x5006016944602d75.0x4001000000000000  standby

# disk     57  64000/0xfa00/0x12   esdisk  CLAIMED     DEVICE       limited  DGC     CX3-40fWDR5
# disk     60  64000/0xfa00/0x15   esdisk  CLAIMED     DEVICE       limited  DGC     CX3-40fWDR5
# disk     64  64000/0xfa00/0x19   esdisk  CLAIMED     DEVICE       limited  DGC     CX3-40fWDR5
# tape     34  64000/0xfa00/0x1c   atdd    CLAIMED     DEVICE       limited  IBM     03592E05
# autoch    4  64000/0xfa00/0x348  eschgr  CLAIMED     DEVICE       offline  IBM     03584L22
ioscan -m lun 2>/dev/null |grep CLAIMED|grep -v online            #  12.07.2010, 16:28  Ralph Roth, HPUX 11.31+++
 
## HPUX 11.11
# ---------------------------------------------------------------------------
# /opt/sfm/bin/sfmconfig: illegal option -- w
# sfmconfig { -c | -m | -a | -r | -h }
#  -c configchange
#  -m fmdcontrol
#  -a setstatus
#  -r refreshcache
#  -h help

#        Unknown | Memory
#          Minor | Network Information
if [ -x /opt/propplus/bin/cprop ]
then    #  30.06.2010, 08:26 modified by Ralph Roth
        /opt/propplus/bin/cprop -list |grep " \| " | grep -v -E "STATUS | No status | Normal "
fi

if [ -x /opt/sfm/bin/evweb ]
then    # 11.23 ++! #  15.4.2009, 13:33  Ralph Roth
        /opt/sfm/bin/evweb eventviewer -L|grep Critical
        /opt/sfm/bin/sfmconfig -m list| grep "Filter Type"|grep -v "HP Def"
fi

if [ -x /opt/sfm/bin/sfmconfig ]
then
        if hp-pa 
        then
                echo "# sfmconfig for SFM on HP-PA not checked!"
        else
                (/opt/sfm/bin/sfmconfig -w -q | grep -v "SysFaultMgmt is monitoring devices")
        fi                
        /opt/sfm/bin/sfmconfig -a -L | grep -v -E ' OK|Caption |^$'
fi 
Check_ParStatus

######################################################### mail ##########
line "misc. stuff"
[ "$CHECK_MAIL" = 1 ] && (grep -e "Can't create output" \
	/var/adm/syslog/mail.log|uniq)

grep ".cf file is out of date" /var/adm/syslog/mail.log | tail                          # sr by wj #  11.09.2004, 19:39 modified by Ralph.Roth
grep -e MCA -e panic /etc/shutdownlog | grep -E '2009|2010|2011|2012'              # HPMC etc.??? 13.05.2008, 18:23, rr
grep "init:2:initdefault:" /etc/inittab
grep "init:1:initdefault:" /etc/inittab

#         ________________________________________________________________
#          |State              | State Description                         |
#          |___________________|___________________________________________|
#          |NORMAL             | Within normal operating temperature range |
#          |                   |                                           |
#          |OVERTEMP_CRIT      | Temperature has exceeded the normal       |
#          |                   | operating range of the system, but is     |
#          |                   | still within the operating limit of the   |
#          |                   | hardware media.                           |
#          |                   |                                           |
#          |OVERTEMP_EMERG     | Temperature has exceeded the maximum      |
#          |                   | specified operating limit of hardware     |
#          |                   | media; power loss is imminent.  A minimum |
#          |                   | of about 60 seconds is guaranteed between |
#          |                   | the OVERTEMP_MID state and the            |
#          |                   | OVERTEMP_POWERLOSS (power loss) state.    |
#          |                   |                                           |
#          |OVERTEMP_POWERLOSS | Hardware will disconnect all power from   |
#          |                   | all cards in the system chassis.          |
#          |                   |                                           |
#          |FAN_NORMAL         | All chassis fans are operating normally.  |
#          |                   |                                           |
#          |FANFAIL_CRIT       | One or more chassis fans have failed, but |
#          |                   | the system has enough redundant fans to   |
#          |                   | allow continued operation while the       |
#          |                   | failed fans are replaced.                 |
#          |                   |                                           |
#          |FANFAIL_EMERG      | Chassis fan failures prevent continued    |
#          |                   | operation of the system; power loss is    |
#          |                   | imminent.                                 |
#          |                   |                                           |
#          |FANFAIL_POWERLOSS  | Hardware will disconnect all power from   |
#          |                   | all cards in the system chassis.          |
#          |                   |                                           |
#          |___________________|___________________________________________|
# 

# /etc/envd.conf, 26.06.2008, 11:59, rr - recommended setup properly configured?
grep -e _CRIT: -e _EMERG: /etc/envd.conf|grep -v ^# | grep -v :y$

[ -d /etc/cmcluster ] && find /etc/cmcluster| grep debug$                        # SAP Serviceguard debug modus?  apache.debug

if [ -x /usr/sbin/cmgetconf ]
then
  if (cmviewcl -l cluster | grep -q up)
  then 
     TMPF=$(mktemp)
     (/usr/sbin/cmgetconf > /dev/null 2> $TMPF)
     grep -v -e pvcreate $TMPF
     rm $TMPF 
  fi 
fi      
# Serviceguard Mismatches? stderr redirect needs work!

###################################################### TimeZone #########
# PHCO_39174 # 11.31 tztab(4) cumulative patch

grep ^$TZ /usr/lib/tztab > /dev/null || echo "TimeZone $TZ not found in /usr/lib/tztab!"
#  01.02.2011, 18:22 modified by Ralph Roth
grep 2038 /usr/lib/tztab > /dev/null || echo "Entries for year 2038 not found in /usr/lib/tztab!"

############ /stand/bootconf ############################################
# cat bootcheck.sh
if [ ! -r /stand/bootconf ]
then
        echo "WARNING: /stand/bootconf is missing!"
else
        for BOOTDEV in $(cat /stand/bootconf | awk '{ print $2;}')
        do
                if [ ! -z "$BOOTDEV" ]
                then
                        lvlnboot -v 2>/dev/null | grep -q $BOOTDEV
                        if [ $? -ne 0 ]
                        then
                                echo "/stand/bootconf mismatch, devicefile=$BOOTDEV"
                        fi
                else
                        echo "Wrong line in /stand/bootconf $BOOTDEV"
                fi
        done
        for BOOTDEV in $(lvlnboot -v  2> /dev/null| grep /dev/d | grep "Boot Disk" |  awk '{ print $1; }')
        do
                grep -q $BOOTDEV /stand/bootconf || echo "Physical device $BOOTDEV is missing in /stand/bootconf"
        done
        
        ## additional check for vparinit..... #  21.1.2009, 13:03  Ralph Roth
        BCALL=$(cat /stand/bootconf|wc -l)
        BCGREP=$(cat /stand/bootconf|grep ^l |wc -l)
        if [ $BCALL -ne $BCGREP ]
        then
                echo "/stand/bootconf contains $BCALL lines versus $BCGREP 'l /device' lines - that may confuse /sbin/init.d/vparinit!"
        fi
        if [ $BCGREP -lt 1 ]
        then
                echo "/stand/bootconf does not contain 'l /device' entries"
        fi        
fi

##########################################################################

line Software

grep -E "Memory fault|coredump" /var/adm/sw/swagent.log
echo "# Software filesets: different versions installed"

# useful for SFM/FIPS/SSL/mega diag bundle stuff.... 
# the P0wer 0f AWK arrayz rulez :-))
swlist -l fileset |  awk \
'/^# / { a[$2]++; v[$2] = v[$2]"/"$3; }
END { for (i in a) { if (a[i] > 1) print i, "\t" v[i]"/" ;} }'

# 2* NFS /B.11.31.04/B.11.31.06.01/
# 2* SysMgmtHomepage /A.2.2.9/A.3.0.1/
# 2* HPOvLcore /6.10.000/3.10.000/

echo "# Corrupted software or not correct installed"
swlist -a state  -l fileset | grep -v -e configured -e ^#
swverify \* > /dev/null | grep -e WARNING: -e ERROR: 
 
[ -x /usr/contrib/bin/check_patches ] && echo "# Hint: Launch /usr/contrib/bin/check_patches to check your patch status!"
 
#### rc.log ##############################################################

line "/etc/rc.log"
# { changed/added 26.02.2004 (10:38) by Ralph Roth } - some cu have error.txt files in /tmp
# uniq because of tons of TSM/Tivolit atdd messages :-()
grep -i -e "Error:" -e Failed -e Usage -e "returned exit code" -e unable -e "WARNING" -e "not found." /etc/rc.log | uniq  

#########################################################################
#### ISEE, mad.log, rr - 18.04.2004, Mittwoch, 29. Oktober 2008
if [ -r /opt/hpservices/etc/hpservices.conf -a -n "$MAD" ]      ## $MAD is set if MAD daemon is running ....
then
    line "ISEE" # OBSOLETE!!! 14. Okt. 2009 - 12:48
    
    # set up environment
    . /opt/hpservices/etc/hpservices.conf
    # START_TUNER=1 ?
    
    [ "$START_TUNER" -eq 1 -a -r /opt/hpservices/log/mad.log ] && grep -i ERROR /opt/hpservices/log/mad.log | uniq|tail -8 # rar, 040704
    # NOTE:     hpservices is stopped//hpservices is running
    [ "$START_TUNER" -eq 1 -a -x /sbin/init.d/hpservices ] && (/sbin/init.d/hpservices status | grep -v running)
fi

#-# 09. Mrz. 2010 - 21:22 #-#
if [ -d /usr/sap/*/*/work ]
then
        line "SAP"
        grep -i -E "error|fatal" /usr/sap/*/*/work/std_server0.out 2> /dev/null
fi

##### files that doesnt belong to a user or group
line "wrong user ids and groups"
# stuff from CIS benchmark 1.4.2
echo "# logins/groups (1)"
/usr/sbin/logins -p -d          # -p   Display logins with no passwords
/usr/sbin/logins -p             # -d   Display logins with duplicate UIDs
cut -f3 -d: /etc/passwd | sort -n | uniq -c| awk '!/ 1 / { print $2; }' # dito
cut -f3 -d: /etc/group | sort -n | uniq -c| awk '!/ 1 / { print $2; }' # dito
/usr/sbin/logins -d | grep ' 0 '

echo "# passwd/pwconv (2)"
grep '^+:' /etc/passwd /etc/group
[ -x /usr/sbin/pwconv ] && /usr/sbin/pwconv -tv

line "Access Security"
logins -ox | cut -f6 -d":" | while read h
do
    for file in "$h/.netrc" "$h/.rhosts" "$h/.shosts"
       do
           if [ -f "$file" ]
           then 
               echo "Security issue: $file exists!"
           fi
       done
       if [ ! -d "$h" ] 
       then
            echo "## No home dir: $h"  ## remove if needed!
            :
       fi
done
line "unowned files"
find -L / -nouser -nogroup 2> /dev/null  | grep -v -E '/opt/VRTSob/jre/|/opt/tivoli/tsm/|/sapsoftware/|_admin/'
# grep/egrep funktioniert hie rnicht mit ^ ReEx -- Hint: Günther Wiehlmann #  28.12.2011, 10:28 modified by Ralph Roth #* rar *#
# <+>  11.03.2008, 1147 -  Ralph Roth ## -L = 18.5.2009, 10:11  Ralph Roth

###################################################### end ##############
line "end of check4errors"
logger -t check4err"["$$"]"  "End of shell script: \$Id: check_errors_hpux.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $"

### optional to add in future release
# ---------------------------------------------------------------------------
# registrar stream tcp6 nowait root /etc/opt/resmon/lbin/registrar /etc/opt/resmon/lbin/registrar
#
# grep registrar /etc/inetd.conf|grep tcp
# v1: tcp
# v2,v3: tcp6
#
# cleanup -s
#
# /var/opt/resmon/log/event.log


## 11.31
# ---------------------------------------------------------------------------
# insf -s
# ioscan -s

#
# cstm>BUBU<<-EOF
# runutil logtool
# rs
# EOF
#
 
# --------------------------------------------------------------------------- 
# merge of subversion:
# r628 | rothra | 2009-11-19 12:30:13 +0100 (Thu, 19 Nov 2009) | 1 line
# r624 | rothra | 2009-11-09 14:09:43 +0100 (Mon, 09 Nov 2009) | 1 line
# r623 | rothra | 2009-11-03 19:45:53 +0100 (Tue, 03 Nov 2009) | 1 line
# r617 | rothra | 2009-10-19 11:41:13 +0200 (Mon, 19 Oct 2009) | 1 line
# r609 | rothra | 2009-09-15 11:28:36 +0200 (Tue, 15 Sep 2009) | 1 line
# r588 | rothra | 2009-08-12 10:41:49 +0200 (Wed, 12 Aug 2009) | 1 line
# r583 | rothra | 2009-07-22 07:55:16 +0200 (Wed, 22 Jul 2009) | 1 line
# r568 | rothra | 2009-05-29 09:12:26 +0200 (Fri, 29 May 2009) | 1 line
# r567 | rothra | 2009-05-26 15:00:37 +0200 (Tue, 26 May 2009) | 1 line
# r561 | rothra | 2009-05-18 10:25:18 +0200 (Mon, 18 May 2009) | 1 line
# r555 | rothra | 2009-04-21 16:27:41 +0200 (Tue, 21 Apr 2009) | 1 line
# r554 | rothra | 2009-04-21 13:20:40 +0200 (Tue, 21 Apr 2009) | 1 line
# r553 | rothra | 2009-04-17 11:23:17 +0200 (Fri, 17 Apr 2009) | 1 line
# r552 | rothra | 2009-04-16 13:55:00 +0200 (Thu, 16 Apr 2009) | 1 line
# r550 | rothra | 2009-04-15 15:12:04 +0200 (Wed, 15 Apr 2009) | 1 line
# r540 | rothra | 2009-04-06 17:06:08 +0200 (Mon, 06 Apr 2009) | 3 lines
# r537 | rothra | 2009-04-03 08:53:35 +0200 (Fri, 03 Apr 2009) | 1 line
# r505 | rothra | 2009-02-17 09:25:38 +0100 (Tue, 17 Feb 2009) | 1 line
# r495 | rothra | 2009-01-21 13:58:11 +0100 (Wed, 21 Jan 2009) | 1 line
# r490 | rothra | 2009-01-14 10:15:49 +0100 (Wed, 14 Jan 2009) | 1 line
# r487 | rothra | 2009-01-13 13:41:43 +0100 (Tue, 13 Jan 2009) | 1 line
# r479 | rothra | 2009-01-05 11:16:09 +0100 (Mon, 05 Jan 2009) | 1 line
# r463 | rothra | 2008-12-19 10:51:50 +0100 (Fri, 19 Dec 2008) | 1 line
# r457 | rothra | 2008-11-25 20:16:12 +0100 (Tue, 25 Nov 2008) | 1 line
# r446 | rothra | 2008-11-19 10:40:39 +0100 (Wed, 19 Nov 2008) | 1 line
# r440 | rothra | 2008-11-17 10:42:50 +0100 (Mon, 17 Nov 2008) | 1 line
# r432 | rothra | 2008-11-13 16:24:13 +0100 (Thu, 13 Nov 2008) | 1 line
# r411 | rothra | 2008-10-29 15:54:18 +0100 (Wed, 29 Oct 2008) | 1 line
# r390 | rothra | 2008-10-15 14:42:44 +0200 (Wed, 15 Oct 2008) | 1 line
# r389 | rothra | 2008-10-15 10:35:34 +0200 (Wed, 15 Oct 2008) | 1 line
# r387 | rothra | 2008-10-09 11:41:19 +0200 (Thu, 09 Oct 2008) | 1 line
# r384 | rothra | 2008-10-08 14:09:00 +0200 (Wed, 08 Oct 2008) | 1 line
# r363 | rothra | 2008-08-19 14:16:36 +0200 (Tue, 19 Aug 2008) | 1 line
# r361 | rothra | 2008-08-15 11:10:54 +0200 (Fri, 15 Aug 2008) | 1 line
# r356 | rothra | 2008-08-14 13:25:34 +0200 (Thu, 14 Aug 2008) | 1 line
# r355 | rothra | 2008-08-14 09:56:15 +0200 (Thu, 14 Aug 2008) | 1 line
# r354 | rothra | 2008-08-12 19:20:47 +0200 (Tue, 12 Aug 2008) | 1 line
# r346 | rothra | 2008-08-11 08:46:50 +0200 (Mon, 11 Aug 2008) | 1 line
# r345 | rothra | 2008-08-06 15:12:41 +0200 (Wed, 06 Aug 2008) | 1 line
# r343 | rothra | 2008-08-04 11:01:49 +0200 (Mon, 04 Aug 2008) | 1 line
# r339 | rothra | 2008-07-22 11:16:11 +0200 (Tue, 22 Jul 2008) | 1 line
# r337 | rothra | 2008-07-21 10:57:35 +0200 (Mon, 21 Jul 2008) | 1 line
# r335 | rothra | 2008-07-21 08:56:56 +0200 (Mon, 21 Jul 2008) | 1 line
# r332 | rothra | 2008-07-18 09:02:26 +0200 (Fri, 18 Jul 2008) | 1 line
# r330 | rothra | 2008-07-15 11:01:02 +0200 (Tue, 15 Jul 2008) | 1 line
# r323 | rothra | 2008-07-10 15:23:04 +0200 (Thu, 10 Jul 2008) | 1 line
# r315 | rothra | 2008-07-09 10:08:48 +0200 (Wed, 09 Jul 2008) | 1 line
# r314 | rothra | 2008-07-08 16:17:45 +0200 (Tue, 08 Jul 2008) | 1 line
# r312 | rothra | 2008-07-08 14:25:54 +0200 (Tue, 08 Jul 2008) | 1 line
# r304 | rothra | 2008-07-02 10:53:33 +0200 (Wed, 02 Jul 2008) | 1 line
# r302 | rothra | 2008-06-30 15:33:32 +0200 (Mon, 30 Jun 2008) | 1 line
# r297 | rothra | 2008-06-26 12:28:03 +0200 (Thu, 26 Jun 2008) | 1 line
# r290 | rothra | 2008-06-24 16:20:24 +0200 (Tue, 24 Jun 2008) | 1 line
# r288 | rothra | 2008-06-23 15:14:06 +0200 (Mon, 23 Jun 2008) | 1 line
# r270 | rothra | 2008-05-20 21:25:10 +0200 (Tue, 20 May 2008) | 1 line
# r254 | rothra | 2008-05-14 09:30:50 +0200 (Wed, 14 May 2008) | 1 line
# r253 | rothra | 2008-05-14 09:21:19 +0200 (Wed, 14 May 2008) | 1 line
# r252 | rothra | 2008-05-13 18:24:56 +0200 (Tue, 13 May 2008) | 1 line
# r250 | rothra | 2008-05-13 17:33:27 +0200 (Tue, 13 May 2008) | 1 line
# r241 | rothra | 2008-05-09 15:39:56 +0200 (Fri, 09 May 2008) | 1 line
# r230 | rothra | 2008-05-02 09:26:17 +0200 (Fri, 02 May 2008) | 1 line
# r229 | rothra | 2008-05-02 09:24:04 +0200 (Fri, 02 May 2008) | 1 line
# ---------------------------------------------------------------------------
