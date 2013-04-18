# @(#) $Id: getVAlogs.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# This script will gather all of the logs needed to trouble shoot a VA.
# To make this script executable run:
#    chmod 777 getVAlogs
# To run this script execute the script name followed by the array ID.
#    getVAlogs {array ID}
#
# This script was released on January 11th 2002.
#
# January 23rd 2002
#  Added an armdsp_{array ID} to the output file.
#
# January 24th 2002
#  Added access.dat and PanConfigParams to the files gathered.
#  Added a vgdisplay -v capture
#
# January 28th 2002
#  Added a syntax statement if the script is run with no parameters.
#  Added the gathering of 3 different swlist outputs and uname -a.
#  Added absolute paths to all commands.
#


typeset -Z2 year yr mth mn day dy

if [ $# -ne 1 ]
then
 echo
 echo Usage: getVAlogs [array ID]
 echo
 echo This script will gather all of the VA logs for the specified array ID.
 echo These logs will be stored in the current directory.
 echo Please verify that there is at least 200MB free in the current directory.
 echo The file output by this script will be named {hostname}_{array ID}.TAR.gz
 echo
 exit
fi 


echo
echo "getVAlogs is executing..."
/usr/bin/hostname | read host
/usr/bin/date +"%y %m %d" | while read year mth day
do
if (($mth==1))
then
 dy="01"
 mn="12"
 yr="$(($year-1))"
 ts="$mn""$dy""000020""$yr"
else
 dy="01"
 mn="$(($mth-1))"
 yr="$(($year))"
 ts="$mn""$dy""000020""$yr"
fi
done

#ts="011000002002"

echo "Gathering logs for array "$1" on host "$host

mkdir "$1""$ts"
cd "$1""$ts"

/opt/sanmgr/commandview/client/sbin/armdsp -i > armdsp_i.txt
/opt/sanmgr/commandview/client/sbin/armdsp $1 > armdsp_$1.txt
/opt/sanmgr/commandview/client/sbin/armdsp -a $1 > armdsp_a_$1.txt

echo "Gathering event logs"
/opt/sanmgr/commandview/client/sbin/logprn -t all -v -s "$ts" -a $1 > logprn_$1.txt

echo "Gathering features and settings"
/opt/sanmgr/commandview/client/sbin/armfeature -r $1 > armfeature_$1.txt
/opt/sanmgr/commandview/client/sbin/armhost -r -f armhost_$1.txt $1 >/dev/null
/opt/sanmgr/commandview/client/sbin/armsecure -r -f armsecure_$1.txt -p AUTORAID $1 >/dev/null

echo "Gathering host configuration"
/opt/sanmgr/commandview/client/sbin/armtopology $host > armtopology_$host.txt
/sbin/ioscan -fnk > ioscan_$host.txt
/sbin/vgdisplay -v > vgdisplay_$host.txt
cp /var/adm/syslog/syslog.log ./syslog.log_$host.txt
cp /var/adm/syslog/OLDsyslog.log ./OLDsyslog.log_$host.txt
cp /opt/sanmgr/hostagent/config/access.dat ./access.dat_$host.txt
cp /opt/sanmgr/commandview/server/config/PanConfigParams.txt ./PanConfigParams_server_$host.txt
/usr/bin/uname -a > uname_$host.txt
/usr/sbin/swlist -v > swlist_v_$host.txt
/usr/sbin/swlist > swlist_$host.txt
/usr/sbin/swlist -l fileset -a patch_state > swlist_patch_state_$host.txt

echo "Gathering array performance data"
/opt/sanmgr/commandview/client/sbin/armperf -c ARRAY -x COMMA -s "$ts" $1 > armperf_array_$1.txt
/opt/sanmgr/commandview/client/sbin/armperf -c OPAQUE -x COMMA -s "$ts" $1 > armperf_opaque_$1.txt
/opt/sanmgr/commandview/client/sbin/armperf -c LUN -x COMMA -s "$ts" $1 > armperf_lun_$1.txt

cd ..
/usr/bin/tar -cvf "$host"_"$1".TAR "$1""$ts"
rm "$1""$ts"/*
rmdir "$1""$ts"
/usr/contrib/bin/gzip -f -9 "$host"_"$1".TAR
echo ""
echo "Data gathering complete."
echo ""
echo "The output is in the file named: ""$host"_"$1"".TAR.gz"
