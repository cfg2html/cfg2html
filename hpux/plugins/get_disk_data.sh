#/bin/sh

# @(#) $Id:$
# -------------------------------------------------------------------------

TMP_PREFIX=/var/tmp/get_disk_data-$$-
TMP_DEV_LUN=${TMP_PREFIX}DEV_LUN
TMP_DEV_VG=${TMP_PREFIX}DEV_VG

function exit_message
{
rm -f ${TMP_PREFIX}*
echo $*
exit
}

function ioscan_1131 {
/usr/sbin/ioscan -m lun|awk '/^disk/ {print "\n"} {printf "%s ", $0} END {print "\n"}'|while read f1 f2 lun rest
 do
    for dev in $rest
    do
       [[ $dev = @(/dev/[rcd]*isk/disk[0-9]*) ]] && echo $dev $lun
    done
 done | sort > $TMP_DEV_LUN
 [[ $? != 0 ]] && exit_message "$0: error in ioscan"

 /usr/sbin/vgdisplay -v 2>/dev/null | awk '/^VG Name/ {vg=$3} /PV Name/ {print $3, vg}'|sort -u > $TMP_DEV_VG
 [[ $? != 0 ]] && exit_message error in vgdisplay

 join -a 1 -o 2.2,1.1,1.2 $TMP_DEV_VG $TMP_DEV_LUN | sort
}

function ioscan_11i {
/usr/sbin/ioscan -kfnC disk|awk '/^disk/ {print "\n"} {printf "%s ", $0} END {print "\n"}'|while read f1 f2 lun rest
 do
    for dev in $rest
    do
       [[ $dev = @(/dev/[rd]*isk/disk[0-9]*) ]] && echo $dev $lun
    done
 done | sort > $TMP_DEV_LUN
 [[ $? != 0 ]] && exit_message "$0: error in ioscan"

 /usr/sbin/vgdisplay -v 2>/dev/null | awk '/^VG Name/ {vg=$3} /PV Name/ {print $3, vg}'|sort -u > $TMP_DEV_VG
 [[ $? != 0 ]] && exit_message error in vgdisplay

 join -a 1 -o 2.2,1.1,1.2 $TMP_DEV_VG $TMP_DEV_LUN | sort

}


# MAIN
os_rel=$(uname -r)
case $os_rel in
    B.11.11|B.11.23) ioscan_11i ;;
    B.11.31) ioscan_1131 ;;
esac

# cleanup
rm -f  ${TMP_PREFIX}*
