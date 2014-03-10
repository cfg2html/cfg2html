# @(#) $Id: cfg2html-linux.sh,v 6.16 2014/02/21 14:42:33 ralph Exp $
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
#        __       ____  _     _             _       _ _
#   ___ / _| __ _|___ \| |__ | |_ _ __ ___ | |     | (_)_ __  _   ___  __
#  / __| |_ / _` | __) | '_ \| __| '_ ` _ \| |_____| | | '_ \| | | \ \/ /
# | (__|  _| (_| |/ __/| | | | |_| | | | | | |_____| | | | | | |_| |>  <
#  \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_|     |_|_|_| |_|\__,_/_/\_\
#           |___/
#  HP Proliant Edition script
#
# ---------------------------------------------------------------------------

## /usr/lib64/qt-3.3/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
PATH=$PATH:/sbin:/bin:/usr/sbin:/opt/omni/bin:/opt/omni/sbin  ## this is a fix for wrong su root (instead for su - root)

_VERSION="cfg2html-linux version $VERSION "  # this a common stream so we don?t need the "Proliant stuff"

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
    L     ) CFG_STINLINE="no";;
    p     ) CFG_HPPROLIANTSERVER="yes";;
    P     ) CFG_PLUGINS="yes";;
    A     ) CFG_ALTIRISAGENTFILES="no";;
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

