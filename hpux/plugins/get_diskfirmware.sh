# @(#) firmware_collect.sh v1.4 07.11.2008, Martin Kalmbach
# @(#) $Id: get_diskfirmware.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# ---------------------------------------------------------------------------

# Uebernommen von firmware_collect.sh, angepasst auf HPUX11.31 Script, um die 
# Firmwarerevisionen der Platten auf dem System und sonstige wichtige 
# Informationen festzuhalten. Dieses Script ist NICHT supportet, HP uebernimmt 
# keinerlei Haftung fuer Schaeden, die durch dieses Script verursacht werden. 
# Martin Kalmbach/Ralph Roth, HP Services, 29.10.2008

# ---------------------------------------------------------------------------

# -ldev usage:
# ./get_diskfirmware.sh -ldev | egrep -v "LVM/|/none"
# ./get_diskfirmware.sh -ldev | egrep -v "LVM/|/partition|/none"

echo "\$Id: get_diskfirmware.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $"
export LANG="C"

if [ $(id -u) -ne 0 ]
then
	echo "ERROR: You must be root!"
	exit 42
fi

TMPFiLE_MARTiN1=$(mktemp -p fwColl) # /tmp/firmware_collect.tmp.1
TMPFiLE_MARTiN2=$(mktemp -p fwColl) # /tmp/firmware_collect.tmp.2

if [ -f /etc/lvmtab_p ]
then
  LVMTAB="/etc/lvmtab /etc/lvmtab_p"
else
  LVMTAB="/etc/lvmtab"
fi

PATH=$PATH:/opt/hpvm/bin:/usr/contrib/bin/:/usr/local/bin
INQ=$(which inq)                # EMC inquiry here? (/usr/local/bin?)
WLDEV="no"

if [ "$1" = "-ldev" -o "$1" = "-ldevs" ] ## typo handling :)
then
        WLDEV="yes"
        echo "Analysing special LDEVs too..."
fi        

