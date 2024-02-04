#!/bin/bash
#
# @(#) $Id: cfg2html-linux.sh,v 6.69 2023/09/14 07:05:13 ralph Exp $
# -----------------------------------------------------------------------------------------
# (c) 1997-2023 by Ralph Roth  -*- http://rose.rult.at -*-  Coding: ISO-8859-15
#     Further modified by Joe Wulf:  20200407@1432.

#  If you change this script, please mark your changes with for example
#  ## <username> and send your diffs from the actual version to my mail
#  address: cfg2html*hotmail.com -- details see in the documentation

CFGSH=$_  ### CFGSH appears unused. Verify use (or export if used externally).
# unset "-set -vx" for debugging purpose (use set +vx to disable); NOTE: After the 'exec 2>' statement all debug info will go the errorlog file (*.err)
# set -vx
# *vim:numbers:ruler
# shellcheck disable=SC2034,SC2154

# ---------------------------------------------------------------------------
# NEW VERSION - v6/github/GPL
#        __       ____  _     _             _       _ _
#   ___ / _| __ _|___ \| |__ | |_ _ __ ___ | |     | (_)_ __  _   ___  __
#  / __| |_ / _` | __) | '_ \| __| '_ ` _ \| |_____| | | '_ \| | | \ \/ /
# | (__|  _| (_| |/ __/| | | | |_| | | | | | |_____| | | | | | |_| |>  <
#  \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_|     |_|_|_| |_|\__,_/_/\_\
#           |___/
#  system collector script
#
# ---------------------------------------------------------------------------

# {jcw} To Do:
# -----------
# -  Print env|set, and 'shopt | sort | column -t' for root user.
# -  Ensure all called functions get the rename of variables from $VAR to ${VAR}.
# -  Rewrite all `<cmd>` to $(<cmd>).
# -
# -
# -
#

# {jcw} Done:
# -  Accomplished massive rename of variables from $VAR to ${VAR}.
# -
# -
# -
# -
#

# [20200312] {jcw}:  PATH management (AKA PathMunge!).
     # Good reference:  http://security.stackexchange.com/questions/117535/ordering-of-the-path-environment-variable
     CallingPATH=${PATH} # save the original PATH to document it # modified on 20201026 by edrulrd
     ShoptExtglob="$(shopt extglob | tr -s ' ' | tr -d '\t' | cut -d' ' -f2)"  # Preserve current state of extglob.
     shopt -s extglob # Force enable it
     if [[ ${EUID} -eq 0 ]]; then
           # Root-based PATH putting priv dirs before userland: colon-separated; should always be this one.  :)
           CorePath='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' # remove kerberos # modified on 20201026 by edrulrd
     else
           CorePath='/usr/local/bin:/usr/bin:/bin'
     fi; unset BuiltPath
     # Add local paths here, in order of importance (i.e. sbin before bin), without being redundant for paths that are already planned/managed by this function.
     ScndryPaths='/usr/kerberos/sbin:/opt/puppetlabs/puppet/bin:/usr/kerberos/bin:/usr/bin/X11:/usr/X11R6/bin:/usr/lib64/qt-3.3/bin:/root/bin' # add kerberos back in # modified on 20201026 by edrulrd
     for PathMgmt in $(echo ${CorePath}:${ScndryPaths} | sed 's/:/\n/g' | awk '!LinesSeen[$0]++'); do # modified on 20201026 by edrulrd
         # The awk defines what lines to print.  "$0" holds the entire contents of 'a' line.  The square brackets are array access.  As each line is processed, awk increments
         # a node of the array (named 'LinesSeen'); printing the line if the content was not (!) previously set.  Very efficient elimination of dups without unwanted 'sorting'.
         if [ -e "${PathMgmt}" ] && [ -d "${PathMgmt}" -a ! -L "${PathMgmt}" ]; then # don't want dirs that are also links (eg. /usr/bin/X11) # modified on 20201027 by edrulrd
              # If the dir doesn't currently exist then ignore it
              # For the rest, assume the provided sorted order is sufficient to add them back in to the path.
              case ${PathMgmt} in
                   . )                  continue ;;  # Never allow '.' as part of PATH.
                   /usr/local/sbin )    continue ;;
                   /usr/local/bin )     continue ;;
                   /usr/sbin )          continue ;;
                   /usr/bin )           continue ;;
                   /sbin )              continue ;;
                   /bin )               continue ;;
                   *games* )            continue ;;
                   * )                  BuiltPath="${BuiltPath}:${PathMgmt}" ;;
              esac
         fi
     done
     export PATH="${CorePath}${BuiltPath}"
     # Reset 'shopt extglob' to previous state; if previously on, no change is required.
     [ "${ShoptExtglob}" == 'off' ] && shopt -u extglob
     # echo "PATH is:  (${PATH})."  # Debug.
unset BuiltPath CorePath PathMgmt ScndryPaths ShoptExtglob

DtFmt='+%Y%m%d@%H%M'; DtFmts='+%Y%m%d@%H%M%S' # [20200312] {jcw} Useful date formats. DtFmt appears unused. Verify use (or export if used externally).

_VERSION="cfg2html-linux version ${VERSION} "  # this a common stream so we don?t need the "Proliant stuff" anymore

#
# getopt
#

while getopts ":o:shxOcSTflzkenaHLvhpPAV2:10w:" Option   ##  -T -0 -1 -2 backported from HPUX # added new options -x and -O and removed the need for an argument on -A, also added -w, -z  and -V # modified on 20240119 by edrulrd
do
  case ${Option} in
    o     ) OUTDIR=${OPTARG};;
    v     ) echo ${_VERSION}"// $(uname -mrs)"; exit 0;; ## add uname output, see YG MSG 790 ##
    h     ) echo ${_VERSION}; usage; exit 0;;  ## regression, issue #165
    s     ) CFG_SYSTEM="no";;
    x     ) CFG_PATHLIST="no";; # don't generate the list of executables in the PATH # added on 20201025 by edrulrd
    O     ) CFG_LSOFDEL="no";; # skip showing the list of open files that have been deleted # added on 20201026 by edrulrd
    c     ) CFG_CRON="no";;
    S     ) CFG_SOFTWARE="no";;
    f     ) CFG_FILESYS="no";;
    l     ) CFG_LVM="no";;
    z     ) CFG_ZFS="no";; # skip showing information about our zfs filesystems # added on 20240119 by edrulrd
    k     ) CFG_KERNEL="no";;
    e     ) CFG_ENHANCEMENTS="no";;
    n     ) CFG_NETWORK="no";;
    a     ) CFG_APPLICATIONS="no";;
    H     ) CFG_HARDWARE="no";;
    V     ) CFG_VMWARE="no";;
    A     ) CFG_ALTIRISAGENTFILES="no";;
    L     ) CFG_STINLINE="no";;
    w     ) CFG_TEXTWIDTH="${OPTARG}";; # override the default width in the generated .txt file for section titles # added on 20240119 by edrulrd
    p     ) CFG_HPPROLIANTSERVER="yes";;
    P     ) CFG_PLUGINS="yes";;
    2     ) CFG_DATE="_"$(date +${OPTARG}) ;;
    1     ) CFG_DATE="_"$(date +%d-%b-%Y) ;;
    0     ) CFG_DATE="_"$(date +%d-%b-%Y-%H%M) ;;
    T     ) CFG_TRACETIME="yes";;   # show each exec_command with timestamp
    *     ) echo "Unimplemented command line option chosen. Try -h for help!"; exit 1;;   # DEFAULT
  esac
done

shift $((${OPTIND} - 1))
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
# using Debian potato, woody

# This is the "Swiss army knife" for the ASE, CE, sysadmin etc. I wrote it to
# get the needed information to plan an update, to perform basic trouble
# shooting or performance analysis. As a bonus cfg2html creates a nice HTML and
# plain ASCII documentation. If you are missing something, let me know it!

# History
#####################################################################
# 28-jan-1999  initial creation, based on get_config, check_config
#              nickel, snapshoot, vim and a idea from a similar
#              script i have seen on-site.
#####################################################################
# 11-Mar-2001  initial creation for Debian GNU Linux i386
#              based on cfg2html Version 1.15.06/HP-UX by
#              by ROSE SWE, Dipl.-Ing. Ralph Roth
#              ported to Linux  by Michael Meifert
#####################################################################
# 15-May-2006  Common stream for cfg2html-linux and the Proliant version



# echo "" # should be a newline, more portable? # rar, 20121230

## test if user = root
check_root

# define the HTML_OUTFILE, TEXT_OUTFILE, ERROR_LOG
define_outfile

# create our VAR_DIR, OUTDIR before we continue
create_dirs

#
if [ ! -d ${OUTDIR} ] ; then
  echo "can't create ${HTML_OUTFILE}, ${OUTDIR} does not exist - stop"
  exit 1
fi
touch ${HTML_OUTFILE}
#echo "Starting up ${VERSION}\r"
[ -s "${ERROR_LOG}" ] && rm -f ${ERROR_LOG} 2> /dev/null
    DATE=$(date "+%Y-%m-%d") # ISO8601 compliant date string
DATEFULL=$(date "+%Y-%m-%d@%H:%M:%S") # ISO8601 compliant date and time string

# [20200311] {jcw} My comment; this restarts the process from within this same shell; all errors now go to the named log file.
exec 2> ${ERROR_LOG}

if [ ! -f ${HTML_OUTFILE} ]; then
     line
     _banner "Error"
     _echo "You do not have the rights to create the file ${HTML_OUTFILE}! (NFS?)\n"
     exit 1
fi

# [20200312] {jcw} 1st logger for starting.
[ $(which logger 2>/dev/null) ] && export _logger="$(which logger)" || export _logger='echo'   # [20200311] {jcw} Aliased logger, just in case. # added /dev/null # modified on 20240202 by edrulrd
${_logger} "1st Start of cfg2html-linux ${VERSION}"
RECHNER=$(hostname)         # `hostname -f`
VERSION_=$(echo "${VERSION}/${RECHNER}"|tr " " "_")
typeset -i HEADL=0                      # Headinglevel

#
# check Linux distribution
#
identify_linux_distribution


####################################################################
# needs improvement!
# trap "echo Signal: Aborting!; rm ${HTML_OUTFILE}"  2 13 15

####################################################################

#
######################################################################
#############################  M A I N  ##############################
######################################################################

#

line
echo "Starting:          ${_VERSION}"
echo "Path to cfg2html:  "$0
echo "HTML Output File:  "${HTML_OUTFILE}
echo "Text Output File:  "${TEXT_OUTFILE}
echo "Partitions:        "${OUTDIR}/${BASEFILE}.partitions.save
echo "Errors logged to:  "${ERROR_LOG}
# echo "Commandline:        ${*}"            ## for issue #154, seems not to be exported?

# [20200312] {jcw} Helpful docs for [ .vs. [[ at:
#            https://unix.stackexchange.com/questions/32210/why-does-parameter-expansion-with-spaces-without-quotes-work-inside-double-brack
[[ -f ${CONFIG_DIR}/local.conf ]] && { echo "Local config      "${CONFIG_DIR}/local.conf "( $(grep -v -E '(^#|^$)' ${CONFIG_DIR}/local.conf | wc -l) lines)"; }

echo "Started at        "${DATEFULL}
echo "WARNING           USE AT YOUR OWN RISK!!! :-))           <<<<<"
line

# 2nd one for starting.
${_logger} "2nd Start of cfg2html-linux ${VERSION}"
open_html
inc_heading_level

#
# CFG_SYSTEM
#

if [ "${CFG_SYSTEM}" != "no" ]
then # else skip to next paragraph

