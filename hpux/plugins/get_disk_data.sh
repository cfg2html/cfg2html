#/bin/sh
TMP_PREFIX=/var/tmp/get_disk_data-$$-
TMP_DEV_LUN=${TMP_PREFIX}DEV_LUN
TMP_DEV_VG=${TMP_PREFIX}DEV_VG

function exit_message
{
rm -f ${TMP_PREFIX}*
echo $*
exit
}
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

rm -f  ${TMP_PREFIX}*
