# @(#) $Id: firmware_collect.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# WARNING MAY HANG INFINTLY ON DEFECT DISK DRIVES!
#####################################################################
# kann durch get_diskfirmware.sh ersetzt werden! Gibt keine 11.31 devicefiles aus
#####################################################################
# $Log: firmware_collect.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.11  2013-06-28 07:16:29  ralph
# Enhanced by GDH - splitted into a HPUX 11.31 and the rest of the world part
# to better handle ioscan.  Cleanup of comments by Ralph Roth
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.17  2010-02-05 08:14:33  ralproth
# cfg4.63-23636: change tempfile creation to mktemp
#
# Revision 4.14  2009/02/17 12:12:57  ralproth
# cfg4.22-22222: small fixes and enhancements for EMC arrays
#
# Revision 4.10.1.1  2008/10/24 11:48:18  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2003/01/21 10:33:33  ralproth
# Initial 3.x stream import
#
# Revision 2.1.1.1  2003/01/21 10:33:33  ralproth
# Import from HPUX to cygwin
#
# Revision 1.3  2002/01/31 15:21:43  ralproth
# Initial working version for cfg2html 1.66
#
# Revision 1.1  2002/01/31 14:52:55  ralproth
# Added Files: firmware_collect.sh
#
#####################################################################

hw_disk_check_1131()	## new 28.06.2013 - Gratien splitted this into two parts
{


TMPFiLE_MARTiN=$(mktemp -c -p hw_disc_chk)

# doesn't work yet with hpux 11.31 agile device files....
DEVICES=`ioscan -fkNnCdisk | grep -e /rdisk/ | grep -v "/dev/deviceFileSystem/" | cut -d "/" -f4`

#     1234567890123456789012345678901234567890123456789012345678901234567890
printf "\n%-31s%-10s%-22s%-7s%-7s%-3s%-3s\n" Hardwarepath  Device Vendor/Product Cap/GB Firm. QD IR
echo "-----------------------------------------------------------------------------------"

for device in $DEVICES
do
    if [ -c /dev/rdisk/$device ]          ## /dev/cdrom -> lssf: /dev/dsk/dev: No such file or directory
    then
	    (diskinfo -v /dev/rdisk/$device;diskinfo /dev/rdisk/$device) 2> /dev/null | grep -e product -e rev -e vendor -e size > $TMPFiLE_MARTiN 2> /dev/null
	    #if !( grep -e DVD-ROM -e DISK-SUBSYSTEM $TMPFiLE_MARTiN>/dev/null )

	    if [ "$(grep -e 'DVD-ROM' -e 'CD-ROM' -e 'DISK-SUBS' -e ' 0 Kbyte' $TMPFiLE_MARTiN)" = "" ]
	    then
	        hw_pfad=` lssf /dev/disk/$device  | awk '{ print $(NF-1) }'`

	        product=` grep product $TMPFiLE_MARTiN  | head -1 | awk '{ print $3  }'`
	        if [ -n "$product"  ]
	            then
	                  vendor=`  grep vendor  $TMPFiLE_MARTiN  | head -1 | awk '{ print $2  }'`
	                  revision=`grep rev     $TMPFiLE_MARTiN  | head -1 | awk '{ print $3  }'`
	                  size=`grep size     $TMPFiLE_MARTiN  | head -1 | awk '{ printf "%-5.1f", ($2+0.01)/1024/1024  }'`
	                  scsi=`/usr/sbin/scsictl -akq /dev/rdisk/$device 2>/dev/null`
	                  sir=`echo $scsi|awk -F";" '{ print $1; }{}'`
	                  sqd=`echo $scsi|awk -F";" '{ print $2; }{}'`
	                  vendor_product=$vendor"/"$product

	                  printf "%-31s%-10s%-22s%-7s%-7s%-3s%-3s\n" \
	                         $hw_pfad $device $vendor_product $size $revision $sqd $sir

	       fi # Product
	    fi # DISK-SUBSYSTEM
    fi
done

# Aufraeumen des Systems
echo "-----------------------------------------------------------------------------------"
echo "QD = SCSI queue depth (0=no hw/medium), IR = immediate reporting (0=off, 1=on)\n"
rm -f $TMPFiLE_MARTiN
}

hw_disk_check()
{

TMPFiLE_MARTiN=$(mktemp -c -p hw_disc_chk)

# doesn't work yet with hpux 11.31 agile device files....
DEVICES=`ioscan -fknCdisk | grep -e /rdsk/ | grep -v "/dev/deviceFileSystem/" | cut -d "/" -f4`

#     1234567890123456789012345678901234567890123456789012345678901234567890
printf "\n%-31s%-10s%-22s%-7s%-7s%-3s%-3s\n" Hardwarepath  Device Vendor/Product Cap/GB Firm. QD IR
echo "-----------------------------------------------------------------------------------"

for device in $DEVICES
do
    if [ -c /dev/rdsk/$device ]          ## /dev/cdrom -> lssf: /dev/dsk/dev: No such file or directory
    then
	    (diskinfo -v /dev/rdsk/$device;diskinfo /dev/rdsk/$device) 2> /dev/null | grep -e product -e rev -e vendor -e size > $TMPFiLE_MARTiN 2> /dev/null
	    #if !( grep -e DVD-ROM -e DISK-SUBSYSTEM $TMPFiLE_MARTiN>/dev/null )

	    if [ "$(grep -e 'DVD-ROM' -e 'CD-ROM' -e 'DISK-SUBS' -e ' 0 Kbyte' $TMPFiLE_MARTiN)" = "" ]
	    then
	        hw_pfad=` lssf /dev/dsk/$device  | awk '{ print $(NF-1) }'`

	        product=` grep product $TMPFiLE_MARTiN  | head -1 | awk '{ print $3  }'`
	        if [ -n "$product"  ]
	            then
	                  vendor=`  grep vendor  $TMPFiLE_MARTiN  | head -1 | awk '{ print $2  }'`
	                  revision=`grep rev     $TMPFiLE_MARTiN  | head -1 | awk '{ print $3  }'`
	                  size=`grep size     $TMPFiLE_MARTiN  | head -1 | awk '{ printf "%-5.1f", ($2+0.01)/1024/1024  }'`
	                  scsi=`/usr/sbin/scsictl -akq /dev/rdsk/$device 2>/dev/null`
	                  sir=`echo $scsi|awk -F";" '{ print $1; }{}'`
	                  sqd=`echo $scsi|awk -F";" '{ print $2; }{}'`
	                  vendor_product=$vendor"/"$product

	                  printf "%-31s%-10s%-22s%-7s%-7s%-3s%-3s\n" \
	                         $hw_pfad $device $vendor_product $size $revision $sqd $sir

	       fi # Product
	    fi # DISK-SUBSYSTEM
    fi
done

# Aufraeumen des Systems
echo "-----------------------------------------------------------------------------------"
echo "QD = SCSI queue depth (0=no hw/medium), IR = immediate reporting (0=off, 1=on)\n"
rm -f $TMPFiLE_MARTiN
}

case $(uname -r) in
   "B.11.31") hw_disk_check_1131 ;;
   *) hw_disk_check ;;
esac

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
# Ralph Roth, old filename: hw_check.sh

