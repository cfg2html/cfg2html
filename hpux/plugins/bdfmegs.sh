#!/usr/bin/sh
# @(#) $Id: bdfmegs.sh,v 1.2 2012-07-09 18:59:15 ralph Exp $
# --=---------------------------------------------------------------------=---
# (c) 1997 - 2012 by Bill Hassell


function bdfmegs
{


#      ######  ######  ####### #     # #######  #####   #####
#      #     # #     # #       ##   ## #       #     # #     #
#      #     # #     # #       # # # # #       #       #
#      ######  #     # #####   #  #  # #####   #  ####  #####
#      #     # #     # #       #     # #       #     #       #
#      #     # #     # #       #     # #       #     # #     #
#      ######  ######  #       #     # #######  #####   #####
#      

# @(#) $ Revision: 6.2 Author: Bill Hassell Date: Jul 2012
VERSION=6.2_Jul2012
# Ver 6.2 - Default sort established for column 1
# Ver 6.1 - Added VxVM naming for -N and -V options
# Ver 6.0 - Added MemFS support
#           Changed Usage to TEXT variable
#           Added DUMMY=$EE to turn off enhancements while tracing
# Ver 5.9 - Change NFS version source from mount -p to nfsstat -m
# Ver 5.8 - Added NFS version to -v output
#           Added -e to specify enhancements.
# Ver 5.7 - Fixed bdf alias
#           Added VGVERSION to -v output for 11.31 and later
# Ver 5.6 - Fixed bug with END and awk in TGconv (10.20 and earlier)
# Ver 5.5 - Added snapshot handling (skip summation)
#           Updated gdf/bdf to use -s when available
# Ver 5.4 - Added -M to deselect mountpoints
# Ver 5.3 - Added -d to toggle ONEK between 1024 and 1000 for divisors
#           The default can be changed by editing ONEK
# Ver 5.2 - Fixed -V and -N for VG matches (found vg00 and Vg000 as a match)
#           Using a trailing / as in /dev/vg00/ fixed the match.
# Ver 5.1 - Fixed an alignment error with largefiles and non-vxfs
# Ver 5.0 - Dropped df and fsadm for verbose options - use mkfs instead
#           Changed -V to allow multiple vgNames such as -V vg01,vg03,vgextra
#           Added -N option to not show volume grouPs (opposite to -V)
# Ver 4.0 - Handle errors when looking at source devices w/out 
#           a filesystem or unmounted such as swap and raw devices.
#           Added -s for sums (total, used, avail)
# Ver 3.0 - Rewrote using temp files to speed up code about 10:1
#           Added non-root check for -v option fsadm needs root
#           permission for fsadm to read lvols directly.
# Ver 2.0 - Change Blks to blk/frag size and add largefile status
#           Made: FSTYPE blk/frag and largefile optional with -v
#             to reduce the width of the line
# Ver 1.0 - Original - 1997
# -----------------------------------------------------------------------

# Show bdf in megs or gigs for easy reading

MYNAME=${0##*/} 
HPUXVER=$(uname -r | cut -d. -f2-3 | tr -d .) 

# Assign the usage text 
#  __customized for available filesystems and VGversion

  [[ $HPUXVER -ge 1131 ]] &&
     VGVERSION=", VGversion" ||
     VGVERSION=""

# filesystem types allowed
  set -A FSID hfs vxfs nfs cdfs cifs autofs DevFS memfs  

# Set the unit of measure: 1000 or 1024
# Toggle with -d

typeset -i ONEK=1000	  # divisor is 1000
## typeset -i ONEK=1024	  # divisor is 1024 <<-- value for bdfmegs before 5.3
export ONEK

SORTCOL=1
NUMFLAG=""

USAGETXT="
Usage:  $MYNAME [ -cghlNPpqstuVv ] [ <file(s) or dir(s)> ]
  where: 
    -c # = Sort on column #, default=$SORTCOL
    -d = Toggle divisor (1000 or 1024, current=$ONEK)
    -e = enhancement for percentage and errors 
         d=dim h=halfbright i=inverse u=underline b=blink
    -g = show gigabytes, otherwise megabytes
    -h = Usage
    -l = local (no NFS)
    -M   <mountpoints> = skip (grep -v) mountpoints
    -N   <VGnames> = skip one or more volume groups
         Repeat -N or use commas: -N vg10,vg24 
    -p   ## = highlight % -ge ##
    -P   ## = show only % -ge ##
    -q = suppress header line and no char enhancements
    -s = summarize total, used and available
    -t   <fs> = filesystem: (${FSID[@]})
    -u = usage 
    -v = verbose (FStype, FSversion, largefiles$VGVERSION)
         (VG version needs read permission for devicefile)
    -V   <VGname> = select one or more volume groups
         Repeat -V or use commas: -V vg00,vg01

File(s) or dirpath(s) may be specified to reduce the output of $MYNAME:

       $MYNAME -vg /usr/contrib/bin . .. /var/tmp
     
If $MYNAME is run as bdfgigs (ie, a link), then -g is default.
                                         ($MYNAME ver $VERSION)
"


set -u
PATH=/usr/bin:/usr/sbin
TRACEME=${TRACEME:-false}               # TRACEME non-null = trace on
[ $TRACEME != false ]  && set -x && PS4='[$LINENO]: '



# After the options, path(s) or file(s) may be added to limit 
#   the filesystems to be listed.

# PERFORMANCE NOTE:
#   bdf has historically performed a filesystem sync as it looks
#       at every mountpoint. This can be very costly in time and
#       disk I/O on a busy system. If gdf has been installed, it
#       will use gdf in place of bdf, or bdf -s if available.

# FORMATTING NOTE:
# The width of the source filesystem will be adjusted to the
# longest path (ie, NFS or other long device filename).  All
# fields are in megs (defined as Kbytes/$ONEK) or gigs.  Field 
# widths for sizes are 7 digits for multi-terabyte capability.

# The -d option will toggle ONEK to the non-default value
#   Set the default value here. Historically, bdfmegs has used 1024
#   but result did not quite match bdf or df -k. Starting with ver 5.3
#   and later, the distributed versian of bdfmegs will use 1000.
#   For backward compatibility, set ONEK=1024.

TEMPDIR=/var/tmp/$MYNAME.$$             # tempfile setup and cleanup
mkdir $TEMPDIR
chmod 700 $TEMPDIR
BDFLIST=$TEMPDIR/bdflist
ERRLIST=$TEMPDIR/bdflist.error
trap "rm -rf $TEMPDIR;exit" 0 1 2 3 6 11 15

# speedup df for 11.23 and up
[ $HPUXVER -ge 1123 ] && FASTDF="-s" || FASTDF=""

# Initial values

typeset -R5  PERCENT
typeset -R6  FSTYPE
typeset -R2  FSVER
typeset -i   SUMTOT=0
typeset -i   SUMUSED=0
typeset -i   SUMAVAIL=0

# filesystems

FSQTY=${#FSID[@]}               # qty of known filesystems
FSONLY=""                       # used if -t <fs-type> specified
NODEVREAD=false                 # flag in case -v can't read devfile ver
PCTLIMIT=0                      # 0=no highlight
PCTLIMITONLY=false              # true=suppress lines under pct limit

# terminal enhancements - error messages and -p option
# set char enhancments only if interactive

if tty -s 
then 
# set char enhancments only if interactive (ie, TERM is set)
#  If TERM is not set or the TERM value is not found in terminfo
#  files, then enhancements are null.
  export HB=$(tput dim   2>/dev/null) # dim text
  export HV=$(tput smso  2>/dev/null) # 1/2 bright inverse
  export IV=$(tput bold  2>/dev/null) # inverse
  export UL=$(tput smul  2>/dev/null) # underline
  export BL=$(tput blink 2>/dev/null) # blink
  export EL=$(tput el    2>/dev/null) # clear to end of line 
  export ED=$(tput ed    2>/dev/null) # clear to end of display 
  export EE=$(tput sgr0  2>/dev/null) # end all enhancements
else
  HB="" HB="" IV="" UL="" BL="" EL="" ED="" EE=""
fi



#########################
#   F U N C T I O N S   #
#########################


###########
#  Usage  #
###########

function Usage
{
 # Minimum Usage function
 # Requires $USAGETXT to be assigned externally.
 #   Typically, this is done at the start of a script
 #   to act as both documentation and a Usage message

  TRACEME=${TRACEME:-false}      # TRACEME non-null = trace on
  [ $TRACEME != false ]  && set -x && PS4='[$LINENO]: '
  MYNAME=${MYNAME:-${0##*/}}

# Was anything passed to Usage?

  if [ $# -gt 0 ]
  then
     ERRMSG="$*"
     WIDTH=${#ERRMSG}
     eval typeset -Z$WIDTH BAR=0
     BAR="$(echo "$BAR" | tr "0" "=")"
     echo "\n\n$BAR" 
     echo "$ERRMSG"
     echo "$BAR"
  fi

# Show the usage message - handle missing USAGETXT

  USAGETXT=${USAGETXT:-NotSet}
  if [[ "$USAGETXT" = "NotSet" || "$USAGETXT" = "" ]]
  then
     echo "\n$MYNAME: USAGETXT is null or not assigned" ||
     exit 1
  fi
  echo "$USAGETXT"

  [[ $# -eq 0 ]] && exit 0 || exit 1  # No Usage error = exit 0

}


function TGconv
{

# Usage: TGconv number magnitude sum
#   number = size in Kbytes
#   magnitude = $ONEK or $ONEK*$ONEK (megs or gigs for results)
#   sum = 0 (normal) or 1 (sum has been normalized to megs or gigs)

# Routine to take a number (in KB) make it fit in 7 characters 
#    with G or T suffix if needed. Will calculate megs or gigs
#    based on magnitude. Because sumtotals can exceed 32 bit
#    integers, the sums are taken in the current units of
#    measure (megs or gigs). So sum=1 bypasses the divisor.

  TRACEME=${TRACEME:-false}               # TRACEME non-null = trace on
  [ $TRACEME != false ]  \
    && set -x && PS4='[$LINENO]: '

# Check the number after magnitude has been handled
#   Convert to GB or TB if still too big for a 7-char field
#   Prints 7 char number field and sets MAG to " " or g, t, p

  DIV=$2 
  if [ $DIV -le $ONEK ] 
  then
     MAG1=g		# Gigabyte suffix for > 9999
     MAG2=t		# Terabyte suffix for > 9999999
  else
     MAG1=t		# Terabyte suffix for > 9999
     MAG2=p		# Petabyte suffix for > 9999999
  fi

  SUMFLAG=$3
  [ $SUMFLAG -eq 0 ] \
    && NUM=$(echo "$1 $DIV" | awk '{printf "%d", $1/$2}') \
    || NUM=$1
  NUMLEN=${#NUM}
  MAG=" "

  # reformat based on the magnitude of the value
  if [ $NUMLEN -le 4 ]
  then
     VAL="$NUM"
  elif [ $NUMLEN -le 7 ]
  then
     VAL="$(print -n "$NUM" | awk '{printf "%7.1f",$1/'"$ONEK"'}')"
     MAG="$MAG1"
  else
     VAL="$(print -n "$NUM" | awk '{printf "%7.1f",$1/'"$ONEK*$ONEK"'}')"
     MAG="$MAG2"
  fi
  printf "%8s" "$VAL$MAG"
}


###############################
#   M A I N   P R O G R A M   #
###############################

# Construct a multiple -e list of filesystem types based on
#    the size of the FSID array. EOPT=" -e hfs -e nfs -e vxfs"ID

EOPT=""
for MYFS in ${FSID[@]}
do
   EOPT="$EOPT -e $MYFS"
done

# Process all options

ENH="$UL"	# default enhancement is underline
DUMMY="$EE"	# to turn off $UL when tracing script
VGNOT=""
NOSYNC=""
VGONLY=""
NOTMNT=""
LOCALFS=""
SUMS="false"
VERBOSE="false"
NOHEADER="false"
GIGABYTES="false"

while getopts ":c:de:lghqiM:N:p:P:st:uvV:" OPTCHAR
do
  case $OPTCHAR in
       l) LOCALFS="-l" 
	  ;;
       q) NOHEADER="true"       # also turn off header and char enhancements
          HB="" HB="" IV="" UL="" BL="" EE=""
          ;;
       g) GIGABYTES=true
          ;;
       d) [ $ONEK -eq 1000 ] && ONEK=1024 || ONEK=1000
	  ;;
       e) [[ $OPTARG = d ]] && ENH=$HB
          [[ $OPTARG = h ]] && ENH=$HV
          [[ $OPTARG = i ]] && ENH=$IV
          [[ $OPTARG = u ]] && ENH=$UL
          [[ $OPTARG = b ]] && ENH=$BL
          ;;
       s) SUMS="true" 
	  SUMTOT=0
	  SUMUSED=0
	  SUMAVAIL=0
	  ;;
       c) SORTCOL="$OPTARG"   	# sort by field (1-6)
	  if [ "$(print -n "$SORTCOL" | tr -d '[:digit:]')" = "" ]
	  then
	     [ $SORTCOL -lt 1 -o $SORTCOL -gt 6 ] \
	       && Usage "sort field ($SORTCOL) must be 1-6"

# set num or text sort (cols 2-5 = nums)

	     [ $SORTCOL -gt 1 -a $SORTCOL -le 5 ] && NUMFLAG="n" || NUMFLAG=""
	  else
	     Usage "Sort field ($SORTCOL) is not numeric"
	  fi
	  ;;
       t) FSONLY="$OPTARG"              # validate filesystem type
          if [ $(echo "$FSONLY" | grep -c $EOPT) -eq 0 ]
          then
             Usage "FS type must be one of: ${FSID[@]}"
          else
             FSONLY="-t $FSONLY"
          fi
          ;;
   P | p) PCTLIMIT="$OPTARG"            # highlight percent limit
          [ ! -z "$(echo $PCTLIMIT | tr -d '[:digit:]')" ] \
            && Usage "-p $PCTLIMIT$EE$IV not a number 1-100" 
          [ $PCTLIMIT -gt 100 -o $PCTLIMIT -lt 1 ] \
            && Usage "-p $PCTLIMIT$EE$IV not in range 1-100" 
          [ $OPTCHAR = P ] && PCTLIMITONLY=true
          ;;
   u | h) Usage 
	  ;;
       v) VERBOSE=true 
	  ;;
       M) for MNT in $(echo $OPTARG | tr "," " ")       # handle multiple mountpoints
          do
             NOTMNT="-e ${MNT%*/}$ $NOTMNT" 		# Anchor search to end of each bdf line
          done						# Drop trailing / if any
          ;;
       N) for VG in $(echo $OPTARG | tr "," " ")        # handle multiple VGs
          do
             VGNOT="-e ^/dev/${VG##*/}/ -e ^/dev/vx/dsk/${VG##*/}/ $VGNOT"  # normalize to VGname then add /dev dirs
          done
          ;;
       V) for VG in $(echo $OPTARG | tr "," " ")	# handle multiple VGs
	  do
             VGONLY="-e ^/dev/${VG##*/}/ -e ^/dev/vx/dsk/${VG##*/}/ $VGONLY" # normalize to VGname then add /dev dirs
	  done
	  ;;
       *) eval "ERROPT=\$$(($OPTIND-1))"
	  [[ "$ERROPT" = "-?" ]] &&
             Usage ||
             Usage "Invalid option $ERROPT"
          ;;
  esac
