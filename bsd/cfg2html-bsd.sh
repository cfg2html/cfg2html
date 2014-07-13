# @(#) $Id: cfg2html-bsd.sh,v 1.5 2014/06/02 10:41:38 dusan Exp dusan $
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
#        __       ____  _     _             _       
#   ___ / _| __ _|___ \| |__ | |_ _ __ ___ | |     
#  / __| |_ / _` | __) | '_ \| __| '_ ` _ \| |_____
# | (__|  _| (_| |/ __/| | | | |_| | | | | | |_____
#  \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_|     
#           |___/
#
#####   #####   #####
#    #  #       #    #
#####    ####   #    #
#    #       #  #    #
#    #  #    #  #    #
#####    ####   #####
#
#  system collector script
#
# FreeBSD|OpenBSD|NetBSD collectors next generation (cfg2html 6.xx)
#  maintained by Dusan Baljevic (dusan.baljevic@ieee.org)
# ---------------------------------------------------------------------------

PATH=$PATH:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin
PATH=$PATH:/var/cfengine/bin:/usr/local/samba/sbin
PATH=$PATH:/usr/local/samba/bin:/usr/local/flexlm/bin

# Counter for stat commands
STATCNT="1 10"

OSREV=$(uname -r | cut -d. -f2)
OSMAJ=$(uname -s)

PLUGIN="/usr/share/cfg2html/plugins"

# use "no" to disable a collection
#
CFG_APPLICATIONS="yes"
CFG_BOOT="yes"
CFG_HARDWARE="yes"
CFG_GIF="yes"
CFG_PLUGINS="no"
CFG_FILESYS="yes"
CFG_DISKS="yes"
CFG_VOLMGR="yes"
CFG_KERNEL="yes"
CFG_FILES="yes"
CFG_LICENSE="yes"
CFG_NETWORK="yes"
CFG_PRINTER="yes"
CFG_CRON="yes"
CFG_CLUSTER="yes"
CFG_PASSWD="yes"
CFG_SYSTEM="yes"
CFG_SOFTWARE="yes"
CFG_LOCAL="yes"

if [ -d "/var/log/cfg2html" ]; then
   OUTDIR="/var/log/cfg2html"
else
   OUTDIR=$(pwd)
fi

_VERSION="cfg2html-BSD version $VERSION "  

usage() {
   echo "  Usage: $(basename $0) [OPTION]"
   echo "  creates HTML and plain ASCII host documentation"
   echo
   echo "  -o     set directory to write or use the environment"
   echo "         variable OUTDIR=\"/path/to/dir\" (directory must exist)"
   echo "  -v     output version information and exit"
   echo "  -h     display this help and exit"
   echo
   echo "  use the following options to disable/enable collections:"
   echo
   echo "  -a     disable: Applications"
   echo "  -b     disable: Boot System"
   echo "  -c     disable: Cron"
   echo "  -C     disable: Cluster"
   echo "  -d     disable: Disks"
   echo "  -D     disable: Volume Manager"
   echo "  -e     enable:  Plugins"
   echo "  -f     disable: Filesystems"
   echo "  -F     disable: Local Files"
   echo "  -H     disable: Hardware"
   echo "  -k     disable: Kernel"
   echo "  -l     disable: Files"
   echo "  -L     disable: Licenses"
   echo "  -n     disable: Network"
   echo "  -p     disable: Passwords"
   echo "  -P     disable: Printers"
   echo "  -s     disable: System"
   echo "  -S     disable: Software"
   echo "  -x     don't create background images"
   echo
}

#
# getopt
#

while getopts ":o:vabcCdDefFhHklLnpPsSx" Option ; do
   case $Option in
      o  ) OUTDIR=$OPTARG;;
      v  ) echo "\nScript name: $VERSION"; echo "Released on: $RELEASED_ON\n";  exit;;
      h  ) usage; exit;;
      a  ) CFG_APPLICATIONS="no";;
      b  ) CFG_BOOT="no";;
      H  ) CFG_HARDWARE="no";;
      x  ) CFG_GIF="no";;
      e  ) CFG_PLUGINS="yes";;
      f  ) CFG_FILESYS="no";;
      F  ) CFG_LOCAL="yes";;
      d  ) CFG_DISKS="no";;
      D  ) CFG_VOLMGR="no";;
      k  ) CFG_KERNEL="no";;
      l  ) CFG_FILES="no";;
      L  ) CFG_LICENSE="no";;
      n  ) CFG_NETWORK="no";;
      P  ) CFG_PRINTER="no";;
      c  ) CFG_CRON="no";;
      C  ) CFG_CLUSTER="no";;
      p  ) CFG_PASSWD="no";;
      s  ) CFG_SYSTEM="no";;
      S  ) CFG_SOFTWARE="no";;
      *  ) echo "Unimplemented option. Try -h for help!";exit 1;; # DEFAULT
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
#####################################################################