#####################################################################
# get the properties of the device (same for dsf and classic devices)
#####################################################################
get_properties()
{
  # device = disk16 or disk408
  
  vendor=`  grep vendor  $TMPFiLE_MARTiN1  | head -1 | awk '{ print $2  }'`
  revision=`grep rev     $TMPFiLE_MARTiN1  | head -1 | awk '{ print $3  }'`
  size=`grep size     $TMPFiLE_MARTiN1  | head -1 | awk '{ printf "%-5.1f", ($2+0.01)/1024/1024  }'`
  scsi=`/usr/sbin/scsictl -akq /dev/r$DEVPREFIX/$device 2>/dev/null`
  sir=`echo $scsi|awk -F";" '{ print $1; }{}'`
  sqd=`echo $scsi|awk -F";" '{ print $2; }{}'`
  vendor_product=$(echo $vendor"/"$product|cut -c1-18)             ## e.g. EMC/SYMMETRIX

  # Additions, Martin Kalmbach, 29.10.2008
  USAGE=""
  USAGE_EXT=""
  ##############################################################################
  # Check, if device is used in LVM. If yes, then show VG (only if VG is active)
  ##############################################################################
  
  ## echo "dev="$device"=="
  if (strings $LVMTAB | grep ^/dev/ | grep /${device}$ >/dev/null 2>&1) || (strings $LVMTAB | grep ^/dev/ |grep $device$DIVIDER..$ >/dev/null 2>&1)
  then
    ### device exists in lvmtab - so it the usage is LVM
    USAGE="LVM/"
    USAGE_EXT="scripterror"
    ### device is in lvmtab, but VG is not activated   
    DISKFOUND="no";VG=""
    for entry in `strings $LVMTAB|grep /dev/`
    do
      if [ $DISKFOUND = "no" ]
      then
        # echo "E=$entry, D=$device, VG=$VG"
        if [ "`echo $entry | cut -d "/" -f 4`" = "" ]
        then
          # lvmtab line is specifying a VG and not a disk
          VG="`echo $entry | cut -d "/" -f 3`"
        else
          # lvmtab line is specifying a disk and not a VG
          if (echo $entry | grep -E "/$device$|/$device$DIVIDER..$" >/dev/null 2>&1)
          then
            if (vgdisplay $VG>/dev/null 2>&1)
            then
              VGVERSION=$(vgdisplay $VG 2>/dev/null|grep "VG Version"|awk '{print $3;}')
              [ -n "$VGVERSION" ] || VGVERSION="1.0"
              USAGE_EXT="$VG/v$VGVERSION"        # 1.0, 2.0, 2.1
            else
              USAGE_EXT="$VG,inactive"
            fi
            DISKFOUND=yes
          fi
        fi
      fi
    done
  else
    ##############################################################################
    # Check if a file system has been created on the device file (would be strange..)
    ##############################################################################
    if (fstyp /dev/r$DEVPREFIX/$device >/dev/null 2>&1) 
    then
      USAGE=Filesystem/
      USAGE_EXT="`fstyp /dev/r$DEVPREFIX/$device`"
    fi

    ##############################################################################
    # Check if device is used in a HPVM. If yes, then show VM name
    ##############################################################################
    if (hpvmstatus >/dev/null 2>/dev/null)
    then
      VMS=`hpvmstatus 2>/dev/null | grep -v -e "Virtual Machine" -e "=====" | awk '{print $1}'`
      for vm in $VMS
      do
        if (hpvmstatus -P $vm -d | grep disk | grep -w $device >/dev/null 2>&1 ) ||
           (hpvmstatus -P $vm -d | grep disk | grep $device$DIVIDER  >/dev/null 2>&1)
        then
          USAGE="HPVM/"
          USAGE_EXT="$vm"
        fi
      done
    fi
  fi # LVM TAB

    SNR=""
    # EMC/Symetricx Serialnumber Diskarray, #  12.1.2009, 11:05  Ralph Roth  
    if [ -x "$INQ" -a "$vendor" = "EMC" ]
    then
        SNR=$($INQ -dev /dev/r$DEVPREFIX/$device -no_dots -et | grep ^/dev/r|cut -f2,11 -d":" | tr ":" " "| awk '{ printf("%s/%s", $1,$2); }' )
        USAGE_EXT=$USAGE_EXT"/"$SNR
        # [9600370000/R10A-1]
        SNR=$(echo $SNR|cut -f1 -d/)    # fix for WLDEV usage!
    fi
    # #  16.6.2010, 15:16  Ralph Roth
    # CLARiiON Device WWN, Serial Number, SP, and IP address:
    # -------------------------------------------------------
    # Device:       /dev/rdisk/disk132
    # Serial:       CK200084900861
    # WWN:          600601601b3119001cd5f3bd79a3de11
    # SP:           B
    # IP Addr:      10.0.71.35
    # Peer IP Addr: 10.0.71.34
    
    if [ -x "$INQ" -a "$vendor" = "DGC" ]
    then
        SNR=$($INQ -dev /dev/r$DEVPREFIX/$device -no_dots -clar_wwn  | grep ^WWN: | awk '{ printf("%s", $2); }' )
        USAGE_EXT=$USAGE_EXT"/"$SNR
    fi

    if [ "$WLDEV" = "yes" ]
    then
        USAGE_EXT=$USAGE_EXT"/"$(hostname)
        GHOST="???"
        if [ "$SNR" != "" ]
        then
                # echo "[$SNR]"
                GHOST=$(grep -li $SNR /hzd_admin/san/emc/ldevs/ldev*  2>/dev/null | awk -F"/" '{ print $NF; }'|sed 's/ldev_//g')
        else
                GHOST="NoSAN"
        fi      
        USAGE_EXT=$USAGE_EXT"/"$GHOST  
    fi    

    if [ -x /usr/sbin/diskowner ]
    then
        USAGE_EXT=$USAGE_EXT"/"$(/usr/sbin/diskowner -FA /dev/$DEVPREFIX/$device | awk -F ":owner=" ' { print $2; } ')
    fi
  
    WARNMSG="Note: Raw device usage is not shown in the usage column."
}