#
# check Linux distribution
#
identify_linux_distribution


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
    echo "Local config      "$CONFIG_DIR/local.conf "( $(grep -v -E '(^#|^$)' $CONFIG_DIR/local.conf | wc -l) )"
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

  paragraph "Linux System ($distrib)"
  inc_heading_level

  if [ -f $CONFIG_DIR/systeminfo ] ; then
    exec_command "cat $CONFIG_DIR/systeminfo" "System description"
  fi

  exec_command "cat /proc/cpuinfo; echo; /usr/bin/lscpu;" "CPU and Model info" #  20.08.2012, 15:59 modified by Ralph Roth #* rar *#
  [ -x /usr/bin/cpufreq-info ] && exec_command cpufreq-info "CPU Freq Kernel Information"

  exec_command  HostNames "uname & hostname"
  exec_command "uname -n" "Host alias"
  exec_command "uname -sr" "OS, Kernel version"
  [ -x /usr/bin/lsb_release ] && exec_command "/usr/bin/lsb_release -a" "Linux Standard Base Version"
  for i in /etc/*-release
  do
      [ -r $i ] && exec_command "cat $i" "OS Specific Release Information ($i)"
  done

  if [ -x /usr/bin/locale ] ; then
    exec_command posixversion "POSIX Standards/Settings"
    exec_command "locale" "locale specific information"
    export LANG="C"
    export LANG_ALL="C"
  fi

  exec_command "ulimit -a" "System ulimit"                #  13.08.2007, 14:24 modified by Ralph Roth
  exec_command "getconf -a" "System Configuration Variables"          ## at least SLES11, #  14.06.2011, 18:53 modified by Ralph Roth #* rar *#
  ##### 19-Sept-2006, Ralph #####
  if [ -x /usr/bin/mpstat ] ; then
    exec_command "mpstat 1 5" "MP-Statistics"
  fi
  if [ -x /usr/bin/iostat ] ; then
    exec_command "iostat" "IO-Statistics"
  fi

  # In "used memory.swap" section I would add :
  # free -tl     (instead of free, because it gives some more useful infos, about HighMem and LowMem memory regions (zones))
  # cat /proc/meminfo (in order to get some details of memory usage)

  exec_command "free -toml;echo;free -tm;echo; swapon -s" "Used Memory and Swap"  		#  04.07.2011, 16:13 modified by Ralph Roth #* rar *#
  exec_command "cat /proc/meminfo; echo THP:; cat /sys/kernel/mm/transparent_hugepage/enabled" "Detailed Memory Usage (meminfo)"  	# changed 20131218 by Ralph Roth
  exec_command "cat /proc/buddyinfo" "Zoned Buddy Allocator/Memory Fragmentation and Zones" 	#  09.01.2012 Ralph Roth
  AddText "The number on the left is bigger than right (by factor 2)."
  AddText "DMA zone is the first 16 MB of memory. DMA64 zone is the first 4 GB of memory on 64-bit Linux. Normal zone is between DMA and HighMem. HighMem zone is above 4 GB of memory." # ripped from Dusan Baljevic ## changed 20131211 by Ralph Roth

      #   TODO
      #           foreach my $bi ( @BUDDYINFO ) {
      #             my @biarr = split(/\s+/, $bi);
      #             $biarr[1] =~ s/,$//g;
      #             print "$INFOSTR $biarr[0]$biarr[1]: Zone $biarr[3] has\n";
      #             my $cntb = 1;
      #             my @who = splice @biarr, 4;
      #             for my $p (0 .. $#who) {
      #                 print $who[$p], " free ", 2*(2**$cntb), "KB pages\n";
      #                 $cntb++;
      #             }

  exec_command "cat /proc/slabinfo" "Kernel slabinfo Statistics" 	# changed 20131211 by Ralph Roth
  AddText "Frequently used objects in the Linux kernel (buffer heads, inodes, dentries, etc.)  have their own cache.  The file /proc/slabinfo gives statistics."
  exec_command "cat /proc/pagetypeinfo" "Additional page allocator information" 	# changed 20131211 by Ralph Roth
  exec_command "cat /proc/zoneinfo" "Per-zone page allocator" 		# changed 20131211 by Ralph Roth

  if [ -x /usr/bin/vmstat ] ; then        ## <c/m/a>  14.04.2009 - Ralph Roth
    exec_command "vmstat 1 10" "VM-Statistics 1 10"
    exec_command "vmstat -dn;vmstat -f" "VM-Statistics (Summary)"
  fi

  # sysutils
  exec_command "uptime" "Uptime"
  # exec_command "sar 1 9" "System Activity Report"
  # exec_command "sar -b 1 9" "Buffer Activity"

  [ -x /usr/bin/procinfo ] && exec_command "procinfo -a" "System status from /proc" #  15.11.2004, 14:09 modified by Ralph Roth
  # usage: pstree [ -a ] [ -c ] [ -h | -H pid ] [ -l ] [ -n ] [ -p ] [ -u ]
  #               [ -G | -U ] [ pid | user]
  exec_command "pstree -p -a  -l -G -A" "Active Process - Tree Overview" #  15.11.2004/2011, 14:09 modified by Ralph.Roth
  exec_command "ps -e -o ruser,pid,args | awk ' (($1+1) > 1) {print $0;} '" "Processes without an named owner"  # changed 20131211 by Ralph Roth, # changed 20140129 by Ralph Roth # cmd. line:1: ^ unexpected newline or end of string
  AddText "The output should be empty!"
  
  exec_command "ps -ef | cut -c39- | sort -nr | head -25 | awk '{ printf(\"%10s   %s\\n\", \$1, \$2); }'" "Top load processes"
  exec_command "ps -e -o 'vsz pid ruser cpu time args' |sort -nr|head -25" "Top memory consuming processes"
  exec_command topFDhandles "Top file handles consuming processes" # 24.01.2013
  AddText "Hint: Number of open file handles should be less than ulimit -n ("$(ulimit -n)")"

  [ -x /usr/bin/pidstat ] && exec_command "pidstat -lrud 2>/dev/null||pidstat -rud" "pidstat - Statistics for Linux Tasks" #  10.11.2012 modified by Ralph Roth #* rar *# fix for SLES11,SP2, 29.01.2014

  exec_command "last| grep boot" "reboots"
  exec_command "alias"  "Alias"
  [ -r /etc/inittab ] && exec_command "grep -vE '^#|^ *$' /etc/inittab" "inittab"
  ## This may report NOTHING on RHEL 3+4 ##
  [ -x /sbin/chkconfig ] && exec_command "/sbin/chkconfig" "Services Startup"  ## chkconfig -A // SLES // xinetd missing
  [ -x /sbin/chkconfig ] && exec_command "/sbin/chkconfig --list" "Services Runlevel" # rar, fixed 2805-2005 for FC4
  [ -x /sbin/chkconfig ] && exec_command "/sbin/chkconfig -l --deps" "Services Runlevel and Dependencies" #*# Alexander De Bernardi 25.02.2011
  [ -x /usr/sbin/service ] && exec_command "/usr/sbin/service --status-all 2> /dev/null" "Services - Status"   #  09.11.2011/12022013 by Ralph Roth #* rar *#
  [ -x  /usr/sbin/sysv-rc-conf ] && exec_command " /usr/sbin/sysv-rc-conf --list" "Services Runlevel" # rr, 1002-2008

  if [ "$GENTOO" = "yes" ] ; then   ## 2007-02-27 Oliver Schwabedissen
    [ -x /bin/rc-status ]  && exec_command "/bin/rc-status --list" "Defined runlevels"
    [ -x /sbin/rc-update ] && exec_command "/sbin/rc-update show --verbose" "Init scripts and their runlevels"
  fi

  if [ "$ARCH" = "yes" ] ; then   ## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
    [ -x /usr/bin/systemctl ] && exec_command "/usr/bin/systemctl list-unit-files | grep enabled" "Systend: installed unit"
    [ -x /usr/bin/systemctl ] && exec_command "/usr/bin/systemctl --failed" "Systend: failed units"
  fi

  if [ -d /etc/rc.config.d ] ; then
    exec_command " grep -v ^# /etc/rc.config.d/* | grep '=[0-9]'" "Runlevel Settings"
  fi
  [ -r /etc/inittab ] && exec_command "awk '!/#|^ *$/ && /initdefault/' /etc/inittab" "default runlevel"
  exec_command "/sbin/runlevel" "current runlevel"

  ##
  ## we want to display the Boot Messages too
  ## 30Jan2003 it233 FRU
  if [ -e /var/log/boot.msg ] ; then
    exec_command "grep 'Boot logging' /var/log/boot.msg" "Last Boot Date"
    exec_command "grep -v '|====' /var/log/boot.msg " "Boot Messages, last Boot"
  fi

  # MiMe: SUSE && UNITEDLINUX
  # MiMe: until SuSE 7.3: params in /etc/rc.config and below /etc/rc.config.d/
  # MiMe; since SuSE 8.0 including UL: params below /etc/sysconfig
  if [ "$SUSE" = "yes" ] || [ "$UNITEDLINUX" = "yes" ] ; then
    if [ -d /etc/sysconfig ] ; then
      # MiMe:
      exec_command "find /etc/sysconfig -type f -not -path '*/scripts/*' -exec grep -vE '^#|^ *$' {} /dev/null \; | sort" "Parameter /etc/sysconfig"
    fi
    if [ -e /etc/rc.config ] ; then
      # PJC: added filters for SuSE rc_ variables
      # PJC: which were in rc.config in SuSE 6
      # PJC: and moved to /etc/rc.status in 7+
      exec_command "grep -vE -e '(^#|^ *$)' -e '^ *rc_' -e 'rc.status' /etc/rc.config | sort" "Parameter /etc/rc.config"
    fi
    if [ -d /etc/rc.config.d ] ; then
      # PJC: added filters for SuSEFirewall and indented comments
      exec_command "find /etc/rc.config.d -name '*.config' -exec grep -vE -e '(^#|^ *$)' -e '^ *true$' -e '^[[:space:]]*#' -e '[{]|[}]' {} \; | sort" "Parameter /etc/rc.config.d"
    fi
  fi

  if [ "$GENTOO" = "yes" ] ; then ## 2007-02-28 Oliver Schwabedissen
    exec_command "grep -vE '^#|^ *$' /etc/rc.conf | sort" "Parameter /etc/rc.conf"
    exec_command "find /etc/conf.d -type f -exec grep -vE '^#|^ *$' {} /dev/null \;" "Parameter /etc/conf.d"
  fi

  if [ -e /proc/sysvipc ] ; then
    exec_command "ipcs" "IPC Status"
    exec_command "ipcs -u" "IPC Summary"
    exec_command "ipcs -l" "IPC Limits"
    ## ipcs -ma ???
  fi

  if [ -x /usr/sbin/pwck ] ; then
    exec_command "/usr/sbin/pwck -r && echo Okay" "integrity of password files"
  fi

  if [ -x /usr/sbin/grpck ] ; then
    exec_command "/usr/sbin/grpck -r && echo Okay" "integrity of group files"
  fi

  dec_heading_level

fi # terminates CFG_SYSTEM wrapper

# -----------------------------------------------------------------------------
# Begin: "Arch Linux spezial section"
## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
if [ "$ARCH" == "yes" ] ; then
  paragraph "Arch Linux spezial"
  inc_heading_level

  exec_command "grep -vE '^#|^ *$' /etc/pacman.conf" "Pacman config"
  exec_command "grep -vE '^#|^ *$' /etc/pacman.d/mirrorlist" "Aktiv mirrors for pacman"
  exec_command "grep -vE '^#|^ *$' /etc/mkinitcpio.conf" "Build Options"

  dec_heading_level
fi
# End: "Arch Linux spezial section"
# -----------------------------------------------------------------------------

#
# CFG_CRON
#
if [ "$CFG_CRON" != "no" ]
then # else skip to next paragraph
paragraph "Cron and At"
inc_heading_level

  for FILE in cron.allow cron.deny
      do
	  if [ -r /etc/$FILE ]
	  then
	  exec_command "cat /etc/$FILE" "$FILE"
	  else
	  exec_command "echo /etc/$FILE" "$FILE not found!"
	  fi
      done

  ## Linux SuSE user /var/spool/cron/tabs and NOT crontabs
  ## 30jan2003 it233 FRU
  ##  SuSE has the user crontabs under /var/spool/cron/tabs
  ##  RedHat has the user crontabs under /var/spool/cron
  ##  UnitedLinux uses /var/spool/cron/tabs (MiMe)
  ##  Arch Linux has the user crontabs under /var/spool/cron  ## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
  if [ "$SUSE" == "yes" ] ; then
    usercron="/var/spool/cron/tabs"
  fi
  if [ "$REDHAT" == "yes" ] || [ "$AWS" == "yes" ] ; then
    usercron="/var/spool/cron"
  fi
  if [ "$SLACKWARE" == "yes" ] ; then
    usercron="/var/spool/cron/crontabs"
  fi
  if [ "$DEBIAN" == "yes" ] ; then
    usercron="/var/spool/cron/crontabs"
  fi
  if [ "$GENTOO" == "yes" ] ; then    ## 2007-02-27 Oliver Schwabedissen
    usercron="/var/spool/cron/crontabs"
  fi
  if [ "$UNITEDLINUX" == "yes" ] ; then
    usercron="/var/spool/cron/tabs"
  fi
  if [ "$ARCH" == "yes" ] ; then      ## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
    usercron="/var/spool/cron"
  fi
  # ##
  # alph@osuse122rr:/etc/cron.d> ll
  # -rw-r--r-- 1 root root 1754 29. Nov 16:21 -?			## !
  # -rw-r--r-- 1 root root  319  1. Nov 2011  ClusterTools2
  # -rw-r--r-- 1 root root 1754 29. Nov 16:21 --help		## !

# maybe this is generic?
# for user in $(getent passwd|cut -f1 -d:); do echo "### Crontabs for $user ####"; crontab -u $user -l; done
# changed 20140212 by Ralph Roth

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

  ##
  ## we do also a listing of utility cron files
  ## under /etc/cron.d 30Jan2003 it233 FRU
  ls /etc/cron.d/* > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
	  _echo "\n\n<br><B>/etc/cron.d files:</B>" >> $HTML_OUTFILE_TEMP
	  for FILE in /etc/cron.d/*
	  do
		  exec_command "cat $FILE | grep -v ^#" "For utility `basename $FILE`"
	  done
  else
	  echo "No /etc/cron.d files for utlities." >> $HTML_OUTFILE_TEMP
  fi

  if [ -f /etc/crontab ] ; then
    exec_command "_echo  'Crontab:\n';cat /etc/crontab | grep -vE '^#|^ *$'" "/etc/crontab"
  fi

  atconfigpath="/etc"
  if [ "$GENTOO" == "yes" ] ; then    ## 2007-02-27 Oliver Schwabedissen
      atconfigpath="/etc/at"
  fi

  for FILE in at.allow at.deny

      do
	  if [ -r $atconfigpath/$FILE ]
	  then
	      exec_command "cat $atconfigpath/$FILE " "$atconfigpath/$FILE"
	  else
	      exec_command "echo $atconfigpath/$FILE" "No $atconfigpath/$FILE"
	  fi
      done

  ## work around by Ralph for missing at
  #(whereis at > /dev/null) || exec_command "at -l" "AT Scheduler"
  # sorry - don't work here (Michael)
  # now we try this
  if [ -x /usr/bin/at ] ; then
    exec_command "at -l" "AT Scheduler"
  fi

  #exec_command "_echo  'Crontab:\n';cat /etc/crontab | grep -vE '#|^ *$';_echo '\nAT Scheduler:\n';at -l" "/etc/crontab and AT Scheduler"

dec_heading_level
fi #terminate CFG_CRON wrapper
#
# CFG_HARDWARE
#
if [ "$CFG_HARDWARE" != "no" ]
then # else skip to next paragraph

paragraph "Hardware"
inc_heading_level

RAM=`awk -F': *' '/MemTotal/ {print $2}' /proc/meminfo`
# RAM=`cat /proc/meminfo | grep MemTotal | awk -F\: '{print $2}' | awk -F\  '{print $1 " " $2}'`
exec_command "echo $RAM" "Physical Memory"

## Murray Barton, 14/4/2010
DMIDECODE=`which dmidecode`; if [ -n "$DMIDECODE" ] && [ -x $DMIDECODE ] ; then exec_command "$DMIDECODE 2> /dev/null" "DMI Table Decoder"; fi

# if [ -e /usr/sbin/dmidecode ]           ## this could be moved out to common stuff (e.g. useful to get serial number, # 26.03.2010 Ralph Roth)
# then
#   exec_command "dmidecode" "/usr/sbin/dmidecode output"
# fi

HWINFO=`which hwinfo`; if [ -n "$HWINFO" ] && [ -x $HWINFO ] ; then exec_command "$HWINFO 2> /dev/null" "Hardware List (hwinfo)"; fi
LSHW=`which lshw`; if [ -n "$LSHW" ] && [ -x $LSHW ] ; then exec_command "$LSHW" "Hardware List (lshw)"; fi ##  13.12.2004, 15:53 modified by Ralph Roth
LSDEV=`which lsdev`; if [ -n "$LSDEV" ] && [ -x $LSDEV ] ; then exec_command "$LSDEV" "Hardware List (lsdev)"; fi
LSHAL=`which lshal`; if [ -n "$LSHAL" ] && [ -x $LSHAL ] ; then exec_command "$LSHAL" "List of Devices (lshal)"; fi
LSUSB=`which lsusb`; if [ -n "$LSUSB" ] && [ -x $LSUSB ] ; then exec_command "$LSUSB" "USB devices"; fi ## SuSE? #  12.11.2004, 15:04 modified by Ralph Roth

LSPCI=`which lspci`
if [ -n "$LSPCI" ] && [ -x $LSPCI ] ; then
  exec_command "$LSPCI -v" "PCI devices"
else
  if [ -f /proc/pci ] ; then
    exec_command "cat /proc/pci" "PCI devices"
  fi
fi

PCMCIA=`grep pcmcia /proc/devices | cut -d" " -f2`
if [ "$PCMCIA" = "pcmcia"  ] ; then
  if [ -x /sbin/cardctl ] ; then
    exec_command "/sbin/cardctl status;/sbin/cardctl config;/sbin/cardctl ident" "PCMCIA"
  fi
fi
[ -r /proc/acpi/info ] && exec_command "cat /proc/acpi/info" "ACPI" #  06.04.2006, 17:44 modified by Ralph Roth

if [ -f /etc/kbd/default.kmap.gz ] ; then
  exec_command "zcat /etc/kbd/default.kmap.gz | head -1 | sed s/#//" "Keymap"
fi
exec_command "cat /proc/ioports" "IoPorts"
exec_command "cat /proc/interrupts" "Interrupts"
if [ -f /proc/scsi/scsi ] ;then
  exec_command "find /proc/scsi" "SCSI Components" #  22.11.2004, 16:08 modified by Ralph.Roth
  exec_command "cat /proc/scsi/scsi" "SCSI Devices"
else
  # Debian 6.06 # 24.01.2013, doesn't have -p option yet!
  #        -p, --protection        Output additional data integrity (protection) information.
  [ -x /usr/bin/lsscsi ] && exec_command "/usr/bin/lsscsi -lv" "SCSI Devices"  ## Alternate Method!, Mittwoch, 16. März 2011
fi

if [ -x "${FDISKCMD}" -a -x "${GREPCMD}" -a -x "${SEDCMD}" -a -x "${AWKCMD}" -a -x "${SMARTCTL}" ]
then
    exec_command DoSmartInfo "SMART disk drive features and information"
fi

## rar, 13.02.2004
## Changed 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA, changed title from SCSI Devices SCSI Disk Devices
[ -x /usr/sbin/lssd ] && exec_command "/usr/sbin/lssd" "SCSI Disk Devices"

## Added 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA
[ -x /usr/sbin/lssg ] && exec_command "/usr/sbin/lssg" "Generic SCSI Devices"

## rar, 13.02.2004
## Added 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA, Added the echo between the command to get a new line and move it down below lssg and lssd.
[ -x /usr/sbin/adapter_info ] && exec_command "/usr/sbin/adapter_info;echo;/usr/sbin/adapter_info -v" "Adapterinfo/WWN"
### ------------------------------------------------------------------------------

#### Start of Fibre HBA info. added 12.05.2006 (15:13) by Peter Lindblom, HP, STCC EMEA

 if [ -f /tmp/fibrehba.txt ]
 then
   rm /tmp/fibrehba.txt
 fi

 # capture /proc/scsi/qla2200

 if [ -d /proc/scsi/qla2200 ]
 then
   for file in /proc/scsi/qla2200/*
    do
      mcat $file >>/tmp/fibrehba.txt
    done
 fi

 # capture /proc/scsi/qla2300

 if [ -d /proc/scsi/qla2300 ]
 then
    for file in /proc/scsi/qla300/*
    do
      mcat $file >>/tmp/fibrehba.txt
     done
 fi

 # capture /proc/scsi/qla2xxx

 if [ -d /proc/scsi/qla2xxx ]
 then
    for file in /proc/scsi/qla2xxx/*
     do
      mcat $file >>/tmp/fibrehba.txt
     done
 fi


 # capture /proc/scsi/lpfc

 if [ -d /proc/scsi/lpfc ]
 then
    for file in /proc/scsi/lpfc/*
     do
      mcat $file >>/tmp/fibrehba.txt
     done
 fi

 if [ -f /tmp/fibrehba.txt ]
 then
   exec_command "cat /tmp/fibrehba.txt" "Fibre Channel Host Bus Adapters"
   rm /tmp/fibrehba.txt
 fi

#### End of Fibre HBA info.


## rar, 13.02.2004
[ -x /usr/sbin/spmgr ] && exec_command "/usr/sbin/spmgr display" "SecurePath - Manager"
[ -r /etc/CPQswsp/sppf ] && exec_command "cat /etc/CPQswsp/sppf" "SecurePath - Bindings"
[ -r /etc/CPQswsp/hsx.conf ] && exec_command "cat /etc/CPQswsp/hsx.conf" "SecurePath - Preferred Path Settings"
[ -r /etc/CPQswsp/swsp.conf ] && exec_command "cat /etc/CPQswsp/swsp.conf" "SecurePath - Path, Load Balance & Auto restore settings"
[ -r /etc/CPQswsp/notify.ini ] && exec_command "cat /etc/CPQswsp/notify.ini" "SecurePath - email address notification settings"
[ -r /etc/CPQswsp/spmgr_alias ] && exec_command "cat /etc/CPQswsp/spmgr_alias" "SecurePath - Alias Name file"
[ -r /etc/CPQswsp/spmgr_stop_list ] && exec_command "cat /etc/CPQswsp/spmgr_stop_list" "SecurePath - reserved key word settings file"
[ -r /etc/CPQswsp/clients ] && exec_command "cat /etc/CPQswsp/clients" "SecurePath - spmgr password information"

## Changed 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA, Moved from the Proliant section.
[ -f /var/log/sp_log ] && exec_command "cat /var/log/sp_log" "Secure path installation log"

## Changed 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA, Moved from the Proliant section.
[ -f /root/sp_install_results.log ] && exec_command "cat /root/sp_install_results.log" "Secure path installation log (backup)"
if [ -e /proc/sound ] ; then
  exec_command "cat /proc/sound" "Sound Devices"
fi
if [ -e /proc/asound ] ; then
  [ -f /proc/asound/version ] && exec_command "cat /proc/asound/version" "Asound Version"
  [ -f /proc/asound/modules ] && exec_command "cat /proc/asound/modules" "Sound modules"
  [ -f /proc/asound/cards ] && exec_command "cat /proc/asound/cards" "Sound Cards"
  [ -f /proc/asound/sndstat ] && exec_command "cat /proc/asound/sndstat" "Sound Stats"
  [ -f /proc/asound/timers ] && exec_command "cat /proc/asound/timers" "Sound Timers"
  [ -f /proc/asound/devices ] && exec_command "cat /proc/asound/devices" "Sound devices"
  [ -f /proc/asound/pcm ] && exec_command "cat /proc/asound/pcm" "Sound pcm"
fi
exec_command "cat /proc/dma" "DMA Devices"
if [ -f /proc/tty/driver/serial ] ; then
   exec_command "grep -v unknown /proc/tty/driver/serial" "Serial Devices"
fi
# test this - please report it
if [ -e /proc/rd ] ; then
  exec_command "cat /proc/rd/c*/current_status" "RAID controller"
