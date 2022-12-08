# @(#) $Id: cfg2html-SunOS.sh,v 1.5 2014/05/20 10:41:38 dusan Exp dusan $
# -----------------------------------------------------------------------------------------
# (c) 1997-2023 by Ralph Roth  -*- http://rose.rult.at -*-

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
 #####  #     # #     # #######  #####
#       #     # # #   # #     # #
 #####  #     # #  #  # #     #  #####
#     # #     # #    ## #     # #     #
 #####   #####  #     # #######  #####
#  system collector script
#
# SunOS/Solaris collectors next generation (cfg2html 6.xx) maintained by
# Dusan Baljevic (dusan.baljevic@ieee.org)
# ---------------------------------------------------------------------------

PATH=$PATH:/usr/bin:/usr/sbin:/local/gnu/bin:/usr/ccs/bin:/local/X11/bin
PATH=$PATH:/usr/openwin/bin:/usr/dt/bin:/usr/proc/bin:/usr/ucb
PATH=$PATH:/etc/vx/bin:/opt/samba/bin:/opt/VRTSvcs/vxfen/bin:/opt/VRTSvxfs/bin
PATH=$PATH:/opt/VRTSdbed/bin:/opt/VRTSdb2ed/bin:/opt/VRTS/vxse/vxvm
PATH=$PATH:/opt/omni/bin:/opt/omni/lbin:/opt/omni/sbin:/usr/openv/netbackup
PATH=$PATH:/usr/openv/netbackup/bin:/usr/openv/netbackup/bin/goodies
PATH=$PATH:/var/cfengine/bin:/opt/EMCpower/bin:/opt/local/bin:/usr/cluster/bin
PATH=$PATH:/opt/OV/bin/OpC/utils:/opt/OV/bin:/opt/flexlm/bin
PATH=$PATH:/opt/chef-server/bin:/opt/chef-server/embedded/bin:/opt/chef/bin
PATH=$PATH:/usr/sap/hostctrl/exe:/opt/SUNWsamfs/bin:/opt/SUNWsamfs/sbin
PATH=$PATH:/opt/netapp/santools/bin:/opt/Ontap/santools/bin:/usr/symcli/bin
PATH=$PATH:/opt/SUNWexplo/bin

# Counter for stat commands
STATCNT="1 10"

OSREV=$(uname -r | cut -d. -f2)

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