#####################################################################
# for HPUX < 11.31 : no DSF devices
#####################################################################
hw_disk_check_classic()
{
    DEVPREFIX=dsk
    DIVIDER=s
    
    DEVICES=`ioscan -fknCdisk | grep -e /r$DEVPREFIX/ | cut -d "/" -f4 | grep -v -e $DIVIDER`  # /dev/cdrom -> dev (bug)!
    # 1234567890123456789012345678901234567890123456789012345678901234567890
    # 2/0/6/1/0/4/0.60.240.22.0.14.7    c104t14d7 HP/OPEN-V        119 10.0    5001   LVM/vg25
    # 2/0/6/1/0/4/0.60.240.22.7.15.7    c105t15d7 HP/OPEN-9-CVS-CM 127 0.0     5001
    #printf "\n%-10s%-18s%-6s%-4s%-8s%-7s%-6s%-12s\n" Device Vendor/Product SCSI LUN Cap/GB FWVer Usage 
    printf "\n%-34s%-10s%-18s%-4s%-8s%-7s%-6s%-12s\n" Hardwarepath Device Vendor/Product LUN Cap/GB FWVer Usage
    echo "-----------------------------------------------------------------------------------------------" 
    
    for device in $DEVICES
    do
        if [ -c /dev/r$DEVPREFIX/$device ]          ## /dev/cdrom -> lssf: /dev/dsk/dev: No such file or directory
        then  
          (diskinfo -v /dev/r$DEVPREFIX/$device;diskinfo /dev/r$DEVPREFIX/$device) \
            2> /dev/null | grep -e product -e rev -e vendor -e size > $TMPFiLE_MARTiN1 2> /dev/null
          if [ "$(grep -e 'DVD-ROM' -e 'CD-ROM' -e 'DISK-SUBS' -e ' 0 Kbyte' $TMPFiLE_MARTiN1)" = "" ]
          then
             hw_pfad=` lssf /dev/$DEVPREFIX/$device  | awk '{ print $(NF-1) }'`
             product=` grep product $TMPFiLE_MARTiN1  | head -1 | awk '{ print $3  }'`
             if [ -n "$product"  ] 
             then
               get_properties
               ##############################################################################
               # Check the LUN Number (decimal)
               ##############################################################################
               SCSITGTLUN="t`echo $device | cut -d t -f 2`"
               SCSITGT=`echo $device| cut -d t -f 2 | cut -d d -f 1|awk '{print $1+0}'`
               SCSILUN=`echo $device| cut -d t -f 2 | cut -d d -f 2|awk '{print $1+0}'`
               ((LUNDEC1=$SCSITGT*8+$SCSILUN))

 if [  "$WLDEV" = "yes" -a "$size" = "0.0  " ]  # Size=0.0  =
           then
                : # Skip Ghost LUNs with -ldev
           else             
               printf "%-34s%-10s%-18s%-4s%-8s%-7s%-4s%-12s\n" \
                       $hw_pfad $device $vendor_product $LUNDEC1 $size $revision $USAGE $USAGE_EXT
         fi
             fi
          fi
    fi
    done
    echo "-------------------------------------------------------------------------------------------------" 
    echo $WARNMSG
}