paragraph "Linux System:  [${distrib}]"   ## empty? ## FIXME ###
inc_heading_level

  ###################################################################################################################################################################
  # [20200324] {jcw}  Added section for determining if this is a physical host (Red Hat KVM/xen or VMware ESX) or virtual machine (VM).
  #                   When it is a VMware VM, identify the version of VMware Tools installed, and if that is current and active.
  #
  #                   One good reference for this is: http://www.dmo.ca/blog/detecting-virtualization-on-linux
  #

  DMESG=$(which dmesg 2>/dev/null)         # Added 20201004 by edrulrd, a possible solution could be using the same trick as done in gdha/upgrade-ux#135
  DMIDECODE=$(which dmidecode 2>/dev/null) # Added 20201004 by edrulrd
  LSCPI=$(which lspci 2>/dev/null)         # Added 20201004 by edrulrd

  # It is better to check on a host for the existence of /usr/sbin/esxupdate. Existence of that binary, and its response, will truly indicate an ESX host.
  PhysHost='TRUE'               # General term. Default, and its state is kept beyond this section. Assumed TRUE at the beginning.  TRUE indicates NO   form of Virt Guest.
  VirtMach='false'              # General term. Default, and its state is kept beyond this section. Assumed false at the beginning. TRUE indicates SOME form of Virt Guest.

  # These are flags indicating if anything related to their virtualization-type has been found (or not).
  # Searching for •virtual' by itself is a bad start, as there are numerous exceptions, non-virtualization related. VMdom0= 11false 11 # term was positively found; Xen-related
  VMdomU='false'                # term was positively found; Xen-related
  VMkvm='false'                 # 'kvm' term was positively found.
  VMKVM='false'                 # KVM-type has been found.
  VMparavirtkrnl='false'        # Indicative of QEmu or KVM; via dmesg, find either of: (Phys) 11 Booting paravirtualized kernel on bare hardware 11 or (kvm-virt) 11 Booting paravirtualized kernel
  VMqemu='false'                # Applicable to KVM, and .... ?
  VMvirtio='false'              # { abstraction layer}
  VMxen='false'                 # Xen (as a term)
  VMXEN='false'                 # Xen Default for any form found true (xen, dom0 domU).

  # VMware-based flags.
  ESXhost='false'               # Default, and its state is kept beyond this section.
  VMTver='false'                # Default of unknown for VMware-Tools version, if it is installed.
  VMware='false'                # VMware Default for any form found (ESX or client VM).

  touch PhysVirt.info_Pt2; chmod 0600 PhysVirt.info_Pt2; chown 0:0 PhysVirt.info_Pt2; sync;sync

  for VIRTs in domo domu kvm paravirt qemu virtio vmware xen; do
      VIRTterm='unset'                                        # Local value used within the loop.

      VIRTci='unset'                                          # /proc/cpuinfo   # These are only used to display state.
      VIRTdc='unset'                                          # dmesg command
      VIRTdf='unset'                                          # /var/log/dmesg {the long output}
      VIRTdd='unset'                                          # dmidecode {the command}
      VIRTls='unset'                                          # /sbin/lspci {the command}

      # These are only indented this way so as to visually distinguish them; there is no desire/need to if-then-else them!
      if [ "$(cat /proc/cpuinfo | grep -i ${VIRTs})" ]; then
           VIRTterm='TRUE'
           VIRTci='TRUE'
      fi

      # These are only indented this way so as to visually distinguish them; there is no desire/need to if-then-else them!
      if [ -n "${DMESG}" ] && [ "$(${DMESG} | grep -i ${VIRTs})" ]; then
           # Using the 'dmesg' command is useful for some number of days after the system was last booted;
           # beyond that, the /var/log/dmesg file is a good alternate datapoint.
           # See also https://github.com/cfg2html/cfg2html/issues/153
           if [ ! "$(${DMESG} | grep 'Booting paravirtualized kernel on bare hardware')" ]; then
                # This exception catches the one case of installing RHEL/CentOS on a real physical machine.  This IS properly/necessarily nested!
                VIRTterm='TRUE'
                VIRTdc='TRUE'
           fi
      fi

      if [ "$(grep -i ${VIRTs} /var/log/dmesg 2>/dev/null)" ]; then
           if [ ! "$(${DMESG} | grep 'Booting paravirtualized kernel on bare hardware')" ]; then
                  # This exception catches the one case of installing RHEL/CentOS on a real physical machine.  This IS properly/necessarily nested!
                  VIRTterm='TRUE'
                  VIRTdf='TRUE'
           fi
      fi

      if [ -n "${DMIDECODE}" ] && [ "$(${DMIDECODE} | grep -i ${VIRTs})" != "" ]; then # modified on 20201004 by edrulrd
           # Value is established up above.
           VIRTterm='TRUE'
           VIRTdd='TRUE'
      fi

      if [ -n "${LSPCI}" ] && [ "$(${LSPCI} -v | grep -i ${VIRTs})" != "" ]; then # modified on 20201004 by edrulrd
           # Value is established up above; '-v' to lscpi command provides verbosity.
           VIRTterm='TRUE'
           VIRTls='TRUE'
      fi

      # Very VMware-based; determine if this is an ESX or a VM, and then use that clue to get and later display the version of VMwareTools (if it can be found).
      if [ "${VIRTs}" == 'vmware' ]; then
           if [ -e /usr/sbin/esxupdate ]; then
                # Is one way to determine it.
                ESXhost='TRUE'
           else
                if [ -n "${DMESG}" -a "$(${DMESG} | grep -i vmxnet)" != "" ] || [ -n "${DMIDECODE}" -a "$(${DMIDECODE} | grep -i vmxnet)" != "" ]; then # modified on 20201004 by edrulrd, Prefer [ p ] && [ q ] as [ p -a q ] is not well defined.
                     VIRTterm='TRUE'
                fi
                # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Have to add options to check sytemctl, too.
                if [ "$(rpm -qa 2>/dev/null | grep -i vmware | grep -i tools)" ] || [ "$(service --status-all 2>&1 | grep -i vmtoolsd)" ] || [ -e /etc/rc.d/init.d/vmware-tools ]; then
                     # Means vmware-tools (but not something like 'xorg-xll-drv-vmware-10.13.0-2.1') might be installed, which makes it a VMware VM.
                     # MIGHT have to exclude 'xorg-xll-drv-vmware-10.13.0-2.1' and the like from satisfying the check.
                     VIRTterm='TRUE'
                     [ -e /usr/bin/vmware-config-tools.pl ] && VMTver="$(grep 'buildNr =' /usr/bin/vmware-config-tools.pl | cut -d\' -f2)" || VMTver='vmware-tools apparently not installed'
                fi
           fi
      fi

      # Need RHEL 7 version of 'chkconfig' accounted for.
      # if [ "$(chkconfig --list vmware-tools 2>&1)" != 'error reading information on service vmware-tools: No such file or directory' ]; then
      #      echo "Status of vmware-tools service: $(-chkconfig --list vmware-tools )"         >> PhysVirt.info
      # else
      #      # RHEL 6 under VMware Workstation, for example, even with vmware-tools •installed', the host does not have the vmware-tools •service' anymore.
      #      echo "vmware-tools not installed, so unable to get its running or stopped status" >> PhysVirt. info
      # fi

      if [ "${VIRTterm}" == 'TRUE' ]; then
           case ${VIRTs} in
                    dom0) #
                          VMdomO='TRUE'
                          VMXEN='TRUE'
                          ;;
                    domU) #
                          VMdomU='TRUE'
                          VMXEN='TRUE'
                          ;;
                     kvm) #
                          VMkvm='TRUE'
                          VMKVM='TRUE'
                          ;;
                paravirt) #
                          # Have to do further checks first before just giving in to this one.
                          # "$(dmesg | grep -i paravirt)" != 'booting paravirtualized kernel on'
                          VMparavirtkrnl='TRUE'
                          ;;
                    qemu) #
                          VMqemu='TRUE'
                          VMKVM='TRUE'
                          ;;
                  virtio) #
                          VMvirtio='TRUE'
                          ;;
                     xen) #
                          VMxen='TRUE'
                          VMXEN='TRUE'
                          ;;
                  vmware) #
                          VMware='TRUE'
                         ;;
           esac

           # When ALL of the conditions tested for, through all iterations of the for-loop, remain false, ONLY then can ${PhysHost}/${ESXhost} remain 'TRUE' and ${VirtMach} remain 'false'.
           PhysHost='false'
           ESXhost='false'
           VirtMach='TRUE'
           # Determinations are over for ${VIRTs} ... now generate output line.
           echo "VIRTs(${VIRTs}), VIRTterm (${VIRTterm}):"                                                                                                                  >> PhysVirt.info_Pt2
           echo "VIRTci(${VIRTci}), VIRTdc(${VIRTdc}), VIRTdf(${VIRTdf}), VIRTdd(${VIRTdd}), VIRTls(${VIRTls})."                                                            >> PhysVirt.info_Pt2
           echo "PhysHost(${PhysHost}), VirtMach(${VirtMach}), VMdom0(${VMdom0}), VMdomU(${VMdomU}), VMkvm(${VMkvm}), VMKVM(${VMKVM}), VMparavirtkrnl(${VMparavirtkrnl}),"  >> PhysVirt.info_Pt2
           echo "VMqemu(${VMqemu}), VMvirtio(${VMvirtio}), VMxen(${VMxen}), VMXEN(${VMXEN}), ESXhost(${ESXhost}), VMTver(${VMTver}), VMware(${VMware})."                    >> PhysVirt.info_Pt2
      fi
  done
  echo ' ' >> PhysVirt.info_Pt2

  if [ ${PhysHost} == 'TRUE' ]; then
       echo "This host is Physical, PhysHost=(${PhysHost}); vice Virtual, VirtMach=(${VirtMach})."    >> PhysVirt.info
       echo ' '                                                                                       >> PhysVirt.info
       cat PhysVirt.info_Pt2                                                                          >> PhysVirt.info
       exec_command "cat PhysVirt.info" 'Host is Physical.'  ## fixed
  else
       echo "This host is Virtual:  VirtMach=(${VirtMach}); vice Physical, PhysHost=(${PhysHost})."   >> PhysVirt.info
       echo ' '                                                                                       >> PhysVirt.info
       cat PhysVirt.info_Pt2                                                                          >> PhysVirt.info
       exec_command "cat PhysVirt.info" 'Host is Virtual.'
  fi
  /bin/rm -f PhysVirt.info PhysVirt.info_Pt2
  unset VMdom0 VMdomU VMkvm VMKVM VMparavirtkrnl VMqemu VMvirtio VMxen VMXEN ESXhost VMTver VMware; sync
  ###################################################################################################################################################################

  if [ -f ${CONFIG_DIR}/systeminfo ] ; then
    exec_command "cat ${CONFIG_DIR}/systeminfo" "System description"
  fi

  # [20200324] {jcw} Separated these-->exec_command "cat /proc/cpuinfo; echo; /usr/bin/lscpu;" "CPU and Model info" #  20.08.2012, 15:59 modified by Ralph Roth #* rar *#
  exec_command "cat /proc/cpuinfo" "CPU and Model info"
  [ -x /usr/bin/lscpu ] && exec_command "/usr/bin/lscpu" "CPU Architecture Information Helper"
  [ -x /usr/bin/cpufreq-info ] && exec_command cpufreq-info "CPU Frequency Information" # noted to be replaced by cpupower # comment added on 20240119 by edrulrd

  CPUPOWER=$(which cpupower 2>/dev/null) # added /dev/null # modified on 20240202 by edrulrd
  if [ -n "${CPUPOWER}" ] && [ -x "${CPUPOWER}" ] ; then
      exec_command "${CPUPOWER} frequency-info" "CPU Frequency Information"  ## closes issue #53 - rr, 20140725 # replacement for cpufreq-info cmd # added on 20240119 by edrulrd
      exec_command "${CPUPOWER} idle-info" "Processor idle state information"  ## closes issue #53 - rr, 20140725
      exec_command "${CPUPOWER} info" "Processor power related kernel or hardware configuration"
      exec_command "${CPUPOWER} monitor" "Processor Monitor"
  fi

  exec_command  HostNames "uname and hostname details"
  exec_command "uname -n; echo; uname -a" "Host alias; and ALL information"  # [20200330] {jcw} added uname -a
  exec_command "uname -sr" "OS, Kernel version"

  # Added by Dusan Baljevic on 15 July 2013
  #
  HOSTNAMECTL=$(which hostnamectl 2>/dev/null)
  if [ -n "${HOSTNAMECTL}" ] && [ -x "${HOSTNAMECTL}" ] ; then
      exec_command "${HOSTNAMECTL}" "Hostname settings"
  fi

  [ -x /usr/bin/lsb_release ] && exec_command "/usr/bin/lsb_release -a 2>\/dev\/null" "Linux Standard Base Version" #modified on 20201026 by edrulrd
  for i in /etc/*-release
  do
      [ -r ${i} ] && exec_command "cat ${i}" "OS Specific Release Information for (${i})"
  done; unset i

  ### Begin changes by Dusan.Baljevic@ieee.org ### 13.05.2014
      if [ -x /usr/bin/virsh ] ; then
        exec_command "${TIMEOUTCMD} 20 /usr/bin/virsh list" "virsh Virtualization Support Status"
        exec_command "${TIMEOUTCMD} 20 /usr/bin/virsh sysinfo" "virsh XML Hypervisor Sysinfo"
        AddText "Hint: You may need to view your browser's page source to see the XML tags, or refer to the ASCII report" # xml tags are taken out (at least) by Firefox # modified on 20240119 by edrulrd
      fi

      if [ -x /usr/sbin/virt-what ] ; then
        exec_command "/usr/sbin/virt-what" "Virtual Machine Check"
      fi
  ### End changes by Dusan.Baljevic@ieee.org ### 14.05.2014

  ### Begin changes by Dusan.Baljevic@ieee.org ### 31.08.2014
      if [ -x /usr/bin/machinectl ] ; then
        exec_command "/usr/bin/machinectl --version" "Systemd Virtual Machine and Container Version"
        exec_command "/usr/bin/machinectl list" "Systemd Virtual Machine and Container Status"
      fi

      if [ -x /usr/bin/VBoxManage ] ; then
        exec_command "/usr/bin/VBoxManage -v" "VirtualBox Version"
        exec_command "/usr/bin/VBoxManage list systemproperties" "VirtualBox System Properties"
        exec_command "/usr/bin/VBoxManage list vms" "VirtualBox VMS"
      fi
  ### End changes by Dusan.Baljevic@ieee.org ### 31.08.2014

  if [ -x /usr/bin/locale ] ; then
    exec_command posixversion "POSIX Standards/Settings"
    exec_command locale "locale specific information" # modified on 20201005 by edrulrd

    # [20200407] {jcw} Commented this out, in favor of standardized function "LANG_C" in shell-functions.sh.
    # export LANG="C"
    # export LANG_ALL="C"
    LANG_C
  fi

  exec_command "ulimit -a" "System ulimit"                            #  13.08.2007, 14:24 modified by Ralph Roth

  # [20200407] {jcw} It's funny, the getconf man-page does not even mention the -a argument, nor does `getconf --help` (they are dated back to 2003, though).
  #                  A good reference page is:  www.mkssoftware.com/docs/man1/getconf.1.asp
  exec_command "getconf -a | sort | column -c ${CFG_TEXTWIDTH}" "System Configuration Variables"   ## at least SLES11, #  14.06.2011, 18:53 modified by Ralph Roth #* rar *#      ## [20200407] {jcw} added sort. # added column # modified on 20240119 by edrulrd

  if [ -x /usr/bin/mpstat ] ; then
    exec_command "mpstat 1 5" "MP-Statistics"
  fi
  if [ -x /usr/bin/iostat ] ; then
    exec_command "iostat" "IO-Statistics"
  fi

  if [ "${CFG_PATHLIST}" != "no" ] # Added on 20201026 by edrulrd
  then # else skip to next paragraph # Added on 20201026 by edrulrd
    # Include information regarding the PATH # Added on 20201025 by edrulrd
    exec_command "" "PATH Settings" # don't display the N/A message # Added on 20201025 by edrulrd # modified on 20240119 by edrulrd
    AddText "${0} was called with PATH set to: \"${CallingPATH}\", but" # Added on 20201025 by edrulrd # modified on 20240119 by edrulrd
    AddText "it generated this report using the PATH set to: \"${PATH}\"" # Added on 20201025 by edrulrd # modified on 20240119 by edrulrd

    if [ -n "${LOCALPATH}" ] # check if we want to list the executables in a different path # added on 20201113 by edrulrd
    then
      AddText "LOCALPATH specified.  Files existing in \""${LOCALPATH}"\" follow:" # Added on 20201113 by edrulrd # modified on 20240119 by edrulrd
      echo ${LOCALPATH} | sed 's/:/\n/g' | while read i # Confirm each entry present in the directory list is a folder # added on 20201113 by edrulrd
      do
        if [ -e "${i}" -a ! -d "${i}" ] # if the entry exists and isn't a directory, then flag it # added on 20201113 by edrulrd
        then
          AddText "Error: "${i}" in "${LOCALPATH}" is not a directory" # Added on 20201113 by edrulrd
          exit 1 # Added on 20201113 by edrulrd
        fi
      done
      LISTPATH=${LOCALPATH} # Added on 20201113 by edrulrd
    else
      LISTPATH=${PATH} # Added on 20201113 by edrulrd
    fi

    # Get all the executable files including soft-links in the PATH and generate a sorted list # Added on 20201025 by edrulrd
    exec_command "for Directory in $(/bin/echo ${LISTPATH} |
    sed 's/:/ /g');
    do
      find \$Directory -executable \( -type f -o -type l \) -print 2>\/dev\/null |
      sort |
      while read Filename;
        do
          /bin/echo -n \$(basename \${Filename});
          /bin/echo -n ' ';
          ls -al \${Filename} |
          awk '{\$1=\"\";\$2=\"\";\$3=\"\";\$4=\"\";\$5=\"\";\$6=\"\";\$7=\"\";\$8=\"\";print}' |
          sed 's/^        //';
        done
    done |
    sort -k1,1 -u |
    awk '{\$1=\"\"; print}' |
    sed 's/^ //' | column -c ${CFG_TEXTWIDTH}" "Executable Commands found in $LISTPATH" # Added on 20201025 by edrulrd, modified on 20240119 by edrulrd
    unset LISTPATH
    # End of code added on 20201025 by edrulrd
  fi # terminates CFG_PATHLIST wrapper # added on 20201026 by edrulrd

  if [ "${CFG_LSOFDEL}" != "no" ] # added on 20201026 by edrulrd
  then # else skip to next paragraph # added on 20201026 by edrulrd
    exec_command "lsof -nP 2>\/dev\/null | grep '(deleted)'" "Files that are open but have been deleted" # modified on 20201026 by edrulrd
  fi # terminates CFG_LSOFDEL wrapper # added on 20201026 by edrulrd

  # In "used memory.swap" section I would add :
  # free -tl     (instead of free, because it gives some more useful infos, about HighMem and LowMem memory regions (zones))
  # cat /proc/meminfo (in order to get some details of memory usage)

  # [20200409] {jcw} Added section for processor, kernel and memory status details
  ESXHost='false'; [ -e /usr/sbin/esxupdate ] && [ $(rpm -qa | grep -i vmware-esx | wc -l | tr -d' ') -ge 2 ] && ESXHost='TRUE'
  echo "Identify processor architecture, installed OS architecture, and the type/amount of system memory (best approximation)."                     > /tmp/ProcKernMem.info
  echo "Note:  Math rounding may result in displaying a slightly smaller number than actually installed/configured (g=GB, m=MB, k=KB, b=bytes)."   >> /tmp/ProcKernMem.info
  echo "       kcore line is processed from size of '/proc/kcore'; free is processed from 'free' command."                                         >> /tmp/ProcKernMem.info
  echo "---------------------------------------------------------------------------------------------------------------------------------------"   >> /tmp/ProcKernMem.info




  # 20190828, rr - swapon -s is deprecated, better use --show
  exec_command "free -tml;echo;free -tm;echo; swapon --show;swapon -s" "Used Memory and Swap Summary" #  04.07.2011+05.07.2018 modified by Ralph Roth #* rar *#
  exec_command "cat /proc/meminfo; echo THP:; cat /sys/kernel/mm/transparent_hugepage/enabled" "Detailed Memory Usage (meminfo)"  # changed 20131218 by Ralph Roth
  exec_command "cat /proc/buddyinfo" "Zoned Buddy Allocator/Memory Fragmentation and Zones" 	#  09.01.2012 Ralph Roth
  AddText "The number on the left is bigger than right (by factor 2)."
  # ripped from Dusan Baljevic ## changed 20131211 by Ralph Roth
  AddText "DMA zone is the first 16 MB of memory. DMA64 zone is the first 4 GB of memory on 64-bit Linux. Normal zone is between DMA and HighMem. HighMem zone is above 4 GB of memory."

      #   TODO
      #           foreach my ${bi} ( @BUDDYINFO ) {
      #             my @biarr = split(/\s+/, ${bi});
      #             ${biarr[1]} =~ s/,$//g;
      #             print "${INFOSTR} ${biarr[0]}${biarr[1]}: Zone ${biarr[3]} has\n";
      #             my ${cntb} = 1;
      #             my @who = splice @biarr, 4;
      #             for my ${p} (0 .. $#who) {
      #                 print ${who[${p}]}, " free ", 2*(2**${cntb}), "KB pages\n";
      #                 ${cntb}++;
      #             }

  exec_command "cat /proc/slabinfo | sed 's/# name/#name/' | tr '<' ' ' | tr '>' ' ' | awk 'NR<3{print;next}{print | \"sort -k3,3nr -k1,1\"}' | column --table -c ${CFG_TEXTWIDTH}" "Kernel slabinfo Statistics" # changed 20131211 by Ralph Roth # added column command to put the output in an aligned table after sorting it in descending order by number  of objects $ modified on 20240119 by edrulrd
  AddText "Frequently used objects in the Linux kernel (buffer heads, inodes, dentries, etc.) have their own cache.  The file /proc/slabinfo gives statistics."
  exec_command "cat /proc/pagetypeinfo" "Additional page allocator information" 	# changed 20131211 by Ralph Roth
  exec_command "cat /proc/zoneinfo" "Per-zone page allocator" 		                # changed 20131211 by Ralph Roth

  if [ -x /usr/bin/vmstat ] ; then        ## <c/m/a>  14.04.2009 - Ralph Roth
    ## [20200408] {jcw} expanded 'VM' to Virtual Memory, to avoid confusion with virtualization.
    exec_command "vmstat -w 1 10" "Virtual Memory-Statistics (1 10)" # added -w option for readability # modified on 20240119 by edrulrd
    exec_command "vmstat -dnw; vmstat -f" "Disk Statistics (averages) and Forks since boot" # changed title and added -w option for readability # modified on 20240119 by edrulrd
  fi

  # sysutils
  exec_command "uptime" "Uptime"
  # exec_command "sar 1 9" "System Activity Report"
  # exec_command "sar -b 1 9" "Buffer Activity"

  [ -x /usr/bin/procinfo ] && exec_command "procinfo" "System status from /proc" #  15.11.2004, 14:09 modified by Ralph Roth # -a option of procinfo appears deprecated, removed # modified on 20240119 by edrulrd
  # usage: pstree [ -a ] [ -c ] [ -h | -H pid ] [ -l ] [ -n ] [ -p ] [ -u ]
  #               [ -G | -U ] [ pid | user]
  exec_command "pstree -a -l -G -A" "Active Process - Tree Overview" #  15.11.2004/2011, 14:09 modified by Ralph.Roth # removed -p (pid) flag to compact the report # modified on 20240119 by edrulrd
                # changed 20131211 by Ralph Roth, # changed 20140129 by Ralph Roth # cmd. line:1: ^ unexpected newline or end of string
  exec_command "ps -e -o ruser,pid,args | awk ' ((\$1+1) > 1) {print \$0;} '" "Processes without a named owner"
  AddText "The output should be empty!"

  ## ps aux --sort=-%cpu,-%mem|head -25 ## 06.03.2015
  exec_command "ps -e -o 'time,cmd' --sort -cputime | head -25 | awk '{ printf(\"%10s   %s\\n\", \$1, \$2); }'" "Top load processes" # modified on 20201009 by edrulrd
  exec_command "ps -e -o 'vsz pid ruser cpu time args'  --sort=-vsz | head -25" "Top memory consuming processes" # use ps command's sort command instead # modified on 20240119 by edrulrd
  exec_command topFDhandles "Top file handles consuming processes" # 24.01.2013
  AddText "Hint: Number of open file handles should be less than ulimit -n ("$(ulimit -n)")"

                                          #  10.11.2012 modified by Ralph Roth #* rar *# fix for SLES11,SP2, 29.01.2014
  [ -x /usr/bin/pidstat ] && exec_command "pidstat -lrud 2>/dev/null||pidstat -rud" "pidstat - Statistics for Linux Tasks"

  if [ -x "$(which tuned-adm 2>/dev/null)" ] ; then #  avoid errors if not available # modified on 20201009 by edrulrd # added /dev/null # modified on 20240202 by edrulrd
    exec_command "tuned-adm list" "Tuned Profiles"     	              #06.11.2014, 20:34 added by Dusan Baljevic
    exec_command "tuned-adm active" "Tuned Active Profile Status"       #06.11.2014, Dusan Baljevic -- see also saptune()
  fi
  NUMACTL="$(which numactl 2>/dev/null)"                               # modified on 20201004 added by edrulrd
  if [ -n "${NUMACTL}" -a -x "${NUMACTL}" ] ; then
    exec_command "${NUMACTL} --hardware" "NUMA Inventory of Available Nodes on the System"     #06.11.2014, added by Dusan Baljevic
  fi

  if [ -x /usr/bin/journalctl ]
  then
	exec_command "/usr/bin/journalctl --list-boots --no-pager| tail -25" "Last 25 Reboots"  ## changed 20150212 by Ralph Roth
  else
  	exec_command "last -F| grep reboot | head -25" "Last 25 Reboots"			### RR, 2014-12-19  ##CHANGED##FIXED## 20150212 by Ralph Roth
  fi
  # common stuff, systemd and old style system-v rc
  exec_command "last -xF  | grep -E 'system|runlevel' | head -25" "Last 25 runlevel changes or reboots" 	###CHANGED### 20150408 by Ralph Roth # modified on 20201009 by edrulrd

  ### Begin changes by Dusan.Baljevic@ieee.org ### 13.05.2014
  #     stderr output from " blame":
  #     /usr/share/cfg2html/lib/html-functions.sh: line 107: blame: command not found

  SYSTEMD=$(which systemd-analyze 2>/dev/null) # added /dev/null # modified on 20240202 by edrulrd
  if [ -x ${SYSTEMD} ] ; then
     exec_command "${SYSTEMD}" "systemd-analyze Boot Performance Profiler"
     exec_command "${SYSTEMD} blame" "systemd-analyze Boot Sequence and Performance Profiler"
  fi
  [ -x /usr/bin/systemd-cgls ] && exec_command "/usr/bin/systemd-cgls" "Systemd: Recursively show control group contents" ## SAP HANA # output was being cut off, added COLUMNS env var. to etc/default.conf file # modified on 20240119 by edrulrd

  [ -r /etc/init/bootchart.conf ] && exec_command "grep -vE '^#' /etc/init/bootchart.conf" "bootchart Boot Sequence and Performance Profiler"
  [ -r /etc/systemd/bootchart.conf ] && exec_command "grep -vE '^#' /etc/systemd/bootchart.conf" "bootchart Boot Sequence and Performance Profiler"

  ### End changes by Dusan.Baljevic@ieee.org ### 13.05.2014

  exec_command "alias"  "Alias"

  if [ -x /usr/bin/systemctl ]   ## 20.02.2018, rr, should fix the first part of issue #124
  then  ## new systemd stuff
    ## OpenSUSE 12.x # changed 20140213 by Ralph Roth ##BACKPORT##
    exec_command "/usr/bin/systemctl" "Systemd: System and Service Manager"
    exec_command "/usr/bin/systemctl list-units --type service" "Systemd: All Services"
    exec_command "/usr/bin/systemctl list-unit-files" " Systemd: All Unit Files"

    ## new 20140613 by Ralph Roth
    [ -x /usr/bin/journalctl ] && exec_command "/usr/bin/journalctl -b -p 3 --no-pager" "Systemd Journal with Errors and Warnings"

    if [ "${ARCH}" = "yes" -o "${DEBIAN}" = "yes" ] ; then   ## M.Weiller, LUG-Ottobrunn.de, 2013-02-04 ## OpenSUSE also and SLES12? # found to be supported on Debian too # modified on 20240119 by edrulrd
      exec_command "/usr/bin/systemctl --failed" "Systemd: Failed Units"
    fi
  else ## old SYS5 RC stuff!
    [ -r /etc/inittab ] && exec_command "grep -vE '^#|^ *$' /etc/inittab" "inittab"
    ## This may report NOTHING on RHEL 3+4 ##
    [ -x /sbin/chkconfig ] && exec_command "/sbin/chkconfig" "Services Startup"  ## chkconfig -A // SLES // xinetd missing
    [ -x /sbin/chkconfig ] && exec_command "/sbin/chkconfig --list" "Services Runlevel" # rar, fixed 2805-2005 for FC4
    [ -x /sbin/chkconfig ] && exec_command "/sbin/chkconfig -l --deps" "Services Runlevel and Dependencies" #*# Alexander De Bernardi 25.02.2011
    [ -x /usr/sbin/service ] && exec_command "/usr/sbin/service --status-all 2> /dev/null" "Services - Status"   #  09.11.2011/12022013 by Ralph Roth #* rar *#
    [ -x  /usr/sbin/sysv-rc-conf ] && exec_command " /usr/sbin/sysv-rc-conf --list" "Services Runlevel" # rr, 1002-2008

    if [ "${GENTOO}" = "yes" ] ; then   ## 2007-02-27 Oliver Schwabedissen
      [ -x /bin/rc-status ]  && exec_command "/bin/rc-status --list" "Defined runlevels"
      [ -x /sbin/rc-update ] && exec_command "/sbin/rc-update show --verbose" "Init scripts and their runlevels"
    fi
  fi

  if [ -d /etc/rc.config.d ] ; then
    exec_command " grep -v ^# /etc/rc.config.d/* | grep '=[0-9]'" "Runlevel Settings"
  fi
  [ -r /etc/inittab ] && exec_command "awk '!/#|^ *$/ && /initdefault/' /etc/inittab" "default runlevel"
  exec_command "/sbin/runlevel" "current runlevel"

  # Added by Dusan Baljevic on 24 December 2017
  NEEDRESTART=$(which needs-restarting 2>/dev/null)
  if [ -n "${NEEDRESTART}" ] && [ -x "${NEEDRESTART}" ] ; then
      exec_command "${NEEDRESTART}" "Report running processes that have been updated and need restart"
  fi

  # Added by Dusan Baljevic on 24 December 2017
  if [ -x /usr/bin/wdctl ] ; then
    exec_command "/usr/bin/wdctl" "Hardware watchdog status"
  fi

  # Added by Dusan Baljevic on 24 December 2017
  if [ -x /usr/bin/coredumpctl ] ; then
    exec_command "/usr/bin/coredumpctl list 2>&1" "List available coredumps" # added error redirection to get 0 coredumps message, if applicable # modified on 20240119 by edrulrd
  fi

  ## we want to display the Boot Messages too ## 30Jan2003 it233 FRU
  if [ -e /var/log/boot.msg ] ; then
    exec_command "grep 'Boot logging' /var/log/boot.msg" "Last Boot Date"
    exec_command "grep -v '|====' /var/log/boot.msg " "Boot Messages, last Boot"
  fi

  # MiMe: SUSE && UNITEDLINUX
  # MiMe: until SUSE 7.3: params in /etc/rc.config and below /etc/rc.config.d/
  # MiMe; since SUSE 8.0 including UL: params below /etc/sysconfig
  if [ "${SUSE}" = "yes" ] || [ "${UNITEDLINUX}" = "yes" ]
  then
    if [ -d /etc/sysconfig ] ; then
      # MiMe:
      exec_command "find /etc/sysconfig -type f -not -path '*/scripts/*' -exec grep -vE '^#|^ *$' {} /dev/null \; | sort" "Parameter /etc/sysconfig"
    fi
    if [ -e /etc/rc.config ] ; then
      # PJC: added filters for SUSE rc_ variables
      # PJC: which were in rc.config in SUSE 6
      # PJC: and moved to /etc/rc.status in 7+
      exec_command "grep -vE -e '(^#|^ *$)' -e '^ *rc_' -e 'rc.status' /etc/rc.config | sort" "Parameter /etc/rc.config"
    fi
    if [ -d /etc/rc.config.d ] ; then
      # PJC: added filters for SUSEFirewall and indented comments
      exec_command "find /etc/rc.config.d -name '*.config' -exec grep -vE -e '(^#|^ *$)' -e '^ *true$' -e '^[[:space:]]*#' -e '[{]|[}]' {} \; | sort" "Parameter /etc/rc.config.d"
    fi
  fi

  if [ "${GENTOO}" = "yes" ] ; then ## 2007-02-28 Oliver Schwabedissen
    exec_command "grep -vE '^#|^ *$' /etc/rc.conf | sort" "Parameter /etc/rc.conf"
    exec_command "find /etc/conf.d -type f -exec grep -vE '^#|^ *$' {} /dev/null \;" "Parameter /etc/conf.d"
  fi

  if [ -e /proc/sysvipc ] ; then
    exec_command "ipcs" "IPC Status"
    exec_command "ipcs -u" "IPC Summary"
    exec_command "ipcs -l" "IPC Limits"
    ## ipcs -ma ???
  fi

  ###  Made by Dusan.Baljevic@ieee.org ### 16.03.2014
  if [ -x /usr/sbin/authconfig ] ; then
    ### Cope with change to authselect in RHEL 8. Omits section if no profile selected. j0hn-c0nn0r 27/01/22 ###
    if [ -x /bin/authselect ] ; then
      if [[ $(/bin/authselect current) =~ 'Profile ID' ]] ; then
        ACPROFILE=$(/bin/authselect current | grep 'Profile ID' | cut -d' ' -f 3-)
        exec_command "(/bin/authselect current; echo; /bin/authselect test '${ACPROFILE}')" "System authentication resources"
      fi
    else
      exec_command "/usr/sbin/authconfig --test" "System authentication resources"
    fi
  fi

  if [ -x /usr/sbin/pwck ] ; then
    exec_command "/usr/sbin/pwck -r && echo Okay" "integrity of password files"
  fi

  if [ -x /usr/sbin/grpck ] ; then
    exec_command "/usr/sbin/grpck -r && echo Okay" "integrity of group files"
  fi

  exec_command "cat /etc/passwd" "Password File"  # Added by Dusan.Baljevic@ieee.org 6/11/2014
  exec_command "awk -F: 'BEGIN{OFS=FS}{if ( \$2 != \"*\" ) \$2='x'; print \$0}' /etc/shadow" "Shadow File"  # Added by Dusan.Baljevic@ieee.org 6/11/2014 (issue #83)
  exec_command "cat /etc/sudoers | grep -vE '^#|^ *$'" "Sudo Config"  # Added by Dusan.Baljevic@ieee.org 6/11/2014 # don't display blank or commented out lines # modified on 20240119 by edrulrd

  # we also show  any local sudoers files under /etc/sudoers.d  # added on 20240119 by edrulrd
  ls /etc/sudoers.d/* > /dev/null 2>&1 # added on 20240119 by edrulrd
  if [ $? -eq 0 ] # added on 20240119 by edrulrd
  then
      for FILE in $(ls -1 /etc/sudoers.d/*)  # added on 20240119 by edrulrd
      do
        if [ $(grep -vE '^#|^ *$' ${FILE} | wc -l) -gt 0 ] # added on 20240119 by edrulrd
        then
          exec_command "cat ${FILE} | grep -vE '^#|^ *$'" "sudoers.d/$(basename ${FILE})" # added on 20240119 by edrulrd
        fi
      done
  fi

  dec_heading_level

fi # terminates CFG_SYSTEM wrapper

# -----------------------------------------------------------------------------
# Begin: "Arch Linux spezial section"
## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
if [ "${ARCH}" == "yes" ] ; then
  paragraph "Arch Linux specific"
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
if [ "${CFG_CRON}" != "no" ]
then # else skip to next paragraph
paragraph "Cron and At"
inc_heading_level

  for FILE in cron.allow cron.deny
      do
	  if [ -r /etc/${FILE} ]
	  then
	  exec_command "cat /etc/${FILE}" "${FILE}"
	  else
	  exec_command "echo /etc/${FILE}" "${FILE} not found!"
	  fi
      done

  ## Linux SUSE user /var/spool/cron/tabs and NOT crontabs
  ## 30jan2003 it233 FRU
  ##  SUSE has the user crontabs under /var/spool/cron/tabs
  ##  RedHat has the user crontabs under /var/spool/cron
  ##  UnitedLinux uses /var/spool/cron/tabs (MiMe)
  ##  Arch Linux has the user crontabs under /var/spool/cron  ## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
  if [ "${SUSE}" == "yes" ] ; then
    usercron="/var/spool/cron/tabs"
  fi
  if [ "${REDHAT}" == "yes" ] || [ "${AWS}" == "yes" ] ; then
    usercron="/var/spool/cron"
  fi
  if [ "${SLACKWARE}" == "yes" ] ; then
    usercron="/var/spool/cron/crontabs"
  fi
  if [ "${DEBIAN}" == "yes" ] ; then
    usercron="/var/spool/cron/crontabs"
  fi
  if [ "${GENTOO}" == "yes" ] ; then    ## 2007-02-27 Oliver Schwabedissen
    usercron="/var/spool/cron/crontabs"
  fi
  if [ "${UNITEDLINUX}" == "yes" ] ; then
    usercron="/var/spool/cron/tabs"
  fi
  if [ "${ARCH}" == "yes" ] ; then      ## M.Weiller, LUG-Ottobrunn.de, 2013-02-04
    usercron="/var/spool/cron"
  fi
  # ##
  # alph@osuse122rr:/etc/cron.d> ll
  # -rw-r--r-- 1 root root 1754 29. Nov 16:21 -?			## !
  # -rw-r--r-- 1 root root  319  1. Nov 2011  ClusterTools2
  # -rw-r--r-- 1 root root 1754 29. Nov 16:21 --help		## !

# maybe this is generic?
# for user in $(getent passwd|cut -f1 -d:); do echo "### Crontabs for ${user} ####"; crontab -u ${user} -l; done
# changed 20140212 by Ralph Roth

  ls ${usercron}/* > /dev/null 2>&1 # $usercron variable was not being used # modified on 20240119 by edrulrd
  if [ $? -eq 0 ]
  then
     exec_command "" "Crontab files:" # fixed title # modified on 20240119 by edrulrd 
	  for FILE in ${usercron}/* # $usercron variable was not being used # modified on 20240119 by edrulrd
	  do
		  exec_command "cat ${FILE} | grep -vE '^#|^ *$'" "${usercron}/$(basename ${FILE})" # get rid of blank lines too # modified on 20240119 by edrulrd
	  done
  else
      exec_command "echo 'No user crontab files'" "${usercron}"  # modified on 20240119 by edrulrd
  fi

  ##
  ## we do also a listing of utility cron files
  ## under /etc/cron.d 30Jan2003 it233 FRU
  ls /etc/cron.d/* > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
      exec_command "" "/etc/cron.d files:" # fixed title in webpage # modified on 20240119 by edrulrd 
	  for FILE in /etc/cron.d/*
	  do
		  exec_command "cat ${FILE} | grep -vE '^#|^ *$'" "For utility: $(basename ${FILE})" # modified on 20240119 by edrulrd
	  done
  else
      exec_command "echo 'No /etc/cron.d files for utilities'" "/etc/cron.d"  # modified on 20240119 by edrulrd
  fi

  if [ -f /etc/crontab ] ; then
    exec_command "_echo  'Crontab:\n';cat /etc/crontab | grep -vE '^#|^ *$'" "/etc/crontab"
  fi

  atconfigpath="/etc"
  if [ "${GENTOO}" == "yes" ] ; then    ## 2007-02-27 Oliver Schwabedissen
      atconfigpath="/etc/at"
  fi

  for FILE in at.allow at.deny; do
	  if [ -r ${atconfigpath}/${FILE} ]
	  then
	      exec_command "cat ${atconfigpath}/${FILE} | grep -vE '^#|^ *$'" "${atconfigpath}/${FILE}" # modified on 20240119 by edrulrd
	  else
	      exec_command " " "${atconfigpath}/${FILE}" # modified on 20240119 by edrulrd
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
if [ "${CFG_HARDWARE}" != "no" ]
then # else skip to next paragraph

paragraph "Hardware"
inc_heading_level

  RAM=`awk -F': *' '/MemTotal/ {print $2}' /proc/meminfo`
  # RAM=`cat /proc/meminfo | grep MemTotal | awk -F\: '{print $2}' | awk -F\  '{print $1 " " $2}'`
  exec_command "echo ${RAM}" "Physical Memory"

  ## Murray Barton, 14/4/2010
  DMIDECODE=`which dmidecode 2>/dev/null`; if [ -n "${DMIDECODE}" ] && [ -x ${DMIDECODE} ] ; then exec_command "${DMIDECODE} 2> /dev/null" "DMI Table Decoder"; fi # added /dev/null # modified on 20240202 by edrulrd

  ### Begin changes by Dusan.Baljevic@ieee.org ### 13.05.2014

  BIOSDECODE=$(which biosdecode 2>/dev/null) # added /dev/null # modified on 20240202 by edrulrd
  if [ -n "${BIOSDECODE}" ] && [ -x ${BIOSDECODE} ] ; then
    exec_command "${BIOSDECODE}" "biosdecode"
  fi

  ### End changes by Dusan.Baljevic@ieee.org ### 13.05.2014 ### needs cleanup, e.g. 2> /dev/null - 06.04.2015, rr

  LSCPU=`which lscpu 2>/dev/null`; if [ -n "${LSCPU}" ] && [ -x ${LSCPU} ] ; then exec_command "${LSCPU}" "CPU architecture"; fi # see issue #52
  ## see issue #82, rr, 20150527-rr, see also issue #129, this a workaround! 23.03.2018-rr
  HWINFO=`which hwinfo 2>/dev/null`; if [ -n "${HWINFO}" ] && [ -x ${HWINFO} ] ; then exec_command "timeout 3m ${HWINFO} --short 2> /dev/null" "Hardware List (hwinfo)"; fi
  LSHW=`which lshw 2>/dev/null`; if [ -n "${LSHW}" ] && [ -x ${LSHW} ] ; then exec_command "${LSHW}" "Hardware List (lshw)"; fi ##  13.12.2004, 15:53 modified by Ralph Roth
  LSDEV=`which lsdev 2>/dev/null`; if [ -n "${LSDEV}" ] && [ -x ${LSDEV} ] ; then exec_command "${LSDEV}" "Hardware List (lsdev)"; fi
  LSHAL=`which lshal 2>/dev/null`; if [ -n "${LSHAL}" ] && [ -x ${LSHAL} ] ; then exec_command "${LSHAL}" "List of Devices (lshal)"; fi
  LSUSB=`which lsusb 2>/dev/null`; if [ -n "${LSUSB}" ] && [ -x ${LSUSB} ] ; then exec_command "${LSUSB}" "List of USB devices"; fi ## SUSE? #  12.11.2004, 15:04 modified by Ralph Roth

  LSPCI=`which lspci 2>/dev/null`
  if [ -n "${LSPCI}" ] && [ -x ${LSPCI} ] ; then
    exec_command "${LSPCI} -v" "PCI devices"
  else
    if [ -f /proc/pci ] ; then
      exec_command "cat /proc/pci" "PCI devices"
    fi
  fi

  PCMCIA=`grep pcmcia /proc/devices | cut -d" " -f2`
  if [ "${PCMCIA}" = "pcmcia"  ] ; then
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
  fi

  if  [ -x /usr/bin/lsscsi ]
  then
    # Debian 6.06 # 24.01.2013, doesn't have -p option yet!
    #        -p, --protection        Output additional data integrity (protection) information. # -p option is available at least in Debian 12 (bookworm), but not (yet) implemented here # modified on 20240119 by edrulrd
    exec_command "cat /proc/scsi/scsi 2>/dev/null || /usr/bin/lsscsi -c" "SCSI Devices" # moved from above.  lsscsi -c provides similar output to /proc/scsi/scsi # modified on 20240119 by edrulrd
    exec_command "/usr/bin/lsscsi -lv 2>/dev/null " "SCSI Devices (long, details)"  ## rr, 16. March 2011 # don't flag it if there are no nvme devices # modified on 20240119 by edrulrd
    exec_command "/usr/bin/lsscsi -s" "SCSI Devices (size)"  ## rr, 16. March 2011, 27 May 2015
  fi

  ## rar, 13.02.2004
  ## Changed 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA, changed title from SCSI Devices SCSI Disk Devices
  [ -x /usr/sbin/lssd ] && exec_command "/usr/sbin/lssd" "SCSI Disk Devices"

  ## Added 15.05.2006 (09:30) by Peter Lindblom, HP, STCC EMEA
  [ -x /usr/sbin/lssg ] && exec_command "/usr/sbin/lssg" "Generic SCSI Devices"

  if [ -x "${FDISKCMD}" -a -x "${GREPCMD}" -a -x "${SEDCMD}" -a -x "${AWKCMD}" -a -x "${SMARTCTL}" ]
  then
    exec_command DoSmartInfo "SMART disk drive features and information"

    # Moved disk info section from below to here # modified on 20240119 by edrulrd
    # get IDE and/or ATA Disk information # modified on 20240119 by edrulrd
    HDPARM=$(which hdparm 2>/dev/null) # modified in case hdparm not installed, on 20201004 by edrulrd
    # if hdparm is installed (DEBIAN 4.0)
    # -i   display drive identification
    # -I   detailed/current information directly from drive

    #  -i   display drive identification (SUSE 10u1)
    #  -I   detailed/current information directly from drive
    #  --Istdin  reads identify data from stdin as ASCII hex
    #  --Istdout writes identify data to stdout as ASCII hex

    # Sep 23 19:12:47 hp02 root: Start of cfg2html-linux version 1.63-2009-08-27
    # Sep 23 19:13:03 hp02 kernel: hda: drive_cmd: status=0x51 { DriveReady SeekComplete Error }
    # Sep 23 19:13:03 hp02 kernel: hda: drive_cmd: error=0x04Aborted Command
    # Sep 23 19:13:18 hp02 root: End of cfg2html-linux version 1.63-2009-08-27

    # Anpassung auf hdparm -i wegen Fehler im Syslog (siehe oben, cfg1.63)
    # Ingo Metzler 23.09.2009

    if [ ${HDPARM} ]  && [ -x ${HDPARM} ]; then # added on 20240119 by edrulrd
      PHYS_DRIVES=$( ${SMARTCTL} --scan | ${AWKCMD} '{print $1}') # only use drives smartctl knows about # modified on 20240119 by edrulrd

      exec_command "for drive in ${PHYS_DRIVES}; do ${HDPARM} -i \${drive}; done" "Disk Identification Information" # added on 20240119 by edrulrd


      for drive in ${PHYS_DRIVES} # added on 20240119 by edrulrd
      do
          exec_command "${HDPARM} -t -T ${drive}" "Transfer Speed for ${drive}" # added on 20240119 by edrulrd
      done
    fi
  fi

  # Moved cdrom info from below to here # modified on 20240119 by edrulrd
  if [ -e /proc/sys/dev/cdrom/info ] ; then
    exec_command "cat /proc/sys/dev/cdrom/info" "CDROM Drive"
  fi

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
        mcat ${file} >>/tmp/fibrehba.txt
      done
  fi

  # capture /proc/scsi/qla2300

  if [ -d /proc/scsi/qla2300 ]
  then
      for file in /proc/scsi/qla300/*
      do
        mcat ${file} >>/tmp/fibrehba.txt
      done
  fi

  # capture /proc/scsi/qla2xxx

  if [ -d /proc/scsi/qla2xxx ]
  then
      for file in /proc/scsi/qla2xxx/*
      do
        mcat ${file} >>/tmp/fibrehba.txt
      done
  fi


  # capture /proc/scsi/lpfc

  if [ -d /proc/scsi/lpfc ]
  then
      for file in /proc/scsi/lpfc/*
      do
        mcat ${file} >>/tmp/fibrehba.txt
      done
  fi

  if [ -f /tmp/fibrehba.txt ]
  then
    exec_command "cat /tmp/fibrehba.txt" "Fibre Channel Host Bus Adapters"
    rm /tmp/fibrehba.txt
  fi

  SYSTOOL=`which systool  2>/dev/null`
  if [ -x "${SYSTOOL}" ]; then # modified on 20201004 by edrulrd
     exec_command "systool -c fc_host -v" "Fibre Channel Host Bus Adapters systool status"
  fi

  SGSCAN=`which sg_scan 2>/dev/null` 2>/dev/null # added /dev/null # modified on 20240202 by edrulrd
  if [ -x "${SGSCAN}" ]; then # modified on 20201009 by edrulrd
     exec_command "sg_scan -i" "Fibre Channel Host Bus Adapters sg_scan SCSI inquiry"
  fi

  SGMAP=`which sg_map 2>/dev/null`
  if [ -x "${SGMAP}" ]; then # modified on 20201009 by edrulrd # fixed variable name bug # modified on 20240119 by edrulrd
     exec_command "sg_map -x" "Fibre Channel Host Bus Adapters sg_map status"
  fi

  exec_command "ls -la /dev/disk/by-id" "Disk devices by-id"
  ls -ld /sys/block/sd* 2>/dev/null 1>&2 # check to see if we have sd* block devices # added on 20240202 by edrulrd
  if [ $? -eq 0 ]
  then
    exec_command "ls -ld /sys/block/sd*" "Block disk devices"
    if [ $(which /lib/udev/scsi_id 2>/dev/null) ]; then # we have this library installed # added on 20240202 by edrulrd
      exec_command "ls -v -1c /dev/sd*[!0-9] | xargs -I {} sh -c 'echo -n "{}:" ; /lib/udev/scsi_id --whitelisted --device={}'" "Fibre Channel Host Bus Adapters scsi_id"
    fi
  else
    exec_command "ls -ld /sys/block/* | grep -v virtual" "Non-virtual Block devices" # if no /sd* devices, list all non-virtual ones # modified on 20240202 by edrulrd
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
  SETSERIAL=$(which setserial 2>/dev/null) # modified in case setserial not installed, on 20201110 by edrulrd
  if [ -n "${SETSERIAL}" ] && [ -x ${SETSERIAL} ]; then
    exec_command "${SETSERIAL} -a /dev/ttyS0" "Serial ttyS0"
    exec_command "${SETSERIAL} -a /dev/ttyS1" "Serial ttyS1"
  fi

  # moved disk information section to up above # modified on 20240119 by edrulrd

  # Moved cdrom section to up above # modified on 20240119 by edrulrd

  if [ -e /proc/ide/piix ] ; then
    exec_command "cat /proc/ide/piix" "IDE Chipset info"
  fi

  # Test HW Health
  # MiMe
  if [ -x /usr/bin/sensors ] ; then
    # if [ -e /proc/sys/dev/sensors/chips ] ; then # commented out as cmd exists, but proc file doesn't # modified on 20240119 by edrulrd
      exec_command "/usr/bin/sensors" "Sensor Information" # modified on 20240119 by edrulrd
    # fi # commented out on 20240119 by edrulrd
  fi

  if [ -x /usr/sbin/xpinfo ]
  then
    XPINFOFILE="${OUTDIR}/$(hostname)_xpinfo.csv"
    /usr/sbin/xpinfo -d";" | grep -v "Scanning" > ${XPINFOFILE}

    AddText "The XP-Info configuration was additionally dumped into the file <b>${XPINFOFILE}</b> for further usage"

  # remarked due to enhancement request by Martin Kalmbach, 25.10.2001
  #  exec_command "/usr/sbin/xpinfo|grep -v Scanning" "SureStore E Disk Array XP Mapping (xpinfo)"

    exec_command "/usr/sbin/xpinfo -r|grep -v Scanning" "SureStore E Disk Array XP Disk Mechanisms"
    exec_command "/usr/sbin/xpinfo -i|grep -v Scanning" "SureStore E Disk Array XP Identification Information"
    exec_command "/usr/sbin/xpinfo -c|grep -v Scanning" "SureStore E Disk Array XP (Continuous Access and Business Copy)"
  # else
  # [ -x /usr/contrib/bin/inquiry256.ksh ] && exec_command "/usr/contrib/bin/inquiry256.ksh" "SureStore E Disk Array XP256 Mapping (inquiry/obsolete)"
  fi

  ### Begin changes by Dusan.Baljevic@ieee.org ### 13.05.2014

  if [ -x /usr/sbin/evainfo ]
  then
    AddText "Hint: evainfo displays a maximum of 1024 paths on Linux-based hosts"
    exec_command "/usr/sbin/evainfo -a -l 2>/dev/null" "HP P6000/EVA Disk Array LUNs"
    exec_command "/usr/sbin/evainfo -g -W 2>/dev/null" "HP P6000/EVA Disk Array Status with Generic Device Names"
  fi

  if [ -x /usr/bin/HP3PARInfo ]
  then
    exec_command "/usr/bin/HP3PARInfo -i 2>/dev/null" "HP 3PAR Disk Array Status"
    exec_command "/usr/bin/HP3PARInfo -f 2>/dev/null" "HP 3PAR Disk Array LUNs"
  fi

### End changes by Dusan.Baljevic@ieee.org ### 13.05.2014

dec_heading_level

fi # terminates CFG_HARDWARE wrapper

######################################################################

if [ "${CFG_SOFTWARE}" != "no" ]
then # else skip to next paragraph

  paragraph "Software"
  inc_heading_level

  # Debian
  if [ "${DEBIAN}" = "yes" ] ; then
    dpkg --get-selections | awk '!/deinstall/ {print $1}' > /tmp/cfg2html-debian.$$
    exec_command "column -c ${CFG_TEXTWIDTH} /tmp/cfg2html-debian.$$" "Packages installed" # specify a maximum width for our columns # modified on 20240119 by edrulrd
    rm -f /tmp/cfg2html-debian.$$
    AddText "Hint: to reinstall this list use:"
    AddText "awk '{print \$1\" install\"}' this_list | dpkg --set-selections" # modified on 20240119 by edrulrd
    exec_command "dpkg -C" "Misconfigured Packages"
#   # { changed/added 25.11.2003 (14:29) by Ralph Roth }
    if [ -x /usr/bin/deborphan ] ; then
      exec_command "deborphan" "Orphaned Packages"
      AddText "Hint: deborphan | xargs aptitude -y purge"   # rar, 16.02.04
    fi
    exec_command "dpkg -l" "Detailed list of installed Packages"
    AddText "$(dpkg --version|grep program)"
    exec_command "grep -vE '^#|^ *$' /etc/apt/sources.list" "Package Source repositories" # modified on 20240119 by edrulrd
    [ -x /usr/bin/dpigs ] && exec_command "/usr/bin/dpigs -H" "Largest installed packages" # added -H # modified on 20240119 by edrulrd
    if [ -x /usr/bin/debconf-get-selections ]; then
      AddText "Debian Settings"
      AddText "Hint: to reinstall this list use:"
      AddText "cat this_list | debconf-set-selections -v "
      exec_command "/usr/bin/debconf-get-selections" "Debian Package Configuration Values"
    fi
  fi
  # end Debian

  # SUSE
  # MiMe: --last tells date of installation
  if [ "${SUSE}" = "yes" ] || [ "${UNITEDLINUX}" = "yes" ] ; then
    exec_command "rpm -qa --last" "Packages installed (last first)"         #*#   Alexander De Bernardi //09.03.2010/rr
    exec_command "rpm -qa | sort -d -f" "Packages installed (sorted)"       #*#   Alexander De Bernardi //09.03.2010/rr
    exec_command "rpm -qa --queryformat '%{NAME}\n' | sort -d -f" "Packages installed, Name only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm -qa --queryformat '%-50{NAME} %{VENDOR}\n' | sort -d -f" "Packages installed, Name and Vendor only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm --querytags" "RPM Query Tags"     #*#   Alexander De Bernardi //21.04.2010/rr
    if [ -x /usr/bin/zypper ]
    then
    #     See Issue #6 - still open - timeout 60 will hopefully fix/workaround this issue
    #     #TODO:#BUG:# stderr output from "zypper ls; echo ''; zypper pt":
    #     System management is locked by the application with pid 1959 (/usr/lib/packagekitd).
    #     Close this application before trying again.
        if [ -r /etc/zypp/zypp.conf ]       ## fix for JW's SLES 10, backported to 2.91
        then
            exec_command "timeout 60 zypper -n ls; echo ''; echo | timeout 60 zypper -n pt " "zypper: Services and Patterns"   #*#   Ralph Roth, Mittwoch, 16. March 2011
            exec_command "timeout 60 zypper -n ps" "zypper: Processes which need restart after update"       #*#   Alexander De Bernardi 17.02.2011
            exec_command "timeout 60 zypper -n lr --details" "zypper: List repositories"                     #*#
            exec_command "timeout 60 zypper -n lu" "zypper: List pending updates"                            #*#
            exec_command "timeout 60 zypper -n lp" "zypper: List pending patches"                            #*#
            exec_command "timeout 60 zypper -n pa" "zypper: List all available packages"                     #*#
            exec_command "timeout 60 zypper -n pa --installed-only" "zypper: List installed packages"        #*#
            exec_command "timeout 60 zypper -n pa --uninstalled-only" "zypper: List not installed packages"  #*#   Alexander De Bernardi 17.02.2011
            exec_command "cut -d '|' -f 1-4 -s --output-delimiter ' | ' /var/log/zypp/history | grep -v ' radd '" "Software Installation History" # rr, 15.11.2017
        else
            AddText "zypper found, but it is not configured!"
        fi
    fi
  fi
  # end SUSE

  # REDHAT
  if [ "${REDHAT}" = "yes" ] || [ "${MANDRAKE}" = "yes" ] ; then
    exec_command "rpm -qia | grep -E '^(Name|Group)( )+:'" "Packages installed" ## Chris Gardner - 24.01.2012
    exec_command "rpm -qa | sort -d -f" "Packages installed (sorted)"       #*#   Alexander De Bernardi //09.03.2010 12:31/rr
    exec_command "rpm -qa --queryformat '%{NAME}\n' | sort -d -f" "Packages installed, Name only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm -qa --queryformat '%-50{NAME} %{VENDOR}\n' | sort -d -f" "Packages installed, Name and Vendor only (sorted)"      #*#   Alexander De Bernardi //21.04.2010/rr
    exec_command "rpm --querytags" "RPM Query Tags"     #*#   Alexander De Bernardi //21.04.2010/rr
    if [ -x /usr/bin/dnf ] ; then
        exec_command "dnf history" "DNF: Last actions performed"
    elif [ -x /usr/bin/yum ] ; then
        exec_command "yum history" "YUM: Last actions performed"
    fi  # yum
  fi
  # end REDHAT

  # SLACKWARE
  if [ "${SLACKWARE}" = "yes" ] ; then
    exec_command "ls /var/log/packages " "Packages installed"
  fi
  # end SLACKWARE
  # GENTOO, rr, 15.12.2004, Rob
  if [ "${GENTOO}" = "yes" ] ; then
    #exec_command "qpkg -I -v|sort" "Packages installed"
    #exec_command "qpkg -I -v  --no-color |sort" "Packages installed" ## Rob Fantini, 15122004
    exec_command "qlist -I -v --nocolor |sort" "Packages installed" ## 2007-02-21 Oliver Schwabedissen
  fi
  # end GENTOO

  # ARCH
  # M.Weiller, LUG-Ottobrunn.de, 2013-02-04
  if [ "${ARCH}" = "yes" ] ; then
    exec_command "pacman -Qq" "all installed packages"
    exec_command "pacman -Q" "all installed packages with version"
    exec_command "pacman -Qi" "all installed packages with full information"
    exec_command "pacman -Qeq" "official installed packages only"
    exec_command "pacman -Qdq" "dependencies installed packages only"
  fi
  # end ARCH

  ## changes by Dusan.Baljevic@ieee.org ### 14.05.2014
  ## AppArmor
  if [ -x /usr/sbin/aa-status ]
  then
    exec_command "/usr/sbin/aa-status --verbose" "AppArmor LSM for Name-based Mandatory Access Control/Profiles"
  fi

  #### programming stuff ##### plugin for cfg2html/linux/hpux #  22.11.2005, 16:03 modified by Ralph Roth
  exec_command ProgStuff "Software Development: Programs and Versions"

  dec_heading_level

fi # terminates CFG_SOFTWARE wrapper

######################################################################
if [ "${CFG_FILESYS}" != "no" ]
then # else skip to next paragraph

paragraph "Filesystems, Dump and Swap configuration"
inc_heading_level

    exec_command "grep -v '^#' /etc/fstab | column -t" "Filesystem Table"  # 281211, rr
    exec_command "${TIMEOUTCMD} 10 df -h" "Filesystems and Usage"   # gdha, 30/Nov/2015, to avoid stale NFS hangs (modified)

    exec_command "my_df" "All Filesystems and Usage"
    if [ -x /sbin/dumpe2fs ]
    then
      exec_command "display_ext_fs_param" "EXT Filesystems Parameters"	# needs fixing, 20140929 by Ralph Roth # modified on 20240202 by edrulrd
    fi
    if [ $(which xfs_db 2>/dev/null) ] # added on 20240202 by edrulrd
    then
      exec_command "display_xfs_fs_param" "XFS Filesystems Parameters" # added on 20240202 by edrulrd
    fi
    exec_command "mount | column --table -c ${CFG_TEXTWIDTH}" "Mount points" # more readable in table format # modified on 20240119 by edrulrd
    exec_command PartitionDump "Disk Partition Layout (showing sizes)"        #  30.03.2011, 20:00 modified by Ralph Roth #** rar ** # modified title # modified on 20240119 by edrulrd

    # moved the partition map showing sectors from below to here  # modified on 20240119 by edrulrd
    # for LVM using sed
    exec_command "/sbin/fdisk -l|sed 's/8e \ Unknown/8e \ LVM/g'" "Disk Partitions (showing sectors)" # modified on 20240119 by edrulrd

    #
    # 20201008 following code added by edrulrd
    # We want to save the partition tables for each of the disks so we can restore them if they get corrupted.
    # With the greatly increased sizes of disks nowadays, on systems with older versions of sfdisk, the data is not saved properly.
    # So, where we can, we'll save the partition tables with sfdisk, and where we can't we'll use sgdisk
    do_sgdisk=no
    do_sfdisk=no
    if [ -x "$(which sfdisk 2>/dev/null)" ] ; then # added /dev/null # modified on 20240202 by edrulrd
      vl="$(sfdisk -v | awk '{print $NF}'|sed 's/\./ /g')" # get version and level of sfdisk command
      v="$(echo ${vl} | awk '{print $1}')" # get version
      l="$(echo ${vl} | awk '{print $2}')" # level
      if [ ${v} -ge 3 ] || [ ${v} -eq 2 -a ${l} -ge 26 ] ; then
        do_sfdisk=yes # we can use sfdisk if the version is 2.26 or higher
      else
        do_sgdisk=yes # otherwise, we can use sgdisk if it's available
      fi
    else
      do_sgdisk=yes  # do sgdisk if sfdisk is not available but sgdisk is
    fi

    if [ -x "$(which lsblk 2>/dev/null)" ] ; then # added /dev/null # modified on 20240202 by edrulrd
      for HardDisk in $(lsblk -p | grep "^/" | grep disk | awk '{print $1}') # get the harddrives only eg. /dev/sda, not lv's etc.
      do
        if [ -x "$(which sgdisk 2>/dev/null)" -a "${do_sgdisk}" = "yes" ] ; then # added /dev/null # modified on 20240202 by edrulrd
          sgdisk --backup="${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk})" ${HardDisk} && # don't proceed if sgdisk fails # modified on 20240119 by edrulrd
          if [ -s "${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk})" ] # ignore empty files # added on 20240119 by edrulrd
          then
            exec_command "ls -l ${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk})" "SGDisk Partition specification for ${HardDisk}" # modified on 20240119 by edrulrd
            AddText "WARNING: use at your own risk!  To restore your partitions use the saved file: ${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk}). Read the man page for sgdisk for usage. (Hint: sgdisk --load-backup=${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk}) ${HardDisk}"
          fi # added on 20240119 by edrulrd
        else
          if [ "${do_sfdisk}" = "yes" ] ; then
            sfdisk -d ${HardDisk} > ${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk}) && # don't proceed if sfdisk fails # modified on 20240119 by edrulrd
            if [ -s "${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk})" ] # ignore empty files # added on 20240119 by edrulrd
            then
              exec_command "cat ${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk})" "SFDisk Partition specification for ${HardDisk}" # modified on 20240119 by edrulrd
              AddText "WARNING: use at your own risk!  To restore your partitions use the saved file: ${OUTDIR}/${BASEFILE}.partitions.save.$(basename ${HardDisk}). Read the man page for sfdisk for usage. (Hint: sfdisk --force /dev/device < file.save)"
            fi
          else
             AddText "Warning: sfdisk version is too old and sgdisk is not available"
          fi
        fi
      done
    fi # end of code added by edrulrd

    #*#
    #*# Alexander De Bernard 20100310
    #*#

    MD_FILE_LIST="/etc/mdadm.conf /etc/mdadm/mdadm.conf" # mdadm.conf found at alternative locations # modified on 20240119 by edrulrd
    MD_CMD="/sbin/mdadm"

    for MD_FILE in ${MD_FILE_LIST} # check each of the files for software raid config # modified on 20240119 by edrulrd
    do
      if [ -f ${MD_FILE} ]
      then
         exec_command "grep -vE '^#|^ *$' ${MD_FILE}" "MD Software RAID Configuration File" # modified title # modified on 20240119 by edrulrd
         if [ -x ${MD_CMD} ]
         then
           MD_DEV=$(grep "ARRAY" ${MD_FILE} | awk '{print $2;}')
           #         stderr output from "/sbin/mdadm --detail ":   ## SLES 11
           #         mdadm: No devices given.
           for d in ${MD_DEV}    # FIXNEEDED: SC2066
           do
               exec_command "${MD_CMD} --detail ${d}" "MD Device Setup of ${d}"
           done
         else
           AddText "${MD_FILE} exists but no ${MD_CMD} command"
         fi
      fi
    done

    # moved the following RAID section from the LVM section # modified on 20240119 by edrulrd
    # MD Tools, Ralph Roth

    # if [ -r /etc/raidtab ] # Note: /etc/raidtab is not present on some software raid enabled systems - commented out # modified on 20240119 by edrulrd
    #then
    [ -r /proc/mdstat ] &&  exec_command "cat /proc/mdstat" "Software RAID: mdstat" # modified on 20240119 by edrulrd
    [ -r /etc/raidtab ] &&  exec_command "cat /etc/raidtab" "Software RAID: raidtab" # modified on 20240119 by edrulrd
    [ -r /proc/devices/md ] && exec_command "cat /proc/devices/md" "Software RAID: MD Devices"
    #fi

    # command showing Partition map showing sectors moved up above # modified on 20240119 by edrulrd

    if [ -f /etc/exports ] ; then
	exec_command "grep -vE '^#|^ *$' /etc/exports" "NFS Filesystems"
    fi

    if [ -x /usr/sbin/kdumptool ]
    then
         ##CHANGED##FIXED## 20150304 by Ralph Roth
	 exec_command "/usr/sbin/kdumptool dump_config; echo; /usr/sbin/kdumptool find_kernel; echo; /usr/sbin/kdumptool print_target" "Kdump Status (kdumptool)"
    else
      if [ -x "$(which kdumpctl 2>/dev/null)" ] ; then # modified on 20201009 by edrulrd # added /dev/null # modified on 20240202 by edrulrd
    	exec_command "kdumpctl status" "Kdump Status"              #  Added by Dusan Baljevic 6/11/2014  (not on SLES11!) // 04.03.2015 Ralph Roth
    	exec_command "kdumpctl showmem" "Kdump memory allocation"  #  Added by Dusan Baljevic 24/12/2017
      fi
    fi # /usr/sbin/kdumptool
    [ -r /proc/diskdump ] && exec_command "cat /proc/diskdump" "Diskdump Status"          #  Added by Dusan Baljevic 6/11/2014, 06.04.2015 Ralph Roth
    [ -r /etc/sysconfig/dump ] && exec_command "cat /etc/sysconfig/dump" "Diskdump config file"    #  Added by Dusan Baljevic 6/11/2014 # Modified on 20201004 by edrulrd

    LKCD=$(which lkcd 2>/dev/null)
    if [ -x "${LKCD}" ] ; then                               #  Modified on 20201004 by edrulrd
      exec_command "$(${LKCD} -q)" "SUSE LKCD Status"                    #  Added by Dusan Baljevic 6/11/2014
    fi

dec_heading_level

fi # terminates CFG_FILESYS wrapper

###########################################################################
## 3/6/08 New: RedHat multipath config  by krtmrrsn@yahoo.com, Marc Korte.
## also available at SLES 11 #  07.04.2012, 19:56 modified by Ralph Roth #* rar *#
if [ ${REDHAT} = "yes" ] && [ -n "$(ps -ef | awk '/\/sbin\/multipathd/ {print $NF}')" ] ; then # modified on 20201005 by edrulrd

    if [ -x /sbin/multipath ]   #  10.11.2011, 22:50 modified by Ralph Roth #* rar *#
    then
      paragraph "Multipath Configuration"
      inc_heading_level

      exec_command "rpm -qa | grep multipath" "Multipath Package Version"
      exec_command "chkconfig --list multipathd" "Multipath Service Status"
      exec_command "/sbin/multipath -v2 -d -ll" "Multipath Devices Basic Information"
      exec_command "/sbin/multipath -v3 -d -ll" "Multipath Devices Detailed Information"
      exec_command "grep -vE '^#|^ *$' /etc/multipath.conf" "Multipath Configuration File"
      exec_command "for MultiPath in \$(/sbin/multipath -v1 -d -l); do ls -l /dev/mapper/\${MultiPath} 2>/dev/null; done" "Device Mapper Files"
      exec_command "cat /var/lib/multipath/bindings" "Multipath Bindings"

      dec_heading_level
    fi
fi

###########################################################################
if [ "${CFG_LVM}" != "no" ]
then # else skip to next paragraph

    paragraph "LVM"
    inc_heading_level

    [ -x /sbin/blkid ] && exec_command "blkid" "Block Device Attributes"    #  07.11.2011, 21:42 modified by Ralph Roth #* rar *#
    [ -x /sbin/pvs ] && exec_command "pvs" "Physical Volumes"         # if LVM2 installed       #  07.11.2011, 21:45 modified by Ralph Roth #* rar *#

    # WONT WORK WITH HP RAID!
    LVMFDISK=$(/sbin/fdisk -l | grep "LVM$")

    if  [ -n "${LVMFDISK}" -o -r /etc/lvmtab -o -r /etc/lvm/lvm.conf ]   # This expression is constant. Did you forget a $ somewhere?
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
                case "${LVM_VER}" in
                "1")
                  exec_command "lvscan --version" "LVM Version"
                  exec_command "ls -la /dev/*/group" "Volume Group Device Files" # minor title change # modified on 20240119 by edrulrd
                  # { changed/added 29.01.2004 (11:15) by Ralph Roth } - sr by winfried knobloch for Serviceguard
                  exec_command "cat /proc/lvm/global" "LVM global info"
                  exec_command "vgdisplay -v | awk -F' +' '/PV Name/ {print \$4}'" "Available Physical Volumes" # changed Groups to Volumes # modified on 20240119 by edrulrd
                  exec_command "vgdisplay -s | awk -F\\\" '{print \$2}'" "Available Volume Groups"
                  exec_command "vgdisplay -v | awk -F' +' '/LV Name/ {print \$3}'" "Available Logical Volumes"
                  ;;
                "2")
                  exec_command "ls -al /dev/mapper/*; [ -x /sbin/vgs ] && echo && /sbin/vgs -o vg_name,lv_name,devices" "Volume Group Device Files" # minor title change # modified on 20240119 by edrulrd
                  exec_command "lvm version" "LVM global info"
                  exec_command "lvm dumpconfig" "LVM dumpconfig"
                  exec_command "vgdisplay -v | awk -F' +' '/PV Name/ {print \$4}'" "Available Physical Volumes" # changed Groups to Volumes # modified on 20240119 by edrulrd
                  exec_command "vgdisplay -s | awk -F\\\" '{print \$2}'" "Available Volume Groups"
                  exec_command "vgdisplay -v | awk -F' +' '/LV Name/ {print \$4}'" "Available Logical Volumes"
                  # The command vgs -o +tags vgname will display any tags that are set for a volume group. *TODO*
                  # vgcreate --addtag $(uname -n) /dev/vgpkgA /dev/sda1 /dev/sdb1 // vgchange --deltag $(uname -n) vgpkgA  *SGLX*
                  # [ -x /sbin/vgs ] && exec_command "/sbin/vgs -o vg_name,lv_name,devices" "Detailed Volume Groups Report" #  27.10.2011 #* rar *# EHR by Jim Bruce # combined with /dev/mapper report to put under same heading # modified on 20240119 by edrulrd
                  exec_command "lvs -o +devices" "Logical Volumes"      #  07.11.2011, 21:46 modified by Ralph Roth #* rar *#
                  ;;
                  *)
                  AddText "Unsupported (new) LVM version (${LVM_VER})!"
                  ;;
                  esac
            #
              exec_command "vgdisplay -v" "Volume Group Details" # minor title change # modified on 20240119 by edrulrd
              exec_command PVDisplay "Physical Devices used for LVM"
              AddText "Note: Run vgcfgbackup on a regular basis to backup your volume group layout"
            else
              # if vgdisplay exist, but no LV configured (dk3hg 21.02.03)
              AddText "LVM binaries found, but this system seems to be configured with whole disk layout (WDL)"
        fi
    else
        AddText "This system seems to be configured with whole disk layout (WDL)"
    fi

    # moved the Software RAID section to up above in the Filesystem section.  # modified on 20240119 by edrulrd
    dec_heading_level