## test if user = root
check_root

# define the HTML_OUTFILE, TEXT_OUTFILE, ERROR_LOG
define_outfile

# create our VAR_DIR, OUTDIR before we continue
create_dirs

if [ ! -d $OUTDIR ] ; then
  echo "can't create $HTML_OUTFILE, $OUTDIR does not exist - stop"
  exit 1
fi

touch $HTML_OUTFILE

[ -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null
DATE=$(date "+%Y-%m-%d") # ISO8601 compliant date string
DATEFULL=$(date "+%Y-%m-%d %H:%M:%S") # ISO8601 compliant date and time string

exec 2> $ERROR_LOG

if [ ! -f $HTML_OUTFILE ]  ;
then
  line
  _banner "Error"
  _echo "You have not the rights to create the file $HTML_OUTFILE! (NFS?)\n"
  exit 1
fi

logger "Start of $VERSION"
RECHNER=$(hostname)
VERSION_=$(echo $VERSION/$RECHNER|tr " " "_")
typeset -i HEADL=0                      # Headinglevel

# Catch interrupts and handle them
#
INTERRUPT_HANDLER() {
   trap "" 1 2 3 9 15
   printf "\nWARN: Interrupt received. Terminating program and cleaning up...\n"

   # killing child processes
   #
   for PID in $(ps -f | $AWK -v PPID=$$ '{if ( \$3 == PPID ) print \$2}') ; do
      if [ "$PID" != "PID" -a $PID -ne $$ ] ; then
         echo "INFO: Executing termination of process ID $PID 2>/dev/null"
         kill $PID 2>/dev/null
      fi
   done

   if [ -f "$ERROR_LOG" ]; then
      echo "INFO: Removing temporary file $ERROR_LOG"
      rm -f $ERROR_LOG 2>/dev/null
   fi

   if [ -f "$HTML_OUTFILE" ]; then
      echo "INFO: Removing temporary file $HTML_OUTFILE"
      rm -f $HTML_OUTFILE
   fi

   if [ -f "$TEXT_OUTFILE" ]; then
      echo "INFO: Removing temporary file $TEXT_OUTFILE"
      rm -f $TEXT_OUTFILE
   fi

   exit 0
}

trap "INTERRUPT_HANDLER" 1 2 3 9 15

#############################  M A I N  ##############################

line
echo "Starting          "$_VERSION
echo "Path to Cfg2Html  "$0
echo "HTML Output File  "$HTML_OUTFILE
echo "Text Output File  "$TEXT_OUTFILE
echo "Errors logged to  "$ERROR_LOG
[[ -f $CONFIG_DIR/local.conf ]] && {
    echo "Local config      "$CONFIG_DIR/local.conf "( $(egrep -v '(^#|^$)' $CONFIG_DIR/local.conf | wc -l) lines)"
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
   paragraph "BSD System"
   inc_heading_level

   if [ -f $CONFIG_DIR/systeminfo ] ; then
      exec_command "cat $CONFIG_DIR/systeminfo" "System description"
   fi

   exec_command "hostname" "Hostname"

   SECLEVEL=$(sysctl kern.securelevel)

   REALSEC=$(echo $SECLEVEL | awk '{print $2}')

   case $REALSEC in
     -1) SECL="permanently insecure" ;;
      0) SECL="insecure" ;;
      2) SECL="highly insecure" ;;
      3) SECL="network secure insecure" ;;
   esac

   exec_command "facter" "System facter"

   exec_command "sysctl kern.securelevel" "Runlevel"
   AddText "State: $SECL"

   exec_command "gpart show -p | awk '/boot/ {print}'" "Root file system device"

   exec_command "kenv -q smbios.system.uuid" "Host UUID"

   EEPROM="$(eeprom)"

   if [ "$EEPROM" ]
   then
      exec_command "echo $EEPROM" "Eeprom on SPARC platform only"
   fi

   exec_command "uname -n" "Host aliases"

   exec_command "uname -sr" "OS, Kernel version"

   exec_command "uname -mi" "Hardware type"

   exec_command "sysctl hw.physmem" "Memory size (bytes)"

   exec_command "pagesize" "Pagesize (bytes)"

   exec_command "sysctl hw.ncpu" "CPUs"

   exec_command "conscontrol" "Console status"

   exec_command "locale" "locale specific information"

   exec_command "ulimit -a" "System ulimit" 

   exec_command "mpstat $STATCNT" "Multiprocessor Statistics"

   exec_command "iostat -dxz $STATCNT" "I/O Statistics"

   exec_command "vmstat $STATCNT" "VM Statistics"

   # sysutils
   exec_command "uptime" "Uptime"

   exec_command "sa -a" "System Accounting statistics"

   exec_command "ps augxww" "Processes"

   exec_command "${PLUGIN}/detailed-process-stat.pl" "${PLUGIN}/detailed-process-stat.pl"

   exec_command "pstree -w" "Active Process - Tree Overview"

  exec_command "ps -efl | sort -nr | head -25" "Top Load processes"

  exec_command "ps -e -o 'vsz pid ruser time args' |sort -nr|head -25" "Top Memory consuming processes"

  exec_command "ps -e -o 'cpu pid ruser time args' |sort -nr|head -25" "Top CPU consuming processes"

  exec_command "ps -e -o 'pri pid ruser time args' |sort -nr|head -25" "Top Priority consuming processes"

   if [ -f /etc/rctl.conf ] ; then
      exec_command "grep -v ^# /etc/rctl.conf" "Resource limits config"
   fi

  exec_command "last| grep boot" "reboots"

  exec_command "fdisk -v" "PC slice summary fdisk"

  exec_command "ipcs -a" "IPC Status"

   dec_heading_level
