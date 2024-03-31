# shellcheck disable=SC2034,SC2148,SC2016
# (note - shellcheck directive needs to be at the very top to be effective over the whole file) # added on 20240322 by edrulrd
# SC2034 - variable appears to be used
# SC2148 - we are shell agnostic
# SC2016 - Don't complain about single quotes in awk command
# @(#) $Id: linux-functions.sh,v 6.15 2020/06/17 21:24:05 ralph Exp $
#     Further modified by Joe Wulf:  20200402@1737.
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4
# coding: utf-8 -*- cfg2html
# Common functions for the Linux part of cfg2html
# [20200310] {jcw} Closed up blank lines.


function HostNames {
    # uname -a                # [20200327] {jcw} Subordinated this and added the following if-check.

    if [ "$(which dnsdomainname 2>/dev/null)" ]; then
         if [ "$(dnsdomainname)" ]; then
              echo "DNS Domainname  =  $(dnsdomainname 2>&1)"
         else
              echo 'DNS Domainname  =  <no result returned/null>'
         fi
	 # -v option on dnsdomainname not available everywhere, -V sometimes used # modified on 20201021 by edrulrd
         if dnsdomainname -v 1> /dev/null 2>&1 # don't write out anything, only get return code
           then
             echo "DNS Domainname version  = $(dnsdomainname -v 2>&1)"
           else
             echo "DNS Domainname Version  = $(dnsdomainname -V 2>&1)"
         fi
    else
         echo 'DNS Domainname  ==  <RPM/binary not installed>'
    fi; echo

    which domainname 2>/dev/null 1>&2 &&
    echo  "NIS Domainname     = $(domainname -y 2>/dev/null)"
    echo  "Hostname (short)   = $(hostname -s)"
    echo  "Hostname (FQDN)    = $(hostname -f)"
    echo  "Hostname (aliases) = $(hostname -a)"
    echo  "Hostname (domain)  = $(hostname -d)"
    echo  "Hostname (IPaddr)  = $(hostname -i)"
    #echo  "Hostname (all IPs) = $(hostname -I)" ## FIXME, not available under SLES1x
}

function posixversion {
    # wie findet man das bei Linux raus?
    #echo "POSIX Version:  \c"; getconf POSIX_VERSION
    #echo "POSIX Version:  \c"; getconf POSIX2_VERSION
    #echo "X/OPEN Version: \c"; getconf XOPEN_VERSION
    echo "LANG setting:   ""${LANG}"
    [ -r /etc/sysconfig/i18n ] && cat /etc/sysconfig/i18n
}

function identify_linux_distribution {

## RR: Maybe easier approach: lsb_release -a

    # check Linux distribution
    if [ -f /etc/gentoo-release ] ; then
        distrib="$(head -1 /etc/gentoo-release)"
        GENTOO="yes"
    else
        GENTOO="no"
    fi

    if [ -f /etc/slackware-version ] ; then
        distrib="$(cat /etc/slackware-version)"
        SLACKWARE="yes"
    else
        SLACKWARE="no"
    fi
    if [ -f /etc/debian_version ] ; then
        if [ -f /etc/lsb-release ] ; then
            UBUNTU_VERSION=$(awk -F\" '/DISTRIB_DESCRIPTION/ {print $2}' /etc/lsb-release)
        fi
        if  [ "${UBUNTU_VERSION}" ]; then
            distrib="${UBUNTU_VERSION}"
            UBUNTU="yes"
        else
            distrib="Debian GNU/Linux Version $(cat /etc/debian_version)"
            UBUNTU="no"
        fi
        DEBIAN="yes"
    else
        DEBIAN="no"
    fi

## This is obsolete/deprecated!
    if [ -f /etc/SuSE-release ] ; then
        distrib="$(head -1 /etc/SuSE-release)"
        SUSE="yes"
    else
        SUSE="no"
    fi

    if [ -f /etc/mandrake-release ] ; then
        distrib="$(head -1 /etc/mandrake-release)"
        MANDRAKE="yes"
    else
        MANDRAKE="no"
    fi

    if [ -f /etc/redhat-release ] ; then
        distrib="$(head -1 /etc/redhat-release)"
        REDHAT="yes"
    else
        REDHAT="no"
    fi

    # MiMe: for UnitedLinux
    if [ -f /etc/UnitedLinux-release ] ; then
        distrib="$(head -1 /etc/UnitedLinux-release)"
        UNITEDLINUX="yes"
    else
        UNITEDLINUX="no"
    fi

    # M.Weiller, LUG-Ottobrunn.de, 2013-02-04
    if [ -f /etc/arch-release ] ; then
        distrib="$(head -1 /etc/os-release | cut -f2 -d'"')"
        ARCH="yes"
    else
        ARCH="no"
    fi

    # left-overs - other tests can be added later
    if [ -f /etc/system-release ] ; then
        distrib="$(head -1 /etc/system-release)"
        echo "${distrib}" | grep -q -i "Amazon" && AWS="yes" || AWS="no"
    fi

    if [ -f /etc/os-release ] ; then  ## rr, 20200617
        distrib="$(grep PRETTY_NAME= /etc/os-release | awk -F"=" '{ print $2; }' | tr -d "\"")"
        grep -q SUSE /etc/os-release && SUSE=yes
    fi

    if [ "$(uname -a | grep -ic synology)" -gt 0 ] ; then # a Synology NAS # added on 20240322 by edrulrd
        distrib="$(uname -a | awk '{print $(NF-1) " " $NF }')"
    fi

    ### TODO: ####
    # AWS backport from cfg2html 2.81 #
}