fi

# get serial information

SETSERIAL=`which setserial`
if [ -n "$SETSERIAL" ] && [ -x $SETSERIAL ]; then
  exec_command "$SETSERIAL -a /dev/ttyS0" "Serial ttyS0"
  exec_command "$SETSERIAL -a /dev/ttyS1" "Serial ttyS1"
fi

# get IDE Disk information
HDPARM=`which hdparm`
# if hdparm is installed (DEBIAN 4.0)
# -i   display drive identification
# -I   detailed/current information directly from drive

#  -i   display drive identification (SuSE 10u1)
#  -I   detailed/current information directly from drive
#  --Istdin  reads identify data from stdin as ASCII hex
#  --Istdout writes identify data to stdout as ASCII hex

# Sep 23 19:12:47 hp02 root: Start of cfg2html-linux version 1.63-2009-08-27
# Sep 23 19:13:03 hp02 kernel: hda: drive_cmd: status=0x51 { DriveReady SeekComplete Error }
# Sep 23 19:13:03 hp02 kernel: hda: drive_cmd: error=0x04Aborted Command
# Sep 23 19:13:18 hp02 root: End of cfg2html-linux version 1.63-2009-08-27

# Anpassung auf hdparm -i wegen Fehler im Syslog (siehe oben, cfg1.63)
# Ingo Metzler 23.09.2009

if [ $HDPARM ]  && [ -x $HDPARM ]; then
  exec_command "\
    if [ -e /proc/ide/hda ] ; then _echo  -n \"read from drive\"; $HDPARM -i /dev/hda;fi;\
    if [ -e /proc/ide/hdb ] ; then echo; _echo -n \"read from drive\"; $HDPARM -i /dev/hdb;fi;\
    if [ -e /proc/ide/hdc ] ; then echo; _echo -n \"read from drive\"; $HDPARM -i /dev/hdc;fi;\
    if [ -e /proc/ide/hdd ] ; then echo; _echo -n \"read from drive\"; $HDPARM -i /dev/hdd;fi;"\
  "IDE Disks"

  if [ -e /proc/ide/hda ] ; then
    if grep disk /proc/ide/hda/media > /dev/null ;then
      exec_command "$HDPARM -t -T /dev/hda" "Transfer Speed"
    fi
  fi
  if [ -e /proc/ide/hdb ] ; then
    if grep disk /proc/ide/hdb/media > /dev/null ;then
      exec_command "$HDPARM -t -T /dev/hdb" "Transfer Speed"
    fi
  fi
  if [ -e /proc/ide/hdc ] ; then
    if grep disk /proc/ide/hdc/media > /dev/null ;then
      exec_command "$HDPARM -t -T /dev/hdc" "Transfer Speed"
    fi
  fi
  if [ -e /proc/ide/hdd ] ; then
    if grep disk /proc/ide/hdd/media > /dev/null ;then
      exec_command "$HDPARM -t -T /dev/hdd" "Transfer Speed"
    fi
  fi
else
# if hdparm not available
  exec_command "\
    if [ -e /proc/ide/hda/model ] ; then _echo -n \"hda: \";cat /proc/ide/hda/model ;fi;\
    if [ -e /proc/ide/hdb/model ] ; then _echo -n \"hdb: \";cat /proc/ide/hdb/model ;fi;\
    if [ -e /proc/ide/hdc/model ] ; then _echo -n \"hdc: \";cat /proc/ide/hdc/model ;fi;\
    if [ -e /proc/ide/hdd/model ] ; then _echo -n \"hdd: \";cat /proc/ide/hdd/model ;fi;"\
 "IDE Disks"
fi

if [ -e /proc/sys/dev/cdrom/info ] ; then
  exec_command "cat /proc/sys/dev/cdrom/info" "CDROM Drive"
fi

if [ -e /proc/ide/piix ] ; then
   exec_command "cat /proc/ide/piix" "IDE Chipset info"
fi

# Test HW Health
# MiMe
if [ -x /usr/bin/sensors ] ; then
  if [ -e /proc/sys/dev/sensors/chips ] ; then
    exec_command "/usr/bin/sensors" "Sensors"
  fi
fi

if [ -x /usr/sbin/xpinfo ]
then
  XPINFOFILE=$OUTDIR/`hostname`_xpinfo.csv
  /usr/sbin/xpinfo -d";" | grep -v "Scanning" > $XPINFOFILE

  AddText "The XP-Info configuration was additionally dumped into the file <b>$XPINFOFILE</b> for further usage"

# remarked due to enhancement request by Martin Kalmbach, 25.10.2001
#  exec_command "/usr/sbin/xpinfo|grep -v Scanning" "SureStore E Disk Array XP Mapping (xpinfo)"

  exec_command "/usr/sbin/xpinfo -r|grep -v Scanning" "SureStore E Disk Array XP Disk Mechanisms"
  exec_command "/usr/sbin/xpinfo -i|grep -v Scanning" "SureStore E Disk Array XP Identification Information"
  exec_command "/usr/sbin/xpinfo -c|grep -v Scanning" "SureStore E Disk Array XP (Continuous Access and Business Copy)"
# else
# [ -x /usr/contrib/bin/inquiry256.ksh ] && exec_command "/usr/contrib/bin/inquiry256.ksh" "SureStore E Disk Array XP256 Mapping (inquiry/obsolete)"
fi

dec_heading_level

fi # terminates CFG_HARDWARE wrapper

######################################################################

##### ToDo: check for Distribution #####

if [ "$CFG_SOFTWARE" != "no" ]
then # else skip to next paragraph

  paragraph "Software"
  inc_heading_level

  # Debian
  if [ "$DEBIAN" = "yes" ] ; then
    dpkg --get-selections | awk '!/deinstall/ {print $1}' > /tmp/cfg2html-debian.$$
    exec_command "column /tmp/cfg2html-debian.$$" "Packages installed"
    rm -f /tmp/cfg2html-debian.$$
    AddText "Hint: to reinstall this list use:"
    AddText "awk '{print \$1\"\\n\"\$2}' this_list |  dpkg --set-selections"
    exec_command "dpkg -C" "Misconfigured Packages"
#   # { changed/added 25.11.2003 (14:29) by Ralph Roth }
    if [ -x /usr/bin/deborphan ] ; then
      exec_command "deborphan" "Orphaned Packages"
      AddText "Hint: deborphan | xargs aptitude -y purge"   # rar, 16.02.04
    fi
    exec_command "dpkg -l" "Detailed list of installed Packages"
    AddText "$(dpkg --version|grep program)"
    exec_command "grep -vE '^#|^ *$' /etc/apt/sources.list" "Installed from"
    [ -x /usr/bin/dpigs ] && exec_command "/usr/bin/dpigs" "Largest installed packages"
  fi
  # end Debian

  # SUSE
  # MiMe: --last tells date of installation
  if [ "$SUSE" = "yes" ] || [ "$UNITEDLINUX" = "yes" ] ; then
    exec_command "rpm -qa --last" "Packages installed (last first)"         #*#   Alexander De Bernardi //09.03.2010/rr
    exec_command "rpm -qa | sort -d -f" "Packages installed (sorted)"       #*#   Alexander De Bernardi //09.03.2010/rr
    exec_command "rpm -qa --queryformat '%{NAME}\n' | sort -d -f" "Packages installed, Name only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm -qa --queryformat '%-50{NAME} %{VENDOR}\n' | sort -d -f" "Packages installed, Name and Vendor only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm --querytags" "RPM Query Tags"     #*#   Alexander De Bernardi //21.04.2010/rr
    if [ -x /usr/bin/zypper ]
    then
    #     #TODO:#BUG:# stderr output from "zypper ls; echo ''; zypper pt":
    #     System management is locked by the application with pid 1959 (/usr/lib/packagekitd).
    #     Close this application before trying again.
        if [ -r /etc/zypp/zypp.conf ]       ## fix for JW's SLES 10
        then
            exec_command "zypper -n ls; echo ''; echo | zypper -n pt " "zypper: Services and Patterns"       #*#   Ralph Roth, Mittwoch, 16. März 2011
            exec_command "zypper  -n ps" "zypper: Processes which need restart after update"       #*#   Alexander De Bernardi 17.02.2011
            exec_command "zypper -n lr --details" "zypper: List repositories"                     #*#   Alexander De Bernardi 17.02.2011
            exec_command "zypper -n lu" "zypper: List pending updates"                            #*#   Alexander De Bernardi 17.02.2011
            exec_command "zypper -n lp" "zypper: List pending patches"                            #*#   Alexander De Bernardi 17.02.2011
            exec_command "zypper -n pa" "zypper: List all available packages"                     #*#   Alexander De Bernardi 17.02.2011
            exec_command "zypper -n pa --installed-only" "zypper: List installed packages"        #*#   Alexander De Bernardi 17.02.2011
            exec_command "zypper -n pa --uninstalled-only" "zypper: List not installed packages"  #*#   Alexander De Bernardi 17.02.2011
        else
            AddText "zypper found, but it is not configured!"
        fi
    fi
  fi
  # end SUSE

  # REDHAT
  if [ "$REDHAT" = "yes" ] || [ "$MANDRAKE" = "yes" ] ; then
    exec_command "rpm -qia | grep -E '^(Name|Group)( )+:'" "Packages installed" ## Chris Gardner - 24.01.2012
    exec_command "rpm -qa | sort -d -f" "Packages installed (sorted)"       #*#   Alexander De Bernardi //09.03.2010 12:31/rr
    exec_command "rpm -qa --queryformat '%{NAME}\n' | sort -d -f" "Packages installed, Name only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm -qa --queryformat '%-50{NAME} %{VENDOR}\n' | sort -d -f" "Packages installed, Name and Vendor only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm --querytags" "RPM Query Tags"     #*#   Alexander De Bernardi //21.04.2010/rr
    if [ -x /usr/bin/yum ] ; then
        exec_command "yum history" "YUM: Last actions performed"
    fi  # yum
  fi
  # end REDHAT

  # SLACKWARE
  if [ "$SLACKWARE" = "yes" ] ; then
    exec_command "ls /var/log/packages " "Packages installed"
  fi
  # end SLACKWARE
  # GENTOO, rr, 15.12.2004, Rob
  if [ "$GENTOO" = "yes" ] ; then
    #exec_command "qpkg -I -v|sort" "Packages installed"
    #exec_command "qpkg -I -v  --no-color |sort" "Packages installed" ## Rob Fantini, 15122004
    exec_command "qlist -I -v --nocolor |sort" "Packages installed" ## 2007-02-21 Oliver Schwabedissen
  fi
  # end GENTOO

  # ARCH
  # M.Weiller, LUG-Ottobrunn.de, 2013-02-04
  if [ "$ARCH" = "yes" ] ; then
    exec_command "pacman -Qq" "all installed packages"
    exec_command "pacman -Q" "all installed packages with version"
    exec_command "pacman -Qi" "all installed packages with full information"
    exec_command "pacman -Qeq" "official installed packages only"
    exec_command "pacman -Qdq" "dependencies installed packages only"
  fi
  # end ARCH

  #### programming stuff ##### plugin for cfg2html/linux/hpux #  22.11.2005, 16:03 modified by Ralph Roth
  exec_command ProgStuff "Software Development: Programs and Versions"

  dec_heading_level