fi
# terminates CFG_SYSTEM wrapper

#
# CFG_BOOT
#
if [ "$CFG_BOOT" != "no" ]
then # else skip to next paragraph
   paragraph "Boot System"
   inc_heading_level

   exec_command "sysctl kern.bootfile" "Kernel bootfile"

   [ -r /etc/rc ] && exec_command "cat /etc/rc" "Command script for auto-reboot and daemon startup /etc/rc"

   [ -r /etc/bootparams ] && exec_command "egrep -v ^# /etc/bootparams" "Diskless clients boot parameters in /etc/bootparams"

   [ -r /etc/bootptab ] && exec_command "cat /etc/bootptab" "Bootstrap protocol server database /etc/bootptab"

   dec_heading_level
fi
# terminates CFG_SYSTEM wrapper

#
# CFG_VOLMGR
#
if [ "$CFG_VOLMGR" != "no" ]
then # else skip to next paragraph
   paragraph "Volume Manager Status"
   inc_heading_level

   exec_command "ccdconfig -g" "Concatenated disk status"

   exec_command "zfs mount" "ZFS mount status"

   exec_command "zfs get all" "ZFS properties"

   exec_command "zpool list -H" "ZFS pool status"

   exec_command "zpool list -Ho bootfs" "ZFS boot pool"

   exec_command "zpool upgrade" "ZFS pool version"

   exec_command "zpool history" "ZFS pool history"

  dec_heading_level
fi
# terminates CFG_VOLMGR wrapper

#
# CFG_CLUSTER
#
if [ "$CFG_CLUSTER" != "no" ]
then # else skip to next paragraph
   paragraph "Clustering"
   inc_heading_level

   exec_command "hastctl list" "Highly Available Storage resources"

   exec_command "hastctl status" "Highly Available Storage status"

   dec_heading_level
fi
# terminates CFG_CLUSTER wrapper