#####################################################################
# for HPUX >= 11.31 : with DSF devices
#####################################################################
hw_disk_check_dsf()
{
    DEVPREFIX=disk
    DIVIDER=_
    DEVICES=`ioscan -fkNnCdisk | grep -e /r$DEVPREFIX/ |grep /dev/ | cut -d "/" -f4 | grep -v $DIVIDER `
    
    printf "\n%-10s%-19s%-6s%-4s%-8s%-7s%-6s%-4s%-12s\n" Device Vendor/Product SCSI LUN Cap/GB FWVer Paths Usage/VG/Owner/ID
    echo "---------------------------------------------------------------------------------------" 
    
    for device in $DEVICES
    do 
      (diskinfo -v /dev/r$DEVPREFIX/$device;diskinfo /dev/r$DEVPREFIX/$device) \
        2> /dev/null | grep -e product -e rev -e vendor -e size > $TMPFiLE_MARTiN1 2> /dev/null
      if [ "$(grep -e 'DVD-ROM' -e 'CD-ROM' -e 'DISK-SUBS' -e ' 0 Kbyte' $TMPFiLE_MARTiN1)" = "" ]
      then
         hw_pfad=` lssf /dev/$DEVPREFIX/$device  | awk '{ print $(NF-1) }'`
         product=` grep product $TMPFiLE_MARTiN1  | head -1 | awk '{ print $3 $4 }'`
         if [ -n "$product"  ] 
         then
           get_properties
           ##############################################################################
           # Check the LUN Number (decimal)
           ##############################################################################
           SCSITGTLUN="t`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep $device | awk '{print $2}' | cut -d t -f 2`"
           SCSITGT=`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep $device | awk '{print $2}' | cut -d t -f 2 | cut -d d -f 1|awk '{printf "%d", $1+0.0}'`
           SCSILUN=`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep $device | awk '{print $2}' | cut -d t -f 2 | cut -d d -f 2|awk '{printf "%d", $1+0.0}'`
           if [ -z "$SCSITGT" -o -z "$SCSILUN" ]
           then
                    LUNDEC2="--"
                    SCSITGTLUN="!LDSF"
           else         
                    ((LUNDEC2=$SCSITGT*8+$SCSILUN))
           fi         
           ##############################################################################
           # Check how many paths the DSF device has
           ##############################################################################
           PATHES=`ioscan -m dsf /dev/r$DEVPREFIX/$device | grep -v -e "Persis" -e "=====" | wc -l`
    
           if [  "$WLDEV" = "yes" -a "$size" = "0.0  " ]  # Size=0.0  =
           then
                : # Skip Ghost LUNs with -ldev
           else     
                printf "%-10s%-19s%-6s%-4s%-8s%-7s%-6s%-4s%-12s\n" \
                   $device $vendor_product $SCSITGTLUN $LUNDEC2 $size $revision $PATHES $USAGE $USAGE_EXT
                   
           fi
         fi
      fi 
    done
    echo "---------------------------------------------------------------------------------------" 
    echo $WARNMSG
}


UX=`uname -r | cut -d "." -f 3`

if [ $UX -ge 31 ]
then
  ### 11.31 and higher #########################################################
  hw_disk_check_dsf
  hw_disk_check_classic > $TMPFiLE_MARTiN2
  if [ `grep -e LVM/ -e HPVM/ -e Filesystem/ $TMPFiLE_MARTiN2 | wc -l` -ne 0 ]
  then
    echo "\nWARNING!!! The following non-DSF Devices are in use. You should rather use DSF devices!"
    printf "%-34s%-10s%-19s%-4s%-8s%-7s%-6s%-12s\n" Hardwarepath Device Vendor/Product LUN Cap/GB FWVer Usage/VG/Owner
    echo "-------------------------------------------------------------------------------------------------------" 
    grep -e LVM/ -e HPVM/ -e Filesystem/ $TMPFiLE_MARTiN2
    #rm $TMPFiLE_MARTiN2
  fi
else
  ### 11.23 and lower  #########################################################
  hw_disk_check_classic
fi

# Clear temp. Files
rm -f $TMPFiLE_MARTiN1 $TMPFiLE_MARTiN2 2>/dev/null

exit 0