function topFDhandles {
    echo "Nr.OpenFileHandles  PID  Command+Commandline"
    (find /proc -maxdepth 1 -type d -exec basename '{}' \; | awk '{if($1+0==0) print " "; else system("echo $(ls /proc/"$1+0"/fd | wc -l) \"\t\"  PID="$1" \"\t\"  CMD=$(strings /proc/"$1+0"/cmdline)")}' | sort -nr | head -25) 2> /dev/null # added working tabs # modified on 20240322 by edrulrd
}

function DoSmartInfo {
    ## Bundled by Ralph Roth to avoid massive exec_command calls under Debian Linux!
    #  18.07.2011, 14:40 modified by Ralph Roth #* rar *#

    echo "Overview:"
    ${SMARTCTL} --scan #  18.07.2011, 14:58 modified by Ralph Roth #* rar *# # modified on 20240119 by edrulrd

    echo ""

    echo "Details:"
    # PHYS_DRIVES=$(${FDISKCMD} -l 2>&1 | sort -u | \
        # ${GREPCMD} "^Disk " | \
        # ${GREPCMD} -vE "md[0-9]|identifier:|doesn't contain a valid" | \
        # ${SEDCMD} -e "s/:.*$//" |  \
        # ${AWKCMD} '{print $2}')
    PHYS_DRIVES=$( ${SMARTCTL} --scan | ${AWKCMD} '{print $1}') # only use drives smartctl knows about # replaced above section on 20240119 by edrulrd

    for drive in ${PHYS_DRIVES}
    do
        echo "---- Drive=${drive} --------------------------------------------------------------------------------" | cut -c1-74 # make the sections more visible # modified on 20240119 by edrulrd
        echo "# ${SMARTCTL} -P show ${drive}" # show the command in the reports # added on 20240119 by edrulrd
        ${SMARTCTL} -P show "${drive}"     # "SMART features of drive $drive"
        echo "" # added on 20240119 by edrulrd

        echo "# ${SMARTCTL} --info ${drive}" # show the command in the reports # added on 20240119 by edrulrd
        ${SMARTCTL} --info "${drive}"      # "SMART information of drive $drive"

        echo "# ${SMARTCTL} --xall ${drive}" # show the command in the reports  # added on 20240119 by edrulrd
        ${SMARTCTL} --xall "${drive}"      # "SMART extended information of drive $drive"
        echo ""
    done
}

function mcat {
    echo "--- ${1}"
    cat "${1}"
}

function ProgStuff {
    for i in libtoolize libtool automake autoconf autoheader g++ gcc make flex sed
    do
        echo
        (which "${i}" 2> /dev/null) && (echo -n "${i}: ";${i} --version | head -1)  #  09.01.2008, 14:49 modified by Ralph Roth
    done
}

