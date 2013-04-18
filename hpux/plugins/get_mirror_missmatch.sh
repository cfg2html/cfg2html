# @(#) $Id: get_mirror_missmatch.sh,v 5.14 2011-11-01 07:26:31 ralproth Exp $
###########################################################################
# Mirror/UX missmatch detection utility
# Initial creation 18.08.2005 by Ralph Roth
###########################################################################
# $Log: get_mirror_missmatch.sh,v $
# Revision 5.14  2011-11-01 07:26:31  ralproth
# cfg5.19-31551: Many enhancements and SuperDome2 stuff submitted by Kathy Leslie
#
# Revision 5.13  2011-05-20 12:43:26  ralproth
# cfg4.97-25655: cfg2html 4.97 upstream (merged/updated)
#
# Revision 4.14  2011-02-25 20:58:20  ralproth
# cfg4.93-25649: added Alex to the Authors
#
# Revision 4.13  2011-02-25 08:44:05  ralproth
# cfg4.93-25647: Added some hints from TB mailing
#
# Revision 4.10.1.1  2008/07/22 18:01:02  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2005/08/19 08:31:27  ralproth
# Initial 3.x stream import
#
# Revision 2.1  2005/08/19 08:31:27  ralproth
# added get_mirror_missmatch.sh, last 2.xx stream
#
###########################################################################
# root@hpul80:/samba30/cfg2html/release/plugins> ./get_mirror_missmatch.sh
# Example:
#
# /dev/vg00/lvol1    \
# /dev/vg00/lvol2    |
# /dev/vg00/lvol3    |
# /dev/vg00/lvol5    |
# /dev/vg00/lvol6    |->  perfectly 1:1 mirrored
# /dev/vg00/lvol7    |
# /dev/vg00/lvol8    |
# /dev/vg00/lvol9    /

#  vvvvvv---- LV        vvvvv---- disks        vvvv--- used PEs
# /dev/vg_a400/lvol1
#                               /dev/dsk/c9t0d2        9744
#                               /dev/dsk/c9t0d1        7579
#                                     No Mirror       17323
# /dev/vgfc30l0/lvol1
#                               /dev/dsk/c8t3d0        8502
#                               /dev/dsk/c8t3d1        8502
#                               /dev/dsk/c8t3d2        8502
#                               /dev/dsk/c8t3d3        8502
#                                     No Mirror       34008
# /dev/vgfc30l2/lvol1
#                               /dev/dsk/c8t3d4        6376
#                               /dev/dsk/c8t3d5        6376
#                                     No Mirror       12752
#

# ---------------------------------------------------------------------------
# HP-UX 11 v3 new layout
# ---------------------------------------------------------------------------

# /dev/vgsapk32b/lvmnt
#                            /dev/disk/disk1242          94
#                                     No Mirror          94
# /dev/vgsapk32b/lvsaptrans
#                            /dev/disk/disk1242          32
#                                     No Mirror          32
# /dev/vgsapk32b/lvusr
#                            /dev/disk/disk1242          63
#                                     No Mirror          63
#

# Use supplied parameter (if applicable).  (KL 26.10.11)
#if [ "$1" = "vg00" ]                    # 21.07.2008, 10:43, rr
if [ "$1" != "" ]
then
    VGS=$1
else
	# Can't assume that all volume group names begin with 'vg' and that all logical volume names begin with 'lv'.  (KL 26.10.11)
    #VGS="/dev/vg*/lv*"
    VGS=`strings /etc/lvmtab* | grep ^/dev | grep -v -e /dev/dsk/ -e /dev/disk/ | sort -u`
fi        

echo "Volume Group/Logical Volume    Disk Device    # Physical Extents"

# Process each volume group.  (KL 26.10.11)
for VG in $VGS
do
	# Find all the logical volumes for this volume group.  (KL 26.10.11)
    for i in `find $VG -type b`
    do
        lvdisplay $i > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo $i
            lvdisplay -v $i | grep -e /dev/dsk/c -e /dev/disk/disk | grep current |
            awk '{
                if ($3 != $6) {
                    a1[$2] ++;
                    if (length($5) < 8) { $5 = "No Mirror"; }
                    a2[$5] ++;
#                   print($2, $3, $5, $6);
                }
            }

            END {
                for (i in a1) { printf ("%45s\t%9d\n",i, a1[i]) };
                for (i in a2) { printf ("%45s\t%9d\n",i, a2[i]) };
            }'
        fi
    done
done
exit 0

# Some suggestions from Thomas Brix mail:
# ---------------------------------------------------------------------------
# Noch einer für die Trickkiste:
# Ob die Platten "schön gespiegelt" sind, sieht man mit
# 130    pvdisplay -v /dev/dsk/c2t2d0 > 1
# 131    pvdisplay -v /dev/dsk/c0t4d0 > 2
# 132    sdiff -w 100 -l  1 2 | more
# ---------------------------------------------------------------------------
# Unique Zeilen ausgeben
# pvdisplay -v /dev/dsk/c0t6d0 | awk ' BEGIN {L=0;D=0;} { if ($2 !~ D|| $3 !~ L) print; L=$3; D=$2; }'
# ---------------------------------------------------------------------------