done
shift $(($OPTIND -1))

[[ $NOHEADER = true ]] && ENH=""

# Setup Mbytes or Gbytes
########################################################

if [ $GIGABYTES = false ]
then
   if [ "$MYNAME" = "bdfgigs" ]
   then
      let MAGNITUDE=$(($ONEK*$ONEK))    # mega...
      GIGABYTES=true
   else
      MAGNITUDE=$ONEK			# kilo...
      GIGABYTES=false
   fi
else
   let MAGNITUDE=$(($ONEK*$ONEK))       # mega...
   GIGABYTES=true
fi

# Any arguments?

[ $# -gt 0 ] && SPECIFY="$@" || SPECIFY=""


#####################################
# Get a list of mountpoints 
# For bdf, process the list and paste the 2-line entries together
#    into a file to speed things up

# Use gdf rather than bdf when available
#   gdf does not try to sync which is much faster (but less up to date)
#   Look for G_df as well as gdf, choose file > 500k in case gdf is
#   a wrapper script. If gdf isn't available, use bdf -s if possible

export BDF=/usr/bin/bdf
if [ -x /usr/local/bin/gdf ]
then
   [ $(cat /usr/local/bin/gdf | wc -c) -gt 500000 ] \
      && BDF="/usr/local/bin/gdf -k --no-sync"
elif [ -x /usr/local/bin/G_df ]
then
   [ $(cat /usr/local/bin/G_df | wc -c) -gt 500000 ] \
      && BDF="/usr/local/bin/G_df -k --no-sync"
else
   /usr/bin/bdf -s / > /dev/null 2>&1
   RTN=$?
   [ $RTN -eq 0 ] && BDF="/usr/bin/bdf -s"
fi

###################################################
# Run bdf listing into a file
# Get error messages into a separate file for later
# The mechanism is to read all the params from each line.  If the
#    line has been split, only the source is on line 1 so the rest
#    of the params are null when read, so if $TOT is blank, read
#    the next line for the missing params.

$BDF $LOCALFS $FSONLY $SPECIFY 2>$ERRLIST | \
  while read FS TOT USED AVAIL PERCENT MNT
  do
    if [ $FS != "Filesystem" ]
    then
       if [ "$TOT" = "" ]
       then
         read TOT USED AVAIL PERCENT MNT
       fi
       echo  $FS $TOT $USED $AVAIL $PERCENT $MNT
    fi
  done > $BDFLIST

#################################################
#   Check if we are selecting and/or sorting    #
#################################################
#
# NOTE: VGNOT replaces any selection for VGONLY.
#  The two options are mutually exclusive.
#
##################################################



################################
#  Select VGnames (-V option)  #
################################

if [ "$VGONLY" != "" ]
then
   BDFTEXT=$(cat $BDFLIST)		# assign the list to a variable
   echo "$BDFTEXT" | grep $VGONLY > $BDFLIST
fi


#########################################
#  delete selected VGnames (-N option)  #
#########################################

if [ "$VGNOT" != "" ]
then
   BDFTEXT=$(cat $BDFLIST)		# assign the list to a variable
   echo "$BDFTEXT" | grep -v $VGNOT > $BDFLIST
fi


##############################################
#  delete selected mount points (-M option)  #
##############################################

if [ "$NOTMNT" != "" ]
then
   BDFTEXT=$(cat $BDFLIST)		# assign the list to a variable
   echo "$BDFTEXT" | grep -v $NOTMNT > $BDFLIST
fi


###############################
#  Sort the list by $SORTCOL  #
###############################
# NUMFLAG sets text versus numbers
 
if [ "$SORTCOL" != "" ]
then
   cp $BDFLIST $BDFLIST.tmp
   sort  -${NUMFLAG}k$SORTCOL $BDFLIST.tmp > $BDFLIST
fi


############################
#  Automatic field sizing  #
############################

# Find the longest source string with a sweep through $BDFLIST
# Minimum length is 12 so typeset will pad on the right when
# needed.


MAXLEN=12
while read SOURCE DUMMY
do
   [ ${#SOURCE} -gt $MAXLEN ] && MAXLEN=${#SOURCE}
done < $BDFLIST

# Variable width typesets here
#
#  By using eval, a variable typeset instruction can be created
#  and then executed as part of the inline script.

#  First is for the filesystem source string
#  Second is to pad the title. Note that PAD must be typeset to
#  a value greater than 0, so subtract 11 for the evaluation.
#  (the minimum width for a source directory is 12 chars)

eval "typeset -L$MAXLEN FS"
eval "typeset -L$(( MAXLEN - 11 )) PAD=' '"

# Print the title line. $PAD is used to prorvide proper spacing for
#   short to long source filesystem names.  This must match the
#   evaluated typeset value for $FS above.  We'll split the line
#   at %Used in order to have plain and verbose versions.

[ $GIGABYTES = "true" ] && BYTES=Gbytes || BYTES=Mbytes
[ $NOHEADER = "true" ] || \
    echo "File-System $PAD $BYTES    Used   Avail %Used \c"

if [ $NOHEADER = "false" ]
then
   if $VERBOSE
   then
      [[ $HPUXVER -ge 1131 ]] &&
         VGVERSION="VGv " ||
         VGVERSION=""
      echo "  Type Vr Lrg ${VGVERSION}Mounted on"
   else
      echo "Mounted on"
   fi
fi

###################################################################
# Walk through each mountpoint gathering info
# To track down the filesystem type, use mount -p in a
#   variable so it can be searched faster in memory

MOUNTP=$(mount -p)

# long while read -- see < $BDFMEGS at end

SNAPS=false
while read FS TOT USED AVAIL PERCENT MNT
do

# Check for a snapshot volume by looking for snapof=
# typical: /dev/vg00/lvol9  /mnt1   vxfs  ro,ioerror=mwdisable,snapof=/dev/vg00/lvol5,snapsize=500000,dev=40000009   0 0
# parse the options into 1-liners such as snapsize=500000
# snapsize is in kbytes

  SNAPOPTS=$(echo "$MOUNTP" \
	   | grep ^$FS \
	   | awk '/snapof=/{print $4}' \
	   | tr "," "\n")
  if [ "$SNAPOPTS" != "" ]
  then
     SNAPS=true
     SNAPOF=$(echo "$SNAPOPTS" | awk -F= '/snapof/{print $2}')
     SNAPSIZE=$(echo "$SNAPOPTS" | awk -F= '/snapsize/{print $2'})
  fi 

# Compute megs or gigs with $MAGNITUDE ($ONEK or $ONEK*$ONEK)
# Exception for snaps - MUSED=snapsize from mount -p, MAVAIL="snap"

  MTOT="$(TGconv $TOT $MAGNITUDE 0)"
  [ "$SNAPOPTS" = "" ] \
    && MUSED="$(TGconv $USED $MAGNITUDE 0)" \
    || MUSED="$(TGconv $SNAPSIZE $MAGNITUDE 0)"
  [ "$SNAPOPTS" = "" ] \
    && MAVAIL="$(TGconv $AVAIL $MAGNITUDE 0)" \
    || MAVAIL="   snap "

  # Setup for highlighting pct limit fields

  I=""
  E=""
  if [ $PCTLIMIT -gt 0 ]
  then
     PCT=$(echo $PERCENT | tr -d %)
     if [ $PCT -ge $PCTLIMIT ] 
     then
        I=$ENH
        E=$EE
     fi
# show only over pct lines?

     [ $PCT -lt $PCTLIMIT -a $PCTLIMITONLY = "true" ] && continue
  fi
  [ "$SNAPOPTS" != "" ] && PERCENT="n/a"

# Sums can easily overflow - change to megs before computing

  if [ $SUMS = "true" -a "$SNAPOPTS" = "" ]
  then
     MEGTOT=$((TOT/$ONEK))
     MEGUSED=$((USED/$ONEK))
     MEGAVAIL=$((AVAIL/$ONEK))
     MEGGIG=$((MAGNITUDE/$ONEK))
     let SUMTOT=$SUMTOT+$(echo $MEGTOT \
         | awk '{printf "%d", int($1/'$MEGGIG'+.5)}')
     let SUMUSED=$SUMUSED+$(echo $MEGUSED \
         | awk '{printf "%d", int($1/'$MEGGIG'+.5)}')
     let SUMAVAIL=$SUMAVAIL+$(echo $MEGAVAIL \
         | awk '{printf "%d", int($1/'$MEGGIG'+.5)}')
  fi

  if [ "$MNT" != "" ]                                # skip unmounted
  then
    echo "$FS $MTOT$MUSED$MAVAIL$I$PERCENT$E \c"     # show first half of line
    if $VERBOSE
    then

#########################
#  Filesystem versions  #
#########################


###################################################################################
# VxFS filesystem version can be found with fstyp or mkfs -m but requires 
#    the device file be readable writable current user. By using mkfs -m, the data
#    is available very quickly. Note that no writes occur -- mkfs and fsadm always
#    check even when reporting read-only data.

# Typical mkfs -m (vxfs only):
# mkfs -m /dev/vg00/lvol8
# mkfs -F vxfs -o ninode=unlimited,bsize=8192,version=4,inosize=256,logsize=256,largefiles /dev/vg00/lvol8 2048000
#   field 7: version=3
#   field 10: largefiles (nolargefiles)

# Find VxFS version - use mount -p to ID the filesystem type
# NOTE: search by mountpoint as cifs may have \\ source names from WinJunk

       FSTYPE=$(echo "${MOUNTP}" \
              | awk -v MNT=${MNT} '{if ($2==MNT) {print $3}}')
       MKFSINFO=""
       if [ "$FSTYPE" = "  vxfs" ]
       then
          if [ -w $FS ]                 # can we write the source devicefile?
          then
	     MKFSINFO="$(mkfs -m $FS 2>/dev/null | tr -s "," " ")"
	     if [ "$MKFSINFO" = "" ]
	     then
		FSVER="--"
		NODEVREAD=true
	     else
	        FSVER=$(echo "$MKFSINFO" | awk '{print $7}'|cut -f2 -d=)
	     fi
          else
             FSVER="--"
             NODEVREAD=true	# flag that /dev/vg??/lvol?? can't be read
          fi
       elif [ "$FSTYPE" = "   nfs" ] 
       then

####################################################################################
# Find NFS version from nfsstat -m (mount -p doesm't always return version)
#
#   /mnt2 from atl4:/tmp  (Addr 10.11.10.240)
#    Flags:   vers=2,proto=udp,auth=unix,hard,intr,dynamic,devs,rsize=8192,wsize=8192,retrans=5
#    All:     srtt=  0 (  0ms), dev=  0 (  0ms), cur=  0 (  0ms)
#   /mnt3 from atl1:/var/tmp/Packages  (Addr 10.11.10.200)
#    Flags:   vers=3,proto=tcp,auth=unix,hard,intr,link,symlink,devs,rsize=32768,wsize=32768,retrans=5
#    All:     srtt=  0 (  0ms), dev=  0 (  0ms), cur=  0 (  0ms)
#
# NOTE: order of arguments in flags is not guarenteed. 
#
         NFSLINE=$(nfsstat -m |
             awk -v MNT=${MNT} '{if ($1==MNT) {printf;getline;print}}' | 
             cut -f 1,3 -d:) 
         for NFSFLAG in $(echo "$NFSLINE" | awk -F : '{print $2}' | tr -s "," " ")
         do
           if [ $(echo $NFSFLAG | grep -ci vers=) -gt 0 ]
           then
              FSVER=$(echo "$NFSFLAG" | cut -d= -f2)
              break 
           fi
         done
       else 
          FSVER="na"		# or not applicable 
       fi

# largefiles - fsadm, mkfs and df can report that state
# Only df can report without write capability, but it is really slow

       if [ "$MKFSINFO" = "" ]
       then
	  LG=" --"
       else
          [ $(echo "$MKFSINFO" | awk '{print $10}' \
	    | grep -ic nolargefiles) -eq 0 ] && LG="yes" || LG=" no" 
       fi

#######################
#      VG version     #
#  (11.31 and later)  #
#######################

       if [[ $HPUXVER -ge 1131 ]]
       then
          VGOK="$(vgdisplay ${FS%/*} 2> /dev/null)"
          RTN=$?

# handle vgdisplay for non-VG sources
          if [[ $RTN -ne 0 ]] 
          then
             VGVER="n/a  "
          else
             VGVER=$(echo "$VGOK" | awk '/VG Version/{print $3," "}')
          fi
       else
          VGVER=""
       fi
       
       echo "$FSTYPE $FSVER $LG ${VGVER}$MNT"
    else
       echo "$MNT"
    fi
  else

# this source is not mounted

    echo "$FS is not mounted or has no filesystem" >> $ERRLIST
  fi
done < $BDFLIST

# Summary of displayed lvol sizes
# BYTES=Mbytes or Gbytes (title line)
#   echo "File-System $PAD $BYTES    Used   Avail %Used \c"
# currently 8-char fields for total, used, avail. trailing char
# will be g,t,p if number is more than a 4 or 7 digit value

# Sum totals displayed here - Sums are in the current unit 
#    of measure (megs, gigs) so call TGconv with 1 for no conversion.

if [ $SUMS = "true" ]
then
   FSUMTOT=$(TGconv $SUMTOT $MAGNITUDE 1)
   FSUMUSED=$(TGconv $SUMUSED $MAGNITUDE 1)
   FSUMAVAIL=$(TGconv $SUMAVAIL $MAGNITUDE 1)
   eval "typeset -L$MAXLEN DASHES"
   DASHES="-- sum totals ------------------------------------------------"
   echo "$DASHES $FSUMTOT$FSUMUSED$FSUMAVAIL  --- sum totals ---"
   [ "$SNAPS" = "true" ] && echo "\n   ${ENH}Note: snap lvols not counted in sums$EE"

fi

# In case -v was specified and one or more device files were not
#   readable by the current user, add a note. To keep notes together,
#   check for $SNAPS

if $NODEVREAD
then
  [ "$SNAPS" = "false" -o "$SUMS" = "false"  ] && echo
  echo "\"--\"for Vr means devicefile info not readable by user $(id -un)" >> $ERRLIST
fi

######################
#   Error messages   #
######################

# Indent and highlight the error messages for readability

if [ -s $ERRLIST ]
then
   echo
   echo "Error messages:"
   cat $ERRLIST | while read
   do
      echo "   ${ENH}$REPLY$EE"
   done
fi

# trailing blank line unless -q (no header line)
[ "$NOHEADER" = "false" ] && echo 

} # bdfmegs


if [ -z "$CFG2HTML" ]           # only execute if not called from
then                            # cfg2html directly!
        bdfmegs "$@"
fi