function display_ext_fs_param {
    #function used in FILESYS added 2011.09.02 by Peter Boysen
    # fixes, changed 20140924 by Ralph Roth
    # function extended to display filesystem paramaters on all ext2, 3 or 4 filesystems, whether they are mounted or not # modified on 20240119 by edrulrd
    if [ "$(which lsblk 2>/dev/null)" ] && lsblk -o PATH 2>/dev/null 1>&2 # added on 20240119 by edrulrd # old versions don't have PATH option # modified on 20240202 by edrulrd
    then
      for fs in $(lsblk -ln -o PATH,FSTYPE | grep -w "ext[2-4]" | awk '{print $1}') # added on 20240119 by edrulrd
      do
        echo "Dumping: ""${fs}" # added on 20240119 by edrulrd
        dumpe2fs -h "${fs}"  2>/dev/null   ## -> dumpe2fs 1.41.3 (12-Oct-2008) # added on 20240119 by edrulrd
      done
    else
      if [ "$(which blkid 2>/dev/null)" ] && blkid | grep -wE 'ext[2-4]' | cut -d: -f1 2>/dev/null 1>&2 # try getting all ext2-4 filesystems using blkid if available # added on 20240202 by edrulrd
      then
        for fs in $(blkid | grep -wE 'ext[2-4]' | cut -d: -f1 | sort -u) # added on 20240202 by edrulrd
        do
          echo "Dumping: ""${fs}" # added on 20240202 by edrulrd
          dumpe2fs -h "${fs}"  2>/dev/null   ## -> dumpe2fs 1.41.3 (12-Oct-2008) # added on 20240202 by edrulrd
        done
      else
        echo "Hint: lsblk and/or blkid commands are old or not available, showing mounted filesystems only" # added on 20240119 by edrulrd # modified on 20240202 by edrulrd
        grep -w "ext[2-4]" /proc/mounts | awk '{print $1}' | sort -u | while read -r fs # if we don't have blk cmds, only check mounted filesystems # modified on 20240119 by edrulrd
        do
          echo "Dumping: ""${fs}"
          dumpe2fs -h "${fs}"  2> /dev/null   ## -> dumpe2fs 1.41.3 (12-Oct-2008)
          ##TODO## better: tune2fs -l  ??? rr, 20140929
          echo
        done
      fi
    fi
}

function display_xfs_fs_param {
    #function used in FILESYS added 20240202 by edrulrd
    # TODO: Needs re-write on Debian 12 (at least)
    if [ "$(which lsblk 2>/dev/null)" ] && lsblk -o PATH 2>/dev/null 1>&2 # added on 20240119 by edrulrd # old versions don't have PATH option # modified on 20240202 by edrulrd
    then
      for fs in $(lsblk -ln -o PATH,FSTYPE | grep -w xfs | awk '{print $1}') # added on 20240119 by edrulrd
      do
        echo "Dumping: ${fs}" # added on 20240119 by edrulrd
        xfs_db -r -c sb -c print "${fs}" # print superblock info,       ## /usr/share/cfg2html/lib/linux-functions.sh: line 222: 11558 Illegal instruction     xfs_db -r -c sb -c print ${fs}
        echo
      done
    else
      if [ "$(which blkid 2>/dev/null)" ] && blkid | grep -w xfs | cut -d: -f1 2>/dev/null 1>&2 # try getting all xfs filesystems using blkid if available # added on 20240202 by edrulrd
      then
        for fs in $(blkid | grep -w xfs | cut -d: -f1 | sort -u) # added on 20240202 by edrulrd
        do
          echo "Dumping: ${fs}" # added on 20240202 by edrulrd
          xfs_db -r -c sb -c print "${fs}" # print superblock info
          echo
        done
      else
        echo "Hint: lsblk and/or blkid commands are old or not available, showing mounted filesystems only" # added on 20240119 by edrulrd # modified on 20240202 by edrulrd
        grep -w xfs /proc/mounts | awk '{print $1}' | sort -u | while read -r fs # if we don't have blk cmds, only check mounted filesystems # modified on 20240119 by edrulrd
        do
          echo "Dumping: ${fs}"
          xfs_db -r -c sb -c print "${fs}" # print superblock info
          echo
        done
      fi
    fi
}