_VERSION="cfg2html-SunOS version $VERSION "  

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
   paragraph "SunOS/Solaris System"
   inc_heading_level

   if [ -f $CONFIG_DIR/systeminfo ] ; then
      exec_command "cat $CONFIG_DIR/systeminfo" "System description"
   fi

   exec_command "hostname" "Hostname"

   exec_command "devnm /" "Root file system device"

   exec_command "hostid" "Hostid"

   exec_command "uname -n" "Host aliases"

   exec_command "uname -sr" "OS, Kernel version"

   exec_command "uname -X" "Extended uname status"

   [ -r /etc/release ] && exec_command "cat /etc/release" "OS specific release information /etc/release"

   exec_command "uname -mi" "Hardware type"

   exec_command "prtconf | awk '/^Memory size:/ { print \$3 }'" "Memory size (MB)"

   exec_command "pagesize" "Pagesize (bytes)"

   exec_command "psrinfo -v" "CPUs"

   exec_command "isainfo -kv" "Kernel instruction set"

   exec_command "isainfo -b" "Native instruction set"

   if [ -x "/usr/platform/$(uname -m)/sbin/eeprom" ]; then
      exec_command "/usr/platform/$(uname -m)/sbin/eeprom" "Eeprom"
   else
      exec_command "eeprom" "Eeprom"
   fi

   exec_command "consadm list" "Aux console status"

   if [ -x "/usr/platform/$(uname -i)/rsc/rscadm" ]; then
      exec_command "/usr/platform/$(uname -i)/rsc/rscadm shownetwork" "RSC console"

      exec_command "/usr/platform/$(uname -i)/rsc/rscadm status" "RSC console status"
   fi

   if [ -x "/usr/platform/$(uname -i)/sbin/scadm" ]; then
      exec_command "/usr/platform/$(uname -i)/sbin/scadm shownetwork" "SCadm console"

      exec_command "/usr/platform/$(uname -i)/sbin/scadm status" "SCadm console status"
   fi

   exec_command "who -r | awk '/run-level/ {print \$3}'" "Runlevel"

   exec_command "locale" "locale specific information"

   exec_command "ulimit -a" "System ulimit" 

   exec_command "getconf -a" "System kernel configuration"   

   exec_command "mpstat $STATCNT" "Multiprocessor Statistics"

   exec_command "lgrpinfo -Ta" "Locality groups"

   if [ "$OSREV" -ge 10 ] ; then
      IOFLAG="CTdrzY"
   fi

   exec_command "iostat -xcn${IOFLAG} $STATCNT" "I/O Statistics"

   exec_command "vmstat $STATCNT" "VM Statistics"

   exec_command "trapstat $STATCNT" "Trap Statistics"

   # sysutils
   exec_command "uptime" "Uptime"

   exec_command "acctadm" "Extended System Accounting facility"

   exec_command "auditconfig -getpolicy" "Auditing facility"

   exec_command "sar $STATCNT" "System Activity Report"

   exec_command "sar -b $STATCNT" "Buffer Activity"

   if [ "$OSREV" -ge 10 ] ; then
      PSFLAG="Z"
   fi

   exec_command "ps -efl${PSFLAG}" "Processes"

   exec_command "${PLUGIN}/detailed-process-stat.pl" "${PLUGIN}/detailed-process-stat.pl"

   exec_command "ptree -a -c" "Active Process - Tree Overview"

   exec_command "psrset" "Processor sets"

   exec_command "rcapstat" "Resource cap enforcement statistics"

   if [ "$OSREV" -ge 10 ] ; then
      exec_command "ppriv -lv" "Process privilege sets and attributes"
   fi

   exec_command "crle" "Runtime linking environment"

   exec_command "ctstat -v -a" "System contracts" 

   exec_command "ps -e -o ruser,pid,args | awk ' (($1+1) > 1) {print \$0;} '" "Processes without named owner" 
   AddText "The output should be empty!"

   exec_command "lockstat sleep 10" "Kernel lock and profiling statistics"

   exec_command "dispadmin -l | nawk NF" "Process scheduler"

   exec_command "rctladm -l" "Global state of system resource controls"

   exec_command "kstat" "Kernel statistics"

   exec_command "vxmemstat" "VxVM memory statistics"

   if [ "$OSREV" -ge 9 ] ; then
      exec_command "echo "::memstat" | mdb -k" "Memory distribution"
   fi
       
  exec_command "ps -efl | sort -nr | head -25" "Top load processes"

  exec_command "ps -e -o 'vsz pid ruser time args' |sort -nr|head -25" "Top memory consuming processes"

  exec_command "prstat -S cpu -c 1 1 | head -25" "Top CPU consuming processes"

  exec_command "prstat -S pri -c 1 1 | head -25" "Top priority processes"

  exec_command "last| grep boot" "reboots"

  exec_command "bootadm list-archive" "Boot status of GRUB-enabled systems"

  exec_command "bootadm list-menu" "Boot list menu of GRUB-enabled systems"

  exec_command "biosdev" "BIOS devices"

  [ -r /etc/inittab ] && exec_command "egrep -v ^# /etc/inittab" "/etc/inittab"

  exec_command "ipcs -a" "IPC Status"

   dec_heading_level
   paragraph "LOM Console"
   inc_heading_level

   exec_command "lom -c" "LOM config"

   exec_command "lom -a" "LOM console status"

   dec_heading_level
   paragraph "ILOM Console"
   inc_heading_level
   exec_command "ilomconfig" "ILOM config"

   dec_heading_level
   paragraph "Sun Web Console"
   inc_heading_level

   exec_command "smreg list" "Sun Web console status"

   exec_command "smcwebserver status" "Sun Web console webserver"

   exec_command "wcadmin list -a" "Sun Web console configuration"
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

   [ -r /etc/sysidcfg ] && exec_command "cat /etc/sysidcfg" "Jumpstart install parameters /etc/sysidcfg"

   [ -r /etc/bootparams ] && exec_command "egrep -v ^# /etc/bootparams" "Jumpstart /etc/bootparams"

   if [ "$OSREV" -ge 11 ] ; then
      exec_command "installadm list -m" "Automated installation services status"

      exec_command "installadm list -p" "Automated installation services profile status"

      exec_command "installadm list -c" "Automated installation services client status"
   fi

   [ -r /etc/netboot/wanboot.conf ] && exec_command "cat /etc/netboot/wanboot.conf" "WAN boot /etc/netboot/wanboot.conf"

   [ -r /etc/netboot/wanboot.conf ] && exec_command "bootconfchk /etc/netboot/wanboot.conf" "WAN boot configuration check"

   [ -r /etc/lutab ] && exec_command "cat /etc/lutab" "Live Upgrade /etc/lutab"

   exec_command "lustatus" "Live Upgrade status"

   exec_command "beadm list -a" "ZFS boot environments"

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

   if [ "$OSREV" -ge 10 ] ; then
      exec_command "zfs mount" "ZFS mount status"

      exec_command "zfs get all" "ZFS properties"

      exec_command "zpool list -H" "ZFS pool status"

      exec_command "zpool list -Ho bootfs" "ZFS boot pool"

      exec_command "zpool upgrade" "ZFS pool version"

      exec_command "zpool history" "ZFS pool history"
   fi

   exec_command "metadb" "SVM metadb replicas"

   exec_command "metastat" "SVM metadevice status"

   exec_command "metastat -i" "SVM meta database status"

   exec_command "metastat -c" "SVM metastat in concise format"

   exec_command "metaset" "SVM metaset"

   exec_command "fsmadm status" "Sun SAMFS/QFS status"

   exec_command "vxdctl list" "Vxdctl status"

   exec_command "vxinfo" "Vxinfo status"

   exec_command "vxdg list" "Vxdg status"

   exec_command "vxdg free" "Vxdg free space status"

   exec_command "vxprint -htvq" "Vxprint status"

   exec_command "vxdmpadm listctlr all" "VxVM DMP status"

   exec_command "vxtask -h list" "VxVM running tasks"

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

   VCSCLUS="$(haclus -display | awk '/ClusterName/ {print \$2}')"
   if [ "$VCSCLUS" ]; then
      echo "Cluster nodes in VCS: $VCSCLUS"
      hasys -list | while read NODENAME
      do
        export NODENAME
        echo "VCS node: $NODENAME state: $(hasys -state $NODENAME |awk '{print \$1}')"
      done
   fi 

   # Check for VCS Software #
   $PLUGIN/VCS_plugin.sh check
   if [ $? ]; then
      #Exited 0, VCS is found. Run the Script#
   
      # Check the VCS Application Version #
      exec_command "$PLUGIN/VCS_plugin.sh version" "VCS Version"

      # Check the status of the Cluster #
      exec_command "$PLUGIN/VCS_plugin.sh status" "VCS Status"

      # Check status of the Cluster heartbeats #
      exec_command "$PLUGIN/VCS_plugin.sh lltstat" "LLT/Heartbeat Status"

      # Display the VCS Configuration File (main.cf) #
      exec_command "$PLUGIN/VCS_plugin.sh main" "VCS Configuration File"

      # Display the LLT / Heartbeat  Configuration File (llttab) #
      exec_command "$PLUGIN/VCS_plugin.sh llttab" "LLT/Heartbeat Configuration File"
   fi

   exec_command "dsstat -m ii -m sndr -m cache $STATCNT" "Sun StorageTek Availability Suite I/O statistics"

   exec_command "sndradm -i" "Sun Network Data Replication (SNDR) volume status"

   exec_command "sndradm -H" "Sun Network Data Replication (SNDR) link status"

   exec_command "clinfo -h" "Sun Cluster"

   exec_command "scinstall -pv" "Sun Cluster version"

   exec_command "scha_cluster_get -O CLUSTERNAME" "Sun Cluster details"

   exec_command "scha_cluster_get -O ALL_NODENAMES" "Sun Cluster nodenames"

   exec_command "scha_cluster_get -O ALL_RESOURCEGROUPS" "Sun Cluster resourcegroups"

   exec_command "scstat -q" "Sun Cluster device and node quorum"

   exec_command "scstat -g" "Sun Cluster resource groups"

   exec_command "scstat -pv" "Sun Cluster components"

   exec_command "scdpm -p" "Sun Cluster disk path info"

   exec_command "scnas -p" "Sun Cluster NAS info"

   exec_command "scnasdir -p" "Sun Cluster NAS directories info"

   exec_command "scrgadm -p" "Sun Cluster registered resources"

   exec_command "scconf -pv" "Sun Cluster scconf report"

   exec_command "scdidadm -L" "Sun Cluster scdidadm report"

   exec_command "sndradm -P" "Sun Network Data Replication (SNDR) detailed software status"

   exec_command "iiadm -i" "Instant Image (II) status"

   exec_command "raidqry -l" "Continentalcluster/Metrocluster status"

   exec_command "raidqry -l -f" "Continentalcluster/Metrocluster floatable hosts"
   exec_command "horcctl -D" "Horcttl status"

   exec_command "cmviewconcl -v" "Cmviewconcl status"

   exec_command "cmquerycl -v" "Cmquerycl status"

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

   usercron="/var/spool/cron/crontabs"

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

   ls /etc/cron.d/* > /dev/null 2>&1
   if [ $? -eq 0 ]
   then
      _echo "\n\n<br><B>/etc/cron.d files:</B>" >> $HTML_OUTFILE_TEMP
      for FILE in /etc/cron.d/*
      do
         exec_command "grep -v ^# $FILE" "For utility $(basename $FILE)"
      done
   else
      echo "No /etc/cron.d files for utilities." >> $HTML_OUTFILE_TEMP
   fi

   exec_command "at -l" "AT Scheduler"

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

   if [ -x "/usr/platform/$(uname -m)/sbin/prtdiag" ]; then
      exec_command "/usr/platform/$(uname -m)/sbin/prtdiag -v" "Prtdiag"
   else
      exec_command "prtdiag -v" "Prtdiag"
   fi

   exec_command "prtconf -v" "Prtconf"

   PATHINST="/etc/path_to_inst"

   if [ -f "$PATHINST" ] ; then
      exec_command "cat $PATHINST" "Device instance number file ($PATHINST)"
   fi

   exec_command "getdevpolicy" "System device policy"

   exec_command "prtpicl -v" "Prtpicl tree"

   exec_command "sysdef" "Sysdef"

   exec_command "sgscan" "Sgscan status"

   exec_command "scanpci -v" "Scan PCI"

   exec_command "lshal" "HAL devices"

   exec_command "devreserv" "Devices currently reserved for exclusive use"

   exec_command "iostat -En" "I/O device error status"

   exec_command "stmsboot -L" "Solaris I/O multipathing (STMS and MPxIO)"

   exec_command "raidctl" "Hardware RAID status"

   exec_command "luxadm probe" "SunFire 880 and FC-AL device status"

   exec_command "luxadm display" "Luxadm display"

   exec_command "cfgadm -la" "Cfgadm status"

   exec_command "ssmadmin -view" "Ssmadmin status"

   exec_command "fcinfo logical-unit -v" "FC logical units"

   exec_command "fcinfo hba-port" "HBAs"

   exec_command "autopath display all" "AuthoPath status"

   exec_command "hrdconf -l" "Fujitsu hrdconf for SPARC servers"

   exec_command "fwflash -l" "Firmware query"

   exec_command "xpinfo -i" "Hitachi/XP SAN xpinfo status"

   exec_command "powermt display dev=all" "EMC SAN powermt status"

   exec_command "symcfg list -v" "EMC Symmetrix SAN status"

   exec_command "navicli getagent" "EMC Clariion SAN status"

   exec_command "navicli getlun" "EMC Clariion LUN status"

   exec_command "apconfig -S" "Alternate Pathing for disks"

   exec_command "inqraid" "Hitachi/XP SAN inqraid status"

   exec_command "evainfo -a -l" "EVA SAN evainfo status"

   exec_command "evadiscovery -l" "EVA SAN discovery"

   exec_command "HP3PARInfo -i" "HP 3PAR SAN hp3parinfo short status"

   exec_command "HP3PARInfo -f" "HP 3PAR SAN LUNs"

   exec_command "sanlun lun show all" "NetApp LUNs"

   exec_command "iscsiadm list target -v" "iSCSI targets"

   exec_command "iscsiadm list initiator-node" "iSCSI initiator nodes"

   exec_command "iscsiadm list static-config" "iSCSI static configuration"

   exec_command "iscsiadm list discovery" "iSCSI discovery"

   exec_command "iscsiadm list target -v" "iSCSI targets"

   exec_command "mpathadm list initiator-port" "Mpathadm initiator ports"

   dec_heading_level

   paragraph "Domains and Containers"
   inc_heading_level

   exec_command "domain_status -m" "E10K domain status"

   exec_command "showfailover" "Failover on system controllers"

   exec_command "smsconfig -v" "SMS network setup"

   exec_command "showenvironment" "Environmental data"

   exec_command "showplatform" "Platform data"

   exec_command "showcomponent -v" "Blacklist status of components"

   exec_command "zonename" "Zonename status"

   exec_command "pooladm" "Resource pool status"

   exec_command "poolstat -r all" "Rool status for all resources"

   exec_command "zoneadm list -cv" "Configured zones"

   zones=$(zoneadm list -c)
   for zone in $zones; do
      exec_command "zonecfg -z $zone export" "Configuration for zone $zone"
   done

   exec_command "zonestat -q -r summary -z 5 -T i -R high $STATCNT" "Zone statistics"

   exec_command "zonep2vchk" "Global zone's P2V migration"

   exec_command "ldominfo -p" "Ldominfo"

   exec_command "virtinfo -a" "Virtinfo"

   exec_command "ldm -V" "Logical Domains (LDoms)"

   exec_command "ldm list-domain" "Logical Domains listing"

   exec_command "ldm list-config" "Logical Domains configuration"

   exec_command "ldm list-services" "Logical Domains services"

   exec_command "ldm list-bindings" "Logical Domains bindings"

   exec_command "ldm list-devices -a" "Logical Domains devices"

   exec_command "ldm list-constraints" "Logical Domains constraints"

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

   exec_command "prodreg browse" "Solaris Product Registry database" 

   exec_command "pkginfo" "Solaris SVR4 package status" 

   exec_command "pkg list" "Solaris 11 Image Packaging System package status" 

   exec_command "showrev -p" "Solaris SVR4 patches installed"

   exec_command "pkg list -u" "Solaris 11 Image Packaging System patches"

   exec_command "pkgchk -l" "Solaris SVR4 package verification"

   exec_command "pkg verify" "Solaris 11 Image Packaging System package verification"

   exec_command "patchsvr setup -l" "Sun Update Connection"

   exec_command "pkg publisher" "Solaris 11 Image Packaging System publisher repositories"

   exec_command "pkg history" "Solaris 11 Image Packaging System update history"

   exec_command "asradm list" "Solaris 11 Auto Service Request status"

   exec_command "smpatch get" "Sun Patch Manager status"

   exec_command ProgStuff "Software Development: Programs and Versions"

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

   exec_command "vxlicense -p" "Veritas license (vxlicense)"

   exec_command "vxlicrep -e" "Veritas license (vxlicrep)"

   exec_command "vxenablef" "Veritas vxenablef status"

   exec_command "showcodlicense -v" "Capacity on Demand (COD) license"

   exec_command "omnicc -check_licenses -detail" "Data Protector license"

   exec_command "bpminlicense -list_keys" "NetBackup license"

   exec_command "fw printlic" "CheckPoint Firewall-1 license"

   exec_command "fw lichosts" "CheckPoint Firewall-1 licensed hosts"

   exec_command "powermt check_registration" "PowerPath license"

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

   exec_command "grep -v ^# /etc/vfstab" "/etc/vfstab"

   exec_command "df -k -h -a" "Filesystems usage"

   exec_command "df -o -i" "Filesystem inode status"

   exec_command "fssnap -i" "Filesystems snapshots"

   exec_command "zfs list -t snapshot" "ZFS snapshots"

   exec_command "lockfs" "Filesystem locks"

   exec_command "fsstat -F $STATCNT" "All filesystem statistics"

   exec_command "cachefsstat" "Cache filesystem statistics"

   exec_command "nfsstat -s" "NFS server statistics"

   exec_command "nfsstat -c" "NFS client statistics"

   DUMPADM="/etc/dumpadm.conf"

   if [ -f "$DUMPADM" ] ; then
      exec_command "cat $DUMPADM" "Crash configuration $DUMPADM"
   fi

   exec_command "dumpadm" "Dumpadm status"

   exec_command "swap -l" "Paging devices (swap)"

   exec_command "${PLUGIN}/swap-check.pl" "${PLUGIN}/swap-check.pl"

   exec_command "mount" "Local mountpoints"

   EXPORTCFG="/etc/exports"
   DFSCFG="/etc/dfs/dfstab"

   if [ -f "$EXPORTCFG" ] ; then
      exec_command "grep -v ^# $EXPORTCFG" "NFS filesystems in $EXPORTCFG"
   else
      exec_command "grep -v ^# $DFSCFG" "NFS filesystems in $DFSCFG"
   fi

   exec_command "sharectl status" "Filesystem services configuration"

   for i in /etc/auto_home /etc/auto_master
   do
      exec_command "cat $i" "Automount config $i"
   done

   exec_command "coreadm" "Coreadm status"

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

   disklist () {
   if [ -d "/opt/IBMdpo" ] ; then
     format <<-EOF | grep "^ *[0-9][0-9]*\. " | awk '{ print $2 }' | grep -v vpath
EOF
   else
     format <<-EOF | grep "^ *[0-9][0-9]*\. " | awk '{ print $2 }'
EOF
   fi
   }

   verdisk () {
      format -d $1 <<-EOF | sed '1,/format> /d' | sed 's/format> //g'
      verify
      inquiry
      quit
EOF
   }

   for i in $(disklist)
   do
      exec_command "verdisk $i 2>&1" "Disk $i"
   done

   for i in $(ls /dev/rdsk/*s0)
   do
      exec_command "devinfo -p $i" "Device info for disk $i"
   done

   exec_command "quotacheck -a -v" "Disk quota check"

   exec_command "croinfo" "Chassis, Receptacle and Occupant info"
 
   exec_command "diskinfo -v | nawk NF" "Diskinfo"

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

   exec_command "netstat -rvn" "List of all routing table entries"

   exec_command "netstat -s" "Summary statistics for each protocol"

   exec_command "tcpstat -c 1" "Tcpstat"

   exec_command "ipstat -c 1" "Ipstat"

   exec_command "arp -a" "ARP table"

   exec_command "dladm show-link" "Data Link status"

   exec_command "dladm show-aggr" "Data Link aggregates"

   exec_command "dladm show-dev" "Data Link device status"

   exec_command "dladm show-phys" "Data Link physical device status"

   exec_command "dladm show-part" "Data Link Infiniband device status"

   exec_command "dladm show-vlan" "Data Link VLAN device status"

   exec_command "dlstat -a" "Data Link statistics"

   exec_command "ibstatus" "Infiniband query status"

   exec_command "iblinkinfo" "Infiniband link status"

   exec_command "ibcheckstate" "Infiniband check status"
   
   exec_command "apconfig -v" "Alternate Pathing status"

   exec_command "apconfig -N" "Alternate Pathing for networks"

   exec_command "apconfig -D" "Alternate Pathing database layout"

   exec_command "nettr -conf" "Sun Trunking status"

   exec_command "ipmpstat -nt" "IP Multi Pathing status"

   exec_command "cat /etc/default/mpathd" "IP Multi Pathing config /etc/default/mpathd"

   exec_command "hippi status" "High Performance Parallel Interface (HIPPI) status"

   for ndls in /dev/tcp /dev/udp /dev/ip /dev/arp /dev/icmp
   do
      exec_command "ndd $ndls \?" "Ndd $ndls status"
   done

   if [ "$OSREV" -ge 11 ] ; then
      exec_command "ipadm show-prop" "Ipadm tunables"

      exec_command "ipadm show-if" "Ipadm interface summary"

      exec_command "ipadm show-addrprop" "Ipadm address object properties"

      exec_command "ipadm show-ifprop" "Ipadm datalink properties"
   fi

   exec_command "cat /etc/netmasks" "/etc/netmasks"

   exec_command "cat /etc/networks" "/etc/networks"

   exec_command "cat /etc/netconfig" "/etc/netconfig"

   exec_command "cat /etc/resolv.conf" "DNS resolver /etc/resolv.conf"

   exec_command "nawk NF /etc/nscd.conf" "Name Service Cache Daemon /etc/nscd.conf"

   exec_command "nscd -g" "Name Service Cache Daemon statistics"

   exec_command "cat /etc/nsswitch.conf" "Name service configuration /etc/nsswitch.conf"

   exec_command "ypwhich 2>&1" "NIS server status"

   exec_command "domainname" "NIS domainname"

   exec_command "ldaplist -g" "LDAP information from configuration profile"

   exec_command "nslookup $(hostname)" "FQDN nslookup local system"

   exec_command "check-hostname" "Sendmail MTA verification of FQDN"

   exec_command "netstat -gi" "Interfaces"

   exec_command "egrep -v ^# /etc/hosts" "/etc/hosts"

   exec_command "ssadm policy -l -v" "SunScreen Secure Net policy"

   exec_command "ssadm active" "SunScreen Secure Net activity status"

   exec_command "ssadm ha status" "SunScreen Secure Net HA status"

   exec_command "ipnat -l -s -v" "IP Filter NAT status"

   exec_command "fw tab -all -u" "CheckPoint Firewall-1 tables"

   exec_command "ufw status" "Netfilter Firewall"

   exec_command "ufw app list" "Netfilter Firewall Application Profiles"

   exec_command "tcpdchk -v" "Tcpd wrapper"

   exec_command "tcpdchk -a" "Tcpd warnings"

   [ -f /etc/hosts.allow ] && exec_command "egrep -v ^# /etc/hosts.allow" "/etc/hosts.allow"
  
   [ -f /etc/hosts.deny ] && exec_command "egrep -v ^# /etc/hosts.deny" "/etc/hosts.deny"

   if [ -f /etc/gated.conf ] ; then
      exec_command "cat /etc/gated.conf" "Gate Daemon"
   fi

   exec_command "inetadm -p" "Inetd service control"

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

   exec_command "lpstat -s" "Configured printers"

   exec_command "lpc status" "BSD Printer Spooler and Printers"

   exec_command "lpstat -d" "Default printer"

   exec_command "lpstat -t" "Printer status"

   exec_command "lpq -a -l" "Printer job queue status"

   [ -r /etc/printers.conf ] && exec_command "egrep -v ^# /etc/printers.conf" "Printcap"

   exec_command "cupsctl" "CUPS current settings"

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

   exec_command "modinfo" "Loaded kernel modules"

   if [ -e "/etc/system" ] ; then
      exec_command "cat /etc/system" "Parameters in /etc/system"
   fi

   exec_command "nm /dev/ksyms | grep OBJ " "Kernel parameters and objects from kernel symbols file /dev/ksyms"

   exec_command "fmadm config" "Fault management config"

   exec_command "fmstat" "Fault management module statistics"

   exec_command "syseventadm list" "Sysevent specifications"

   exec_command "auditstat -T d" "Kernel Auditing statistics"

   exec_command "cryptoadm list" "Cryptographic framework"

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

   exec_command "cat /etc/shadow" "/etc/shadow"

   exec_command "cat /etc/group" "/etc/group"

   exec_command "nawk NF /etc/default/passwd" "/etc/default/passwd"

   exec_command "nawk NF /etc/default/login" "/etc/default/login"

   exec_command "nawk NF /etc/default/su" "/etc/default/su"

   exec_command "nawk NF /etc/default/inetinit" "/etc/default/inetinit"

   exec_command "cat /etc/shells" "Valid Shells in /etc/shells"

   exec_command "cat /var/adm/loginlog" "Failed login attempts in /var/adm/loginlog"
   if [ -f "/var/adm/loginlog" ] ; then
      AddText "The output should be empty!"
   else
      AddText "Logfile /var/adm/loginlog should be created!"
   fi

   exec_command "nawk NF /etc/security/crypt.conf" "Available Hashes in /etc/security/crypt.conf"

   exec_command "passwd -sa" "Password attributes"

   exec_command "logins -p" "Unix logins without passwords"
   AddText "The output should be empty!"

   exec_command "pwck 2>&1" "Integrity of Unix password file"
   AddText "The output should be empty!"

   exec_command "cat /etc/group" "/etc/group"

   exec_command "grpck 2>&1" "Integrity of Unix group file"

   exec_command "cat /etc/sudoers" "/etc/sudoers"

   for sd in /etc/sudoers.d/*
   do
      exec_command "nawk NF $sd" "Sudoers file $sd"
   done

   exec_command "auths list" "List authorizations"

   exec_command "roles" "RBAC roles"

   exec_command "profiles" "Rights profiles"

   exec_command "projects" "Projects"

   exec_command "whodo" "Current logged-in users"

   dec_heading_level
fi
# terminates CFG_PASSWD wrapper

#
# CFG_FILES
#
if [ "$CFG_FILES" != "no" ] ; then
   paragraph "Startup Scripts and SMF Services"
   inc_heading_level

   exec_command "svcs -a" "Services"

   exec_command "svcs -x" "Services with status explanation"

   exec_command "svccfg listnotify problem-diagnosed,problem-updated" "Svccfg service notification status"

   files()
   {
      ls /etc/rc0.d/*
      ls /etc/rc1.d/*
      ls /etc/rc2.d/*
      ls /etc/rc3.d/*
   }

   COUNT=1

   for FILE in $(files)
   do
      exec_command "cat ${FILE}" "${FILE}"
      COUNT=$(expr $COUNT + 1)
   done

   exec_command "check-permissions" "Sendmail MTA check permissions"

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

    if [ -e /opt/OV/bin/OpC/utils/opcdcode ] ; then
       if [ -e /opt/OV/bin/OpC/install/opcinfo ] ; then
         exec_command "cat /opt/OV/bin/OpC/install/opcinfo" "HP OpenView version"
       fi

       if [ -e /var/opt/OV/conf/OpC/monitor ] ; then
         exec_command "opcdcode /var/opt/OV/conf/OpC/monitor | grep DESCRIPTION" "HP OpenView configuration monitor"
       fi

       if [ -e /var/opt/OV/conf/OpC/le ] ; then
         exec_command "opcdcode /var/opt/OV/conf/OpC/le | grep DESCRIPTION" "HP OpenView configuration logging"
       fi
    fi

    if [ -e /usr/openv/netbackup/bp.conf ] ; then
       paragraph "Veritas Netbackup Configuration"
       inc_heading_level

       NetBuVersion=$(find /usr/openv/netbackup -name "version")
       if [ -e ${NetBuVersion} ] ; then
          exec_command "cat ${NetBuVersion}" "Veritas Netbackup Version"
       fi

       exec_command "cat /usr/openv/netbackup/bp.conf" "Veritas Netbackup Configuration"

       exec_command "netstat -tap | egrep '(bpcd|bpjava-msvc|bpjava-susvc|vnetd|vopied)|(Active|Proto)'" "Veritas Netbackup Network Connections"

       ## Use FS="=" in case there's no whitespace in the SERVER lines.
       exec_command "for NetBuServer in $(awk 'BEGIN {FS="="} /SERVER/ {printf $NF}' /usr/openv/netbackup/bp.conf); do ping -c 3 \${NetBuServer} && echo \"\"; done" "Veritas Netbackup Servers Ping Check"

       if ping -c 3 $(awk 'BEGIN {FS="="} /SERVER/ {print $NF}' /usr/openv/netbackup/bp.conf | head -1) >/dev/null
       then
          exec_command "/usr/openv/netbackup/bin/bpclntcmd -pn" "Veritas Netbackup Client to Server Inquiry"
       fi
       dec_heading_level
   fi

   if [ -x /usr/bin/puppet ]
   then
      dec_heading_level
      paragraph "Puppet Configuration Management System"
      inc_heading_level

      exec_command "ps -ef | grep -E 'puppetmaster[d]|puppet maste[r]'" "Active Puppet Master"

      exec_command "ps -ef | grep -E 'puppet[d]'" "Active Puppet Client"

      if [ -x /usr/sbin/puppetd ]; then
         exec_command "/usr/sbin/puppetd -V" "Puppet Client agent version"
      else
         exec_command "puppet agent -V" "Puppet Client agent version"
      fi

      exec_command "puppet status master" "Puppet Server status"

      PUPPETCHK=$(puppet help | awk '$1 == "config" {print}')
      if [ "$PUPPETCHK" ] ; then
         exec_command "puppet config print all" "Puppet configuration"

	 exec_command "puppet config print modulepath" "Puppet configuration module paths"
      fi

      if [ -x /usr/sbin/puppetca ]; then
         exec_command "puppetca -l -a" "Puppet certificates"
      else
         exec_command "puppet ca list --all" "Puppet certificates"
      fi

      exec_command "/usr/bin/puppet resource user" "Users in Puppet Resource Abstraction Layer (RAL)"

      exec_command "/usr/bin/puppet resource package" "Packages in Puppet Resource Abstraction Layer (RAL)"

      exec_command "puppet resource service" "Services in Puppet Resource Abstraction Layer (RAL)"
   fi # puppet

   CHEFSRV="$(chef-server-ctl 2>/dev/null)"
   if  [ "$CHEFSRV" ]
   then
      dec_heading_level
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
   fi

   if [ -x /var/cfengine/bin/cfagent ]
   then
      ###  CFEngine settings
      dec_heading_level
      paragraph "CFEngine Configuration Management System"
      inc_heading_level

      exec_command "ps -ef | grep -E 'cfserv[d]|cf-server[d]'" "Active CFEngine Server"

      exec_command "ps -ef | grep -E 'cfagen[t]|cf-agen[t]'" "Active CFEngine Agent"

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

   exec_command "twadmin --print-cfgfile" "Tripwire status"
 
dec_heading_level
fi
# terminates CFG_APPLICATIONS wrapper

#
# execute system log check
#
paragraph "System logs"
inc_heading_level
exec_command "cat /etc/syslog.conf" "/etc/syslog.conf" 

exec_command "cat /etc/logadm.conf" "Logadm master config /etc/logadm.conf" 

for LFILE in /etc/logadm.d/*.conf
do
   [ -s "$LFILE" ] && exec_command "cat $LFILE" "Logadm config $LFILE"
done

NFSLOG="/etc/nfs/nfslog.conf"

[ -f "$NFSLOG" ] && exec_command "cat $NFSLOG" "NFS logfile $NFSLOG"

exec_command "cat /var/adm/messages" "/var/adm/messages"

exec_command "dmesg" "dmesg logfile" 

exec_command "fmdump -m -v" "Fault Management log" 

dec_heading_level

#
# execute Mail Transfer Agent check 
#
paragraph "Standard Mail Transfer Agents"
inc_heading_level

svcs -a | while read LLINE
do
   export LLINE
   if [ "$( echo $LLINE | grep -i postfix)" ]; then
      AddText "MTA is seemingly Postfix"

      POSTFIXCFG="$(postconf -n)"

      exec_dommand "postconf -n" "Postfix configuration summary"

      for PFILE in /etc/postfix/*.cf
      do
         [ -s "$PFILE" ] && exec_command "cat $PFILE" "Postfix config file $PFILE"
      done

      exec_command "showq" "Postfix mail queue"

      exec_command "qshape" "Postfix queue shape"
   fi
 
   if [ "$( echo $LLINE | grep -i smtp:sendmail)" ]; then
      AddText "MTA is seemingly Sendmail"

      for SFILE in /etc/mail/*.cf
      do
         [ -s "$SFILE" ] && exec_command "cat $SFILE" "Sendmail config file $SFILE"
      done

      exec_command "mailq" "Sendmail mail queue"

      exec_command "mailstats" "Sendmail mail statistics"
   fi
done

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

dec_heading_level

#
# execute FTP check 
#
paragraph "FTP Services"
inc_heading_level

exec_command "cat /etc/ftpusers" "/etc/ftpusers"
exec_command "nawk NF /etc/proftpd.conf" "/etc/proftpd.conf"

for fls in $(ls /etc/ftpd/* )
do
   if [ -f $fls ] ; then
      exec_command "nawk NF $fls" "$fls"
   fi
done

dec_heading_level

#
# execute Explorer check 
#
paragraph "Explorer - diagnostic collector"
inc_heading_level

exec_command "cat /etc/opt/SUNWexplo/default/explorer" "/etc/opt/SUNWexplo/default/explorer" 

exec_command "cat /etc/explorer/default/explorer" "/etc/explorer/default/explorer" 

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