fi # terminates CFG_LVM wrapper
#
# CFG_ZFS
#
if [ "$CFG_ZFS" != "no" ]
then # else skip to next paragraph
   paragraph "ZFS Filesystem Status"
   inc_heading_level

  if [ $(which zfs 2>/dev/null) ] # check if the command is in the program's path # Modified on 20240119 by edrulrd
  then
      exec_command "zfs mount" "ZFS mount status"
      exec_command "zfs get all" "ZFS properties"
  else 
      exec_command " " "zfs command"  # execute nothing, but allow the N/A message to appear # modified on 20240119 by edrulrd
  fi

  if [ $(which zpool 2>/dev/null) ] # check if the command is in the program's path # Modified on 20240119 by edrulrd
  then
      exec_command "zpool list -H" "ZFS pool status"
      exec_command "zpool list -Ho bootfs" "ZFS boot pool"
      exec_command "zpool upgrade" "ZFS pool version"
      exec_command "zpool history" "ZFS pool history"
  else
      exec_command " " "zpool command" # execute nothing, but allow the N/A message to appear # modified on 20240119 by edrulrd

  fi

  dec_heading_level
fi
# terminates CFG_ZFS wrapper

###########################################################################
if [ "${CFG_NETWORK}" != "no" ]
then # else skip to next paragraph

  paragraph "Network Settings"
  inc_heading_level

  if [[ -x /sbin/ifconfig ]]; then
     exec_command "/sbin/ifconfig" "LAN Interfaces Settings (ifconfig)"    #D011 -- 16. March 2011,  28. Dezember 2011, ER by Heiko Andresen // to avoid error if ifconfig not found
  fi
  exec_command "ip addr" "LAN Interfaces Settings (ip addr)"            #D011 -- 16. March 2011,  28. Dezember 2011, ER by Heiko Andresen
  exec_command "ip -s l" "Detailed NIC Statistics"                      #07.11.2011, 21:33 modified by Ralph Roth #* rar *#
  # nmcli not available on SLES11##FIXED## 20150304 by Ralph Roth
  if [ -x /usr/bin/nmcli ]
  then
      # exec_command "nmcli nm status" "NetworkManager Status"
      #06.11.2014, 20:34 added by Dusan Baljevic dusan.baljevic@ieee.org##FIXED## 20150304 by Ralph Roth //  not available on openSUSE 13.2!
      exec_command "nmcli device status" "NetworkManager Device Status"   	#20150527 by Ralph Roth
      exec_command "nmcli connection show" "NetworkManager Connections"     	#06.11.2014, 20:34 added by Dusan Baljevic dusan.baljevic@ieee.org##FIXED## 20150304 by Ralph Roth
  fi ## /usr/bin/nmcli

  if [ -x /usr/sbin/ethtool ]     ###  22.11.2010, 23:44 modified by Ralph Roth
  then
      LANS=$(ip link | grep -v '^ ' | awk '{print $2}' | grep -v "lo:" | sed 's/://') # netstat is deprecated, use ip link instead # modified on 20240119 by edrulrd
      for i in ${LANS}
      do
        # netstat is now (2023) also deprecated, see issue #166
        exec_command "/usr/sbin/ethtool ${i} 2>/dev/null; /usr/sbin/ethtool -i ${i}" "Ethernet Settings for Interface "${i}
      done; unset i
  fi

  if [ ${DEBIAN} = "yes" ] ; then
    if [ -f /etc/network/interfaces ] ; then
      exec_command "grep -vE '(^#|^$)' /etc/network/interfaces" "Netconf Settings"
    fi
  fi

  ## Added 3/05/08 by krtmrrsn@yahoo.com, Marc Korte, display ethernet
  ##  LAN and route config files for RedHat.
  if [ ${REDHAT} = "yes" ] ; then
    ## There will always be at least ifcfg-lo.
    exec_command "for CfgFile in /etc/sysconfig/network-scripts/ifcfg-*; do printf \"\n\n\$(basename \${CfgFile}):\n\n\"; cat \${CfgFile}; done" "LAN Configuration Files"
    ## Check first that any route-* files exist # modified on 20201005 by edrulrd
    ### # [20200319] {jcw} See if I can put this as a multi-line command.
    exec_command "if [ $(find /etc/sysconfig/network-scripts/ -name route-* -print |wc -l) -gt 0 ]; then for RouteCfgFile in /etc/sysconfig/network-scripts/route-*; do printf \"\n\n\$(basename \${RouteCfgFile}):\n\n\"; cat \${RouteCfgFile}; done; fi" "Route Configuration Files" # modified on 20201005 by edrulrd
  fi
  ## End Marc Korte display ethernet LAN config files.

  # Need to add the interface to the mii-tool and mii-diag commands # added on 20201005 by edrulrd
  # Warning: mii-tool is noted to be obsolete, especially for speeds > 100 mb # added on 20240119 by edrulrd
  [ -x /sbin/mii-tool ] && exec_command "for Interface in $(ip link | grep -v '^ ' | awk '{print $2}' | grep -v "lo:" | sed 's/://'); do /sbin/mii-tool -v \${Interface} 2>/dev/null; done" "MII Status" # use ip link instead of netstat -ni # modified on 20240119 by edrulrd
  [ -x /sbin/mii-diag ] && exec_command "for Interface in $(ip link | grep -v '^ ' | awk '{print $2}' | grep -v "lo:" | sed 's/://'); do /sbin/mii-diag -a \${Interface} 2>/dev/null; done" "MII Diagnostics" # use ip link instead of netstat -ni # modified on 20240119 by edrulrd

  exec_command "ip route | column -t" "Network Routing"  #  07.11.2011, 21:37 modified by Ralph Roth #* rar *# #added table format # modified on 20240119 by edrulrd
  NETSTAT=$(which netstat 2> /dev/null) # modified on 20240119 by edrulrd
  [ ${NETSTAT} ] && [ -x ${NETSTAT} ] && exec_command "netstat -r | column -t" "Routing Tables" # modified on 20240119 by edrulrd
  exec_command "ip neigh | column --table" "Network Neighborhood"      #  07.11.2011, 21:38 modified by Ralph Roth #* rar *# # added table format # modified on 20240119 by edrulrd

  if [ ${NETSTAT} ]  && [ -x ${NETSTAT} ]; then
    # test if netstat version 1.38, because some options differ in older versions
    # MiMe: '\' auf awk Zeile wichtig
    RESULT=$(netstat -V | awk '/netstat/ {
      if ( $2 < 1.38 ) {
        print "NO"
      } else { print "OK" }
    }')

    #exec_command "if [ "${RESULT}" = "OK" ] ; then netstat -gi; fi" "Interfaces"
    if [ "${RESULT}" = "OK" ]
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

  # Since netstat is deprecated, the following commands attempt to show the equivalent output using more modern network commands # added on 20240119 by edrulrd
  exec_command "ip maddress show" "Multicast IP addresses" # replacement for netstat -gi # added on 20240119 by edrulrd

  if [ $(which ss 2>/dev/null) ] # check if the command is in the program's path # added on 20240119 by edrulrd
  then
    exec_command "ss -planeto" "TCP Listening Sockets Statistics" # changed 20131211 by Ralph Roth # modified on 20240119 by edrulrd
    exec_command "ss -planeuo" "UDP Listening Sockets Statistics" # UDP and listening? :) # modified on 20240119 by edrulrd
  fi # ss
  if [ $(which pminfo 2>/dev/null) ] # check if the command is in the program's path # Added on 20240119 by edrulrd
  then
     exec_command "pminfo -f network | column -c ${CFG_TEXTWIDTH}" "Summary statistics for each protocol"  # replacement for the netstat -s command.  Is part of the "pcp" package if installed.  # added on 20240119 by edrulrd
  fi

  if [ $(which nstat 2>/dev/null) ] # just check if it's in the path # modified on 20240119 by edrulrd
  then
     exec_command "nstat -a | grep -v '^#' | column -c ${CFG_TEXTWIDTH}" "Other Network statistics" # Added on 20240119 by edrulrd
  fi

  exec_command "ip -statistics link" "Kernel Interface table" # replacement for the netstat -i command.  # added on 20240119 by edrulrd
  exec_command "ss -a | column -c ${CFG_TEXTWIDTH}" "list of all sockets" # replacement for the netstat -a command.  # added on 20240119 by edrulrd
  # -----------------------------------------------------------------------------
  ## Added 4/07/06 by krtmrrsn@yahoo.com, Marc Korte, probe and display
  ##        kernel interface bonding info.
  if [ -e /proc/net/bonding ]; then
    for BondIF in `ls -1 /proc/net/bonding`
    do
      exec_command "cat /proc/net/bonding/${BondIF}" "Bonded Interfaces: ${BondIF}"
    done
  fi
  ## End Marc Korte kernel interface bonding addition.
  # -----------------------------------------------------------------------------
  DIG=`which dig 2>/dev/null` # added /dev/null # modified on 20240202 by edrulrd
  if [ -n "${DIG}" ] && [ -x ${DIG} ] ; then
    exec_command "dig `hostname -f`| grep -vE '^;|^ *$'" "dig hostname"
  else
    NSLOOKUP=`which nslookup`
    if [ -n "${NSLOOKUP}" ] && [ -x ${NSLOOKUP} ] ; then
      exec_command "nslookup `hostname -f`" "Nslookup hostname"
    fi
  fi

  exec_command "grep -vE '^#|^ *$' /etc/hosts | column -t" "/etc/hosts" # added column # modified on 20240119 by edrulrd
