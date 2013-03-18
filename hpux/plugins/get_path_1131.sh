# @(#) $Id: get_path_1131.sh,v 5.12 2012-06-01 18:13:56 ralph Exp $
# ---------------------------------------------------------------------------
# $Log: get_path_1131.sh,v $
# Revision 5.12  2012-06-01 18:13:56  ralph
# small typo fixes adn code cleanup, CVS cleanup, added comments etc.
#
# Revision 5.11  2011-07-18 09:27:52  ralproth
# cfg5.13-33157: enhancements for long tape device files (tape999_BEST)
#
# Revision 4.17  2010-10-05 20:41:06  ralproth
# cfg4.84-24823: Enhanced: Online/Offline devices
#
# Revision 4.14  2010-04-07 11:27:58  ralproth
# cfg4.68-24162: Enhancements for EMC CLARiION LunZ stuff
#
# Revision 4.12  2010-02-05 08:11:25  ralproth
# cfg4.63-23636: complete rewrite by Michael Meyer
#
# Revision 4.10.1.1  2008/07/07 16:38:54  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.1  2008/07/07 15:38:54  ralproth
# get_path_1131.sh from Marc Heinrich added
#
##### Initial creation:  Marc Heinrich ##################

##!/usr/bin/ksh

SCSI_ATTR_FILE=$(mktemp -c -d /tmp -p Scsimgr_Get_Attr.)
SCSI_INFO_FILE=$(mktemp -c -d /tmp -p Scsimgr_Get_Info.)

# 
# Maybe a more smarter approach? (cr: Thomas Brix)
# ---------------------------------------------------------------------------
# # scsimgr -p get_attr  all_lun -a device_file -a wwid -a vid -a pid -a total_path_cnt -a load_bal_policy
# /dev/rdisk/disk5:0x5000cca00cb38d67:"HP 146 G":"HUS153014VL3800 ":1:round_robin
# /dev/rdisk/disk6:0x5000cca00cb120b3:"HP 146 G":"HUS153014VL3800 ":1:round_robin
# /dev/rdisk/disk7:0x5000cca00cb14893:"HP 146 G":"HUS153014VL3800 ":1:round_robin
# /dev/rdisk/disk8:0x5000cca00cb4061f:"HP 146 G":"HUS153014VL3800 ":1:round_robin
# ...
# 
sammel () {
	   scsimgr get_attr -H $1 -a device_file > $SCSI_ATTR_FILE
	   scsimgr get_info -H $1                > $SCSI_INFO_FILE

	   DEV=`awk -F'/' '/current/ {print substr($NF,1,12)}' $SCSI_ATTR_FILE`
	   WWID=`awk -F= '/WWID/ {gsub(/ |\"/, ""); print substr($2,1,38)}' $SCSI_INFO_FILE `

	   CPATH=`awk '/LUN path count/    {print $5}' $SCSI_INFO_FILE `
	   APATH=`awk '/Active LUN paths/  {print $5}' $SCSI_INFO_FILE `
	   SPATH=`awk '/Standby LUN paths/ {print $5}' $SCSI_INFO_FILE `
	   FPATH=`awk '/Failed LUN paths/  {print $5}' $SCSI_INFO_FILE `

	   LB=`awk '/I\/O load balance policy/ {print substr($6,1,11)}' $SCSI_INFO_FILE`
	   LTYPE=`awk '/LUN access type/ {print $5$6}' $SCSI_INFO_FILE`

	   INQ=`awk -F= '/Product id|Vendor id/ {gsub(/ |\"/, ""); printf ("%s/", substr($2,1,15)); }' $SCSI_INFO_FILE`
	   REV=`awk -F= '/Product revision/ {gsub(/ |\"/, ""); printf("%s", $2);}' $SCSI_INFO_FILE | awk '{print $1;}' `

	   printf "%-13s%-6s%-6s%-6s%-5s%-38s%-12s%-16s%-16s\n" \
	            $DEV $CPATH $APATH $SPATH $FPATH $WWID $LB $LTYPE $INQ$REV
}

line ()
{
      	   echo "=========================================================================================================================="
}

myheader () {
	   printf "%-13s%-6s%-6s%-6s%-5s%-38s%-12s%-16s%-16s%-16s\n" \
	            "Devices" "#Paths" "act." "stdby" "fail" "WWID" "LB" "LunType" "Type/Rev"
           line         
}



