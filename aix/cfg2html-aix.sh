# @(#) $Id: cfg2html-linux.sh,v 6.24 2014/03/24 17:00:03 ralph Exp $
# -----------------------------------------------------------------------------------------
# (c) 1997-2014 by Ralph Roth  -*- http://rose.rult.at -*-

#  If you change this script, please mark your changes with for example
#  ## <username> and send your diffs from the actual version to my mail
#  address: cfg2html*hotmail.com -- details see in the documentation

CFGSH=$_
# unset "-set -vx" for debugging purpose, after the exec 2> statement all debug infos will go the errorlog file (*.err)
#set -vx
#*vim:numbers:ruler
# ---------------------------------------------------------------------------
# NEW VERSION - v6/github/GPL
#        __       ____  _     _             _            _
#   ___ / _| __ _|___ \| |__ | |_ _ __ ___ | |      __ _(_)__  __
#  / __| |_ / _` | __) | '_ \| __| '_ ` _ \| |____ / _` | |\ \/ /
# | (__|  _| (_| |/ __/| | | | |_| | | | | | |____| (_| | | >  <
#  \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_|     \__,_|_|/_/\_\
#           |___/
#  system collector script
#
# ---------------------------------------------------------------------------

PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/omni/bin  ## this is a fix for wrong su root (instead for su - root)

_VERSION="cfg2html-aix version $VERSION "  # this a common stream so we don?t need the "Proliant stuff"

#
# getopt
#
#

while getopts ":o:shcSTflkenaHLvhpPA:2:10" Option   ##  -T -0 -1 -2 backported from HPUX
do
  case $Option in
    o     ) OUTDIR=$OPTARG;;
    v     ) echo $_VERSION"// "$(uname -mrs); exit 0;; ## add uname output, see YG MSG 790 ##
    h     ) echo $_VERSION; usage; exit 0;;
    s     ) CFG_SYSTEM="no";;
    c     ) CFG_CRON="no";;
    S     ) CFG_SOFTWARE="no";;
    f     ) CFG_FILESYS="no";;
    l     ) CFG_LVM="no";;
    k     ) CFG_KERNEL="no";;
    e     ) CFG_ENHANCEMENTS="no";;
    n     ) CFG_NETWORK="no";;
    a     ) CFG_APPLICATIONS="no";;
    H     ) CFG_HARDWARE="no";;
#    L     ) CFG_STINLINE="no";;
#    p     ) CFG_HPPROLIANTSERVER="yes";;
    P     ) CFG_PLUGINS="yes";;
#    A     ) CFG_ALTIRISAGENTFILES="no";;
    2     ) CFG_DATE="_"$(date +$OPTARG) ;;
    1     ) CFG_DATE="_"$(date +%d-%b-%Y) ;;
    0     ) CFG_DATE="_"$(date +%d-%b-%Y-%H%M) ;;
    T     ) CFG_TRACETIME="yes";;   # show each exec_command with timestamp
    *     ) echo "Unimplemented option chosen. Try -h for help!"; exit 1;;   # DEFAULT
  esac
done

shift $(($OPTIND - 1))
# Decrements the argument pointer so it points to next argument.

#
# linux port
MAILTO="&#106;&#101;&#114;&#111;&#101;&#110;&#46;&#107;&#108;&#101;&#101;&#110;&#64;&#104;&#112;&#46;&#99;&#111;&#109;"
MAILTORALPH="cfg2html&#64;&#104;&#111;&#116;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;"
# changed/added 08.07.2003 (13:04) by Ralph Roth


#####################################################################
# @(#)Cfg2Html (c) by ROSE SWE, Dipl.-Ing. Ralph Roth, cfg2html@hotmail.com
# HP Proliant Server Module Integrated by Jeroen.Kleen@hp.com
#####################################################################

# cfg2html-linux ported (c) by Michael Meifert, SysAdm from HP-UX version
# using debian potato, woody

# This is the "swiss army knife" for the ASE, CE, sysadmin etc. I wrote it to
# get the needed information to plan an update, to perform basic trouble
# shooting or performance analysis. As a bonus cfg2html creates a nice HTML and
# plain ASCII documentation. If you are missing something, let me know it!

