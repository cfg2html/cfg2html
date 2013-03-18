# @(#)  $Id: incfs.sh,v 5.1 2012-02-28 15:36:33 ralproth Exp $ 
# ---------------------------------------------------------------------------
# @(#)  $OriginalID: incfs.sh 813 2011-11-28 11:36:04Z rothralph $ 
# ---------------------------------------------------------------------------

# increase filesystem online using lvextend and fsadm
# $1 = account of Gigabytes that the file system shoudl grow, 0.2 for 200 MB!

## needs to be fine tuned 
echo "Filesysteme [regex Expression] eingeben, die um $1 GB erweitert werden sollen:"
read FS

[ -z "$FS" ] && exit 40

LANG=C

[ $# -lt 1 ] && exit 41

bdf $FS 


VGS=$(bdf $FS|grep -v /vg00/ | cut -f3 -d"/"|grep ^vg|sort -u); 


for i in $VGS 
do 
	echo $i
	vgdisplay -v $i|grep "PV Name"|sort|uniq -c; 
done

echo "Hat jede Voulumegruppe zwei Platteneintraege?  (PVG + VG, je eine Disk bei 11.31)?"

echo $FS "--OK? [ENTER]"
read Dummy

for i in $FS
do
   	#LV=$(bdf $i|grep $i|grep ^/dev/| awk '{ print $1; }')
	LV=$(df $i|grep ^$i|grep /dev/| awk '{ print $2; }'|cut -c2-)
   	SIZE=$(lvdisplay $LV| grep "^LV Size"| awk '{ print $NF; }')
	echo "## $LV ($SIZE) $i"
	
        [ "$SIZE" -lt 123 ] && exit 42
	
        NSIZE=`echo  "${SIZE} +  $1 * 1000 " |bc `
	### echo "New Size=$NSIZE"; exit 0
	lvextend -L $NSIZE $LV
   	ESIZE=$(lvdisplay $LV| grep "^LV Size"| awk '{ print $NF; }')
	NESIZE=$(echo "${ESIZE} * 1024 "|bc)
	fsadm -b $NESIZE $i
   	SIZE=$(lvdisplay $LV| grep "^LV Size"| awk '{ print $NF; }')
	echo "## $LV ($SIZE) $i"
	echo ""

	bdf $i
done

exit 0

# HISTORY/Subversion
# ---------------------------------------------------------------------------
# r820 | rothra | 2012-02-27 11:28:59 +0100 (Mon, 27 Feb 2012) 
# r813 | rothra | 2011-11-28 12:36:04 +0100 (Mon, 28 Nov 2011) 
# r798 | rothra | 2011-11-01 13:07:44 +0100 (Tue, 01 Nov 2011) 
# r791 | rothra | 2011-08-31 15:04:59 +0200 (Wed, 31 Aug 2011) 
# r789 | rothra | 2011-08-25 09:24:50 +0200 (Thu, 25 Aug 2011) 
# r788 | rothra | 2011-08-25 09:14:16 +0200 (Thu, 25 Aug 2011) 
# r770 | rothra | 2011-07-14 12:05:47 +0200 (Thu, 14 Jul 2011) 
# r763 | rothra | 2011-06-21 18:39:51 +0200 (Tue, 21 Jun 2011) 
# r762 | rothra | 2011-06-21 18:37:39 +0200 (Tue, 21 Jun 2011) 
# r761 | rothra | 2011-06-21 18:36:58 +0200 (Tue, 21 Jun 2011) 
# r760 | rothra | 2011-06-16 15:29:27 +0200 (Thu, 16 Jun 2011) 