function display_btrfs_fs_param {
    #function used in FILESYS added 20240202 by edrulrd
    if [ "$(which lsblk 2>/dev/null)" ] && lsblk -o PATH 2>/dev/null 1>&2 # added on 20240202 by edrulrd
    then
      for fs in $(lsblk -ln -o PATH,FSTYPE | grep -w btrfs | awk '{print $1}') # added on 20240202 by edrulrd
      do
        echo "Dumping: ""${fs}" # added on 20240202 by edrulrd
        btrfs inspect-internal dump-super "${fs}" # print superblock summary info # added on 20240202 by edrulrd
        echo
      done
    else
      if [ "$(which blkid 2>/dev/null)" ] && blkid | grep -w btrfs | cut -d: -f1 2>/dev/null 1>&2 # try getting all btrfs filesystems using blkid if available # added on 20240202 by edrulrd
      then
        for fs in $(blkid | grep -w btrfs | cut -d: -f1 | sort -u) # added on 20240202 by edrulrd
        do
          echo "Dumping: ""${fs}" # added on 20240202 by edrulrd
          btrfs inspect-internal dump-super "${fs}" # print superblock summary info # added on 20240202 by edrulrd
          echo
        done
      else
        echo "Hint: lsblk and/or blkid commands are old or not available, showing mounted filesystems only" # added on 20240202 by edrulrd
        grep -w btrfs /proc/mounts | awk '{print $1}' | sort -u | while read -r fs # if we don't have blk cmds, only check mounted filesystems # added on 20240202 by edrulrd
        do
          echo "Dumping: ""${fs}" # added on 20240202 by edrulrd
          btrfs inspect-internal dump-super "${fs}" # print superblock summary info # added on 20240202 by edrulrd
          echo
        done
      fi
    fi
}

function PartitionDump {
    if [ -x /sbin/fdisk ]; then
        if [ -x /sbin/parted ]; then
            for i in $(fdisk -l| grep "^Disk " | grep "/dev/"|cut -f1 -d:|cut -f2 -d" ")
            do
                /sbin/parted -s "${i}" print 2> /dev/null || # The -s option avoids prompts that cause parted to wait forever for user interaction. # discard error message # modified on 20240119 by edrulrd
                echo # issue a blank line if we have a physical volume without known partitions (ie, just logical volumes) # modified on 20240119 by edrulrd
            done
        else
            /sbin/fdisk -l      ## -cul, fixed for OpenSUSE 12.1/KDE -- #  28.08.2012, 07:55 modified by Ralph Roth #* rar *#
            #      -c[=<mode>]           compatible mode: 'dos' or 'nondos' (default)
            #      -h                    print this help text
            #      -u[=<unit>]           display units: 'cylinders' or 'sectors' (default)

        fi
    fi
}

function extract_xpinfo_i {
   # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -i'
   # the CSV file contains the following:
   #device_file; target_id; LUN_id; port_id; CU:LDev; type; device_size; serial#; code_rev; subsystem; CT_group; CA_vol; BC0_vol; BC1_vol; BC2_vol; ACP_pair; RAID_level; RAID_group; disk1; disk2; disk3; disk4; model; port_WWN; ALPA; FC-AL Loop Id; SCSI Id; FC-LUN Id
   # for xpinfo -i we need:
   # device_file  ALPA  target_id  LUN_id  port_id   CU:LDev  type  serial#
   local CSVfile=${1}
   local outf=${2}
   [[ ! -f "${CSVfile}" ]] && {
       echo "Error: xpinfo -i (did not find input file ${CSVfile})"
       exit 1
   }
   cat > "${outf}" <<-EOF
	Device File                 ALPA Tgt Lun Port  CU:LDev Type             Serial#
	================================================================================
	EOF
   grep "^/dev" "${CSVfile}" | while read -r LINE
   do
       echo "${LINE}" | awk -F";" '{printf "%-27s %-4s %-3s %-3s %-6s %-7s %-13s %s\n", $1, $25, $2, $3, $4, $5, $6, $8}' >>  "${outf}"
   done
}

function extract_my_xpinfo {
   # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -i' with VG/Lvol info and VGsize
   local CSVfile="{$1}"
   local outf="${2}"
   cat > "${outf}" <<-EOF
	Device File        Tgt Lun Port CU:LDev Type       Size MB   Sn# VG - DG
	============================================================================
	EOF
   grep "^/dev" "${CSVfile}" | while read -r LINE
   do
       echo "${LINE}" | awk -F";" '{printf ("%-18s %-3s %-3s %-4s %-7s %-10s %7s %5s %-10s\n",$1,$2,$3,$4,$5,$6,$7,substr($8,4),$29)}' >> "${outf}"
   done
}