# History
#####################################################################
# 28-jan-1999  initial creation, based on get_config, check_config
#              nickel, snapshoot, vim and a idea from a similar
#              script i have seen on-site.
#####################################################################
# 11-Mar-2001  initial creation for debian GNU Linux i386
#              based on Cfg2Html Version 1.15.06/HP-UX by
#              by ROSE SWE, Dipl.-Ing. Ralph Roth
#              ported to Linux  by Michael Meifert
#####################################################################
# 15-May-2006  Common stream for cfg2html-linux and the Proliant version



echo "" # should be a newline, more portable? # rar, 20121230

## test if user = root
check_root

# define the HTML_OUTFILE, TEXT_OUTFILE, ERROR_LOG
define_outfile

# create our VAR_DIR, OUTDIR before we continue
create_dirs

#
if [ ! -d $OUTDIR ] ; then
  echo "can't create $HTML_OUTFILE, $OUTDIR does not exist - stop"
  exit 1
fi
touch $HTML_OUTFILE
#echo "Starting up $VERSION\r"
[ -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null
DATE=`date "+%Y-%m-%d"` # ISO8601 compliant date string
DATEFULL=`date "+%Y-%m-%d %H:%M:%S"` # ISO8601 compliant date and time string

exec 2> $ERROR_LOG

if [ ! -f $HTML_OUTFILE ]  ;
then
  line
  _banner "Error"
  _echo "You have not the rights to create the file $HTML_OUTFILE! (NFS?)\n"
  exit 1
fi

logger "Start of $VERSION"
RECHNER=$(hostname)         # `hostname -f`
VERSION_=`echo $VERSION/$RECHNER|tr " " "_"`
typeset -i HEADL=0                      # Headinglevel


####################################################################
# needs improvement!
# trap "echo Signal: Aborting!; rm $HTML_OUTFILE_TEMP"  2 13 15

####################################################################

#
######################################################################
# Hauptprogramm mit Aufruf der obigen Funktionen und deren Parametern
#############################  M A I N  ##############################
#

line
echo "Starting          "$_VERSION       ## "/"$(arch) - won't work under Debian 5.0.8 ## /usr/bin/cfg2html-linux: line 597: arch: command not found
echo "Path to Cfg2Html  "$0
echo "HTML Output File  "$HTML_OUTFILE
echo "Text Output File  "$TEXT_OUTFILE
echo "Partitions        "$OUTDIR/$BASEFILE.partitions.save
echo "Errors logged to  "$ERROR_LOG
[[ -f $CONFIG_DIR/local.conf ]] && {
    echo "Local config      "$CONFIG_DIR/local.conf "( $(grep -v -E '(^#|^$)' $CONFIG_DIR/local.conf | wc -l) lines)"
    }

echo "Started at        "$DATEFULL
echo "WARNING           USE AT YOUR OWN RISK!!! :-))           <<<<<"
line
logger "Start of $VERSION"
open_html
inc_heading_level

#
# CFG_SYSTEM
#


if [ "$CFG_SYSTEM" != "no" ]
then # else skip to next paragraph

  paragraph "IBM AIX ($(oslevel -r))"
  inc_heading_level

  if [ -f $CONFIG_DIR/systeminfo ] ; then
    exec_command "cat $CONFIG_DIR/systeminfo" "System description"
  fi

  for i in $(lsdev -Ccprocessor | awk '{print $1}')
  do
    exec_command "lsattr -EHl $i" "CPU Information: $i"
  done
  exec_command  HostNames "uname & hostname"
  exec_command "uname -n" "Host alias"
  exec_command "echo $(uname -s) $(oslevel -s)" "OS, Version TL and SP"

  if [ -x /usr/bin/locale ] ; then
    exec_command "locale" "locale specific information"
    export LANG="C"
    export LC_ALL="C"
  fi

  exec_command "ulimit -a" "System ulimit"                #  13.08.2007, 14:24 modified by Ralph Roth
  exec_command "getconf -a" "System Configuration Variables"          ## at least SLES11, #  14.06.2011, 18:53 modified by Ralph Roth #* rar *#

  if [ -x /usr/bin/mpstat ] ; then
    exec_command "mpstat 1 5" "MP-Statistics"
  fi
  if [ -x /usr/bin/iostat ] ; then
    exec_command "iostat" "IO-Statistics"
  fi

  exec_command "lsattr -El sys0 -a realmem | awk {'print \$1,\$2'};echo;svmon -G;echo;lsps -a;echo;swap -l" "Used Memory and Swap"  		#  04.07.2011, 16:13 modified by Ralph Roth #* rar *#

  if [ -x /usr/bin/vmstat ] ; then        ## <c/m/a>  14.04.2009 - Ralph Roth
    exec_command "vmstat 1 10" "VM-Statistics 1 10"
    exec_command "vmstat; vmstat -f" "VM-Statistics (Summary)"
  fi

  # sysutils
  exec_command "uptime" "Uptime"
  exec_command "sar 1 9" "System Activity Report"
  exec_command "sar -b 1 9" "Buffer Activity"

  exec_command "proctree -atT" "Active Process - Tree Overview" #  15.11.2004/2011, 14:09 modified by Ralph.Roth
  exec_command "ps -e -o ruser,pid,args | awk ' (($1+1) > 1) {print $0;} '" "Processes without an named owner"  # changed 20131211 by Ralph Roth, # changed 20140129 by Ralph Roth # cmd. line:1: ^ unexpected newline or end of string
  AddText "The output should be empty!"

  exec_command "ps -ef | cut -c39- | sort -nr | head -25 | awk '{ printf(\"%10s   %s\\n\", \$2, \$3); }'" "Top load processes"
  exec_command "ps -e -o 'vsz pid ruser cpu time args' |sort -nr|head -25" "Top memory consuming processes"
  exec_command topFDhandles "Top file handles consuming processes" # 24.01.2013
  AddText "Hint: Number of open file handles should be less than ulimit -n ("$(ulimit -n)")"

  exec_command "last| grep boot" "reboots"
  exec_command "alias"  "Alias"
  [ -r /etc/inittab ] && exec_command "grep -vE '^#|^ *$' /etc/inittab" "inittab"
  exec_command "lssrc -a" "Services - Status"
  exec_command "who -r | awk '{print $2,$3}" "Current runlevel"

  exec_command "ipcs -o" "IPC Summary"
  exec_command "ipcs -qa" "IPC Message Queue"
  exec_command "ipcs -ma" "IPC Shared Memory"
  exec_command "ipcs -sa" "IPC Semaphores"

  ###  Made by Dusan.Baljevic@ieee.org ### 16.03.2014
  if [ -x /usr/sbin/mksecldap ] ; then
    exec_command "/usr/bin/egrep -ve '^#|^$' /etc/security/ldap/ldap.cfg && echo Okay" "LDAP Client Configuration"
  fi

  if [ -x /usr/bin/pwdck ] ; then
    exec_command "/usr/bin/pwdck -n ALL" "integrity of password files"
  fi

  if [ -x /usr/sbin/grpck ] ; then
    exec_command "/usr/sbin/grpck -n ALL" "integrity of group files"
  fi

  dec_heading_level

fi # terminates CFG_SYSTEM wrapper

#
# CFG_CRON
#
if [ "$CFG_CRON" != "no" ]
then # else skip to next paragraph
paragraph "Cron and At"
inc_heading_level

  for FILE in cron.allow cron.deny
      do
	  if [ -r /var/adm/cron/$FILE ]
	  then
	  exec_command "cat /var/adm/cron/$FILE" "$FILE"
	  else
	  exec_command "echo /var/adm/cron/$FILE" "$FILE not found!"
	  fi
      done

    usercron="/var/spool/cron/crontabs"

  ls $usercron/* > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
	  _echo  "\n\n<B>Crontab files:</B>" >> $HTML_OUTFILE_TEMP
	  for FILE in $usercron/*
	  do
		  exec_command "cat $FILE | grep -v ^#" "For user `basename $FILE`"
	  done
  else
	  echo "No crontab files for user.<br>" >> $HTML_OUTFILE_TEMP
  fi

  atconfigpath="/var/adm/cron"

  for FILE in at.allow at.deny

      do
	  if [ -r $atconfigpath/$FILE ]
	  then
	      exec_command "cat $atconfigpath/$FILE " "$atconfigpath/$FILE"
	  else
	      exec_command "echo $atconfigpath/$FILE" "No $atconfigpath/$FILE"
	  fi
      done

  if [ -x /usr/bin/at ] ; then
    exec_command "at -l" "AT Scheduler"
  fi

dec_heading_level
fi #terminate CFG_CRON wrapper

#
# CFG_HARDWARE
#
if [ "$CFG_HARDWARE" != "no" ]
then # else skip to next paragraph

paragraph "Hardware"
inc_heading_level

RAM=`prtconf | awk -F': *' '/^Memory Size/ {print $2}'` 
exec_command "echo $RAM" "Physical Memory"
exec_command "prtconf | egrep -e 'Processor Type|Number Of Processors|Processor Clock Speed|CPU Type' 2> /dev/null" "CPU Information"
exec_command "prtconf -L" "LPAR Information"
exec_command "prtconf |egrep '^\*|^\+|^\-'" "Hardware List"
exec_command "lsdev -Ccadapter" "HW adapters list"
exec_command "lsdev -Ccdisk" "Disk Device list"
exec_command "lsdev -Cctape" "Tape Device list"
exec_command "lsdev -Ccif" "Network Device list"
exec_command "prtconf -v" "Detailed Hardware List"
### ------------------------------------------------------------------------------


## MPIO Device Configuration
[ -x /usr/sbin/lspath ] && exec_command "lspath -s enabled" "MPIO - Enabled Devices"
[ -x /usr/sbin/lspath ] && exec_command "lspath -s disabled" "MPIO - Disabled Devices"
[ -x /usr/sbin/lspath ] && exec_command "lspath -s failed" "MPIO - Failed Devices"
[ -x /usr/sbin/lspath ] && exec_command "lspath -F'name:status:connection:parent:path_status'" "MPIO - Detailed Status"
## PowerPath Device Configuration
[ -x /usr/sbin/powermt ] && exec_command "/usr/sbin/powermt display" "Powerpath - Overview"
[ -x /usr/sbin/powermt ] && exec_command "/usr/sbin/powermt display dev=all" "Powerpath - Devices"


dec_heading_level

fi # terminates CFG_HARDWARE wrapper

######################################################################

##### ToDo: check for Distribution #####

if [ "$CFG_SOFTWARE" != "no" ]
then # else skip to next paragraph

  paragraph "Software"
  inc_heading_level

    exec_command "lslpp -l" "AIX Filesets installed"
    exec_command "lslpp -e" "Applied efixes"
    exec_command "rpm -qia | grep -E '^(Name|Group)( )+:'" "RPM Packages installed" 
    exec_command "rpm -qa | sort -d -f" "RPM Packages installed (sorted)"       
    exec_command "rpm --querytags" "RPM Query Tags" 

  dec_heading_level

fi # terminates CFG_SOFTWARE wrapper

######################################################################
if [ "$CFG_FILESYS" != "no" ]
then # else skip to next paragraph

paragraph "Filesystems, Dump and Swap configuration"
inc_heading_level



exec_command "cat /etc/filesystems" "Filesystem Tab"  
exec_command "lsfs -a" "Filesystem Information"  
exec_command "df -k" "Filesystems Usage"

exec_command "sysdumpdev" "System Dump Information"
exec_command "sysdumpdev -e" "Estimated System Dump Size"

exec_command "lsps -a" "Swap Partitions"
exec_command "swap -l" "Swap Usage"

if [ -f /etc/exports ] ; then
    exec_command "grep -vE '^#|^ *$' /etc/exports" "NFS Filesystem Exports"
fi

dec_heading_level

fi # terminates CFG_FILESYS wrapper

paragraph "Multipath Configuration"
inc_heading_level

## MPIO Device Configuration
if [ -x /usr/sbin/lspath ] ; then
	exec_command "lspath -s enabled" "MPIO - Enabled Devices"
	exec_command "lspath -s disabled" "MPIO - Disabled Devices"
	exec_command "lspath -s failed" "MPIO - Failed Devices"
	exec_command "lspath -F'name:status:connection:parent:path_status'" "MPIO - Detailed Status"
fi

## PowerPath Device Configuration
if [ -x /usr/sbin/powermt ] ; then
	exec_command "lsattr -EHl powerpath0" "Powerpath Control Device"
	exec_command "/usr/sbin/powermt display" "Powerpath - Overview"
	exec_command "/usr/sbin/powermt display dev=all" "Powerpath - Devices"
fi
dec_heading_level

###########################################################################
if [ "$CFG_LVM" != "no" ]
then # else skip to next paragraph

    paragraph "LVM"
    inc_heading_level

    [ -x /usr/sbin/lspv ] && exec_command "lspv" "Physical Volumes" 

    exec_command "lsvg" "Defined Volume Groups"
    exec_command "lsvg -o" "Available Volume Groups"
    for VG in `lsvg -o`
    do
	exec_command "lsvg ${VG}" "${VG} (VG Properties)"
	exec_command "lsvg -p ${VG}" "${VG} (Physical Volumes)"
	exec_command "lsvg -l ${VG}" "${VG} (Logical Volumes)"
	for LV in `lsvg -l ${VG}|awk '{print $1}'|grep -Ev "^LV|:"`
	do
		exec_command "lslv ${LV}" "${LV} (LV Properties)"
		exec_command "lslv -l ${LV}" "${LV} Physical Allocation (${VG})"
	done
    done
		
    dec_heading_level

fi # terminates CFG_LVM wrapper

###########################################################################
if [ "$CFG_NETWORK" != "no" ]
then # else skip to next paragraph

  paragraph "Network Settings"
  inc_heading_level

  exec_command "lsdev -Ccadapter|grep Ethernet|grep Available" "Network Physical Adapters"
  for ETHER in `lsdev -Ccadapter|grep Ethernet|grep Available|awk '{print $1}'`
  do
	exec_command "lsattr -EHl ${ETHER}" "${ETHER} Adapter Properties"
  done
  exec_command "lsdev -Ccif|grep Available" "LAN Interfaces"
  for NIC in `lsdev -Ccif|grep Available|awk '{print $1}'`
  do
	exec_command "ifconfig ${NIC}" "${NIC} Interface Status"
	exec_command "lsattr -EHl ${NIC}" "${NIC} Interface Properties"
	exec_command "entstat -d ${NIC}" "${NIC} Interface Statistics"
  done	


  exec_command "netstat -r" "Routing Tables"
  exec_command "netstat -i" "Kernel Interface table"
  exec_command "netstat -s" "Summary statistics for each protocol"
  exec_command "netstat -an" "List of all sockets"

  HOSTNAME=`hostname -s`
  DOMAIN=`grep domain /etc/resolv.conf | awk '{print $2}'`	
  FQDN="$HOSTNAME.$DOMAIN"
  DIG=`which dig`
  if [ -n "$DIG" ] && [ -x $DIG ] ; then
    exec_command "dig ${FQDN}" "dig hostname"
  else
    NSLOOKUP=`which nslookup`
    if [ -n "$NSLOOKUP" ] && [ -x $NSLOOKUP ] ; then
      exec_command "nslookup ${FQDN}" "Nslookup hostname"
    fi
  fi

  exec_command "grep -vE '^#|^ *$' /etc/hosts" "/etc/hosts"


  if [ -x /usr/sbin/tcpdchk ] ; then
    exec_command "/usr/sbin/tcpdchk -v" "tcpd wrapper"
    exec_command "/usr/sbin/tcpdchk -a" "tcpd warnings"
  fi

  [ -f /etc/hosts.allow ] && exec_command "grep  -vE '^#|^ *$' /etc/hosts.allow" "hosts.allow"
  [ -f /etc/hosts.deny ] && exec_command "grep  -vE '^#|^ *$' /etc/hosts.deny" "hosts.deny"


  #if [ -f /etc/gated.conf ] ; then
  #    exec_command "cat /etc/gated.conf" "Gate Daemon"
  #fi

  if [ -f /etc/bootptab ] ; then
      exec_command "grep -vE '(^#|^ *$)' /etc/bootptab" "BOOTP Daemon Configuration"
  fi

  if [ -r /etc/inetd.conf ]; then
    exec_command "grep -vE '^#|^ *$' /etc/inetd.conf" "Internet Daemon Configuration"
  fi


  #exec_command "cat /etc/services" "Internet Daemon Services"
  if [ -f /etc/resolv.conf ] ; then
     exec_command "grep -vE '^#|^ *$' /etc/resolv.conf;echo; ( [ -f /etc/netsvc.conf ] &&  grep -vE '^#|^ *$' /etc/netsvc.conf)" "DNS & Names"
  fi

  # if portmap not available, do nothing
  RES=`ps -e | grep [Pp]ortmap`
  if [ -n "$RES" ] ; then
    exec_command "rpcinfo -p " "RPC (Portmapper)"
    MOUNTD=`rpcinfo -p | awk '/mountd/ {print $5; exit}'`
    if [ -n "$MOUNTD" ] ; then
      exec_command "rpcinfo -u 127.0.0.1 100003" "NSFD responds to RPC requests"
      SHOWMOUNT=`which showmount`
      if [ $SHOWMOUNT ] && [ -x $SHOWMOUNT ] ; then
        exec_command "$SHOWMOUNT -a" "Mounted NFS File Systems"
      fi
      if [ -f /etc/auto.master ] ;then
        exec_command "grep -vE '^#|^$' /etc/auto.master" "NFS Automounter Master Settings"
      fi
      if [ -f /etc/auto.misc ] ;then
        exec_command "grep -vE '^#|^$' /etc/auto.misc" "NFS Automounter misc Settings"
      fi
      exec_command "nfsstat" "NFS Statistics"
    fi # mountd
  fi


  NTPQ=`which ntpq`
  if [ -n "$NTPQ" ] && [ -x "$NTPQ" ] ; then      
    exec_command "$NTPQ -p" "XNTP Time Protocol Daemon"
  fi

  [ -f /etc/ntp.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/ntp.conf" "ntp.conf"
  [ -f /etc/shells ] && exec_command "grep  -vE '^#|^ *$'  /etc/shells" "Login Shells"
  [ -f /etc/ftpusers ] && exec_command "grep  -vE '^#|^ *$'  /etc/ftpusers" "FTP Rejections (/etc/ftpusers)"
  [ -f /etc/ftpaccess.ctl ] && exec_command "grep  -vE '^#|^ *$'  /etc/ftpaccess.ctl" "FTP Permissions (/etc/ftpaccess.ctl)"
  [ -f /etc/syslog.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/syslog.conf" "syslog.conf"

  ######### SNMP ############
  [ -f /etc/snmpd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmpd.conf" "Simple Network Management Protocol (SNMP)"

  ## ssh
  [ -f /etc/ssh/sshd_config ] && exec_command "grep -vE '^#|^ *$' /etc/ssh/sshd_config" "sshd config"
  [ -f /etc/ssh/ssh_config ] && exec_command "grep -vE '^#|^ *$' /etc/ssh/ssh_config" "ssh config"

  dec_heading_level

fi # terminates CFG_NETWORK wrapper


###########################################################################
if [ "$CFG_KERNEL" != "no" ]
then # else skip to next paragraph

    paragraph "Kernel, Modules and Libraries" "Kernelparameters"
    inc_heading_level
	exec_command "lsattr -E -l sys0" "Kernel Parameters"
	exec_command "vmo -a" "Virtual Memory Parameters"
	exec_command "no -a" "Network Parameters"
	exec_command "genkex" "Kernel Modules"
    dec_heading_level

fi # terminates CFG_KERNEL wrapper
######################################################################

if [ "$CFG_ENHANCEMENTS" != "no" ]
then # else skip to next paragraph

    paragraph "System Enhancements"
    inc_heading_level

	# X Window? ...

    dec_heading_level

fi # terminates CFG_ENHANCEMENTS wrapper
###########################################################################

if [ "$CFG_APPLICATIONS" != "no" ]
then # else skip to next paragraph

    paragraph "Applications and Subsystems"

### COMMON ################################################################

    inc_heading_level

    if [ -d /usr/local/bin ] ; then
      exec_command "ls -lisa /usr/local/bin" "Files in /usr/local/bin"
    fi
    if [ -d /usr/local/sbin ] ; then
      exec_command "ls -lisa /usr/local/sbin" "Files in /usr/local/sbin"
    fi
    if [ -d /opt ] ; then
      exec_command "ls -lisa /opt" "Files in /opt"
    fi


    #if [ -x /usr/bin/lpstat ] ; then
    #  exec_command "/usr/bin/lpstat -t" "SYSV Printer Spooler and Printers"      #*# Alexander De Bernardi, 20100310
    #fi

    if [ -e /usr/lpp/OV/bin/opcagt ] ; then
        exec_command "/usr/lpp/OV/bin/opcagt -version" "HP OpenView Agent Version"
        exec_command "/usr/lpp/OV/bin/opcagt -status" "HP OpenView Agent Status"
    fi
    if [ -e /usr/lpp/perf/bin/ovpa ] ; then
        exec_command "/usr/lpp/perf/bin/ovpa version" "HP OpenView PerfAgent Info, Version"
    fi

# Backup Software

    # Veritas Netbackup
    if [ -e /usr/openv/netbackup/bp.conf ] ; then

      paragraph "Veritas Netbackup Configuration"
      inc_heading_level

          NetBuVersion=$(find /usr/openv/netbackup -name "version")
          if [ -e ${NetBuVersion} ] ; then
            exec_command "cat ${NetBuVersion}" "Veritas Netbackup Version"
          fi
          exec_command "cat /usr/openv/netbackup/bp.conf" "Veritas Netbackup Configuration"
          exec_command "netstat -a | egrep '(bpcd|bpjava-msvc|bpjava-susvc|vnetd|vopied)|(Active|Proto)'" "Veritas Netbackup Network Connections"
            ## Use FS="=" in case there's no whitespace in the SERVER lines.
          if ping -c 3 $(awk 'BEGIN {FS="="} /SERVER/ {print $NF}' /usr/openv/netbackup/bp.conf | head -1) >/dev/null
          then
            exec_command "/usr/openv/netbackup/bin/bpclntcmd -pn" "Veritas Netbackup Client to Server Inquiry"
          fi
      dec_heading_level
    fi ## Veritas Netbackup

    # HP Dataprotector
    if [ -d /usr/omni/config/client ]; then
	
	paragraph "HP Data Protector Configuration"
	inc_heading_level
	
	exec_command "/usr/omni/bin/omnicc -query|grep -v ' 0'" "Data Protector License Info."
	exec_command "cat /usr/omni/config/client/omni_info" "Data Protector Client Information"
	[ -f /usr/omni/.omnirc ] && exec_command "cat /usr/omni/.omnirc | grep -v ^#" "Data Protector Client Configuration"
	exec_command "cat /usr/omni/config/client/cell_server" "Data Protector Cell Server"
	exec_command "cat /etc/services | grep -w omni" "Data Protector Service Port"
	exec_command "netstat -a|grep -w omni" "Data Protector Service Status"

	dec_heading_level
    fi ## HP Dataprotector   




## SAP stuff 
if [ -x /usr/sap/hostctrl/exe/saphostexec ]
then
    paragraph "SAP Information"
    inc_heading_level

    exec_command "/usr/sap/hostctrl/exe/saphostexec -version" "SAP Installed Components"
    exec_command "ps -ef| grep -i ' pf=' | grep -v grep" "Active SAP Processes"

    dec_heading_level
fi ## SAP


######## HACMP/PowerHA stuff ########## 
    if [ -d /usr/es/sbin/cluster/utilities ] # HACMP #
    then
	paragraph "HACMP / PowerHA Configuration"
	inc_heading_level

	HACMDPATH="/usr/es/sbin/cluster/utilities"
        exec_command "${HACMDPATH}/cldump" "HACMP Cluster Configuration Overview"  		
        exec_command "${HACMDPATH}/cllsnode" "HACMP Cluster Nodes Configuration"
        exec_command "${HACMDPATH}/cltopinfo" "HACMP Cluster Topology Configuration"
        exec_command "${HACMDPATH}/clshowres" "HACMP Cluster Resources Configuration"
        exec_command "odmget HACMPdaemons" "HACMP Cluster Daemons Configuration"

	dec_heading_level
    fi ## HACMP

dec_heading_level

fi  #"$CFG_APPLICATIONS"# <m>  23.04.2008, 2145 -  Ralph Roth

##########################################################################
##
## Display Oracle configuration if applicable
## Begin Oracle Config Display
## 31jan2003 it233 FRU U.Frey

if [ -s /etc/oratab ] ; then    # exists and >0

  paragraph "Oracle Configuration"
  inc_heading_level

  exec_command "grep -vE '^#|^$|:N' /etc/oratab " "Configured Oracle Databases Startups"        #  27.10.2011, 15:01 modified by Ralph Roth #* rar *#

  ##
  ## Display each Oracle initSID.ora File
  ##     orcl:/home/oracle/7.3.3.0.0:Y
  ##     leaveup:/home/oracle/7.3.2.1.0:N

  for  DB in $(grep ':' /etc/oratab|grep -v '^#'|grep -v ':N$')                                 #  27.10.2011, 14:58 modified by Ralph Roth #* rar *#
       do
         Ora_Home=`echo $DB | awk -F: '{print $2}'`
         Sid=`echo $DB | awk -F: '{print $1}'`
         Init=${Ora_Home}/dbs/init${Sid}.ora
         if [ -r "$Init" ]
         then
            exec_command "cat $Init" "Oracle Instance $Sid"
         else
            AddText "WARNING: obsolete entry $Init in /etc/inittab for SID $Sid!"
         fi
       done
  dec_heading_level
fi

###
##############################################################################

#
# execute custom plugins   -- anaumann 2009/07/10
#

if [ "$CFG_PLUGINS" != "no" ];
then # else skip to next paragraph
    if [ -f $CONFIG_DIR/plugins ]; then
    paragraph "Custom plugins"

        # include plugin configuration
    . $CONFIG_DIR/plugins


    if [ -n "$CFG2HTML_PLUGIN_DIR" -a -n "$CFG2HTML_PLUGINS" ]; then
            # only run plugins when we know where to find them and at least one of them is enabled

        inc_heading_level

        if [ "$CFG2HTML_PLUGINS" == "all" ]; then
        # include all plugins
        CFG2HTML_PLUGINS="$(ls -1 $CFG2HTML_PLUGIN_DIR)"
        fi

        for CFG2HTML_PLUGIN in $CFG2HTML_PLUGINS; do
        if [ -f "$CFG2HTML_PLUGIN_DIR/$CFG2HTML_PLUGIN" ]; then
            . $CFG2HTML_PLUGIN_DIR/$CFG2HTML_PLUGIN
            exec_command cfg2html_plugin "$CFG2HTML_PLUGINTITLE"
        else
            AddText "Configured plugin $CFG2HTML_PLUGIN not found in $CFG2HTML_PLUGIN_DIR"
        fi
        done
        dec_heading_level
    fi
    fi
fi

## end of plugin processing


#
# collect local files
#
if [ -f $CONFIG_DIR/files ] ; then
  paragraph "Local files"
  inc_heading_level
  . $CONFIG_DIR/files
  for i in $FILES
  do
    if [ -f $i ] ; then
      exec_command "grep -vE '(^#|^ *$)' $i" "File: $i"
    fi
  done
  AddText "You can customize this entry by editing /etc/cfg2html/files"
  dec_heading_level
fi

dec_heading_level

close_html

###########################################################################


logger "End of $VERSION"
_echo "\n"
line

logger "End of $VERSION"
rm -f core > /dev/null

########## remove the error.log if it has size zero #######################
[ ! -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

####################################################################
