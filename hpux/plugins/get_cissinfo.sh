# @(#)  $Id: get_cissinfo.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $ 
# ---------------------------------------------------------------------------
# This plugin is part of the cfg2html package for HP-UX
# ---------------------------------------------------------------------------
# ****          S A U T I L   S u p p o r t   U t i l i t y            ****
# ****                                                                 ****
# ****          for the HP SmartArray RAID Controller Family           ****
# ---------------------------------------------------------------------------
# $Log: get_cissinfo.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.3  2011-02-02 12:41:56  ralproth
# cfg4.92-25241: SAConfig sanity check, removed some comments
#
# Revision 4.2  2011-02-02 11:46:50  ralproth
# cfg4.90-24837: Added get_cissinfo/enhanced with saconfig
#
# ---------------------------------------------------------------------------

if [ -x /usr/sbin/saconfig ]
then
    
    #if raid160 or sa6402 card is installed
    I=`ioscan -fnkd ciss | grep /dev/ciss`
    
    for J in $I
    do
        echo "---=[ Device $J ]=------------------------------------------------------" | cut -c1-76
        #echo "---=[ Configuration ]=---"
        saconfig $J
        #echo "---=[ Status ]=---" 
        sautil $J
        sautil $J vpd
        sautil $J stat
        
        #should work with both SAS and SCSI targets
        disklist=`sautil $J | perl -n -e   'if(/(SCSI|SAS\/SATA) DEVICE (\S+:\S+) (\[DISK\] )*-/){ print "$2\n";}'`
        for disk in $disklist  
        do
            [ -c $disk ] && sautil $J get_disk_err_log $disk
        done

        #sautil $J get_trace_buf                # generates a lot of logs
        #sautil $J get_fw_err_log -raw          # generates a lot of logs
    done
fi # sautil

exit 0

# ---------------------------------------------------------------------------