function extract_xpinfo_c {
   # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -c'
   # the CSV file contains the following:
   #device_file; target_id; LUN_id; port_id; CU:LDev; type; device_size; serial#; code_rev; subsystem; CT_group; CA_vol; BC0_vol; BC1_vol; BC2_vol; ACP_pair; RAID_level; RAID_group; disk1; disk2; disk3; disk4; model; port_WWN; ALPA; FC-AL Loop Id; SCSI Id; FC-LUN Id
   # for xpinfo -c  we need:
   # device_file  subsys  CT group   CA Vol   BC Volumes MU#0 MU#1 MU#2
   local CSVfile=$1
   local outf=$2
   [[ ! -f ${CSVfile} ]] && {
       echo "Error: xpinfo -i (did not find input file ${CSVfile})"
       exit 1
   }
   cat > "${outf}" <<-EOF
	                                   CT       CA        BC Volume
	Device File              Subsys    Group    Vol     MU#0 MU#1 MU#2
	==================================================================
	EOF
   grep "^/dev" "${CSVfile}" | while read -r LINE
   do
      echo "${LINE}" | awk -F";" '{printf "%-25s %-10s %-6s %-7s %-5s %-5s %s\n", $1, $10, $11, $12, $13, $14, $15}' >>  "${outf}"
   done
}

function extract_xpinfo_r {
    # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -r'
    # for xpinfo -r  we need:
    # device_file   ACP Pair   Raid Level  RAID type  Raid group   disk Mechanisms
    # FIXME: RAID Type is pointing to which field in the CSV file?? I use now "---" as a replacement
    local CSVfile="${1}"
    local outf="${2}"
    cat > "${outf}" <<-EOF
	                         ACP       RAID   RAID   RAID                      Disk
	Device File              Pair      Level  Type   Group                     Mechanisms
	===============================================================================================
	EOF
    grep "^/dev" "${CSVfile}" | while read -r LINE
    do
        echo "${LINE}" | awk -F";" '{printf "%-25s %-9s %-5s %-6s %-6s %-8s %-8s %-8s %s\n", $1, $16, $17, "---", $18, $19, $20, $21, $22}' >> "${outf}"
    done
}

function my_df {
    # df summary for Linux, Chris Gardner, 26-Jan-2012
    df -kl -x rootfs -x devtmpfs -x tmpfs -x iso9660 --total |tail -n1 |awk '{
      print  "Allocated\tUsed \t \tAvailable\tUsed (%)";
      printf "%ld \t%ld \t%ld\t \t%3.1f\n", $2, $3, $4, $5;
      }'
}

function PVDisplay {
    #function used in LVM-section
    # for disk in $(strings /etc/lvmtab.d/* |grep -e hd -e sc) ;
    for disk in $(vgdisplay -v 2> /dev/null | awk -F\ + '/PV Name/ {print $4}' | sort);    # fix by Alvaro Jimenez Cabrera, Mittwoch, 5. November 2008
    do
        # [20200321] {jcw} Added redirection of stderr.
        pvdisplay -v "${disk}" 2>&1
    done
}

function GetElevator {
    for i in $(find /sys/devices/ | grep /queue/scheduler | grep -v -e /loop -e /block/ram)
    do
        echo "${i}: $(cat "${i}")"
    done
}

function DoPATHList {
    #function used in System-section
    # arg1: a list of directories separated by colons (":") # moved from cfg2html-linux.sh on 20240202 by edrulrd
    local LISTPATH="${1}"
    local Directory
    for Directory in $(/bin/echo "${LISTPATH}" |
        sed 's/:/ /g');
        do
          find "${Directory}" -executable \( -type f -o -type l \) -xtype f -print 2>/dev/null | # when a link, ensure the target is a file # modified on 20240322 by edrulrd
          sort |
          while read -r Filename;
            do
              /bin/echo -n "$(basename "${Filename}")";
              /bin/echo -n ' ';
              echo "${Filename}"
            done
        done |
        sort -k1,1 -u |
        awk '{$1=""; print}' |
        sed 's/^ //' | column -c "${CFG_TEXTWIDTH}"
}

#* END *#