fi # terminates CFG_SOFTWARE wrapper

######################################################################
if [ "$CFG_FILESYS" != "no" ]
then # else skip to next paragraph

paragraph "Filesystems, Dump- and Swapconfiguration"
inc_heading_level



exec_command "grep -v '^#' /etc/fstab | column -t" "Filesystem Tab"  # 281211, rr
exec_command "df -k" "Filesystems and Usage"
exec_command "my_df" "All Filesystems and Usage"
if [ -x /sbin/dumpe2fs ]
then
   exec_command "display_ext_fs_param" "Filesystems parameters"
fi
exec_command "mount" "Local Mountpoints"
exec_command PartitionDump "Disk Partition Layout"        #  30.03.2011, 20:00 modified by Ralph Roth #** rar **#
#
if [ -x /sbin/sfdisk ]
then
    sfdisk -d > $OUTDIR/$BASEFILE.partitions.save
    exec_command "cat $OUTDIR/$BASEFILE.partitions.save" "Disk Partitions to restore from"
    AddText "To restore your partitions use the saved file: $BASEFILE.partitions.save, read the man page for sfdisk for usage. (Hint: sfdisk --force /dev/device < file.save)"
fi
#*#
#*# Alexander De Bernard 20100310
#*#

MD_FILE="/etc/mdadm.conf"
MD_CMD="/sbin/mdadm"

if [ -f ${MD_FILE} ]
then
    exec_command "grep -vE '^#|^ *$' ${MD_FILE}" "MD Configuration File"
    if [ -x ${MD_CMD} ]
    then
        MD_DEV=$(grep "ARRAY" ${MD_FILE} | awk '{print $2;}')
        #         stderr output from "/sbin/mdadm --detail ":   ## SLES 11
        #         mdadm: No devices given.
        for d in "$MD_DEV"
        do
            exec_command "${MD_CMD} --detail ${d}" "MD Device Setup of $d"
        done
    else
        AddText "${MD_FILE} exists but no ${MD_CMD} command"
    fi
fi

# for LVM using sed
exec_command "/sbin/fdisk -l|sed 's/8e \ Unknown/8e \ LVM/g'" "Disk Partitions"

if [ -f /etc/exports ] ; then
    exec_command "grep -vE '^#|^ *$' /etc/exports" "NFS Filesystems"
fi

dec_heading_level

fi # terminates CFG_FILESYS wrapper

###########################################################################
## 3/6/08 New: RedHat multipath config  by krtmrrsn@yahoo.com, Marc Korte.
## also available at SLES 11 #  07.04.2012, 19:56 modified by Ralph Roth #* rar *#
if [ $REDHAT = "yes" ] && [ -n $(ps -ef | awk '/\/sbin\/multipathd/ {print $NF}') ] ; then
#FIXME#if [ $REDHAT = "yes" ] && [ $(pgrep multipathd) ] ; then
    if [ -x /sbin/multipath ]   #  10.11.2011, 22:50 modified by Ralph Roth #* rar *#
    then
      paragraph "Multipath Configuration"
      inc_heading_level

      exec_command "rpm -qa | grep multipath" "Multipath Package Version"
      exec_command "chkconfig --list multipathd" "Multipath Service Status"
      exec_command "/sbin/multipath -v2 -d -ll" "Multipath Devices Basic Information"
      exec_command "/sbin/multipath -v3 -d -ll" "Multipath Devices Detailed Information"
      exec_command "grep -vE '^#|^ *$' /etc/multipath.conf" "Multipath Configuration File"
      exec_command "for MultiPath in \$(/sbin/multipath -v1 -d -l); do ls -l /dev/mapper/\${MultiPath}; done" "Device Mapper Files"
      exec_command "cat /var/lib/multipath/bindings" "Multipath Bindings"

      dec_heading_level
    fi
fi

###########################################################################
if [ "$CFG_LVM" != "no" ]
then # else skip to next paragraph

    paragraph "LVM"
    inc_heading_level

    [ -x /sbin/blkid ] && exec_command "blkid" "Block Device Attributes"    #  07.11.2011, 21:42 modified by Ralph Roth #* rar *#
    [ -x /sbin/pvs ] && exec_command "pvs" "Physical Volumes"         # if LVM2 installed       #  07.11.2011, 21:45 modified by Ralph Roth #* rar *#

    # WONT WORK WITH HP RAID!
    LVMFDISK=$(/sbin/fdisk -l | grep "LVM$")

    if  [ -n "$LVMFDISK" -o -s /etc/lvmtab -o /etc/lvm/lvm.conf ]
    then # <m>  11.03.2008, 1158 -  Ralph Roth
        vgdisplay -s > /dev/null 2>&1 #  10032008 modified by Ralph.Roth
        # due to LVM2 (doesn't use /etc/lvmtab anymore), but should be compatible to LVM1; A. Kumpf
        if [ "$?" = "0" ] ; then
              AddText "The system file layout is configured using the LVM (Logical Volume Manager)"
        # choose between LVM1 and LVM2 because of different syntaxes; A. Kumpf, 21.07.06
             if [ -x "/sbin/lvm" ]; then
               LVM_VER=2
             else
               LVM_VER=1
             fi
            #
                case "$LVM_VER" in
                "1")
                  exec_command "lvscan --version" "LVM Version"
                  exec_command "ls -la /dev/*/group" "Volumegroup Device Files"
                  # { changed/added 29.01.2004 (11:15) by Ralph Roth } - sr by winfried knobloch for Serviceguard
                  exec_command "cat /proc/lvm/global" "LVM global info"
                  exec_command "vgdisplay -v | awk -F' +' '/PV Name/ {print \$4}'" "Available Physical Groups"
                  exec_command "vgdisplay -s | awk -F\\\" '{print \$2}'" "Available Volume Groups"
                  exec_command "vgdisplay -v | awk -F' +' '/LV Name/ {print \$3}'" "Available Logical Volumes"
                  ;;
                "2")
                  exec_command "ls -al /dev/mapper/*" "Volumegroup Device Files"
                  exec_command "lvm version" "LVM global info"
                  exec_command "vgdisplay -v | awk -F' +' '/PV Name/ {print \$4}'" "Available Physical Groups"
                  exec_command "vgdisplay -s | awk -F\\\" '{print \$2}'" "Available Volume Groups"
                  exec_command "vgdisplay -v | awk -F' +' '/LV Name/ {print \$4}'" "Available Logical Volumes"
                  # The command vgs -o +tags vgname will display any tags that are set for a volume group. *TODO*
                  # vgcreate --addtag $(uname -n) /dev/vgpkgA /dev/sda1 /dev/sdb1 // vgchange --deltag $(uname -n) vgpkgA  *SGLX*
                  [ -x /sbin/vgs ] && exec_command "/sbin/vgs -o vg_name,lv_name,devices" "Detailed Volume Groups Report" #  27.10.2011 #* rar *# EHR by Jim Bruce
                  exec_command "lvs -o +devices" "Logical Volumes"      #  07.11.2011, 21:46 modified by Ralph Roth #* rar *#
                  ;;
                  *)
                  AddText "Unsupported (new) LVM version ($LVM_VER)!"
                  ;;
                  esac
            #
              exec_command "vgdisplay -v" "Volumegroups"
              exec_command PVDisplay "Physical Devices used for LVM"
              AddText "Note: Run vgcfgbackup on a regular basis to backup your volume group layout"
            else
              # if vgdisplay exist, but no LV configured (dk3hg 21.02.03)
              AddText "LVM binaries found, but this system seems to be configured with whole disk layout (WDL)"
        fi
    else
        AddText "This system seems to be configured with whole disk layout (WDL)"
    fi

    # MD Tools, Ralph Roth

    if [ -r /etc/raidtab ]
    then
        exec_command "cat /proc/mdstat" "Software RAID: mdstat"
        exec_command "cat /etc/raidtab" "Software RAID: raidtab"
        [ -r /proc/devices/md ] && exec_command "cat /proc/devices/md" "Software RAID: MD Devices"
    fi

    dec_heading_level

fi # terminates CFG_LVM wrapper

