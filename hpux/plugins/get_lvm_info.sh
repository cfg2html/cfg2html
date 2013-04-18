# @(#) $Id: get_lvm_info.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
#####################################################################
#
#  get_lvm_info  Version 1.0  25.01.1999
#  Version 2.0, 22-may-1999, strongly modified by Ralph Roth, HP
#  Version 2.1, 29-may-1999, Added minor printout for ZF Friedrichshafen
#  Version 3.0, 21-June-1999, prints now hw path and cards, e.g. for fc/mc256
#  Version 3.01,11-July-1999, changed for cfg2html
#  Version 3.1, 23-Sept-1999, added fstyp
#  Version 3.2, 7-Jan-2000, added vxfs version (-> jfs 3.3)
#
#####################################################################
#
#  The script collects information about activated volume groups,
#  physical and logical volumes to format a list which can be used
#  as an input file (ASCII text) for EXCEL (delimiter character is tab)
#  redirect the output for EXCEL e.g. into vginfo.dif
#
#####################################################################
#  stderr output from "/opt/cfg2html/plugins/get_lvm_info.sh":
#      pvdisplay: Couldn't find the volume group to which
#       physical volume "/dev/disk//disk5_p2" belongs.
#      pvdisplay: Cannot display physical volume "/dev/disk//disk5_p2".
#      pvdisplay: Couldn't find the volume group to which
#       physical volume "/dev/disk//disk4_p2" belongs.
#      pvdisplay: Cannot display physical volume "/dev/disk//disk4_p2".
#      pvdisplay: Couldn't find the volume group to which
#       physical volume "/dev/disk//disk10" belongs.
#      pvdisplay: Cannot display physical volume "/dev/disk//disk10".
#      pvdisplay: Couldn't find the volume group to which
#       physical volume "/dev/disk//disk11" belongs.
#      pvdisplay: Cannot display physical volume "/dev/disk//disk11".
#####################################################################

ShowLVM () {

 export PATH=$PATH:/usr/sbin

 pvs=/tmp/lvm.pvs_$$
 mnttab=/tmp/lvm.mnttab_$$		## does not exists ????

echo "Primary  :Alternate:Size/PE:Free/PE:Controller/Product/HW Path:Log.Volume:Filesys:MinorNr:LVSize:Mirrors:Mount Point"

# 20100624, Reinhard Lubos, added some stuff to handle PVGs and 11iv3 PVs (disk instead of dsk)
 vgdisplay -v 2>/dev/null| awk '

   BEGIN {notprinted=0; OFS=":"}

   /VG Name/ {skip=1; PVG=0}

   /PV Name/ {
     if (PVG == 0) {
       skip=0;
       if (NF==3)
         {if (notprinted) print pl, al, ts, fs;
          pf=split($3,pd,"/")                             # to handle different length of dsk and disk
          pl=pd[4]; al=""; notprinted=1}
       else 
         if (al == "") { af=split($3,ad,"/"); al=ad[4]}   # remember the first PV Link
     }
   }

   /PVG Name/ {
     PVG=1;
   }

   /Total/ {if ( ! skip) ts=$3}
   /Free/  {if ( ! skip) fs=$3}

   END {if (notprinted) print pl, al, ts, fs}

 ' > $pvs

#  process for each physical volume (Prim. Link)

 for line in `cat $pvs`
 do

   dev=$( echo $line | cut -d ':' -f1 )
   hwpath1=$(lssf /dev/d*sk/$dev | awk ' { print $5"/"; } ')
   hwpath2=$(diskinfo /dev/rd*sk/$dev|grep describe| awk {'print $1; }')
   hwvendor=$(diskinfo /dev/rd*sk/$dev|grep product| awk {'print " ("$3")"; }')
   hwpath3=$(lssf /dev/d*sk/$dev | awk ' { print "-"$(NF-1); } ')
   hwpath=$hwpath1$hwpath2$hwvendor$hwpath3
#  search for logical volumes on physical volumes

   lvs=$( pvdisplay -v /dev/d*sk/$dev | awk '

     BEGIN {lvs=""}

     /\/dev/ {
       if (substr($1,2,3) == "dev")
         lvs=sprintf("%s:%s",lvs, substr($1,6))
     }

     /PE   Status/ {exit}

     END {print lvs}

   ')

#  search for mount points of logical volumes

   n=2
   lv=$( echo $lvs | cut -d ':' -f$n )
   cp /etc/mnttab $mnttab

   while test ! -z "$lv"
   do

     mnt=$( grep $lv" " $mnttab | awk '{print $2}' )
     if test -z "$mnt"
     then
       swap=$( swapinfo | grep $lv | awk '{print substr($9,6)}' )
       if test "$swap" = "$lv"
       then
         mnt="***swap***"
       fi
     fi

        fsver=""
        fsver=`fstyp -v /dev/$lv 2>/dev/null |awk '/version/ {print $2;}'`
     fstyp=`fstyp /dev/$lv 2> /dev/null`$fsver || fstyp="raw"
     lvsiz_mir=$( lvdisplay /dev/$lv | awk '

	       BEGIN {OFS=":"}
	       /LV Size/ {lvsiz=$4}
	       /Mirror/ {lvmir=$3}
	      END {printf ("%s:%s", lvsiz, lvmir)}
     ')

     # Fetch Minor Dev. Number
     lvmin=$(ls -l /dev/$lv | awk ' { print $6; } '|cut -c3-)

     if test $n = 2
     then
       echo $line":"$hwpath":"$lv":$fstyp:"$lvmin":"$lvsiz_mir":"$mnt
     else
       echo ":::::"$lv":$fstyp:"$lvmin":"$lvsiz_mir":"$mnt
     fi

     n=`expr $n + 1`
     lv=$( echo $lvs | cut -d ':' -f$n )

   done

 done

 rm $pvs 2> /dev/null
 rm $mnttab 2> /dev/null

}

######################################################################
PrintLVM() {
        ShowLVM | awk '
BEGIN { FS=":" }
	{
	        printf("%-9s %-9s ", $1, $2);    # prim, alt
	        printf("%-18s ", $6);           # vg+lvol
	        printf("%7s %-7s ", $3, $4); # size, free, contr
	        printf("%7s %7s %7s %-7s %-22s", $8, $7, $9, $10, $11);
	        printf("%s", $5);  # hw path + scsi info
	        printf("\n");
	} '
}

PrintLVM