#
  if [ -f /proc/sys/net/ipv4/ip_forward ] ; then
    FORWARD=`cat /proc/sys/net/ipv4/ip_forward`
    if [ ${FORWARD} = "0" ] ; then
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

  ### Begin changes by Dusan.Baljevic@ieee.org ### 13.05.2014

  if [ -x /usr/sbin/ufw ] ; then
    exec_command "/usr/sbin/ufw status" "Netfilter Firewall"
    exec_command "/usr/sbin/ufw app list" "Netfilter Firewall Application Profiles"
  fi

  ### End changes by Dusan.Baljevic@ieee.org ### 14.05.2014

  if [ -x /usr/sbin/tcpdchk ] ; then
    exec_command "/usr/sbin/tcpdchk -v 2>/dev/null" "tcpd wrapper"
    exec_command "/usr/sbin/tcpdchk -a 2>/dev/null" "tcpd warnings"
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
  # Confirm there is at least one file # added on 20201005 by edrulrd
  if [ -d /etc/xinetd.d ] && [ $(find /etc/xinetd.d -type f -print | wc -l) -gt 0 ]; then # modified on 20201005 by edrulrd
    # mdk/rh has a /etc/xinetd.d directory with a file per service
    exec_command "cat /etc/xinetd.d/*|grep -vE '^#|^ *$'" "/etc/xinetd.d/ section"
  fi

  #exec_command "cat /etc/services" "Internet Daemon Services"
  if [ -f /etc/resolv.conf ] ; then
     exec_command "grep -vE '^#|^ *$' /etc/resolv.conf;echo; ( [ -f /etc/nsswitch.conf ] &&  grep -vE '^#|^ *$' /etc/nsswitch.conf)" "DNS & Names"
  fi
  [ -r /etc/bind/named.boot ] && exec_command "grep -v '^;' /etc/named.boot"  "DNS/Named"

  if [ -s /etc/dnsmasq.conf ] ; then
     exec_command "cat /etc/dnsmasq.conf | grep -vE '^#|^ *$'; systemctl status dnsmasq" "DNSMASQ" # removed commented and blank lines # modified on 20240119 by edrulrd
  fi

  if [ -s /etc/nscd.conf ] ; then
     exec_command "cat /etc/nscd.conf" "Name Service Cache Daemon (NSCD)"
  fi

  if [ -x /usr/sbin/nullmailer-send ]	## backport from cfg2html-linux 2.97 -- 04.04.2015, rr
  then
        :               ##  provides sendmail which NO options
  else
      if [ -L /etc/alternatives/mta ]; then
          MTA=$(readlink -e /etc/alternatives/mta)
      else
          MTA=''
      fi
      if  [ -z "${MTA}" ]; then
          if [ -x /usr/sbin/postconf ]; then
            MTA='sendmail.postfix'
          elif [ -f /usr/sbin/sendmail.sendmail ]; then
            MTA='/usr/sbin/sendmail/sendmail.sendmail'
          elif [ -x /usr/sbin/sendmail ]; then
            MTA='/usr/sbin/sendmail'
          fi
      fi
      case "${MTA}" in
        *sendmail.postfix)
          exec_command "/usr/sbin/postconf -h mail_version" "Postfix Version"
          ;;
        *sendmail)
          exec_command "${MTA} -d0.1 < /dev/null | grep Version ; grep ^DZ /etc/mail/sendmail.cf" "Sendmail version"
          SMARTHOST=$(grep -e "^DS" /etc/mail/sendmail.cf | sed s/^DS//g)
          exec_command "echo '\$Z' |/usr/sbin/sendmail -bt -d0.1; echo Smart Relay Host=${SMARTHOST}" "Detailed Sendmail Configuration"   # From cfg2html-hpux
          #  From cfg2html-hpux
          exec_command "cat $(grep -e '^Kmailertable' /etc/mail/sendmail.cf | cut -d ' ' -f 4 | sed s/\.db//) /dev/null | grep -vE '^#|^ *$'" "Sendmail Mailertable"
          ;;
        *)
          exec_command "echo SENDMAIL or POSTFIX VERSION not found issue" "Sendmail/Postfix version"
          ;;
      esac
  fi

  aliasespath="/etc"
  if [ "${GENTOO}" == "yes" ] ;then   ## 2007-02-27 Oliver Schwabedissen
    aliasespath="/etc/mail"
  fi
  if [ -f ${aliasespath}/aliases ] ; then
    exec_command "grep -vE '^#|^ *$' ${aliasespath}/aliases | column -t" "Email Aliases" # added column cmd # modified on 20240119 by edrulrd
  fi
  #exec_command "grep -vE '^#|^$' /etc/rc.config.d/nfsconf" "NFS settings"
  exec_command "ps -ef|grep -E '[Nn]fsd|[Bb]iod'" "NFSD and BIOD utilization"   ## fixed 2007-02-28 Oliver Schwabedissen

  # if portmap not available, do nothing
  RES=`ps xau | grep [Pp]ortmap`
  if [ -n "${RES}" ] ; then
    exec_command "rpcinfo -p " "RPC (Portmapper)"
    # test if mountd running
    MOUNTD=`rpcinfo -p | awk '/mountd/ {print $5; exit}'`
  #  if [ "${MOUNTD}"="mountd" ] ; then
    if [ -n "${MOUNTD}" ] ; then
      exec_command "rpcinfo -u 127.0.0.1 100003" "NSFD responds to RPC requests"
      SHOWMOUNT=`which showmount 2>/dev/null`   ## 2007-02-27 Oliver Schwabedissen # added /dev/null # modified on 20240202 by edrulrd
      if [ ${SHOWMOUNT} ] && [ -x ${SHOWMOUNT} ] ; then
        exec_command "${SHOWMOUNT} -a" "Mounted NFS File Systems"
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
  NTPQ=`which ntpq 2>/dev/null` # modified in case ntpq not installed, on 20201004 by edrulrd
  # if [ ${NTPQ} ] && [ -x ${NTPQ} ] ; then
  if [ -n "${NTPQ}" -a -x "${NTPQ}" ] ; then      # fixes by Ralph Roth, 180403
    exec_command "${NTPQ} -p" "XNTP Time Protocol Daemon"
  fi

  # Chronyc is replacement for standard NTP, now default in RHEL/CentOS 7
  # Added by Dusan Baljevic on 13 July 2014
  #
  CHRONYC=$(which chronyc 2>/dev/null)
  if [ -n "${CHRONYC}" -a -x "${CHRONYC}" ] ; then
    exec_command "${CHRONYC} -n sourcestats" "CHRONY Time Protocol Daemon sources"
    exec_command "${CHRONYC} -n tracking" "CHRONY Time Protocol Daemon tracking"
  fi

  exec_command "timedatectl status" "System Time and Date Status"  # Added by Dusan Baljevic on 6 November 2014

  exec_command "hwclock -r" "Time: HWClock" # rr, 20121201
  [ -f /etc/ntp.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/ntp.conf" "ntp.conf"
  [ -f /etc/shells ] && exec_command "grep  -vE '^#|^ *$'  /etc/shells" "FTP Login Shells"
  [ -f /etc/ftpusers ] && exec_command "grep  -vE '^#|^ *$'  /etc/ftpusers" "FTP Rejections (/etc/ftpusers)"
  [ -f /etc/ftpaccess ] && exec_command "grep  -vE '^#|^ *$'  /etc/ftpaccess" "FTP Permissions (/etc/ftpaccess)"
  [ -f /etc/syslog.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/syslog.conf" "syslog.conf"
  [ -f /etc/syslog-ng/syslog-ng.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/syslog-ng/syslog-ng.conf" "syslog-ng.conf"
  [ -f /etc/host.conf ] && exec_command "grep  -vE '^#|^ *$' /etc/host.conf" "host.conf"

  ######### SNMP ############
  [ -f /etc/snmpd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmpd.conf | column -t" "Simple Network Management Protocol (SNMP)" # added column cmd # modified on 20240119 by edrulrd
  [ -f /etc/snmp/snmpd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmp/snmpd.conf | column -t" "Simple Network Management Protocol (SNMP)" # added column cmd # modified on 20240119 by edrulrd
  [ -f /etc/snmp/snmptrapd.conf ] && exec_command "grep -vE '^#|^ *$' /etc/snmp/snmptrapd.conf" "SNMP Trapdaemon config"

  [ -f  /opt/compac/cma.conf ] && "grep -vE '^#|^ *$' /opt/compac/cma.conf" "HP Insight Management Agents configuration"

  ## ssh
  [ -f /etc/ssh/sshd_config ] && exec_command "grep -vE '^#|^ *$' /etc/ssh/sshd_config" "sshd config"
  [ -f /etc/ssh/ssh_config ] && exec_command "grep -vE '^#|^ *$' /etc/ssh/ssh_config" "ssh config"

  dec_heading_level

fi # terminates CFG_NETWORK wrapper


###########################################################################
if [ "${CFG_KERNEL}" != "no" ]
then # else skip to next paragraph

# In the v2.6 Linux kernel, preventing the starvation of requests in general,
# and read requests in particular, was a primary focus of the new (four) I/O
# schedulers. The default I/O Elevator in the v2.6 Linux kernel is the
# anticipatory scheduler. RedHat RHEL4/5.6 and Novell/SUSE SLES 9-11
# installations overwrite this with the CFQ scheduler.
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

    if [ -f /boot/grub/grub.cfg ] ; then
      exec_command "grep -vE '^#|^ *$' /boot/grub/grub.cfg" "GRUB2 Boot Manager"
    fi

    if [ -f /boot/grub2/grub.cfg ] ; then
      exec_command "grep -vE '^#|^ *$' /boot/grub2/grub.cfg" "GRUB2 Boot Manager" # Fedora/RedHat
    fi

    if [ -f /etc/palo.conf ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/palo.conf" "Palo Boot Manager"
    fi

    [ -x /usr/bin/lsinitrd ] && exec_command "/usr/bin/lsinitrd" "Contents of the InitRD RAM File System" ## Closes issue #26, RR, 18.06.2018, new with dracut distros

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
      exec_command "grep -vE '^#|^ *$' /etc/sysconfig/kernel" "Modules for the ramdisk" # rar, SUSE only
      exec_command "sed -e '/^#/d;/^$/d;/^[[:space:]]*$/d' /etc/sysconfig/kernel" "Missing Kernel Modules" # changed 20130205 by Ralph Roth
      AddText "See: Modules failing to load at boot time - TID 7005784"
    fi

    if [ "${DEBIAN}" = "no" ] && [ "SLACKWARE" = "no" ] ; then
            which rpm > /dev/null  && exec_command "rpm -qa | grep -e ^k_def -e ^kernel -e k_itanium -e k_smp -e ^linux" "Kernel RPMs" # rar, SUSE+RH+Itanium2
    fi

    if [ "${DEBIAN}" = "yes" ] ; then
        exec_command "dpkg -l | grep -i -e Kernel-image -e Linux-image" "Kernel related DEBs"
    fi
    [ -x /usr/sbin/getsebool ] && exec_command "/usr/sbin/getsebool -a" "SELinux Settings"

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

    if [ "${DEBIAN}" = "no" ] && [ "${SLACKWARE}" = "no" ] && [ "${GENTOO}" = "no" ] ; then  ## fixed 2007-02-27 Oliver Schwabedissen
            which rpm > /dev/null  && exec_command "rpm -qi glibc" "libc6 Version (RPM)" # rar, SUSE+RH
    fi

    exec_command "/sbin/ldconfig -vN  2>/dev/null | column -c ${CFG_TEXTWIDTH}" "Run-time link bindings" ### changed 20130730 by Ralph Roth # modified on 20240119 by edrulrd

    # MiMe: SUSE patched kernel params into /proc
    if [ -e /proc/config.gz ] ; then
      exec_command "zcat /proc/config.gz | grep -vE '^#|^ *$'" "Kernel Parameter /proc/config.gz" # modified on 20240119 by edrulrd
    else
      if [ -e /usr/src/linux/.config ] ; then
        exec_command "grep -vE '^#|^ *$' /usr/src/linux/.config" "Kernel Source .config" # modified on 20240119 by edrulrd
      fi
    fi

    ## we want to display special kernel configuration as well
    ## done in /etc/init.d/boot.local
    ## 31Jan2003 it233 U.Frey FRU
    if [ -e /etc/init.d/boot.local ] ; then
      exec_command "grep -vE '^#|^ *$' /etc/init.d/boot.local" "Additional Kernel Parameters init.d/boot.local"
    fi

    if [ -x /sbin/sysctl ] ; then ##  11.01.2010, 10:44 modified by Ralph Roth
      exec_command "/sbin/sysctl -a 2> /dev/null | sort -u | column -c ${CFG_TEXTWIDTH}" "Configured Kernel variables at runtime"  ## rr, 20120212 # added column # modified on 20240119 by edrulrd
      exec_command "cat /etc/sysctl.conf | sort -u |grep -v -e ^# -e ^$" "Configured Kernel variables in /etc/sysctl.conf" # minor title change # modified on 20240119 by edrulrd
    fi

    # Added by Dusan Baljevic on 15 July 2013
    #
    BOOTCTL=$(which bootctl 2>/dev/null) # added /dev/null # modified on 20240202 by edrulrd
    if [ -n "${BOOTCTL}" ] && [ -x "${BOOTCTL}" ] ; then
      exec_command "${BOOTCTL} status | awk NF" "Firmware and boot manager settings"
    fi

    if [ -f "/etc/rc.config" ] ; then
       exec_command "grep ^INITRD_MODULES /etc/rc.config" "INITRD Modules"
    fi

    if [ -d /sys/devices ]
    then                                                    # The new Linux 2.6.x  I/O system and the I/O scheduler
        exec_command GetElevator "Kernel I/O Elevator"      # 18.07.2011, 13:33 modified by Ralph Roth #* rar *#
        exec_command "lsblk -ta -o +UUID" "List of Block Devices"    # changed 20130627 by Ralph Roth # add UUID option # modified on 20240119 by edrulrd
    fi
    dec_heading_level

fi # terminates CFG_KERNEL wrapper
######################################################################

if [ "${CFG_ENHANCEMENTS}" != "no" ]
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
        # old command   [ -x /usr/bin/X11/xdpyinfo ] && [ -n "${DISPLAY}" ] && exec_command "/usr/bin/X11/xdpyinfo" "X11"
        # this will only check if the display is 0 or 1 which is more then enough
            [ -x /usr/bin/X11/xdpyinfo ] && [ -n "${DISPLAY}" ] && [ `echo ${DISPLAY} | cut -d: -f2 | cut -d. -f1` -le 1 ] && exec_command "/usr/bin/X11/xdpyinfo" "X11"
            [ -x /usr/bin/X11/fsinfo ] && [ -n "${FONTSERVER}" ] && exec_command "/usr/bin/X11/fsinfo" "Font-Server"
      fi
    fi

    [ -x /opt/gnome/bin/gconftool-2 ] &&  exec_command "gconftool-2 -R /system"  "GNOME System Config"  ##  BF=bernhard keppel/110711, 30.11.2010/Ralph Roth

    dec_heading_level

fi # terminates CFG_ENHANCEMENTS wrapper
###########################################################################

if [ "${CFG_APPLICATIONS}" != "no" ]
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

    [ -n "${SWAT}" ] && exec_command  "echo ${SWAT}" "Samba: SWAT-Port"

    [ -x /usr/sbin/smbstatus ] && exec_command "/usr/sbin/smbstatus 2>/dev/null" "Samba (smbstatus)"
    ### Debian...., maybe a smbstatus -V/samba -V is useful
    [ -x /usr/bin/smbstatus ] && exec_command "/usr/bin/smbstatus 2>/dev/null" "Samba (smbstatus)"  ## fixed 2007-02-27 Oliver Schwabedissen
    [ -x /usr/bin/testparm ] && exec_command "/usr/bin/testparm -s 2> /dev/null" "Samba Configuration (testparm)" #  09.01.2008, 14:53 modified by Ralph Roth
    [ -f /etc/samba/smb.conf ] && exec_command "cat /etc/samba/smb.conf" "Samba Configuration (smb.conf)" #*#  Alexander De Bernardi, 20100421 testparm does not show complete config
    [ -f /etc/init.d/samba ] && exec_command "ps -ef | grep -E '(s|n)m[b]'" "Samba Daemons"

    if [ -x /usr/sbin/lpc ] ; then
      exec_command "/usr/sbin/lpc status" "BSD Printer Spooler and Printers"    #*# Alexander De Bernardi, 20100310
    fi
     if [ -x /usr/bin/lpstat ] ; then
     exec_command "/usr/bin/lpstat -t 2>/dev/null" "SYSV Printer Spooler and Printers"      #*# Alexander De Bernardi, 20100310 # dismiss error report # modified on 20240202 by edrulrd
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


## we want to display Veritas Netbackup configurations
## 31Jan2003 it233 FRU U.Frey
## 3/5/08 Modified/added functionality by krtmrrsn@yahoo.com, Marc Korte.
##  Some things have changed in NetBU 6.x.
##  Made a separate section for Veritas Netbackup
    if [ -e /usr/openv/netbackup/bp.conf ] ; then

      dec_heading_level
      paragraph "Veritas Netbackup Configuration"
      inc_heading_level

          NetBuVersion=$(find /usr/openv/netbackup -name "version")
          if [ -e ${NetBuVersion} ] ; then
            exec_command "cat ${NetBuVersion}" "Veritas Netbackup Version"
          fi
          exec_command "cat /usr/openv/netbackup/bp.conf" "Veritas Netbackup Configuration"
          # bring the logic of hpux test to linux as well - gdha - 16/Dec/2015
          if [ -s /usr/openv/netbackup/exclude_list ] ; then
              exec_command "cat /usr/openv/netbackup/exclude_list" "Symantec Netbackup exclude_list"
          fi
          if [ -s /usr/openv/netbackup/include_list ] ; then
              exec_command "cat /usr/openv/netbackup/include_list" "Symantec Netbackup include_list"
          fi
          if [ -x /usr/openv/netbackup/bin/bpclimagelist ] ; then
            exec_command "${TIMEOUTCMD} 20 /usr/openv/netbackup/bin/bpclimagelist | head -12" "Overview of the last 10 backups"
            LASTFULL=$(${TIMEOUTCMD} 20 /usr/openv/netbackup/bin/bpclimagelist | grep Full | head -1 | cut -c1-10)
            [[ -z "${LASTFULL}" ]] && LASTFULL=$(date +%m/%d/%Y) # if no output was retrieved we use today's date
            LASTFULLSEC=$(date +%s -d ${LASTFULL})
            sleep 1 # to have at least 1 sec difference
            NOWSEC=$(date +%s)

            let DIFFDAYS=$(( (${NOWSEC}-${LASTFULLSEC})/86400 ))  # [20200821] {jcw} added 'let' and removed spaces.
            if [[ ${DIFFDAYS} -gt 14 ]]; then
                AddText "Warning: Last full backup is ${DIFFDAYS} days old"
            else
                AddText "Last full backup is ${DIFFDAYS} days old"
            fi
          fi

          exec_command "netstat -tap | egrep '(bpcd|bpjava-msvc|bpjava-susvc|vnetd|vopied)|(Active|Proto)'" "Veritas Netbackup Network Connections"
            ## Use FS="=" in case there's no whitespace in the SERVER lines.
### # [20200319] {jcw} See if I can put this as a multi-line command.
          exec_command "for NetBuServer in $(awk 'BEGIN {FS="="} /SERVER/ {printf ${NF}}' /usr/openv/netbackup/bp.conf); do ping -c 3 \${NetBuServer} && echo \"\"; done" "Veritas Netbackup Servers Ping Check"
          if ping -c 3 $(awk 'BEGIN {FS="="} /SERVER/ {print ${NF}}' /usr/openv/netbackup/bp.conf | head -1) >/dev/null
          then
            exec_command "/usr/openv/netbackup/bin/bpclntcmd -pn" "Veritas Netbackup Client to Server Inquiry"
          fi
    fi

### Section about HP Data Protector info - gdha - 04/Jan/2016
    if [ -f /etc/opt/omni/client/cell_server ] ; then
      dec_heading_level
      paragraph "HP Data Protector Configuration"
      inc_heading_level
      exec_command "cat /etc/opt/omni/client/cell_server" "HP Data Protector cell manager"
      if [ -x /opt/omni/bin/omnicheck ]; then
          exec_command "/opt/omni/bin/omnicheck -version" "HP Data Protector version"
          exec_command "/opt/omni/bin/omnicheck -patches -host $(hostname)" "HP Data Protector patches"
      fi
    fi

### Section about borg and borgmatic backups # added on 20240119 by edrulrd
    if [ $(which borgmatic 2>/dev/null) ] ; then # added /dev/null # modified on 20240202 by edrulrd
      dec_heading_level
      paragraph "Borg backups"
      inc_heading_level
      exec_command "cat ~root/.config/borgmatic/config.yaml 2>/dev/null | grep -vE '^ *#|^ *$'" "Borgmatic backup configuration"
      exec_command "borgmatic -l --syslog-verbosity=-1 -c ~root/.config/borgmatic/config.yaml 2>/dev/null" "List of borg backups"
    fi

### new stuff with 2.83 by Dusan // # changed 20140319 by Ralph Roth
PUPPETEXE=$(which puppet  2>/dev/null)
if [ -x "${PUPPETEXE}" ] # modified on 20201006 by edrulrd
then
  ##############################################################################
  ###  Puppet settings
  ###  Made by Dusan.Baljevic@ieee.org ### 12.03.2014, # changed 20140425 by Ralph Roth, # changed 20140428 by Dusan, backported from 2.90, 2.91
  ###  Updated by Dusan.Baljevic@ieee.org ### 24.12.2017 to include Puppet 5
  dec_heading_level
  paragraph "Puppet Configuration Management System"
  inc_heading_level
  exec_command "ps -ef | grep -E 'puppetmaster[d]|puppet maste[r]'" "Active Puppet Master (prior to version 5)"
  exec_command "ps -ef | grep -E 'puppet[d]'" "Active Puppet Client (prior to version 5)"
  exec_command "puppetca -l -a" "Puppet certificates (prior to version 5)"
  exec_command "ps -ef | grep -E 'puppetserve[r]'" "Active Puppet Master (version 5)"
  exec_command "ps -ef | grep -E 'puppet agen[t]'" "Active Puppet Client (version 5)"
  exec_command "${PUPPETEXE} ca list --all" "Puppet certificates (version 5)"
  exec_command "${PUPPETEXE} -V" "Puppet Client agent version"
  exec_command "${PUPPETEXE} master status" "Puppet Server status"
  exec_command "${PUPPETEXE} module list" "Puppet modules"
  exec_command "${PUPPETEXE} facts" "Puppet facts"
  exec_command "${PUPPETEXE} describe --list" "Puppet known types"

  PUPPETCHK=$(${PUPPETEXE} help | awk '$1 == "config" {print}')
  if [ "${PUPPETCHK}" ] ; then
    exec_command "${PUPPETEXE} config print all" "Puppet configuration"
    exec_command "${PUPPETEXE} config print modulepath" "Puppet configuration module paths"
  fi

  # gdha - 16/Nov/2015 - added TIMEOUTCMD - issue #95
  exec_command "${TIMEOUTCMD} 60 ${PUPPETEXE} resource user" "Users in Puppet Resource Abstraction Layer (RAL)"
  exec_command "${PUPPETEXE} resource package" "Packages in Puppet Resource Abstraction Layer (RAL)"
  # SUSE-SU-2014:0155-1 # seems to crash plain installed servers, puppet not configured ## changed 20140429 by Ralph Roth
  # Bug References: 835122,853982 - CVE References: CVE-2013-4761 - puppet-2.6.18-0.12.1
  #exec_command "/usr/bin/puppet resource service" "Services in Puppet Resource Abstraction Layer (RAL)"
fi # puppet

if  [ -x /opt/chef-server/embedded/bin/knife ]
then
  ###  Chef settings
  ###  Made by Dusan.Baljevic@ieee.org ### 16.03.2014
  dec_heading_level
  paragraph "Chef Configuration Management System"
  inc_heading_level
  [ -x /opt/chef-server/bin/chef-server-ctl ] && exec_command "/opt/chef-server/bin/chef-server-ctl test" "Chef Server"
  [ -x /opt/chef-server/embedded/bin/knife ] && exec_command "/opt/chef-server/embedded/bin/knife list -R /" "Chef full status"
  [ -x /opt/chef-server/embedded/bin/knife ] && exec_command "/opt/chef-server/embedded/bin/knife environment list -w" "Chef list of environments"
  [ -x /opt/chef-server/embedded/bin/knife ] && exec_command "/opt/chef-server/embedded/bin/knife client list" "Chef list of registered API clients"
  [ -x /opt/chef-server/embedded/bin/knife ] && exec_command "/opt/chef-server/embedded/bin/knife cookbook list" "Chef list of registered cookbooks"
  [ -x /opt/chef-server/embedded/bin/knife ] && exec_command "/opt/chef-server/embedded/bin/knife data bag list" "Chef list of data bags"
  [ -x /opt/chef-server/embedded/bin/knife ] && exec_command "/opt/chef-server/embedded/bin/knife diff" "Chef differences between local chef-repo and files on server"
  [ -x /opt/chef-server/embedded/bin/chef-client ] && exec_command "/opt/chef-server/embedded/bin/chef-client -v" "Chef Client"
fi

if  [ -x /usr/lpp/mmfs/bin/mmlscluster ]
then
  ###  IBM GPFS clusters
  ###  Made by Dusan.Baljevic@ieee.org ### 24.12.2017
  dec_heading_level
  paragraph "IBM GPFS Clustering"
  inc_heading_level
  [ -x /usr/lpp/mmfs/bin/mmlscluster ] && exec_command "/usr/lpp/mmfs/bin/mmlscluster" "GPFS cluster status"
  [ -x /usr/lpp/mmfs/bin/mmlsconfig ] && exec_command "/usr/lpp/mmfs/bin/mmlsconfig" "GPFS config"
  [ -x /usr/lpp/mmfs/bin/mmfsenv ] && exec_command "/usr/lpp/mmfs/bin/mmfsenv" "GPFS environment"
  [ -x /usr/lpp/mmfs/bin/mmdiag ] && exec_command "/usr/lpp/mmfs/bin/mmdiag --config" "GPFS complete configuration status"
  [ -x /usr/lpp/mmfs/bin/mmlsnode ] && exec_command "/usr/lpp/mmfs/bin/mmlsnode -a" "GPFS node status"
  [ -x /usr/lpp/mmfs/bin/mmlsnsd ] && exec_command "/usr/lpp/mmfs/bin/mmlsnsd -a" "GPFS Network Shared Disk (NSD) status"
  [ -x /usr/lpp/mmfs/bin/mmlsfs ] && exec_command "/usr/lpp/mmfs/bin/mmlsfs all" "GPFS file system status"
  [ -x /usr/lpp/mmfs/bin/mmlsmount ] && exec_command "/usr/lpp/mmfs/bin/mmlsmount all -L" "GPFS mount status"
  [ -x /usr/lpp/mmfs/bin/mmlslicense ] && exec_command "/usr/lpp/mmfs/bin/mmlslicense -L" "GPFS licenses"
  [ -x /usr/lpp/mmfs/bin/mmhealth ] && exec_command "/usr/lpp/mmfs/bin/mmhealth node show --verbose" "GPFS node health status"
  [ -x /usr/lpp/mmfs/bin/mmhealth ] && exec_command "/usr/lpp/mmfs/bin/mmhealth cluster show" "GPFS cluster health status"
  [ -x /usr/lpp/mmfs/bin/mmhealth ] && exec_command "/usr/lpp/mmfs/bin/mmhealth thresholds list" "GPFS thresholds"
  [ -x /usr/lpp/mmfs/bin/mmlsnode ] && exec_command "/usr/lpp/mmfs/bin/mmlsnode -N waiters -L" "GPFS waiters"
  [ -x /usr/lpp/mmfs/bin/mmdiag ] && exec_command "/usr/lpp/mmfs/bin/mmdiag --network" "GPFS mmdiag network"
  [ -x /usr/lpp/mmfs/bin/mmnetverify ] && exec_command "/usr/lpp/mmfs/bin/mmnetverify connectivity -N all -T all" "GPFS network verification"
fi

# Added by Dusan Baljevic (dusan.baljevic@ieee.org) on 24 December 2017
#
SSSDCONF="/etc/sssd/sssd.conf"
if [ -s "${SSSDCONF}" ] ; then
    dec_heading_level
    paragraph "System Security Services Daemon (SSSD)"
    inc_heading_level
    exec_command "cat ${SSSDCONF}" "SSSD configuration"
    exec_command "realm list" "List enrollments in realms"
    [ -x /usr/bin/systemctl ] && exec_command "/usr/bin/systemctl status sssd" "Systemd SSSD status"
    exec_command "getent passwd" "List all users"  ## Fix-Typing mistake result in invalid command (Issue #175)
    exec_command "getent group" "List all groups"
    [ -x /sbin/sssctl ] && exec_command "/sbin/sssctl config-check" "SSSD configuration verification"
    [ -x /sbin/sssctl ] && exec_command "/sbin/sssctl domain-list" "SSSD domain list"
    [ -x /sbin/sssctl ] && exec_command "/sbin/sssctl domain-list | xargs -n1 /sbin/sssctl domain-status" "SSSD domain status"
fi

# removed duplicate GPFS Clustering section # modified on 20240119 by edrulrd
# removed duplicate SSSD Status section # modified on 20240119 by edrulrd

# this may need reworking - works only if CFEngine agent is installed. # changed 20140319 by Ralph Roth
if [ -x /var/cfengine/bin/cfagent ]
then
  ### new stuff with 2.85 by Dusan
  ##############################################################################
  ###  CFEngine settings
  ###  Made by Dusan.Baljevic@ieee.org ### 19.03.2014
  dec_heading_level
  paragraph "CFEngine Configuration Management System"
  inc_heading_level
  exec_command "ps -ef | grep -E 'cfserv[d]|cf-server[d]'" "Active CFEngine Server"
  exec_command "ps -ef | grep -E 'cfagen[t]|cf-agen[t]'" "Active CFEngine Agent"
  [ -x /var/cfengine/bin/cfagent ] && exec_command "/var/cfengine/bin/cfagent -V" "CFEngine v2 Agent version"
  [ -x /var/cfengine/bin/cfagent ] && exec_command "/var/cfengine/bin/cfagent -p -v" "CFEngine v2 classes"
  [ -x /var/cfengine/bin/cfagent ] && exec_command "/var/cfengine/bin/cfagent --no-lock --verbose --no-splay" "CFEngine v2 managed client status"
  [ -x /var/cfengine/bin/cfagent ] && exec_command "/var/cfengine/bin/cfagent -n" "CFEngine v2 pending actions for managed client (dry-run)"
  [ -x /var/cfengine/bin/cfshow ] && exec_command "/var/cfengine/bin/cfshow --active" "CFEngine v2 dump of active database"
  [ -x /var/cfengine/bin/cfshow ] && exec_command "/var/cfengine/bin/cfshow --classes" "CFEngine v2 dump of classes database"
  [ -x /var/cfengine/bin/cf-serverd ] && exec_command "/var/cfengine/bin/cf-serverd --version" "CFEngine v3 Server version"
  [ -x /var/cfengine/bin/cf-agent ] && exec_command "/var/cfengine/bin/cf-agent --version" "CFEngine v3 Agent version"
  [ -x /var/cfengine/bin/cf-report ] && exec_command "/var/cfengine/bin/cf-report -q --show promises" "CFEngine v3 promises"
  [ -x /var/cfengine/bin/cf-promises ] && exec_command "/var/cfengine/bin/cf-promises -v" "CFEngine v3 validation of policy code"
  [ -x /var/cfengine/bin/cf-agent ] && exec_command "/var/cfengine/bin/cf-agent -n" "CFEngine v3 pending actions for managed client (dry-run)"
fi # CFEngine

##############################################################

####BACKPORT####
## SAP stuff # changed 20140213 by Ralph Roth, backported from Gratien SAP-Info collector 12.04.2015,Ralph Roth
# -----------------------------------------------------------------------------
if [ -x /usr/sap/hostctrl/exe/saphostexec ]
then
    dec_heading_level
    paragraph "SAP Information"
    inc_heading_level
    exec_command "/usr/sap/hostctrl/exe/saphostexec -version" "Installed SAP Components"
    exec_command "/usr/sap/hostctrl/exe/saphostexec -status" "Status SAP"		### Ralph Roth, 12.04.2015
    exec_command "/usr/sap/hostctrl/exe/lssap -F stdout" "SAP - lssap"	                ### FIX?: issue #131
    exec_command "ps fax | grep -i ' pf=/' | grep -v grep" "Active SAP Processes" 	### CHANGED ### 20150412 by Ralph Roth
fi ## SAP
## independent of installed SAP stuff
if [ -x /usr/sbin/saptune ]  ## only SLES12SP2+, Ralph Roth, 23.05.2018
then
    exec_command "/usr/sbin/saptune note list; /usr/sbin/saptune solution list" "saptune: Applied Solutions and Notes"
    exec_command "/usr/sbin/saptune solution verify" "saptune: Verification Against Recommended Settings"
fi

# SAP HANA in-depth investigation by Gratien D'haese - 10 May 2016 - issue #109
if [ -x /usr/sap/hostctrl/exe/lssap ]
then
    /usr/sap/hostctrl/exe/lssap -F stdout | grep $(uname -n) | grep -q HDB              ### FIX?: issue #131
    if [ $? -eq 0 ] ; then
        # SAP HANA present
        dec_heading_level
        paragraph "SAP HANA Information"
        inc_heading_level
        /usr/sap/hostctrl/exe/lssap -F stdout| awk -F"|" '{ if ($0 ~/\// ) print tolower($1)"adm " $2}' | while read  hdbadm sapnr
        do
            exec_command "su - ${hdbadm} -c 'HDB proc'" "SAP HANA processes"
            exec_command "su - ${hdbadm} -c \"sapcontrol -nr ${sapnr} -function GetProcessList\"" "SAP HANA ProcessList"
            exec_command "su - ${hdbadm} -c 'python exe/python_support/systemReplicationStatus.py'" "SAP HANA Replication"
            exec_command "su - ${hdbadm} -c 'hdbnsutil -sr_state'" "SAP HANA System Replication State"
        done
    fi
fi
##

###########################################################################
# { MC/Serviceguard || changed/added 28.01.2004 by Ralph Roth }
  if [ -r /etc/cmcluster.conf ] ; then
      dec_heading_level
      paragraph "Serviceguard/SGLX"
      inc_heading_level
      . ${SGCONFFILE:=/etc/cmcluster.conf}   # get env. setting, rar 12.05.2005
      PATH=${PATH}:${SGSBIN}:$SGLBIN
      exec_command "cat ${SGCONFFILE:=/etc/cmcluster.conf}" "Cluster Config Files"
      # gdha - 17/Nov/2015 - what does not exist on Linux
      #exec_command "what  ${SGSBIN}/cmcld|head; what  ${SGSBIN}/cmhaltpkg|head" "Real Serviceguard Version"  ##  12.05.2005, 10:07 modified by Ralph Roth
      exec_command "cmversion" "Serviceguard Version"  ## gdha - 17/Nov/2015
      exec_command "cmquerycl -v" "Serviceguard Configuration"
      exec_command "cmviewcl -v" "Serviceguard Nodes and Packages"
      exec_command "cmviewconf" "Serviceguard Cluster Configuration Information"
      exec_command "${TIMEOUTCMD} 60 cmscancl -s" "Serviceguard Scancl Detailed Node Configuration"
      exec_command "netstat -in" "Serviceguard Network Subnets"
      exec_command "netstat -a |fgrep hacl" "Serviceguard Sockets"
      exec_command "ls -l ${SGCONF}" "Files in ${SGCONF}"
  fi

  dec_heading_level
  paragraph "Cluster Services"
  inc_heading_level

######## SLES 11 SP1 Pacemaker stuff ########## Mittwoch, 16. March 2011 ##### Ralph Roth ####
  [ -x /usr/sbin/corosync-cfgtool ] && exec_command "/usr/sbin/corosync-cfgtool -s;corosync -v" "Corosync TOTEM Status/Active Rings"
  # see also:  corosync-objctl runtime.totem.pg.mrp.srp.members
  [ -x /usr/sbin/corosync-objctl ] && exec_command "/usr/sbin/corosync-objctl" "Corosync Object Database" # changed 20140507 by Ralph Roth

  if [ -x /usr/sbin/crm ] # pacemaker #
  then
      exec_command "/usr/sbin/crm_mon -rnA1" "Cluster Configuration"  		## 281113, rr
      exec_command "/usr/sbin/crm -D plain configure show" "Cluster Configuration"
      exec_command "/usr/sbin/crm -D plain status" "Cluster Status"
  fi

  [ -x /usr/sbin/clusterstate ] && exec_command "/usr/sbin/clusterstate --all" "Status of pacemaker HA cluster" ##  04.04.2012, 14:27 modified by Ralph Roth #* rar *#
  [ -x /usr/sbin/crm_simulate ] && exec_command "/usr/sbin/crm_simulate -LsU" "Current Cluster status, scores and utilization" ## changed 20140507 by Ralph Roth

  # only if ClusterTools2/SLES11 HAE are installed #  04.04.2012, modified by Ralph Roth #* rar *#
  [ -x /usr/sbin/grep_cluster_patterns ] && exec_command "/usr/sbin/grep_cluster_patterns --show"  "Output of grep_cluster_patterns"
  for i in  grep_error_patterns  grep_cluster_transition cs_show_scores cs_list_failcounts
  do
      [ -x /usr/sbin/${i} ] && exec_command "${i}" "ClusterTool2: Output of ${i}"
  done; unset i

######## RHEL 5.x CRM stuff ######## 18. March 2011 #### Ralph Roth ####
  if [ -x /usr/sbin/cman_tool ]
  then
      exec_command "/usr/sbin/cman_tool status"   "Cluster Resource Manager Status"
      exec_command "/usr/sbin/cman_tool nodes"    "Cluster Resource Manager Nodes"
      exec_command "/usr/sbin/cman_tool services" "Cluster Resource Manager Services"
  fi

####### Red Hat Cluster Suite configuration  #  04.07.2011, modified by Ralph Roth #* rar *#
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

# moved the end of the CFG_APPLICATIONS section to below the Oracle section # modified on 20240119 by edrulrd

##########################################################################
  ##
  ## Display Oracle configuration if applicable
  ## Begin Oracle Config Display
  ## 31jan2003 it233 FRU U.Frey

  if [ -s /etc/oratab ] ; then    # exists and >0

    dec_heading_level
    paragraph "Oracle Configuration"
    inc_heading_level

    exec_command "grep -vE '^#|^$|:N' /etc/oratab " "Configured Oracle Databases Startups"        #  27.10.2011, modified by Ralph Roth #* rar *#

    ##
    ## Display each Oracle initSID.ora File
    ##     orcl:/home/oracle/7.3.3.0.0:Y
    ##     leaveup:/home/oracle/7.3.2.1.0:N

    for  DB in $(grep ':' /etc/oratab|grep -v '^#'|grep -v ':N$')                                 #  27.10.2011, 14:58 modified by Ralph Roth #* rar *#
         do
           Ora_Home=`echo ${DB} | awk -F: '{print $2}'`
           Sid=`echo ${DB} | awk -F: '{print $1}'`
           Init=${Ora_Home}/dbs/init${Sid}.ora
           if [ -r "${Init}" ]
           then
              exec_command "cat ${Init}" "Oracle Instance ${Sid}"
           else
              AddText "WARNING: obsolete entry ${Init} in /etc/inittab for SID ${Sid}!"
           fi
         done
    dec_heading_level
  fi

dec_heading_level

fi  #"${CFG_APPLICATIONS}"# <m>  23.04.2008 -  Ralph Roth # included Oracle within the Applications section # modified on 20240119 by edrulrd

###
##############################################################################
###   HP Proliant Server LINUX Logfiles from HP tools and or the HP PSP.   ###
###   Made by Jeroen.Kleen@hp.com EMEA ISS Competence Center Engineer      ###

if [ "${CFG_HPPROLIANTSERVER}" != "no" ]
then # else skip to next paragraph

# @(#) Below follows HP Proliant specific stuff mainly written by Jeroen Kleen
# --=----------------------------------------------------------------------=---
#

    paragraph "hp ProLiant Server Log- and configuration Files"
    inc_heading_level

    temphp=${TMP_DIR}/cfg2html_temp
    if [ ! -d ${temphp} ] ; then
         mkdir ${temphp}
    fi

    if [ -x /opt/hp/hpdiags/hpdiags ] ; then
        /opt/hp/hpdiags/hpdiags -v 5 -o ${temphp}/hpdiagsV5.txt -f -p >/dev/null
    fi

    if [ -x /opt/hp/hp_fibreutils/hp_system_info ] ; then
                rm /tmp/system_info*.tar.gz -f
                /opt/hp/hp_fibreutils/hp_system_info > /dev/null
                cp /tmp/system_info*.tar.gz ${temphp}
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
    if [ -x "${CPQACUXE}" ] ; then
            ${CPQACUXE} -c ${temphp}/cpqacuxe.cfg
    fi

    HPADUCLI=$(which hpaducli 2>/dev/null )
    if [ -x "${HPADUCLI}" ] ; then
            ${HPADUCLI} -f ${temphp}/ADUreport.txt -r
    fi

    # Where is hponcfg installed? /opt/hp/tools ???
    if [ -x /usr/lib/hponcfg ] ; then
        /usr/lib/hponcfg -a -w ${temphp}/ilo.cfg  	# closes issue #31 # changed 20131218 by Ralph Roth
    fi
    if [ -x /sbin/hponcfg ] ; then
        /sbin/hponcfg  -a -w ${temphp}/ilo.cfg  		# closes issue #31 # changed 20131218 by Ralph Roth
    fi

    if [ -x ${DMIDECODE} ] ;  then
        exec_command "${DMIDECODE} | grep Product" "HP Proliant Server model Information taken from dmidecode"
    fi

    SURVEY=$(which survey 2>/dev/null)
    if [ -x "${SURVEY}" ] ; then
            exec_command "${SURVEY} -v 5 -t" "Classic Survey output -v 5"
    fi

    if [ -x /sbin/hplog ] ; then
            exec_command "hplog -t -f -p" "Current Thermal Sensor, Fan and Power data"
            # RE: [cfg2html] cfg2html hangs on Oracle Linux 6.7 --> I fixed the problem. It was giving the error “FAILURE Event log buffer is too small”
            # when running the “hplog –v” command so I just commented out this command line in the cfg2html_linux script. 07.09.2015
	    # gdha - 16/Nov/2015 - added TIMEOUTCMD (defined in default.conf) - issue #92
            exec_command "${TIMEOUTCMD} 60 hplog -v" "Proliant Integrated Management Log"
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
    if [ -x "${HPASMCLI}" ] ; then
### # [20200319] {jcw} See if I can put this as a multi-line command.
            ${HPASMCLI} -s "show asr; show boot; show dimm; show f1; show fans; show ht; show ipl; show name; show powersupply; show pxe; show serial bios; show serial embedded; show serial virtual; show server; show temp; show uid; show wol" >${temphp}/hpasmcliOutput.txt
            exec_command "cat ${temphp}/hpasmcliOutput.txt" "HP ASM CLI command line output"
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

    if [ -e ${temphp}/ilo.cfg ] ; then
            exec_command "cat ${temphp}/ilo.cfg" "iLO configuration file captured via HPONCFG"
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
                        cp /var/log/messages ${temphp} > /dev/null
                        cp /var/log/messages.1 ${temphp} > /dev/null
                        cp /var/log/messages.2 ${temphp} > /dev/null
    fi

    if [ -e /var/log/boot.log ] ; then
            exec_command "cat /var/log/boot.log" "boot.log logfile (older boot.log logfiles in TARBALL)"
            cp /var/log/boot.log.1 ${temphp} > /dev/null
            cp /var/log/boot.log.2 ${temphp} > /dev/null
    fi

    if [ -e /var/log/dmesg ] ; then
            exec_command "cat /var/log/dmesg" "dmesg logfile /var/log/dmesg"
    fi

    if [ -e /var/log/acpid ] ; then
            exec_command "cat /var/log/acpid" "ACPID power boot / reboot log"
    fi

#   if [ -e ${temphp}/ADUreport.txt ] ; then
#           exec_command "cat ${temphp}/ADUreport.txt" "Array Diagnostic Utility report is included in the TAR ball as a single file"
#   fi

    if [ -e ${temphp}/cpqacuxe.cfg ] ; then
            exec_command "cat ${temphp}/cpqacuxe.cfg" "cpqacuxe configuration file (SmartArray configuration)"
    fi

    if [ -e /tmp/hpsum ] ; then ## bugfixed 29052013 by Ralph Roth after an ER by Henrik Rosqvist
            echo "Generating HPSUM reports"
            /tmp/hpsum /report /veryv > /dev/null
            /tmp/hpsum /inventory_report /veryv > /dev/null
            /tmp/hpsum /firmware_report /veryv > /dev/null
            cp /tmp/discovery.xml ${temphp} > /dev/null
            cp /tmp/HPSUM_* ${temphp} > /dev/null
            cp /tmp/hp_sum/*.trace ${temphp} > /dev/null
            cp /tmp/hp_sum/InventoryResults.xml ${temphp} > /dev/null
    fi

    if [ -d /var/hp/log ] ; then
            cp /var/hp/log/* ${temphp}
            cp /var/hp/log/localhost/* ${temphp}
            cp /var/log/hp_sum/* ${temphp}
    fi

    if [ -d /opt/hp/hpdiags ] ; then
            cp /opt/hp/hpdiags/survey* ${temphp}
    fi

    if [ -d /opt/hp/hp-fc-enablement/elxreport.sh ] ; then
            /opt/hp/hp-fc-enablement/elxreport > /dev/null
            cp /tmp/elxreport.sh* ${temphp}
    fi

    if [ -d /opt/hp/hp-fc-enablement/ql-hba-collect-1.8/ql-hba-collect.sh ] ; then
            /opt/hp/hp-fc-enablement/ql-hba-collect-1.8/ql-hba-collect.sh > /dev/null
            cp /tmp/QLogicDiag* ${temphp}
    fi

    if [ -x /usr/local/bin/vcsu ] ; then
        echo "HP Virtual Connect Support Utility (VCSU) detected; get if needed the VC logs"
        echo " collected via /usr/local/bin/vcsu -a collect. and with vcsu -a -supportdump and"
        echo " execute cfg2html again to get all the logs included automatically." # modified phrasing # modified on 20240119 by edrulrd
        cp /usr/local/bin/*.txt ${temphp}
        cp /usr/local/bin/vcsu*.log ${temphp}
    fi

    if [ -e /opt/netxen ] ; then
        echo "NetXen diagnostic utility detected; to get full NetXEN diag output run command:"
        echo "/opt/netxen/nxudiag -i ethX (ethX is your eth adapter like eth0 / eth1)"  # added closing ')' # modified on 20240119 by edrulrd
    fi

    ###below partitioning and HPACUCLI is contributed by kgalal@gmail.com
    ## Changed 2011-09-05 Peter Boysen - Previous hpacucli commands was redundant.
    if [ -x /usr/sbin/hpacucli ] ; then
	export INFOMGR_BYPASS_NONSA=1  # see issue #25
#       exec_command "/usr/sbin/hpacucli controller all show" "HP SmartArray controllers Detected"   # added by jeroenkleen HP
#       exec_command "/usr/sbin/hpacucli controller all show status" "HP SmartArray controllers Detected with Status"
#       slotnum=`/usr/sbin/hpacucli controller all show | awk '{if($0!="")print $6}'`  # jkleen: this doesn't work (yet) for MSA1x000 controllers
#       exec_command "/usr/sbin/hpacucli controller slot=${slotnum} physicaldrive all show" "Physical Drives on SmartArray Controller"
#       exec_command "/usr/sbin/hpacucli controller slot=${slotnum} logicaldrive all show" "Logical Drives on SmartArray controller"
        exec_command "/usr/sbin/hpacucli ctrl all show config detail" "HP SmartArray controllers Detected"   # added by jeroenkleen HP # Changed 2011-09-05 Peter Boysen
        /usr/sbin/hpacucli controller all diag file=${temphp}/hpacucli_diag.txt          # Added 2011-09-05 Peter Boysen.
    fi

    disks=`/sbin/fdisk -l`
    if [ ! -z "${disks}" ] ; then
        exec_command "/sbin/fdisk -l" "Disk Partitions on Logical Drives"
    else
        disks=`cat /proc/partitions | awk '{if($4 ~ /\//)print $4}' |grep -v p`
        for adisk in ${disks} ; do
            exec_command "/sbin/fdisk -l /dev/${adisk}" "Disk Partitions - /dev/${adisk}"
        done
    fi

    ###above partitioning and HPACUCLI is contributed by kgalal@gmail.com

    exec_command "ls ${temphp}" "These files have been made or captured during CFG2html execution and should be in the zipped TARball"
    if [ -x "$(which hplog 2> /dev/null)" ] # modified on 20201113 by edrulrd
    then
      hplog -s INFO -l "CFG2HTML HP Proliant Server report successfully created"
    fi

    dec_heading_level


fi  # end of CFG_HPPROLIANTSERVER paragraph
###  END of HP Proliant Server Integration
###############################################################################
###



###
##############################################################################
###   Altiris ADL agent settings and logfiles
###   Made by Jeroen.Kleen@hp.com EMEA ISS Competence Center Engineer      ###

if [ "${CFG_ALTIRISAGENTFILES}" != "no" ]
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

if [ "${CFG_VMWARE}" != "no" ]
then # else skip to next paragraph
# checking if VMWare directory exist otherwise skip this section
  if [ -e /proc/vmware ] ; then

    paragraph "VMWare logfiles and settings"
    inc_heading_level
      exec_command "vmware -v" "VMWare Server version"
      echo "VMWare server detected. We will now start the vm-support script in case you" # wording changes # modified on 20240119 by edrulrd
      echo "need this vmware debugging file to send to VMWare support or other support teams." # wording changes # modified on 20240119 by edrulrd
      vm-support
      exec_command "ls -l esx-$(date -I).$$.tgz" "vm-support ticket generated in local directory if vm-support is installed." # changed cat to ls for tar file # modified on 20240119 by edrulrd
    dec_heading_level
  fi
fi  # end of CFG_VMWARE paragraph
##############################################################################

#
# execute custom plugins   -- anaumann 2009/07/10
#

if [ "${CFG_PLUGINS}" != "no" ];
then # else skip to next paragraph
    if [ -f ${CONFIG_DIR}/plugins ]; then
      paragraph "Custom plugins"

      # include plugin configuration
      . ${CONFIG_DIR}/plugins


      if [ -n "${CFG2HTML_PLUGIN_DIR}" -a -n "${CFG2HTML_PLUGINS}" ]; then
        # only run plugins when we know where to find them and at least one of them is enabled

        inc_heading_level

        if [ "${CFG2HTML_PLUGINS}" == "all" ]; then
          # include all plugins
          CFG2HTML_PLUGINS="$(ls -1 ${CFG2HTML_PLUGIN_DIR})"
        fi

        for CFG2HTML_PLUGIN in ${CFG2HTML_PLUGINS}; do
          if [ -f "${CFG2HTML_PLUGIN_DIR}/${CFG2HTML_PLUGIN}" ]; then
              . ${CFG2HTML_PLUGIN_DIR}/${CFG2HTML_PLUGIN}
              exec_command cfg2html_plugin "${CFG2HTML_PLUGINTITLE}"
          else
              AddText "Configured plugin ${CFG2HTML_PLUGIN} not found in ${CFG2HTML_PLUGIN_DIR}"
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

paragraph "Local files" # moved title so it's always generated # modified on 20240119 by edrulrd
if [ -f ${CONFIG_DIR}/files ] ; then
        inc_heading_level
        ## . ${CONFIG_DIR}/files -- not needed anymore to be sourced with the fix below/changed format
        ## FILES=`grep -vE '(^#|^ *$)' ${CONFIG_DIR}/files`   ## 25.08.2017 modified by Bernhard Keppel
        for i in $(grep -v ^# ${CONFIG_DIR}/files) # suggested fix by John Emmert , 2016/04 ## ${FILE}S
        do
                if [ -f ${i} ] ; then
                        exec_command "grep -vE '(^#|^ *$)' ${i}" "Contents of the file: ${i}"
                fi
        done; unset i
        dec_heading_level
fi
AddText "You can customize this paragraph by editing the file: ${CONFIG_DIR}/files" # always add this final statement # modified on 20240119 by edrulrd

dec_heading_level

close_html
###########################################################################
###########################################################################
######     Creating gzipped TAR File for all needed files together. Added by Jeroen Kleen HP EMEA ISS CC

if [ "${CFG_HPPROLIANTSERVER}" != "no" ]
then # else skip to next paragraph

 if [ -f ${OUTDIR}/${BASEFILE}.tar.gz ] ; then # added .gz appendage # modified on 20240119 by edrulrd
        rm ${OUTDIR}/${BASEFILE}.tar.gz # added .gz appendage # modified on 20240119 by edrulrd
 fi
echo " "
    echo "The following files are included in your gzipped tarball file:"
	ls -l ${temphp} # added file listing # modified on 20240119 by edrulrd
    tar -czf ${OUTDIR}/${BASEFILE}.tar.gz ${temphp}
    echo " "
    echo "The tar file can be mailed to your support supplier if needed"

fi  # end of CFG_HPPROLIANTSERVER (making tarball)
###########################################################################


# 1st end use of logger.
${_logger} "1st End of cfg2html-linux ${VERSION}"
_echo "\n"
line

# 2nd end use of logger.
${_logger} "2nd End of cfg2html-linux ${VERSION}"
rm -f core > /dev/null

########## remove the error.log if it has size zero #######################
[ ! -s "${ERROR_LOG}" ] && rm -f ${ERROR_LOG} 2> /dev/null

rm -rf /tmp/cfg2html.???????????????  # [20200312] {jcw} Pattern of seemingly hangers-on directories after a run. # adjusted file name # modified on 20240119 by edrulrd

####################################################################

# [20200311] {jcw} Added sync's and sane exit
sync;sync;sync
exit 0