###########################################################################
if [ "$CFG_NETWORK" != "no" ]
then # else skip to next paragraph

  paragraph "Network Settings"
  inc_heading_level

  exec_command "/sbin/ifconfig" "LAN Interfaces Settings (ifconfig)"    #D011 -- 16. März 2011,  28. Dezember 2011, ER by Heiko Andresen
  exec_command "ip addr" "LAN Interfaces Settings (ip addr)"            #D011 -- 16. März 2011,  28. Dezember 2011, ER by Heiko Andresen
  exec_command "ip -s l" "Detailed NIC Statistics"                      #07.11.2011, 21:33 modified by Ralph Roth #* rar *#

  if [ -x /usr/sbin/ethtool ]     ###  22.11.2010, 23:44 modified by Ralph Roth
  then
      LANS=$(ifconfig|grep ^[a-z]|grep -v ^lo|awk '{print $1;}')	# RR: ifconfig is decrecapted -> ip a? 13.11.2013
      for i in $LANS
      do
	  exec_command "/usr/sbin/ethtool $i 2>/dev/null; /usr/sbin/ethtool -i $i" "Ethernet Settings for Interface "$i
      done
  fi

  if [ $DEBIAN = "yes" ] ; then
    if [ -f /etc/network/interfaces ] ; then
      exec_command "grep -vE '(^#|^$)' /etc/network/interfaces" "Netconf Settings"
    fi
  fi

  ## Added 3/05/08 by krtmrrsn@yahoo.com, Marc Korte, display ethernet
  ##  LAN and route config files for RedHat.
  if [ $REDHAT = "yes" ] ; then
    ## There will always be at least ifcfg-lo.
    exec_command "for CfgFile in /etc/sysconfig/network-scripts/ifcfg-*; do printf \"\n\n\$(basename \${CfgFile}):\n\n\"; cat \${CfgFile}; done" "LAN Configuration Files"
    ## Check first that any route-* files exist ("grep  -q ''" exit status). Seems buggy!
    exec_command "if grep -q '' /etc/sysconfig/network-scripts/route-*; then for RouteCfgFile in /etc/sysconfig/network-scripts/route-*; do printf \"\n\n\$(basename \${RouteCfgFile}):\n\n\"; cat \${RouteCfgFile}; done; fi" "Route Configuration Files"
  fi
  ## End Marc Korte display ethernet LAN config files.

  [ -x /sbin/mii-tool ] && exec_command "/sbin/mii-tool -v" "MII Status"
  [ -x /sbin/mii-diag ] && exec_command "/sbin/mii-diag -a" "MII Diagnostics"

    exec_command "ip route" "Network Routing"           #  07.11.2011, 21:37 modified by Ralph Roth #* rar *#
    exec_command "netstat -r" "Routing Tables"
    exec_command "ip neigh" "Network Neighborhood"      #  07.11.2011, 21:38 modified by Ralph Roth #* rar *#

  NETSTAT=`which netstat`
  if [ $NETSTAT ]  && [ -x $NETSTAT ]; then
      # test if netstat version 1.38, because some options differ in older versions
      # MiMe: '\' auf awk Zeile wichtig
      RESULT=`netstat -V | awk '/netstat/ {
	  if ( $2 < 1.38 ) {
	    print "NO"
	  } else { print "OK" }
	}'`

      #exec_command "if [ "$RESULT" = "OK" ] ; then netstat -gi; fi" "Interfaces"
      if [ "$RESULT" = "OK" ]
	then
	  exec_command "netstat -gi" "Interfaces"
	  exec_command "netstat -tlpn" "TCP Daemons accepting connection"
	  exec_command "netstat -ulpn" "UDP Daemons accepting connection"
	fi

      exec_command "netstat -s" "Summary statistics for each protocol"
      exec_command "netstat -i" "Kernel Interface table"
      # MiMe: iptables since 2.4.x
      # MiMe: iptable_nat realisiert dabei das Masquerading
      # MiMe: Details stehen in /proc/net/ip_conntrack
      if [ -e /proc/net/ip_masquerade ]; then
	exec_command "netstat -M" "Masqueraded sessions"
      fi
      if [ -e /proc/net/ip_conntrack ]; then
	exec_command "cat /proc/net/ip_conntrack" "Masqueraded sessions"
      fi
      exec_command "netstat -an" "list of all sockets"
  fi  ## netstat
  # -----------------------------------------------------------------------------
  if [ -x /usr/sbin/ss ]
  then
    exec_command "/usr/sbin/ss -planeto" "TCP Listening Sockets Statistics" # changed 20131211 by Ralph Roth
    exec_command "/usr/sbin/ss -planeuo" "UDP Listening Sockets Statistics" # UDP and listening? :)
  fi # ss
  # -----------------------------------------------------------------------------
  ## Added 4/07/06 by krtmrrsn@yahoo.com, Marc Korte, probe and display
  ##        kernel interface bonding info.
  if [ -e /proc/net/bonding ]; then
    for BondIF in `ls -1 /proc/net/bonding`
    do
      exec_command "cat /proc/net/bonding/$BondIF" "Bonded Interfaces: $BondIF"
    done
  fi
  ## End Marc Korte kernel interface bonding addition.
  # -----------------------------------------------------------------------------
  DIG=`which dig`
  if [ -n "$DIG" ] && [ -x $DIG ] ; then
    exec_command "dig `hostname -f`" "dig hostname"
  else
    NSLOOKUP=`which nslookup`
    if [ -n "$NSLOOKUP" ] && [ -x $NSLOOKUP ] ; then
      exec_command "nslookup `hostname -f`" "Nslookup hostname"
    fi
  fi

  exec_command "grep -vE '^#|^ *$' /etc/hosts" "/etc/hosts"
