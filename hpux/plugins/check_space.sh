# @(#) $Id: check_space.sh,v 5.13 2013-02-09 10:24:35 ralph Exp $
# --=---------------------------------------------------------------------=---
# (c) 1997 - 2013 by Ralph Roth  -*- http://rose.rult.at -*-

# Initial version provided 25-Jul-2003 by Martin Kalmbach
# ---------------------------------------------------------------------------
# check_space.sh - BillHassell
# Based on:  check_space.sh,v 5.10.1.1 2011-02-15
# Optimized using $VG and $BDFTXT to reduce repetitive LVM process calls 


FILTER="-v -E 'byte|^DevFS|Filesystem'"
export LANG=C 
PATH=/sbin:/usr/sbin:/usr/bin:$PATH
# set -vx

echo "================================================================"
for vg in `vgdisplay -v 2>/dev/null|awk -F'/' '/^VG Name/ {print $NF}'|sort -u`
do
    vgexport -p -s -m $vg.maps.temp $vg 1>/dev/null 2>&1
    VGID=`head -1 $vg.maps.temp`
    rm $vg.maps.temp
    VG="$(vgdisplay $vg)"		# Speed up processing with one vgdisplay

    PESIZE=$( echo "$VG" | awk '/PE Size/  {print $4}' )
    MAXPE=$(  echo "$VG" | awk '/Max PE/   {print $5}' )
    MAXPV=$(  echo "$VG" | awk '/Max PV/   {print $3}' )
    CURPV=$(  echo "$VG" | awk '/Cur PV/   {print $3}' )
    ALLPE=$(  echo "$VG" | awk '/Alloc PE/ {print $3}' )
    FREEPE=$( echo "$VG" | awk '/Free PE/  {print $3}' )
    TOTALPE=$(echo "$VG" | awk '/Total PE/ {print $3}' )
    ((ALLOCMB=$PESIZE*$ALLPE))
    ((TOTALMB=$PESIZE*$TOTALPE))
    ((FREEMB=$PESIZE*$FREEPE))
    ((MAXDISKSIZE=$PESIZE*$MAXPE))
    echo "Volumegroup Informations for $vg ($VGID)"
    echo "PESize=$PESIZE MaxPE=$MAXPE MaxPV=$MAXPV CurPV=$CURPV MaxDiskSize=$MAXDISKSIZE MB"
    echo "----------------------------------------------------------------"
    
    echo "Total capacity in Volumegroup $vg               : $TOTALMB MB"
    echo "Allocated capacity in Volumegroup $vg           : $ALLOCMB MB"
    echo "Unallocated capac. in Volumegroup $vg           : $FREEMB MB"

    # possible output of bdf (mounted/unmounted || wrapped/unwrapped)
    # Filesystem          kbytes    used   avail %used Mounted on
    # /dev/vg00/lvol6     524288   21176  499256    4% /tmp
    # /dev/vg00/lvol5     393216    8592  381624    2%  
    # /dev/vg00-old/lvol3
    #                884736  358328  522384   41% /root/old-lvol3
    # /dev/vg00-old/lvol4                                                      
    #               6569984 4417320 2135848   67%                       
    # if number of fields (NF) eq 1 then get next line
    # check if XX% is last val $NF or next to last $(NF-1)
    # take appropriate values from the end
    # MiMe

# One bdf line rather than 3

    BDFTXT="$(bdf $(vgdisplay -v $vg | awk '/LV Name/ {print $3}' | sort -u) 2>/dev/null)"

    printf "Filesystemcapacity in Volumegroup $vg total     : "
    echo "$BDFTXT" |
      awk ' NF == 1 || /^Filesystem/ { next }
           $(NF-1) ~ /%$/ { sum=sum+$(NF-4) } 
           $NF     ~ /%$/ { sum=sum+$(NF-3) } 
           END {printf "%ld MB\n", sum/1024 }'
    

    printf "Filesystemcapacity in Volumegroup $vg used      : "
    echo "$BDFTXT" |
      awk 'NF == 1 || /^Filesystem/  { next }
           $(NF-1) ~ /%$/ { sum=sum+$(NF-3) } 
           $NF     ~ /%$/ { sum=sum+$(NF-2) } 
           END {printf "%ld MB\n", sum/1024 }'
    
    printf "Filesystemcapacity in Volumegroup $vg available : "
    echo "$BDFTXT" |
      awk 'NF == 1 || /^Filesystem/  { next }
           $(NF-1) ~ /%$/ { sum=sum+$(NF-2) } 
           $NF     ~ /%$/ { sum=sum+$(NF-1) } 
           END {printf "%ld MB\n", sum/1024 }'
    echo "================================================================"

done
