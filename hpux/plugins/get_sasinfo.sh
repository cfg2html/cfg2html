# HP-UX SAS Collector , 21.07.2008, 11:57, rr
# HP-UX Serial Attached SCSI (SAS) Mass Storage I/O cards / HBAs
# @(#) $Id: get_sasinfo.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# ---------------------------------------------------------------------------
# $Log: get_sasinfo.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.12  2009-08-19 20:00:17  ralproth
# cfg4.48-23483: vPar 5.0.5
#
# Revision 4.11  2008/11/13 20:22:57  ralproth
# cfg4.13: fixes for mywhat utility
#
# Revision 3.1  2008/07/22 17:01:02  ralproth
# added sas and mpt plugins
#

if [ -x /opt/sas/bin/sasmgr ]
then
    ioscan -fnkd sasd
    for dev in /dev/sasd*
    do
        if [ -c "$dev" ]
        then
            echo "---= $dev ===="
            /opt/sas/bin/sasmgr get_info -D $dev
            for i in vpd smp_addr raid "lun=all -q lun_locate"  "phy=all"  "reg=all"
            do
                echo "\n-----= $i ($dev) ----"
		# -N for HPUX 11.31, agile view -> use $1 = -D
                /opt/sas/bin/sasmgr $1 get_info -D $dev -q $i
            done
            echo ""
        fi     
    done # for
fi

###