#
  if [ -f /proc/sys/net/ipv4/ip_forward ] ; then
    FORWARD=`cat /proc/sys/net/ipv4/ip_forward`
    if [ $FORWARD = "0" ] ; then
      exec_command "echo \"IP forward disabled\"" "IP forward"
    else
      exec_command "echo \"IP forward enabled\"" "IP forward"
    fi
  fi

  if [ -r /proc/net/ip_fwnames ] ; then
    if [ -x /sbin/ipchains ] ;then
      exec_command "/sbin/ipchains -n -L forward" "ipfilter forward settings"
      exec_command "/sbin/ipchains -L -v" "ip filter settings"
    fi
  fi

  if [ -r /proc/net/ip_tables_names ] ; then
    if [ -x /sbin/iptables ] ; then
      exec_command "/sbin/iptables -L -v --line-numbers" "Firewall: iptables rules and chains" ## rr, 030604 -v added, 101111, rar
      exec_command "/sbin/iptables-save -c" "Firewall: iptables saved rules" ## rr, 120704 added, -c 101111, rar
    fi
  fi

  if [ -x /usr/sbin/tcpdchk ] ; then
    exec_command "/usr/sbin/tcpdchk -v" "tcpd wrapper"
    exec_command "/usr/sbin/tcpdchk -a" "tcpd warnings"
  fi

  [ -f /etc/hosts.allow ] && exec_command "grep  -vE '^#|^ *$' /etc/hosts.allow" "hosts.allow"
  [ -f /etc/hosts.deny ] && exec_command "grep  -vE '^#|^ *$' /etc/hosts.deny" "hosts.deny"

  #exec_command "nettl -status trace" "Nettl Status"

  if [ -f /etc/gated.conf ] ; then
      exec_command "cat /etc/gated.conf" "Gate Daemon"
  fi

  if [ -f /etc/bootptab ] ; then
      exec_command "grep -vE '(^#|^ *$)' /etc/bootptab" "BOOTP Daemon Configuration"
  fi

  if [ -r /etc/inetd.conf ]; then
    exec_command "grep -vE '^#|^ *$' /etc/inetd.conf" "Internet Daemon Configuration"
  fi
  #  02.05.2005, 15:23 modified by Ralph Roth

  # RedHat default
  ## exec_command "grep -vE '^#|^ *$' /etc/inetd.conf" "Internet Daemon Configuration"
  if [ -d /etc/xinetd.d ]; then
    # mdk/rh has a /etc/xinetd.d directory with a file per service
    exec_command "cat /etc/xinetd.d/*|grep -vE '^#|^ *$'" "/etc/xinetd.d/ section"
  fi

  #exec_command "cat /etc/services" "Internet Daemon Services"
  if [ -f /etc/resolv.conf ] ; then
     exec_command "grep -vE '^#|^ *$' /etc/resolv.conf;echo; ( [ -f /etc/nsswitch.conf ] &&  grep -vE '^#|^ *$' /etc/nsswitch.conf)" "DNS & Names"
  fi
  [ -r /etc/bind/named.boot ] && exec_command "grep -v '^;' /etc/named.boot"  "DNS/Named"

  if [ -f /usr/sbin/postconf ]; then
       exec_command "/usr/sbin/postconf | grep '^mail_version' | cut -d= -f2" "Postfix Version"
  elif [ -f /usr/sbin/sendmail.sendmail ]; then
       exec_command "echo | /usr/sbin/sendmail.sendmail -v root | grep 220" "Sendmail version"
  elif [ -f /usr/sbin/sendmail ]; then
       exec_command "echo | /usr/sbin/sendmail -v root | grep 220" "Sendmail version"
  else
       exec_command "echo SENDMAIL VERSION not found issue" "Sendmail version"
  fi

  aliasespath="/etc"
  if [ "$GENTOO" == "yes" ] ;then   ## 2007-02-27 Oliver Schwabedissen
    aliasespath="/etc/mail"
  fi
  if [ -f $aliasespath/aliases ] ; then
    exec_command "grep -vE '^#|^ *$' $aliasespath/aliases" "Email Aliases"
  fi
  #exec_command "grep -vE '^#|^$' /etc/rc.config.d/nfsconf" "NFS settings"
  exec_command "ps -ef|grep -E '[Nn]fsd|[Bb]iod'" "NFSD and BIOD utilization"   ## fixed 2007-02-28 Oliver Schwabedissen

  # if portmap not available, do nothing
  RES=`ps xau | grep [Pp]ortmap`
  if [ -n "$RES" ] ; then
    exec_command "rpcinfo -p " "RPC (Portmapper)"
    # test if mountd running
    MOUNTD=`rpcinfo -p | awk '/mountd/ {print $5; exit}'`
  #  if [ "$MOUNTD"="mountd" ] ; then
    if [ -n "$MOUNTD" ] ; then
      exec_command "rpcinfo -u 127.0.0.1 100003" "NSFD responds to RPC requests"
      SHOWMOUNT=`which showmount`   ## 2007-02-27 Oliver Schwabedissen
      if [ $SHOWMOUNT ] && [ -x $SHOWMOUNT ] ; then
        exec_command "$SHOWMOUNT -a" "Mounted NFS File Systems"
      fi
      # SUSE
      if [ -x /usr/lib/autofs/showmount ] ; then
        exec_command "/usr/lib/autofs/showmount -a" "Mounted NFS File Systems"
      fi
      if [ -f /etc/auto.master ] ;then
        exec_command "grep -vE '^#|^$' /etc/auto.master" "NFS Automounter Master Settings"
      fi
      if [ -f /etc/auto.misc ] ;then
        exec_command "grep -vE '^#|^$' /etc/auto.misc" "NFS Automounter misc Settings"
      fi
      if [ -f /proc/net/rpc/nfs ] ; then
        exec_command "nfsstat" "NFS Statistics"
      fi
    fi # mountd
  fi

  #(ypwhich 2>/dev/null>/dev/null) && \
  #    (exec_command "what /usr/lib/netsvc/yp/yp*; ypwhich" "NIS/Yellow Pages")

  # ntpq live sometimes in /usr/bin or /usr/sbin
  NTPQ=`which ntpq`
  # if [ $NTPQ ] && [ -x $NTPQ ] ; then
  if [ -n "$NTPQ" ] && [ -x "$NTPQ" ] ; then      # fixes by Ralph Roth, 180403
    exec_command "$NTPQ -p" "XNTP Time Protocol Daemon"
  fi

  exec_command "hwclock -r" "Time: HWClock" # rr, 20121201
  [ -f /etc/ntp.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/ntp.conf" "ntp.conf"
  [ -f /etc/shells ] && exec_command "grep  -vE '^#|^ *$'  /etc/shells" "FTP Login Shells"
  [ -f /etc/ftpusers ] && exec_command "grep  -vE '^#|^ *$'  /etc/ftpusers" "FTP Rejections (/etc/ftpusers)"
  [ -f /etc/ftpaccess ] && exec_command "grep  -vE '^#|^ *$'  /etc/ftpaccess" "FTP Permissions (/etc/ftpaccess)"
  [ -f /etc/syslog.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/syslog.conf" "syslog.conf"
  [ -f /etc/syslog-ng/syslog-ng.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/syslog-ng/syslog-ng.conf" "syslog-ng.conf"
  [ -f /etc/host.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/host.conf" "host.conf"

  ######### SNMP ############
  [ -f /etc/snmpd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmpd.conf" "Simple Network Management Protocol (SNMP)"
  [ -f /etc/snmp/snmpd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmp/snmpd.conf" "Simple Network Management Protocol (SNMP)"
  [ -f /etc/snmp/snmptrapd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmp/snmptrapd.conf" "SNMP Trapdaemon config"

  [ -f  /opt/compac/cma.conf ] && "grep -vE '^#|^ *$' /opt/compac/cma.conf" "HP Insight Management Agents configuration"

  ## ssh
  [ -f /etc/ssh/sshd_config ] && exec_command "grep -vE '^#|^ *$' /etc/ssh/sshd_config" "sshd config"
  [ -f /etc/ssh/ssh_config ] && exec_command "grep -vE '^#|^ *$' /etc/ssh/ssh_config" "ssh config"

  dec_heading_level

fi # terminates CFG_NETWORK wrapper


###########################################################################
if [ "$CFG_KERNEL" != "no" ]
then # else skip to next paragraph

# In the v2.6 Linux kernel, preventing the starvation of requests in general,
# and read requests in particular, was a primary focus of the new (four) I/O
# schedulers. The default I/O Elevator in the v2.6 Linux kernel is the
# anticipatory scheduler. RedHat RHEL4/5.6 and Novell/SUSE SLES 9-11
# installations overwrite this with the “CFQ scheduler”.
# see also
#     # blockdev -v --getra /dev/sda
#     get readahead: 1024
#

    paragraph "Kernel, Modules and Libraries" "Kernelparameters"
    inc_heading_level

    if [ -f /etc/lilo.conf ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/lilo.conf" "Lilo Boot Manager"
      exec_command "/sbin/lilo -q" "currently mapped files"
    fi

    if [ -f /boot/grub/menu.lst ] ; then
      exec_command "grep -vE '^#|^ *$' /boot/grub/menu.lst" "GRUB Boot Manager" # rar
    fi

    if [ -f /etc/palo.conf ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/palo.conf" "Palo Boot Manager"
    fi

    exec_command "ls -l /boot" "Files in /boot" # 2404-2006, ralph
    exec_command "lsmod" "Loaded Kernel Modules" # Fix/ER by VG - on RHEL 5.3, it is : /sbin/lsmod / on Ubuntu 10.04 it is /bin/lsmod,
    exec_command "ls -l /lib/modules" "Available Modules Trees"  # rar

    if [ -f /etc/modules.conf ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/modules.conf" "modules.conf"
    fi
    if [ -f /etc/modprobe.conf ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/modprobe.conf" "modprobe.conf (all settings)"
      exec_command "grep -r = /etc/modprob*   | grep -v ':#'" "modprobe related settings "
    fi

    if [ -f /etc/sysconfig/kernel ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/sysconfig/kernel" "Modules for the ramdisk" # rar, SuSE only
      exec_command "sed -e '/^#/d;/^$/d;/^[[:space:]]*$/d' /etc/sysconfig/kernel" "Missing Kernel Modules" # changed 20130205 by Ralph Roth
      AddText "See: Modules failing to load at boot time - TID 7005784"
    fi

    if [ "$DEBIAN" = "no" ] && [ "SLACKWARE" = "no" ] ; then
            which rpm > /dev/null  && exec_command "rpm -qa | grep -e ^k_def -e ^kernel -e k_itanium -e k_smp -e ^linux" "Kernel RPMs" # rar, SuSE+RH+Itanium2
    fi

    if [ "$DEBIAN" = "yes" ] ; then
        exec_command "dpkg -l | grep -i -e Kernel-image -e Linux-image" "Kernel related DEBs"
    fi
    [ -x /usr/sbin/get_sebool ] && exec_command "/usr/sbin/get_sebool -a" "SELinux Settings"

    who -b 2>/dev/null > /dev/null && exec_command "who -b" "System boot" #  23.03.2006, 13:18 modified by Ralph Roth
    exec_command "cat /proc/cmdline" "Kernel command line"

    exec_command "getconf GNU_LIBC_VERSION" "libc Version (getconf)"

    if [ -r  /lib/libc.so.5 ]
    then
        if [ -x  /lib/libc.so.5 ]
        then
            exec_command "/lib/libc.so.5" "libc5 Version"  # Mandrake 9.2
        else
            exec_command "strings /lib/libc.so.5 | grep \"release version\"" "libc5 Version (Strings)"
            ############# needs work out!
            ## rpm ## ldd
        fi
    fi

    if [ -r  /lib/libc.so.6 ]
    then
        if [ -x  /lib/libc.so.6 ]
        then
            exec_command "/lib/libc.so.6" "libc6 Version"  # Mandrake 9.2
        else
            exec_command "strings /lib/libc.so.6 | grep \"release version\"" "libc6 Version (Strings)"
            ############# needs work out!
            ## rpm ## ldd
        fi
    fi

    if [ "$DEBIAN" = "no" ] && [ "$SLACKWARE" = "no" ] && [ "$GENTOO" = "no" ] ; then  ## fixed 2007-02-27 Oliver Schwabedissen
            which rpm > /dev/null  && exec_command "rpm -qi glibc" "libc6 Version (RPM)" # rar, SuSE+RH
    fi

    exec_command "/sbin/ldconfig -vN  2>/dev/null" "Run-time link bindings"		### changed 20130730 by Ralph Roth

    # MiMe: SuSE patched kernel params into /proc
    if [ -e /proc/config.gz ] ; then
      exec_command "zcat /proc/config.gz | grep -vE '^#|^ *$'" "Kernelparameter /proc/config.gz"
    else
      if [ -e /usr/src/linux/.config ] ; then
        exec_command "grep -vE '^#|^ *$' /usr/src/linux/.config" "Kernelsource .config"
      fi
    fi

    ##
    ## we want to display special kernel configuration as well
    ## done in /etc/init.d/boot.local
    ## 31Jan2003 it233 U.Frey FRU
    if [ -e /etc/init.d/boot.local ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/init.d/boot.local" "Additional Kernel Parameters init.d/boot.local"
    fi

    if [ -x /sbin/sysctl ] ; then ##  11.01.2010, 10:44 modified by Ralph Roth
      exec_command "/sbin/sysctl -a 2> /dev/null | sort -u" "configured kernel variables at runtime"  ## rr, 20120212
      exec_command "cat /etc/sysctl.conf | sort -u |grep -v -e ^# -e ^$" "configured kernel variables in /etc/sysctl.conf"
    fi

    if [ -f "/etc/rc.config" ] ; then
       exec_command "grep ^INITRD_MODULES /etc/rc.config" "INITRD Modules"
    fi

    if [ -d /sys/devices ]
    then                                                    # The new Linux 2.6.x  I/O system and the I/O scheduler
        exec_command GetElevator "Kernel I/O Elevator"      # 18.07.2011, 13:33 modified by Ralph Roth #* rar *#
        exec_command "lsblk -ta" "List of Block Devices"    # changed 20130627 by Ralph Roth
    fi
    dec_heading_level

fi # terminates CFG_KERNEL wrapper
######################################################################

if [ "$CFG_ENHANCEMENTS" != "no" ]
then # else skip to next paragraph

    paragraph "System Enhancements"
    inc_heading_level

    if [ -e /etc/X11/XF86Config ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/X11/XF86Config" "XF86Config"
    else
      if  [ -e /etc/XF86Config ] ; then
        exec_command "grep -vE '^#|^ *$' /etc/XF86Config" "XF86Config"
      fi
    fi

    # stderr output from "grep -vE '^#|^ *$' /etc/XF86Config-4":
    #    grep: /etc/XF86Config-4: No such file or directory

    if [ -e /etc/X11/XF86Config-4 ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/X11/XF86Config-4" "XF86Config-4"
    else
      if  [ -e /etc/XF86Config-4 ] ; then                                   #  09.01.2008, 14:49 modified by Ralph Roth
        exec_command "grep -vE '^#|^ *$' /etc/XF86Config-4" "XF86Config-4"
      fi
    fi

    if [ -e /etc/X11/xorg.conf ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/X11/xorg.conf" "xorg.conf"
    fi

    # MiMe: fuer X braucht man Rechte
    if [ -x /usr/X11R6/bin/xhost ] ; then
      /usr/X11R6/bin/xhost > /dev/null 2>&1
      if [ "$?" -eq "0" ] ;
      then
        # Gratien D'haese
        # fix for sshdX11
        # old command   [ -x /usr/bin/X11/xdpyinfo ] && [ -n "$DISPLAY" ] && exec_command "/usr/bin/X11/xdpyinfo" "X11"
        # this will only check if the display is 0 or 1 which is more then enough
            [ -x /usr/bin/X11/xdpyinfo ] && [ -n "$DISPLAY" ] && [ `echo $DISPLAY | cut -d: -f2 | cut -d. -f1` -le 1 ] && exec_command "/usr/bin/X11/xdpyinfo" "X11"
            [ -x /usr/bin/X11/fsinfo ] && [ -n "$FONTSERVER" ] && exec_command "/usr/bin/X11/fsinfo" "Font-Server"
      fi
    fi

    [ -x /opt/gnome/bin/gconftool-2 ] &&  exec_command "gconftool-2 -R /system"  "GNOME System Config"  ##  BF=bernhard keppel/110711, 30.11.2010/Ralph Roth

    dec_heading_level

fi # terminates CFG_ENHANCEMENTS wrapper
###########################################################################

if [ "$CFG_APPLICATIONS" != "no" ]
then # else skip to next paragraph

    paragraph "Applications and Subsystems"

### COMMON ################################################################

    inc_heading_level

    [ -x /usr/sbin/rear ] && exec_command "/usr/sbin/rear dump" "ReaR Configuration"    #  14.06.2011, 18:58 modified by Ralph Roth #* rar *#

    if [ -d /usr/local/bin ] ; then
      exec_command "ls -lisa /usr/local/bin" "Files in /usr/local/bin"
    fi
    if [ -d /usr/local/sbin ] ; then
      exec_command "ls -lisa /usr/local/sbin" "Files in /usr/local/sbin"
    fi
    if [ -d /opt ] ; then
      exec_command "ls -lisa /opt" "Files in /opt"
    fi

############ Samba and Swat ########################

    if [ -f /etc/inetd.conf ] ; then
      SWAT=`grep swat /etc/services /etc/inetd.conf`
    fi
    if [ -f /etc/xinetd.conf ] ; then
      SWAT=`grep swat /etc/services /etc/xinetd.conf`
    fi

    [ -n "$SWAT" ] && exec_command  "echo $SWAT" "Samba: SWAT-Port"

    [ -x /usr/sbin/smbstatus ] && exec_command "/usr/sbin/smbstatus 2>/dev/null" "Samba (smbstatus)"
    ### Debian...., maybe a smbstatus -V/samba -V is usefull
    [ -x /usr/bin/smbstatus ] && exec_command "/usr/bin/smbstatus 2>/dev/null" "Samba (smbstatus)"  ## fixed 2007-02-27 Oliver Schwabedissen
    [ -x /usr/bin/testparm ] && exec_command "/usr/bin/testparm -s 2> /dev/null" "Samba Configuration (testparm)" #  09.01.2008, 14:53 modified by Ralph Roth
    [ -f /etc/samba/smb.conf ] && exec_command "cat /etc/samba/smb.conf" "Samba Configuration (smb.conf)" #*#  Alexander De Bernardi, 20100421 testparm does not show complete config
    [ -f /etc/init.d/samba ] && exec_command "ps -ef | grep -E '(s|n)m[b]'" "Samba Daemons"

    if [ -x /usr/sbin/lpc ] ; then
      exec_command "/usr/sbin/lpc status" "BSD Printer Spooler and Printers"    #*# Alexander De Bernardi, 20100310
    fi
     if [ -x /usr/bin/lpstat ] ; then
     exec_command "/usr/bin/lpstat -t" "SYSV Printer Spooler and Printers"      #*# Alexander De Bernardi, 20100310
     fi
#     if [ -x /usr/bin/hp-info ] ; then
#
# This for a bug in linux version
# Found: cfg2html stalls (freeze) when hplip is installed
# Cause: hp-info called in interactive mode, waits for a reply
# EL, 1.84 - 25. Januar 2011
#     exec_command "echo q | /usr/bin/hp-info -i | \
#        /usr/bin/col" "HPLIP Printer Info"  #*# Alexander De Bernardi, 20100310
#     fi

    [ -r /etc/printcap ] && exec_command "grep -vE '^#|^ *$' /etc/printcap" "Printcap"
    [ -r /etc/hosts.lpd ] && exec_command "grep -vE '^#|^ *$' /etc/hosts.lpd" "hosts.lpd"

##
## we want to display HP OpenVantage Operations configurations
## 31Jan2003 it233 FRU U.Frey

    if [ -e /opt/OV/bin/OpC/utils/opcdcode ] ; then
      if [ -e /opt/OV/bin/OpC/install/opcinfo ] ; then
        exec_command "cat /opt/OV/bin/OpC/install/opcinfo" "HP OpenView Info, Version"
      fi
      if [ -e /var/opt/OV/conf/OpC/monitor ] ; then
        exec_command "/opt/OV/bin/OpC/utils/opcdcode /var/opt/OV/conf/OpC/monitor | grep DESCRIPTION" "HP OpenView Configuration MONITOR"
      fi

      if [ -e /var/opt/OV/conf/OpC/le ] ; then
        exec_command "/opt/OV/bin/OpC/utils/opcdcode /var/opt/OV/conf/OpC/le | grep DESCRIPTION" "HP OpenView Configuration LOGGING"
      fi
    fi

## we want to display Veritas netbackup configurations
## 31Jan2003 it233 FRU U.Frey
## 3/5/08 Modified/added functionality by krtmrrsn@yahoo.com, Marc Korte.
##  Some things have changed in NetBU 6.x.
##  Made a seperate section for Veritas Netbackup
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

###########################################################################
# { changed/added 28.01.2004 (17:56) by Ralph Roth }
    if [ -r /etc/cmcluster.conf ] ; then
        dec_heading_level
        paragraph "Serviceguard"
        inc_heading_level
        . ${SGCONFFILE:=/etc/cmcluster.conf}   # get env. setting, rar 12.05.2005
        PATH=$PATH:$SGSBIN:$SGLBIN
        exec_command "cat ${SGCONFFILE:=/etc/cmcluster.conf}" "Cluster Config Files"
        exec_command "what  $SGSBIN/cmcld|head; what  $SGSBIN/cmhaltpkg|head" "Real Serviceguard Version"  ##  12.05.2005, 10:07 modified by Ralph Roth
        exec_command "cmquerycl -v" "Serviceguard Configuration"
        exec_command "cmviewcl -v" "Serviceguard Nodes and Packages"
        exec_command "cmviewconf" "Serviceguard Cluster Configuration Information"
        exec_command "cmscancl -s" "Serviceguard Scancl Detailed Node Configuration"
        exec_command "netstat -in" "Serviceguard Network Subnets"
        exec_command "netstat -a |fgrep hacl" "Serviceguard Sockets"
        exec_command "ls -l $SGCONF" "Files in $SGCONF"
    fi

######## SLES 11 SP1 Pacemaker stuff ########## Mittwoch, 16. März 2011 ##### Ralph Roth ####
    [ -x /usr/sbin/corosync-cfgtool ] && exec_command "/usr/sbin/corosync-cfgtool -s" "Corosync TOTEM Status/Active Rings"
    if [ -x /usr/sbin/crm ] # pacemaker #
    then
        exec_command "/usr/sbin/crm_mon -rnA1" "Cluster Configuration"  		## 281113, rr
        exec_command "/usr/sbin/crm -D plain configure show" "Cluster Configuration"
        exec_command "/usr/sbin/crm -D plain status" "Cluster Status"
    fi
    [ -x /usr/sbin/clusterstate ] && exec_command "/usr/sbin/clusterstate --all" "Status of pacemaker HA cluster" ##  04.04.2012, 14:27 modified by Ralph Roth #* rar *#

    # only if ClusterTools2/SLES11 HAE are installed #  04.04.2012, 14:52 modified by Ralph Roth #* rar *#
    [ -x /usr/sbin/grep_cluster_patterns ] && exec_command "/usr/sbin/grep_cluster_patterns --show"  "Output of grep_cluster_patterns"
    for i in  grep_error_patterns  grep_cluster_transition cs_show_scores cs_list_failcounts
    do
        [ -x /usr/sbin/$i ] && exec_command "$i" "ClusterTool2: Output of $i"
    done

######## RHEL 5.x CRM stuff ######## Freitag, 18. März 2011 #### Ralph Roth ####
    if [ -x /usr/sbin/cman_tool ]
    then
        exec_command "/usr/sbin/cman_tool status"   "Cluster Resource Manager Status"
        exec_command "/usr/sbin/cman_tool nodes"    "Cluster Resource Manager Nodes"
        exec_command "/usr/sbin/cman_tool services" "Cluster Resource Manager Services"
    fi

####### Red Hat Cluster Suite configuration  #  04.07.2011, 16:23 modified by Ralph Roth #* rar *#
    if [ -r /etc/cluster/cluster.conf ]
    then
        exec_command "/usr/sbin/clustat" "Cluster Status"   ## ER by David Williams
        if [[ $(grep -c xml /etc/cluster/cluster.conf) -gt 0 ]];
        then  ## small example can be found at http://pastebin.com/Yi5humeL
            exec_command "cat /etc/cluster/cluster.conf|sed 's{<{\&lt{g'|sed 's{>{\&gt{g'" "Cluster Configuration (XML)"
        else
            exec_command "cat /etc/cluster/cluster.conf" "Cluster Configuration"
        fi
    fi
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
###   HP Proliant Server LINUX Logfiles from HP tools and or the HP PSP.   ###
###   Made by Jeroen.Kleen@hp.com EMEA ISS Competence Center Engineer      ###

if [ "$CFG_HPPROLIANTSERVER" != "no" ]
then # else skip to next paragraph

# @(#) Below follows HP Proliant specific stuff mainly written by Jeroen Kleen
# --=----------------------------------------------------------------------=---
#

    paragraph "hp ProLiant Server Log- and configuration Files"
    inc_heading_level

    temphp=/tmp/cfg2html_temp
    if [ ! -d $temphp ] ; then
         mkdir $temphp
    fi

    if [ -x /opt/hp/hpdiags/hpdiags ] ; then
        /opt/hp/hpdiags/hpdiags -v 5 -o $temphp/hpdiagsV5.txt -f -p >/dev/null
    fi

    if [ -x /opt/hp/hp_fibreutils/hp_system_info ] ; then
                rm /tmp/system_info*.tar.gz -f
                /opt/hp/hp_fibreutils/hp_system_info > /dev/null
                cp /tmp/system_info*.tar.gz $temphp
                rm /tmp/system_info*.tar.gz -f
    fi


# Request:              Dienstag, 12. Januar 2010 -- Koerber, Martin
# ========
# Starting with "8.28-13.0 (6 May 2009)" of cpqacuxe the capture functionality is no longer supported.
# http://h20000.www2.hp.com/bizsupport/TechSupport/SoftwareDescription.jsp?lang=en&cc=us&prodTypeId=15351&prodSeriesId=1121486&swItem=MTX-a72c1471380f45f4a5cb2f4ec9&prodNameId=3288144&swEnvOID=4049&swLang=8&taskId=135&mode=5
#
# Version: 8.28-13.0  (6 May 2009), hpacucli-8.70-8.0 (April 2012)
# Scripting for captures and inputs is no longer supported in ACU HPACUCLI is now responsible for scripting

    CPQACUXE=$(which cpqacuxe 2>/dev/null)
    if [ -x "$CPQACUXE" ] ; then
            $CPQACUXE -c $temphp/cpqacuxe.cfg
    fi

    HPADUCLI=$(which hpaducli 2>/dev/null )
    if [ -x "$HPADUCLI" ] ; then
            $HPADUCLI -f $temphp/ADUreport.txt -r
    fi

    # Where is hponcfg installed? /opt/hp/tools ???
    if [ -x /usr/lib/hponcfg ] ; then
        /usr/lib/hponcfg -a -w $temphp/ilo.cfg  	# closes issue #31 # changed 20131218 by Ralph Roth
    fi
    if [ -x /sbin/hponcfg ] ; then
        /sbin/hponcfg  -a -w $temphp/ilo.cfg  		# closes issue #31 # changed 20131218 by Ralph Roth
    fi

    if [ -x $DMIDECODE ] ;  then
        exec_command "$DMIDECODE | grep Product" "HP Proliant Server model Information taken from dmidecode"
    fi

    SURVEY=$(which survey 2>/dev/null)
    if [ -x "$SURVEY" ] ; then
            exec_command "$SURVEY -v 5 -t" "Classic Survey output -v 5"
    fi

    if [ -x /sbin/hplog ] ; then
            exec_command "hplog -t -f -p" "Current Thermal Sensor, Fan and Power data"
            exec_command "hplog -v" "Proliant Integrated Management Log"
    fi

    if [ -r /var/log/hppldu.log ] ; then
            exec_command "cat /var/log/hppldu.log" "Installation Log Proliant Support Pack 7.*"
    fi

    if [ -r /tmp/hppldu.cfg ] ; then
            exec_command "cat /tmp/hppldu.cfg" "Proliant Support Pack 7.* Installation Settings file"
    fi

    if [ -r /var/hp/log/localhost/hpsum_log.txt ] ; then
            exec_command "cat /var/hp/log/localhost/hpsum_log.txt" "Installation Log Proliant Support Pack 8.* using HP SUM"
    fi

    if [ -r /var/hp/log/localhost/hpsum_detail_log.txt ] ; then
            exec_command "cat /var/hp/log/localhost/hpsum_detail_log.txt" "Detailed Installation Log Proliant Support Pack 8.* using HP SUM"
    fi

    if [ -e /opt/compaq/cma.conf ] ; then
            exec_command "cat /opt/compaq/cma.conf" "/opt/compaq/cma.conf file"
    fi

    if [ -e /opt/hp/hp-snmp-agents/cma.conf ] ; then
            exec_command "cat /opt/hp/hp-snmp-agents/cma.conf" "/opt/hp/hp-snmp-agents/cma.conf file"
    fi

    if [ -e /opt/compaq/snmpd.conf.orig ] ; then
            exec_command "cat /opt/compaq/snmpd.conf.orig" "/opt/compaq/snmpd.conf.orig file "
    fi

    if [ -e /var/hp/install_history.txt ] ; then
            exec_command "cat /var/hp/install_history.txt" "/var/hp/install_history.txt file"
    fi

    if [ -e /var/log/hplog.txt ] ; then
            exec_command "cat /var/log/hplog.txt" "/var/log/hplog.txt file"
    fi

    if [ -e /var/opt/hp/nicfwupg.log ] ; then
            exec_command "cat /var/opt/hp/nicfwupg.log" "/var/opt/hp/nicfwupg.log file"
    fi

    if [ -e /var/spool/compaq/cma.log ] ; then
            exec_command "cat /var/spool/compaq/cma.log" "/var/spool/compaq/cma.log Agents logfile"
    fi

    if [ -e /var/cpq/Component.log ] ; then
            exec_command "cat /var/cpq/Component.log" "Individual Components Installation Log file (ROMBIOS/SA FW/iLO)"
    fi

    if [ -e /etc/snmp/snmpd.conf ] ; then
            exec_command "cat /etc/snmp/snmpd.conf" "/etc/snmp/snmpd.conf file"
    fi

    if [ -x /etc/init.d/hpasm ] ; then
            exec_command "/etc/init.d/hpasm status" "hpasm status of how what modules are loaded and running correctly."
    fi

    if [ -e /opt/compaq/cpqhealth/cpqhealth_boot.log ] ; then
            exec_command "cat /opt/compaq/cpqhealth/cpqhealth_boot.log" "LOGfile from when hpasm failed installation"
    fi

    if [ -e /opt/compaq/hprsm/hprsm_boot.log ] ; then
            exec_command "cat /opt/compaq/hprsm/hprsm_boot.log" "LOGfile during boot from hprsm"
    fi

    if [ -x /opt/compaq/nic/bin/hpetfe  ] ; then
            exec_command "/opt/compaq/nic/bin/hpetfe -A" "/opt/compaq/utils/nic/bin/hpetfe -A HP NIC information"
    fi

    HPASMCLI=$(which hpasmcli 2>/dev/null)
    if [ -x "$HPASMCLI" ] ; then
            $HPASMCLI -s "show asr; show boot; show dimm; show f1; show fans; show ht; show ipl; show name; show powersupply; show pxe; show serial bios; show serial embedded; show serial virtual; show server; show temp; show uid; show wol" >$temphp/hpasmcliOutput.txt
            exec_command "cat $temphp/hpasmcliOutput.txt" "HP ASM CLI command line output"
    fi

    if [ -e /etc/opt/hp/hp-vt/hp-vt.conf ] ; then
            exec_command "cat /etc/opt/hp/hp-vt/hp-vt.conf" "Intelligent Networking Pack Virus Throttling conf file"
    fi

    if [ -x /etc/init.d/hp-vt ] ; then
            exec_command "/etc/init.d/hp-vt status" "Intelligent Networking Pack Virus Throttling Status"
    fi

    if [ -e /var/opt/hp/hp-vt/hp-vt.log ] ; then
            exec_command "cat /var/opt/hp/hp-vt/hp-vt.log" "Intelligent Networking Pack Logfile"
    fi

    if [ -x /opt/hp/hp-pel/nalicense ] ; then
            exec_command "/opt/hp/hp-pel/nalicense -d" "Proliant Essentials Licenses installed overview"
    fi
    if [ -e /var/opt/hp/hp-pel/hp-pel.log ] ; then
            exec_command "cat /var/opt/hp/hp-pel/hp-pel.log" "Proliant Essentials Licenses Logfile"
    fi

    if [ -e $temphp/ilo.cfg ] ; then
            exec_command "cat $temphp/ilo.cfg" "iLO configuration file captured via HPONCFG"
    fi

    if [ -e /root/install.log.syslog ] ; then
            exec_command "cat /root/install.log.syslog" "Installation SYS logfile"
    fi

    if [ -r /root/install.rdp.log ] ; then
        exec_command "cat /root/install.rdp.log" "Rapid Deployment Pack RDPinstall logfile"
    fi

    if [ -e /root/anaconda-ks.cfg ] ; then
            exec_command "cat /root/anaconda-ks.cfg" "anaconda kickstart file used during OS deployment"
    fi

    if [ -e /var/log/messages ] ; then
    #       exec_command "cat /var/log/messages" "messages logging file (older messages logfiles in TARBALL)"
                        cp /var/log/messages $temphp > /dev/null
                        cp /var/log/messages.1 $temphp > /dev/null
                        cp /var/log/messages.2 $temphp > /dev/null
    fi

    if [ -e /var/log/boot.log ] ; then
            exec_command "cat /var/log/boot.log" "boot.log logfile (older boot.log logfiles in TARBALL)"
            cp /var/log/boot.log.1 $temphp > /dev/null
            cp /var/log/boot.log.2 $temphp > /dev/null
    fi

    if [ -e /var/log/dmesg ] ; then
            exec_command "cat /var/log/dmesg" "dmesg logfile /var/log/dmesg"
    fi

    if [ -e /var/log/acpid ] ; then
            exec_command "cat /var/log/acpid" "ACPID power boot / reboot log"
    fi

#   if [ -e $temphp/ADUreport.txt ] ; then
#           exec_command "cat $temphp/ADUreport.txt" "Array Diagnostic Utility report is included in the TAR ball as a single file"
#   fi

    if [ -e $temphp/cpqacuxe.cfg ] ; then
            exec_command "cat $temphp/cpqacuxe.cfg" "cpqacuxe configuration file (SmartArray configuration)"
    fi

    if [ -e /tmp/hpsum ] ; then ## bugfixed 29052013 by Ralph Roth after an ER by Henrik Rosqvist
            echo "Generating HPSUM reports"
            /tmp/hpsum /report /veryv > /dev/null
            /tmp/hpsum /inventory_report /veryv > /dev/null
            /tmp/hpsum /firmware_report /veryv > /dev/null
            cp /tmp/discovery.xml $temphp > /dev/null
            cp /tmp/HPSUM_* $temphp > /dev/null
            cp /tmp/hp_sum/*.trace $temphp > /dev/null
            cp /tmp/hp_sum/InventoryResults.xml $temphp > /dev/null
    fi

    if [ -d /var/hp/log ] ; then
            cp /var/hp/log/* $temphp
            cp /var/hp/log/localhost/* $temphp
            cp /var/log/hp_sum/* $temphp
    fi

    if [ -d /opt/hp/hpdiags ] ; then
            cp /opt/hp/hpdiags/survey* $temphp
    fi

    if [ -d /opt/hp/hp-fc-enablement/elxreport.sh ] ; then
            /opt/hp/hp-fc-enablement/elxreport > /dev/null
            cp /tmp/elxreport.sh* $temphp
    fi

    if [ -d /opt/hp/hp-fc-enablement/ql-hba-collect-1.8/ql-hba-collect.sh ] ; then
            /opt/hp/hp-fc-enablement/ql-hba-collect-1.8/ql-hba-collect.sh > /dev/null
            cp /tmp/QLogicDiag* $temphp
    fi

    if [ -x /usr/local/bin/vcsu ] ; then
        echo "HP Virtual Connect Support Utility (VCSU) detected; get if needed the VC logs"
        echo " collected via /usr/local/bin/vcsu -a collect. and with vcsu -a -supportdump and"
        echo " executute then again cfg2html to get all the logs included automatically."
        cp /usr/local/bin/*.txt $temphp
        cp /usr/local/bin/vcsu*.log $temphp
    fi

    if [ -e /opt/netxen ] ; then
        echo "NetXen diagnostic utility detected; to get full NetXEN diag output run command:"
        echo "/opt/netxen/nxudiag -i ethX (ethX is your eth adapter like eth0 / eth1"
    fi

    ###below partitioning and HPACUCLI is contributed by kgalal@gmail.com
    ## Changed 2011-09-05 Peter Boysen - Previous hpacucli commands was redundant.
    if [ -x /usr/sbin/hpacucli ] ; then
	export INFOMGR_BYPASS_NONSA=1  # see issue #25
#       exec_command "/usr/sbin/hpacucli controller all show" "HP SmartArray controllers Detected"   # added by jeroenkleen HP
#       exec_command "/usr/sbin/hpacucli controller all show status" "HP SmartArray controllers Detected with Status"
#       slotnum=`/usr/sbin/hpacucli controller all show | awk '{if($0!="")print $6}'`  # jkleen: this doesn't work (yet) for MSA1x000 controllers
#       exec_command "/usr/sbin/hpacucli controller slot=$slotnum physicaldrive all show" "Physical Drives on SmartArray Controller"
#       exec_command "/usr/sbin/hpacucli controller slot=$slotnum logicaldrive all show" "Logical Drives on SmartArray controller"
        exec_command "/usr/sbin/hpacucli ctrl all show config detail" "HP SmartArray controllers Detected"   # added by jeroenkleen HP # Changed 2011-09-05 Peter Boysen
        /usr/sbin/hpacucli controller all diag file=$temphp/hpacucli_diag.txt          # Added 2011-09-05 Peter Boysen.
    fi

    disks=`/sbin/fdisk -l`
    if [ ! -z "$disks" ] ; then
        exec_command "/sbin/fdisk -l" "Disk Partitions on Logical Drives"
    else
        disks=`cat /proc/partitions | awk '{if($4 ~ /\//)print $4}' |grep -v p`
        for adisk in $disks ; do
            exec_command "/sbin/fdisk -l /dev/$adisk" "Disk Partitions - /dev/$adisk"
        done
    fi

    ###above partitioning and HPACUCLI is contributed by kgalal@gmail.com

    exec_command "ls $temphp" "These files have been made or captured during CFG2html execution and should be in the zipped TARball"
    hplog -s INFO -l "CFG2HTML HP Proliant Server report successfully created"

    dec_heading_level


fi  # end of CFG_HPPROLIANTSERVER paragraph
###  END of HP Proliant Server Integration
###############################################################################
###



###
##############################################################################
###   Altiris ADL agent settings and logfiles
###   Made by Jeroen.Kleen@hp.com EMEA ISS Competence Center Engineer      ###

if [ "$CFG_ALTIRISAGENTFILES" != "no" ]
then # else skip to next paragraph

  # checking if Altiris directory exist otherwise skip this section
  if [ -e /opt/altiris/deployment/adlagent ] ; then

    paragraph "Altiris ADL Agent logfiles and settings"
    inc_heading_level

    exec_command "cat /opt/altiris/deployment/adlagent/conf/adlagent.conf" "Altiris ADLagent settings file"
    exec_command "cat /opt/altiris/deployment/adlagent/log/adlagentdbg.txt" "Altris ADLagent Debugging file"
    exec_command "cat /opt/altiris/deployment/adlagent/log/adlagentIpTrace.txt" "Altiris ADLagent IP tracing file"

    dec_heading_level
  fi

fi  # end of CFG_ALTIRISAGENTFILES paragraph
###  END of Altiris ADL agent settings and logfiles
##############################################################################


###
##############################################################################
###   VMWARE settings and logfiles
###   Made by Jeroen Kleen, EMEA ISS Competence Center Engineer      ###

if [ "$CFG_VMWARE" != "no" ]
then # else skip to next paragraph
# checking if VMWare directory exist otherwise skip this section
  if [ -e /proc/vmware ] ; then

    paragraph "VMWare logfiles and settings"
    inc_heading_level
      exec_command "vmware -v" "VMWare Server version"
      echo "VMWare server detected. We will start now the vm-support script in case you"
      echo "need this vmware debugging file send to VMWare support or other support teams."
      vm-support
      exec_command "cat esx-$(date -I).$$.tgz" "vm-support ticket generated in local directory if vm-support is installed."
    dec_heading_level
  fi
fi  # end of CFG_VMWARE paragraph
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
###########################################################################
######     Creating gzipped TAR File for all needed files together. Added by Jeroen Kleen HP EMEA ISS CC

if [ "$CFG_HPPROLIANTSERVER" != "no" ]
then # else skip to next paragraph

 if [ -f $OUTDIR/$BASEFILE.tar ] ; then
        rm $OUTDIR/$BASEFILE.tar
 fi
echo " "
    echo "The following files are included in your gzipped tarball file:"
    tar -czf $OUTDIR/$BASEFILE.tar.gz $temphp
    echo " "
    echo "The tar file can be mailed to your support supplier if needed"

fi  # end of CFG_HPPROLIANTSERVER (making tarball)
###########################################################################


logger "End of $VERSION"
_echo "\n"
line

logger "End of $VERSION"
rm -f core > /dev/null

########## remove the error.log if it has size zero #######################
[ ! -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

####################################################################