#
# CFG_CRON
#
if [ "$CFG_CRON" != "no" ]
then # else skip to next paragraph
   paragraph "Cron and At"
   inc_heading_level

   [ -r /etc/crontab ] && exec_command "cat /etc/crontab" "System-wide /etc/crontab"

   usercron="/var/cron/tabs"

   ls $usercron/* > /dev/null 2>&1
   if [ $? -eq 0 ]
   then
      _echo  "\n\n<B>Crontab files:</B>" >> $HTML_OUTFILE_TEMP
      for FILE in $usercron/*
      do
         exec_command "grep -v ^# $FILE" "For user $(basename $FILE)"
      done
   else
      echo "No crontab files for user.<br>" >> $HTML_OUTFILE_TEMP
   fi

   [ -r /var/cron/allow ] && exec_command "cat /var/cron/allow" "Users allowed to use cron"

   [ -r /var/cron/deny ] && exec_command "cat /var/cron/deny" "Users prohibited to use cron"

   exec_command "at -l" "AT Scheduler"

   [ -r /var/at/at.allow ] && exec_command "cat /var/at/at.allow" "Users allowed to use at"

   [ -r /var/at/at.deny ] && exec_command "cat /var/at/at.deny" "Users prohibited to use at"

   dec_heading_level
fi
# terminates CFG_CRON wrapper

#
# CFG_HARDWARE
#
if [ "$CFG_HARDWARE" != "no" ]
then # else skip to next paragraph
   paragraph "Hardware"
   inc_heading_level

   exec_command "dmidecode" "DMI (SMBIOS) table"

   exec_command "biosdecode" "BIOS information decoder"

   exec_command "vpddecode" "Vital Product Data (VPD) decoder"

   OWN="$(ownership)"

   if [ "$OWN" ] ; then
      exec_command "ownership" "Compaq ownership tag retriever"
   fi

   exec_command "pciconf -l -cv" "PCI devices"

   exec_command "sysctl dev" "Configured devices"

   exec_command "usbdevs -v" "USB devices"

   exec_command "atacontrol list" "ATA devices"

   exec_command "camcontrol devlist -v" "SCSI devices"

   exec_command "scanpci -v" "Scan PCI"

   exec_command "iscsictl -L" "iSCSI initiator sessions"

   exec_command "iscsiadm list target -v" "iSCSI targets"

   exec_command "mptutil show adapter" "FC/SAN controller information"

   exec_command "mptutil show drives" "FC/SAN physical drives"

   exec_command "mptutil show volumes" "FC/SAN logical volumes"

   exec_command "mptutil show config" "FC/SAN RAID configuration"

   dec_heading_level

fi
# terminates CFG_HARDWARE wrapper

#
# CFG_SOFTWARE
#
if [ "$CFG_SOFTWARE" != "no" ]
then # else skip to next paragraph
   paragraph "Software"
   inc_heading_level

   if [ -x /usr/sbin/pkg ]
   then
       exec_command "pkg info" "Package status" 

       exec_command "pkg version -v" "Package update status" 

       exec_command "pkg stats" "Package statistics" 

       exec_command "pkg plugins" "Package plugins"
   else
       exec_command "pkg_info" "Package status" 

       exec_command "pkg_version -v" "Package update status" 
   fi

  dec_heading_level
fi
# terminates CFG_SOFTWARE wrapper

#
# CFG_LICENSE
#
if [ "$CFG_LICENSE" != "no" ]
then # else skip to next paragraph
   paragraph "Licenses"
   inc_heading_level

   exec_command "find /usr/ports/ -name 'Makefile' -exec fgrep -H "LICENSE=" {} \;" "License types in Ports Collection"

   exec_command "lmgrd status" "FlexLM license"

   dec_heading_level
fi
# terminates CFG_LICENSE wrapper

#
# CFG_FILESYS
#
if [ "$CFG_FILESYS" != "no" ]
then # else skip to next paragraph
   paragraph "Filesystems, Dump and Swap configuration"
   inc_heading_level

   exec_command "grep -v ^# /etc/fstab" "/etc/fstab"

   exec_command "df -k -h -a" "Filesystems usage"

   for dd in $(df -t ufs | awk '! /Filesystem/ {print $1}') 
   do
      exec_command "dumpfs $dd" "Dumpfs for UFS $dd"
   done

   exec_command "df -i" "Filesystem inode status"

   exec_command "snapinfo -a" "UFS Filesystem snapshots"

   exec_command "fstat" "Active file statistics"

   exec_command "sockstat" "Open socket statistics"

   exec_command "nfsstat -s" "NFS server statistics"

   exec_command "nfsstat -c" "NFS client statistics"

   exec_command "dumpon -v -l" "Crash dump device status"

   exec_command "swapinfo" "Paging devices (swap)"

   exec_command "mount" "Local mountpoints"

   EXPORTCFG="/etc/exports"

   if [ -f "$EXPORTCFG" ] ; then
      exec_command "grep -v ^# $EXPORTCFG" "NFS filesystems in $EXPORTCFG"
   fi

   exec_command "showmount -a" "Remote filesystem mounts"

   dec_heading_level
fi
# terminates CFG_FILESYS wrapper

#
# CFG_DISKS
#
if [ "$CFG_DISKS" != "no" ] ; then
   paragraph "Disks"
   inc_heading_level

   exec_command "gpart list" "Gpart disk summary"

   exec_command "fdisk -p" "Short disk summary"

   exec_command "mdconfig -l" "Memory disk summary"

   exec_command "nvmecontrol devlist" "NVM Express storage devices"

   exec_command "quotacheck -a -v" "Disk quota check"

   dec_heading_level
fi
# terminates CFG_DISKS wrapper

#
# CFG_NETWORK
#
if [ "$CFG_NETWORK" != "no" ]
then # else skip to next paragraph
   paragraph "Network Settings"
   inc_heading_level

   exec_command "ifconfig -a" "Ifconfig status"

   exec_command "netstat -an" "List of all sockets"

   exec_command "netstat -in" "List of all network interfaces"

   exec_command "netstat -rn" "List of all routing table entries"

   exec_command "netstat -s" "Summary statistics for each protocol"

   exec_command "arp -a" "ARP table"

   for HFILE in /etc/hostname*
   do
      if [ -f "$HFILE" ]
      then
          exec_command "cat $HFILE" "$HFILE"
      fi
   done

   exec_command "etherswitchcfg info" "Built-in Ethernet switch"

   if [ -f /etc/dhclient.conf ]
   then
       exec_command "cat /etc/dhclient.conf" "DHCP client /etc/dhclient.conf"
   fi

   if [ -f /etc/dhcpd.conf ]
   then
       exec_command "cat /etc/dhcpd.conf" "DHCP server /etc/dhcpd.conf"
   fi

   exec_command "cat /etc/networks" "/etc/networks"

   exec_command "cat /etc/netconfig" "/etc/netconfig"

   exec_command "cat /etc/resolv.conf" "DNS resolver /etc/resolv.conf"

   exec_command "nawk NF /etc/nscd.conf" "Name Service Cache Daemon /etc/nscd.conf"

   exec_command "cat /etc/nsswitch.conf" "Name service configuration /etc/nsswitch.conf"

   exec_command "cat /etc/host.conf" "Name service configuration /etc/host.conf"

   exec_command "ypwhich 2>&1" "NIS server status"

   exec_command "domainname" "NIS domainname"

   exec_command "nslookup $(hostname)" "FQDN nslookup local system"

   exec_command "netstat -gi" "Interfaces"

   exec_command "egrep -v ^# /etc/hosts" "/etc/hosts"

   exec_command "ipfw set show" "Firewall status"

   exec_command "pfctl -vvsTables" "Packet filter tables"

   exec_command "ipnat -l -s -v" "IP Filter NAT status"

   exec_command "ipfstat -a" "Packet filter statistics"

   exec_command "tcpdchk -v" "Tcpd wrapper"

   exec_command "tcpdchk -a" "Tcpd warnings"

   [ -f /etc/hosts.allow ] && exec_command "egrep -v ^# /etc/hosts.allow | nawk NF" "/etc/hosts.allow"
  
   [ -f /etc/hosts.deny ] && exec_command "egrep -v ^# /etc/hosts.deny | nawk NF" "/etc/hosts.deny"

   if [ -f /etc/rtadvd.conf ] ; then
      exec_command "cat /etc/rtadvd.conf" "Router advertisement daemon config"
   fi

   if [ -f /etc/rrenumd.conf ] ; then
      exec_command "cat /etc/rrenumd.conf" "Router renumbering daemon config"
   fi

   exec_command "egrep -v ^# /etc/inetd.conf" "Internet Daemon Configuration"

   exec_command "cat /etc/services" "Internet Daemon Services"

   exec_command "cat /etc/protocols" "/etc/protocols"

   exec_command "cat /etc/rpc" "/etc/rpc"

   exec_command "rpcinfo -p " "RPC (Portmapper)"

   exec_command "ntpq -p" "NTP peers"

   exec_command "ntpq -c as" "NTP associations"

   exec_command "ntpq -c rv" "NTP variables"

   dec_heading_level
fi
# terminates CFG_NETWORK wrapper

#
# CFG_PRINTER
#
if [ "$CFG_PRINTER" != "no" ] ; then
   paragraph "Printers"
   inc_heading_level

   exec_command "lpc status all" "BSD Printer Spooler and Printers"

   exec_command "lpq -a -l" "Printer job queue status"

   [ -r /etc/printcap ] && exec_command "egrep -v ^# /etc/printcap" "Printcap"

   exec_command "chkprintcap" "Check printcap"
   AddText "The output should be empty!"

   [ -r /etc/hosts.lpd ] && exec_command "egrep -v ^# /etc/hosts.lpd" "Trusted hosts that may use local print services"

   dec_heading_level
fi
# terminates CFG_PRINTER wrapper

#
# CFG_KERNEL
#
if [ "$CFG_KERNEL" != "no" ]
then # else skip to next paragraph
   paragraph "Kernel, Modules and Libraries" "Kernel parameters"
   inc_heading_level

   exec_command "kldstat -v" "System dynamic kernel linker"   

   exec_command "kldconfig -r" "System kernel module search path"   

   exec_command "ldconfig -r" "Shared library hints file"   

   if [ -f /boot/loader.conf ] ; then
      exec_command "cat /boot/loader.conf" "/boot/loader.conf"
   fi

   exec_command "sysctl -a | nawk NF" "System kernel state"   

   exec_command "pstat -f" "Open file table"

   dec_heading_level
fi
# terminates CFG_KERNEL wrapper

#
# CFG_PASSWD
#
if [ "$CFG_PASSWD" != "no" ] ; then
   paragraph "Password and group consistency"
   inc_heading_level

   exec_command "cat /etc/passwd" "/etc/passwd"

   for pw in $(awk -F: '{print $6}' /etc/passwd | sort | uniq) 
   do
      if [ -f "$pw/.rhosts" ] ; then
         exec_command "cat $pw/.rhosts" "$pw/.rhosts"
         AddText "The output should be empty!"
      fi
   done

   exec_command "cat /etc/master.passwd" "BSD equivalent of shadow file"

   exec_command "cat /etc/login.conf" "Login configuration file"

   exec_command "cat /etc/login.access" "Login access configuration file"

   exec_command "cat /etc/ttys" "Terminal configuration file"

   exec_command "cat /etc/shells" "Valid Shells"

   for FILE in /etc/pam.d/*
   do
      exec_command "grep -v ^# $FILE" "PAM config file $FILE"
   done

   for SFILE in /etc/security/*
   do
      exec_command "grep -v ^# $SFILE" "Audit config file $SFILE"
   done

   exec_command "logins -p" "Unix logins without passwords"
   AddText "The output should be empty!"

   exec_command "logins -a -o" "Unix logins password change and expiration times"

   exec_command "logins -d" "Unix logins with duplicate UIDs"

   exec_command "cat /etc/group" "Unix group file"

   exec_command "who" "Current logged-in users"

   dec_heading_level
fi
# terminates CFG_PASSWD wrapper

#
# CFG_FILES
#
if [ "$CFG_FILES" != "no" ] ; then
   paragraph "Startup Scripts"
   inc_heading_level

   files()
   {
      ls /etc/rc.* /etc/rc.d/* | grep -v "^[A-Z}|^[a-z]" 
   }

   COUNT=1

   for FILE in $(files)
   do
      if [ -f ${FILE} ]
      then
         exec_command "cat ${FILE}" "${FILE}"
         COUNT=$(expr $COUNT + 1)
      fi
   done

   exec_command "service -r" "Boot time RC order"

   exec_command "service -e" "Enabled RC services"

   dec_heading_level
fi
# terminates CFG_FILES wrapper

#
# CFG_APPLICATIONS
#
if [ "$CFG_APPLICATIONS" != "no" ]
then # else skip to next paragraph
    paragraph "Applications and Subsystems"
    inc_heading_level

   exec_command "smbstatus 2>/dev/null" "Samba (smbstatus)"

   exec_command "testparm -s 2>/dev/null" "Samba Configuration (testparm)"

   if [ -x /usr/local/bin/puppet ]
   then
      dec_heading_level
      paragraph "Puppet Configuration Management System"
      inc_heading_level

      exec_command "puppet agent -V" "Puppet Client agent version"

      exec_command "puppet status master" "Puppet Server status"

      exec_command "puppet config print all" "Puppet configuration"

      exec_command "puppet config print modulepath" "Puppet configuration module paths"

      exec_command "puppet ca list --all" "Puppet certificates"

      exec_command "puppet resource user" "Users in Puppet Resource Abstraction Layer (RAL)"

      exec_command "puppet resource package" "Packages in Puppet Resource Abstraction Layer (RAL)"

      exec_command "puppet resource service" "Services in Puppet Resource Abstraction Layer (RAL)"

      dec_heading_level
   fi # puppet


   CHEFSRV="$(chef-server-ctl 2>/dev/null)"
   if [ "$CHEFSRV" ]
   then
      paragraph "Chef Configuration Management System"
      inc_heading_level

      exec_command "chef-server-ctl test" "Chef Server"

      exec_command "knife list -R /" "Chef full status"

      exec_command "knife environment list -w" "Chef list of environments"

      exec_command "knife client list" "Chef list of registered API clients"

      exec_command "knife cookbook list" "Chef list of registered cookbooks"

      exec_command "knife data bag list" "Chef list of data bags"

      exec_command "knife diff" "Chef differences between local chef-repo and files on server"

      exec_command "chef-client -v" "Chef Client"

      dec_heading_level
   fi

   if [ -x /var/cfengine/bin/cfagent ]
   then
      ###  CFEngine settings
      paragraph "CFEngine Configuration Management System"
      inc_heading_level

      exec_command "ps augxww | grep -E 'cfserv[d]|cf-server[d]'" "Active CFEngine Server"

      exec_command "ps augxww | grep -E 'cfagen[t]|cf-agen[t]'" "Active CFEngine Agent"

      exec_command "cfagent -V" "CFEngine v2 Agent version"

      exec_command "cfagent -p -v" "CFEngine v2 classes"

      exec_command "cfagent --no-lock --verbose --no-splay" "CFEngine v2 managed client status"

      exec_command "cfagent -n" "CFEngine v2 pending actions for managed client (dry-run)"

      exec_command "cfshow --active" "CFEngine v2 dump of active database"

      exec_command "cfshow --classes" "CFEngine v2 dump of classes database"

      exec_command "cf-serverd --version" "CFEngine v3 Server version"

      exec_command "cf-agent --version" "CFEngine v3 Agent version"

      exec_command "cf-report -q --show promises" "CFEngine v3 promises"

      exec_command "cf-promises -v" "CFEngine v3 validation of policy code"

      exec_command "cf-agent -n" "CFEngine v3 pending actions for managed client (dry-run)"

      dec_heading_level
   fi # CFEngine

   exec_command "saphostexec -version" "Installed SAP Components"

   exec_command "ps -efl | grep -i ' pf[=]'" "Active SAP Processes"

   [ -f /etc/sapconf ] && exec_command "cat /etc/sapconf" "Local configured SAP R3 instances"

   if [ -s /etc/oratab ] ; then    # exists and >0
      exec_command "egrep -v ^# /etc/oratab " "Configured Oracle DB startups in /etc/oratab" 

      for DB in $(grep ':' /etc/oratab|egrep -v '^#|:N$') 
      do
         Ora_Home=$(echo $DB | awk -F: '{print $2}')
         Sid=$(echo $DB | awk -F: '{print $1}')
         Init=${Ora_Home}/dbs/init${Sid}.ora
         if [ -r "$Init" ]
         then
            exec_command "cat $Init" "Oracle Instance $Sid"
         else
            AddText "WARNING: obsolete entry $Init in /etc/inittab for SID $Sid!"
         fi
      done
   fi

   exec_command "/bin/su - informix -c \"onstat -l\"" "Configured Informix databases"

   exec_command "aide -v" "AIDE status"

   TWIRE=$(twadmin --print-cfgfile)
   
   if [ "$TWIRE" ]
   then
       exec_command "echo $TWIRE" "Tripwire status"
   else
       exec_command "tripwire -preprocess" "Tripwire status"
   fi
 
dec_heading_level
fi
# terminates CFG_APPLICATIONS wrapper

#
# execute system log check
#
paragraph "System logs"
inc_heading_level
exec_command "cat /etc/syslog.conf" "/etc/syslog.conf" 

exec_command "tail -500 /var/log/messages" "Recent /var/log/messages"

exec_command "dmesg" "dmesg logfile" 

dec_heading_level

#
# execute Mail Transfer Agent check 
#
paragraph "Standard Mail Transfer Agents"
inc_heading_level

exec_command "cat /etc/mail/mailer.conf" "Default Mail Transfer Agent" 

POSTFIXCFG="$(postconf -n)"
if [ "$POSTFIXCFG" ]; then
   AddText "MTA is seemingly Postfix"

   exec_dommand "postconf -n" "Postfix configuration summary"

   for PFILE in /etc/postfix/*.cf
   do
      [ -s "$PFILE" ] && exec_command "cat $PFILE" "Postfix config file $PFILE"
   done

   exec_command "showq" "Postfix mail queue"

   exec_command "qshape" "Postfix queue shape"
fi
 
MAILSTATS="$(mailstats)"
if [ "$MAILSTATS" ]; then
   AddText "MTA is seemingly Sendmail"

   for SFILE in /etc/mail/*.cf
   do
      [ -s "$SFILE" ] && exec_command "cat $SFILE" "Sendmail config file $SFILE"
   done

   exec_command "mailq" "Sendmail mail queue"

   exec_command "cat /etc/aliases" "Sendmail aliases"

   exec_command "mailstats" "Sendmail mail statistics"
fi

EXIMCHK="$(exiwhat)"
if [ "$EXIMCHK" ]; then
   AddText "MTA is seemingly Exim"

   exec_command "exim -bP" "Exim configuration settings"

   exec_command "exim -bp" "Exim mail queue"
fi

dec_heading_level

#
# execute banners check 
#
paragraph "Banners"
inc_heading_level

exec_command "cat /etc/motd" "/etc/motd"

exec_command "cat /etc/issue" "Generic banner /etc/issue" 

for FTPF in /etc/ftpmotd /etc/ftpwelcome
do
   if [ -f "$FTPF" ]
   then
       exec_command "cat $FTPF" "FTP banner $FTPF" 
   fi
done

exec_command "cat /var/log/nologin" "Disable login banner /var/log/nologin" 

dec_heading_level

#
# execute FTP check 
#
paragraph "FTP Services"
inc_heading_level

exec_command "cat /etc/ftpusers" "/etc/ftpusers"

dec_heading_level

#
# execute custom plugins
#
if [ "$CFG_PLUGINS" != "no" ];
then # else skip to next paragraph
    if [ -d $PLUGIN ]; then
    paragraph "Custom plugins"

    inc_heading_level

    # include all plugins
    CFG2HTML_PLUGINS="$(ls -1 $PLUGIN)"

    for cfgplugin in $CFG2HTML_PLUGINS; do
       if [ -x "${PLUGIN}/$CFG2HTML_PLUGIN" ]; then
          exec_command "${PLUGIN}/$CFG2HTML_PLUGIN" "${PLUGIN}/$CFG2HTML_PLUGIN" 
       else
          AddText "Configured plugin $CFG2HTML_PLUGIN not found in $PLUGIN"
       fi
    done

    dec_heading_level
    fi
fi

## end of plugin processing

#
# collect local files
#
# CFG_LOCAL
#
if [ "$CFG_LOCAL" != "no" ]
then # else skip to next paragraph
   if [ -f $CONFIG_DIR/files ] ; then
      paragraph "Local files"
      inc_heading_level

      for i in $(cat $CONFIG_DIR/files)
      do
         if [ -f $i ] ; then
            exec_command "egrep -v ^# $i" "File: $i"
         fi
      done
      AddText "You can customize this entry by editing ${CONFIG_DIR}/files"

      dec_heading_level
   fi
fi

close_html

logger "End of $VERSION"
_echo "\n"
line

logger "End of $VERSION"
rm -f core > /dev/null

########## remove the error.log if it has size zero #######################
[ ! -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

exit 0