# $Log: get_diskfirmware.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.16  2012-02-28 15:11:33  ralproth
# cfg5.25-32080: Fixes for partitions (_p2, _s2) detection
#
# Revision 5.14  2011-08-24 12:03:19  ralproth
# cfg5.14-31549: + root check
#
# Revision 4.11  2010-07-09 07:36:34  ralproth
# cfg4.78-24591: Added CVS log keyword
#
# ----------------------------
# revision 4.10
# date: 2010-07-09 09:29:05 +0200;  author: ralproth;  state: Exp;  lines: +51 -8;
# VG fixes, enhancements for LDEV/KM collector
# ----------------------------
# revision 4.9
# date: 2010-06-30 07:25:43 +0200;  author: ralproth;  state: Exp;  lines: +101 -9
# cfg4.74-24576: Applied the enhancements from Reinhard Lubos
# ----------------------------
# revision 4.7
# date: 2009-03-06 13:21:13 +0100;  author: ralproth;  state: Exp;  lines: +3 -2;
# cfg4.22-22227: added EMC enhancements
# ----------------------------
# revision 4.6
# date: 2009-01-12 14:04:31 +0100;  author: ralproth;  state: Exp;  lines: +21 -9;
# cfg4.21-21814: -Elroy, +Diskfirmware, +lvmadm etc.
# ----------------------------
# revision 4.4
# date: 2008-11-10 15:53:50 +0100;  author: ralproth;  state: Exp;  lines: +2 -2;
# cfg4.13: Enhancements by Martin
# ----------------------------
# revision 4.3
# date: 2008-11-07 14:14:10 +0100;  author: ralproth;  state: Exp;  lines: +245 -2
# cfg4.13: Fixes for 11.31, added VG version (e.g. v2.1)
# ----------------------------
# revision 4.2
# date: 2008-11-07 13:31:40 +0100;  author: ralproth;  state: Exp;  lines: +233 -2
# cfg4.13: Updated GetFirmwareCollect 1.4a from Martin
# ----------------------------
# revision 4.1
# date: 2008-11-05 10:16:08 +0100;  author: ralproth;  state: Exp;
# New version from Martin
# =============================================================================

#####################################################################
# Ralph Roth, ASO, 18-Aug-1999, major fixes (HPFL etc.)
# Ralph Roth, ASO, 14-Sept-1999, version for cfg2html.sh
# Ralph Roth, 28-March-2000, fixes: /rdsk/, QD+IR added
# Ralph/Martin, 24-July-2000 added disk size in GB
# Martin Kalmbach, 28-July-2000, beautified
# Ralph Roth, 9-Nov-2000, fixes for XP256 DISK SUBSYSTEM hangs
# Ralph, 10-Nov-2000, Hopefully the last XP256 fixes?
# Ralph, 14-Nov-2000, XP512 fixes....
#####################################################################
# History
# -------------------------------------------------------------------
# Revision 1.0 29.10.2008, Kalmbach 
# Revision 1.1 31.10.2008, Kalmbach. Check for non-DSF file usage 
# Revision 1.2 01.11.2008, Kalmbach. Show also inactive LVM usage
# Revision 1.3 03.11.2008, Kalmbach. Check also lvmtab_p for LVM v2
# Revision 1.4 07.11.2008, Kalmbach. Minor Bugfixes
#####################################################################

# 
# r730 | rothra | 2010-11-08 14:12:44 +0100 (Mon, 08 Nov 2010)
# r704 | rothra | 2010-08-17 10:26:24 +0200 (Tue, 17 Aug 2010)
# r681 | rothra | 2010-07-09 10:46:16 +0200 (Fri, 09 Jul 2010)
# r680 | rothra | 2010-07-05 11:44:52 +0200 (Mon, 05 Jul 2010)
# r677 | rothra | 2010-07-02 09:40:58 +0200 (Fri, 02 Jul 2010)
# r676 | rothra | 2010-06-16 15:46:54 +0200 (Wed, 16 Jun 2010)
# r651 | rothra | 2010-03-19 14:01:25 +0100 (Fri, 19 Mar 2010)
# r553 | rothra | 2009-04-17 11:23:17 +0200 (Fri, 17 Apr 2009)
# r510 | rothra | 2009-03-06 13:18:34 +0100 (Fri, 06 Mar 2009)
# r467 | rothra | 2008-12-22 14:57:27 +0100 (Mon, 22 Dec 2008)