# 	#######################
# 	#####   M a i n   #####
# 	#######################

echo "ONLINE DISK DEVICES"
myheader

# ---------------------------------------------------------------------------
# bus_type, cdio, is_block, is_char, is_pseudo, b_major, c_major, 
# minor, class, driver, hw_path, id_bytes, instance, module_name, sw_state, 
# hw_type, description, health, error_recovery, is_inst_replaceable, wwid, 
# uniq_name, alias_path, physical_location, and ms_scan_time.
# ---------------------------------------------------------------------------

for i in `ioscan -NkC disk -P is_block -P health| grep online| awk '/disk/ {print $3}'`
do
    sammel $i
done 
line
echo "\n"

echo "OFFLINE DISK DEVICES"
myheader
for i in `ioscan -NkC disk -P is_block -P health| grep -v online| awk '/disk/ {print $3}'`
do
    sammel $i
done 
line
echo "\n"

if [ "$1" != "-notape" ]
then
    echo "TAPE DEVICES"
    myheader
    for i in `ioscan -NkC tape -P is_block | awk '/tape/ {print $3}'`
    do
       	sammel $i
    done
    line
    echo "\n"
fi

rm -f $SCSI_ATTR_FILE $SCSI_INFO_FILE

# 
# ---------------------------------------------------------------------------
# # scsimgr get_info -H 64000/0xfa00/0x4e
# 
#         STATUS INFORMATION FOR LUN : 64000/0xfa00/0x4e
# 
# Generic Status Information
# 
# SCSI services internal state                  = UNOPEN
# Device type                                   = Array_Controller
# EVPD page 0x83 description code               = 1
# EVPD page 0x83 description association        = 0
# EVPD page 0x83 description type               = 3
# World Wide Identifier (WWID)                  = 0x60060480000290102796000000002700
# Serial number                                 = "102796000000"
# Vendor id                                     = "EMC     "
#*Product id                                    = "SYMMETRIX       "
#*Product revision                              = "5772"
# Other properties                              = ""
# SPC protocol revision                         = 4
# Open count (includes chr/blk/pass-thru/class) = 0
# Raw open count (includes class/pass-thru)     = 0
# Pass-thru opens                               = 0
#*LUN path count                                = 1
#*Active LUN paths                              = 1
#*Standby LUN paths                             = 0
#*Failed LUN paths                              = 0
# Maximum I/O size allowed                      = 2097152
# Preferred I/O size                            = 2097152
# Outstanding I/Os                              = 0
#*I/O load balance policy                       = path_lockdown
# Path fail threshold time period               = 0
# Transient time period                         = 0
# Tracing buffer size                           = 1024
# LUN Path used when policy is path_lockdown    = 0/0/12/1/0/4/0.0x5006048c52a78307.0x0
# LUN access type                               = NA
# Asymmetric logical unit access supported      = No
# Asymmetric states supported                   = NA
# Preferred paths reported by device            = No
# Preferred LUN paths                           = 0
# ---------------------------------------------------------------------------

# Some Remarks by MiMe:
# awk is quite powerful and can substitute grep, sed, tr and some more. I did some
# cleaning on /opt/cfg2html/plugins/get_path_1131.sh in that sense of useless use.
#
# 'scsimgr get_info -H $1' was called 8 times in that script. Therefore I used a
# temporary file created by mktemp. Watch out : Using temp files with predefined
# names like /tmp/mytempfile or /tmp/mytempfile.$$ can be unsafe when filled by
# '>'. Somebody could know/guess that name and could create a link /tmp/mytempfile
# -> /etc/passwd or so. Running cfg2html will destroy the system due to it.
#
# It's safe to use mktemp that guarantees unique file names.
#
# Back to the script get_path_1131.sh that runs 3 times faster now.
#
# root@zsmx7230:/root # time /opt/cfg2html/plugins/get_path_1131.ori.sh >
# /tmp/get_path_1131.ori.txt
#
# real 38.3
# user 0.9
# sys 5.8
#
# root@zsmx7230:/root # time /opt/cfg2html/plugins/get_path_1131.mime.sh >
# /tmp/get_path_1131.mime.txt
#
# real 13.1
# user 1.6
# sys 10.7
