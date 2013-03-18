# Mini Status Collector, re-written Oct. 2010
############################################################
# @(#) $Id: get_ministat.sh,v 5.11 2011-07-22 09:52:38 ralproth Exp $
# $Log: get_ministat.sh,v $
# Revision 5.11  2011-07-22 09:52:38  ralproth
# cfg5.13-33157: ? Workaround/Memory troubleshooting
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.13  2010-10-05 20:42:04  ralproth
# cfg4.84-24823: Total rewritten, using PA-RiSC binary
#
# Revision 4.12  2010-09-28 17:11:34  ralproth
# Revision 4.10.1.1  2008/02/28 02:55:04  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.17  2008/02/28 02:55:03  ralproth
# Revision 3.16  2008/02/26 20:30:12  ralproth
# Revision 3.11  2007/03/20 01:01:00  ralproth
# Revision 3.10  2004/09/09 18:53:48  ralproth
# Revision 2.1   2003/05/20 13:39:40  ralproth
############################################################

# Meulen, H.R. van der (Hans) - 14.03.2007 13:40 Today I took a look at the
# plugin get_ministat.sh and found that the number of cpu’s in a vpar was not
# calculated correct. The number of cpu was added to the number of io devices. I
# think that it does not matter if your on a n-par or v-par or physical machine
# the initial cpu’s is calculated correct.
# ioscan -k | grep processor | wc -l works fine for the three of them

SYSSMALL=$(dirname $0)/syssmall.hppa 
[ -x $SYSSMALL ] || exit 42

echo "Hostname          " $(hostname)
echo "Model             " $(getconf MACHINE_MODEL)
echo "uname -a          " $(uname -a)
echo "Software ID       " $(getconf MACHINE_SERIAL) " (not available on every machine)"

# CPU=$(ioscan -k|grep processor|wc -l)
CPUMEM=$($SYSSMALL)

    # if [ -r /stand/vpmon ]
    # then
    # 	# HOSTNAME=`vparstatus -w | awk '{ print $6 }'`
    #         HOSTNAME=`vparstatus -wM`
    # 	CPUS=`vparstatus | grep $HOSTNAME | awk '!/Up/ { print $4, $5 }'`
    #         # this seems to be wrong with vPars 5.xx "vparstatus"
    # 	CPU1=`echo $CPUS | awk '{ print $1 }'`
    # 	CPU2=`echo $CPUS | awk '{ print $2 }'`
    #
    # 	# (( CPU = CPU1 + CPU2 ))
    #         CPU=$CPU1"/"$CPU2
    #         echo "vPar CPUs Count   " $CPU" (may include iCOD/iCAP CPUs)"
    # fi
    #

echo "# CPUs (Cores)    " $(echo $CPUMEM|cut -f1 -d\;)
echo "# Disks           " $(ioscan -k|grep disk|grep -iv -E 'DVD|D-ROM'|awk ' { sum++;a[$3]++;} END { print "Total = "sum; for (i in a) print "- "a[i]" x " i; }')  ## wc -l

MEM=$(echo $CPUMEM|cut -f2 -d\;)
# MEM=$(head -l -n 2200 /var/adm/syslog/syslog.log|grep Physical|grep avail|cut -c 34-|dos2ux)
# [ -z "$MEM" ] && MEM=$(dmesg|grep Physical|grep avail|cut -c 4-|dos2ux)

## fix for hpux 11i v3, thx: Steve Yakes
#  # grep System /var/adm/syslog/syslog.log
# Mar 23 18:58:37 xxxx-xxx vmunix: System :  140209 MB            140209 MB            140209 
# **FIXME**   $MEM should NOT be empty....
[ -z "$MEM" ] && MEM=$(grep System /var/adm/syslog/syslog.log|grep vmunix:|grep " MB" |grep " : " | tr -d ':'| awk -F"System" '{print $2;}')
echo "Memory            " $MEM" GB"

# Note: on 11i Version 1 the command "getconf MACHINE_SERIAL" would not return
# the serial number of the system (it only gives the software id not the serial
# number, if it gives anything at all). From 11i Version 1.5 this command works
# correctly on IA and PA systems and should be used in preference to getsn (note
# that getsn will never be ported to Itanium systems).

swapinfo -tam | awk '

/dev/	{ dev += $2; lvol++ };
/memory/   { mem += $2; };

{}

END {
	printf ("Deviceswap         %.3f GB\n", dev/1024);
	#printf ("# of devices = %ld\n", lvol);
	printf ("Memory swapable    %.3f GB\n", mem/1024);     ## %ld

	#printf  ("'$(hostname)';%ld;%ld;%ld;\n", lvol, dev, mem);
}
'

exit 0
