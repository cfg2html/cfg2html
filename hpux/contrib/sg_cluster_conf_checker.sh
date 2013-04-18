# set -vx
# ---------------------------------------------------------------------------
# This plugin is part of the cfg2html package for HP-UX
# --------------------------------------------------------------------------- 
# SGCCC -  @(#) $Id: sg_cluster_conf_checker.sh,v 5.14 2013-02-09 10:24:35 ralph Exp $
# Initial creation and copyright: 08.07.2008, (c) by Ralph Roth, http://rose.rult.at
# ---------------------------------------------------------------------------
# assumes the following to be true:
# package name is $SGCONF/package_name directory
# ssh password less access to and from all cluster nodes
# Serviceguard A.11.19 or higher installed!
#
# Checks Serviceguard cluster consistency, inetd settings and
# also checks binaries (Kernel, Serviceguard, LibC) for unique patch level
# ---------------------------------------------------------------------------
# Distributed Systems Administration Utilities (DSAU) may also be a solution...
# New with Serviceguard A.11.20:
#       cmcompare - Compares files on multiple nodes
# ---------------------------------------------------------------------------

# check if you are root, if not terminate the script!
[ $(id -u) -ne 0 ] && (echo "Error: Get ROOT!"; exit 1) # root check

# gets cluster name, e.g. nvscl2
# or: cmviewcl -l cluster

# /etc/cmcluster # cmquerycl
# 
# Cluster Name   Node Name
# UNUSED
#                nry0
# 
# nvscl01
#                nka0-v01
#                nka1-v01

[ -x /usr/sbin/cmviewcl ] || exit 3             # no serviceguard?

# CL=$(cmquerycl 2>/dev/null | grep -v -e ^"  " -e ^$ | tail +2| awk '{if ($1 =="") print("Standalone"); else printf("%s", $1); }')
# better
CL=$(cmviewcl -l cluster | grep up|awk '{if ($1 =="") print("No_Cluster"); else printf("%s", $1); }') 

set -A nodes  
HOST=$(hostname)
GETPATCH="yes"
GETCMBIN="yes"
   
echo "# Serviceguard "$(cmversion)" Cluster Configuration Checker [SGCCC] on cluster $CL"
echo "# ---------------------------------------------------------------------------"
echo "# \$Id: sg_cluster_conf_checker.sh,v 5.14 2013-02-09 10:24:35 ralph Exp $\n"

#### fetch Serviceguard Environment ####
. ${SGCONFFILE:=/etc/cmcluster.conf}
FIN="false"
CIS="no"
while [ $FIN = "false" -a $# -gt 0 ]
do 
    case "xy$1" in
        xy-cfg)                 # grep cmgetconf for some settings
                cmgetconf|grep -E "^QS_|_NAME|_INTERVAL|_TIMEOUT" |grep -v ^#|awk '{ printf "%-30s %s\n", $1, $2 ;}';
                exit 0;
                ;;
        xy-quorum)              # greps cmviewconf for Quorumservices 
                hostname 
                cmviewconf | grep "^   qs " 
                exit 0;
                ;;            
        xy-cis)                 # check internal start/stop/sap scripts (A.11.19++)
                CIS="yes";        
                ;;
        xy-autocl)              # check the autostart parameter
                grep "AUTOSTART_CMCLD=" /etc/rc.config.d/cmcluster
                exit $?
                ;;
        xy-autorun)             # checks packages in /etc/cmcluster for AUTO_RUN parameter
                grep ^AUTO_RUN /etc/cmcluster/*/*.c*|grep -v  -e "/VxVM-" -e "cfs/SG-CFS"
                exit $?
                ;;                 
        xy-nopatch)             # don't check for Kernel patches
                GETPATCH="no" 
                ;;
        xy-bin)                 # check binary files like cmclconfig
                SGBIN="yes"         
                ;;               
        xy)	
                FIN="true"
                ;;          
        xy-nocmbin)             # don't check libc, cm* for patch level
                GETCMBIN="no"
                ;;        
        xy-*)                   # prints above usage
                grep "xy-.*)" $0 |grep -v grep| awk -Fxy '{ print $2; }'
                echo ""
                echo "$0: Wrong parameter ($1)!\nSee source code above for supported parameter!"; 
                echo "Hint: sh -x $0 to debug"
                echo "Hint: $0 -nopatch -nocmbin | grep -v -e identd -e /dev/vg for mixed 11.23 and 11.31 environments"
                exit 2;
                ;;
    esac
    shift
done

# VPM=$(test -s /stand/vpmon)     # vpar Monitor? currently not implemented!
# echo $VPM

### get all running Serviceguard packages
SGP=$(cmviewcl -l package | grep ^"    " |grep -v STATUS | awk '{ print $1; }')

for i in $SGP   # for each SG packet do....
do
	PNODES=$(cmviewcl -v -p $i | grep -e Primary -e Alternate | grep -v unknown | awk ' { printf ("%s ", $4); } ')
	# $i = package
	# $j = node
	typeset -i n=0 
	for j in $PNODES
	do
 	    #if [ "$HOST" != "$j" ]
	    #then
            #echo "$CL.$i@$j" # checked from $HOST"      # cl,node,pkg $HOST
            file="/tmp/sgcc_"$CL"_"$j"_"$i".tmp"
            echo "\n" > $file     # reset
            nodes[$n]=$file
            SGFILES="/etc/cmcluster.conf"
            [ "$SGBIN" = "yes" ] && SGFILES=$SGFILES" $SGCONF/cmclconfig"
            [ -r $SGCONF/cmclnodelist ] && SGFILES=$SGFILES" $SGCONF/cmclnodelist"     ## fix for old SG A.11.15 (pre A.11.16)  
            # ----------- get remote stuff --------
            
            ssh $j "uname -r" >> $file
            if [ $? -eq 0 ]     # does SSH work?  -> Host key verification failed.
            then
                [ "$GETCMBIN" = "yes" ] &&  (ssh $j "what /usr/lib/libc.?" >> $file)
                ssh $j "[ -d $SGCONF/$i ] && cksum \$(find $SGCONF/$i|sort) $SGFILES" | grep -v -e "/.backup" -e "/_HIST" -e " "$SGCONF/$i"$" -e .log$ >> $file
                echo "\n" >> $file   
                [ "$GETCMBIN" = "yes" ] && (ssh $j "what /usr/sbin/cmversion /usr/sbin/cmstopres " >> $file) 
                echo "\n" >> $file   
                
                if [ "$CIS" = "yes" ]
                then                
                        # Check for additional startup scripts ## THIS REQUIRES SG A.11.19 or higher!
                        # cmviewcl: illegal option -- f
                        # usage: cmviewcl [-v] [-r {A.11.09|A.11.12}] [-c cluster_name] [-n node_name]... [-l {package|cluster|node|group}]
        
                        SUS="" # safty for pre-A.11.19
                        SUS=$(cmviewcl -v -f line -p $i 2> /dev/null| grep "_script=/" | awk -F"=" '{ print $2; }'|uniq) 2>/dev/null
                        # echo $SUS
                        # cmviewcl  -v  -f line|grep _script=/
                        # package:HR_TRANS|run_script=/etc/cmcluster/HR_TRANS/trans.cntl
                        # package:HR_TRANS|halt_script=/etc/cmcluster/HR_TRANS/trans.cntl
                        # package:LP1|run_script=/etc/cmcluster/LP1/dbci.cntl
                        # package:LP1|halt_script=/etc/cmcluster/LP1/dbci.cntl
                        # package:LP2|run_script=/etc/cmcluster/LP2/dbci.cntl
                        # package:LP2|halt_script=/etc/cmcluster/LP2/dbci.cntl
                        # package:LPP|run_script=/etc/cmcluster/LPP/dbci.cntl
                        for k in $SUS  ## only if A.11.19 
                        do
                                # echo "k=$j@$k"
                                # [ -r "$k" ] && cksum $k 2>&1 >> $file
                                ssh $j cksum  $k $(grep start $k | grep -v ^# | awk '{ print $1; }' | grep ^/ | uniq) 2>&1 >> $file
                                ssh $j cksum  $k $(grep stop  $k | grep -v ^# | awk '{ print $1; }' | grep ^/ | uniq) 2>&1 >> $file
                                ssh $j cksum  $k $(grep /sap  $k | grep -v ^# | awk '{ print $1; }' | grep ^/ | uniq) 2>&1 >> $file
                        done
                fi		
		# check for identd service, this could solve some hours of troubleshooting!
		# awk is used the eliminated different whitespace formating...
                ssh $j "grep identd /etc/services" | awk '{ for (i=1; i<= NF; i++) printf"%s ", $i; print"\n";}' >> $file
                echo "#--- inetd.conf\n" >> $file   
		ssh $j "grep ident /etc/inetd.conf" | awk '{ for (i=1; i<= NF; i++) printf"%s ", $i; print"\n";}'  >> $file
                echo "#--- /var/adm/inetd.sec\n" >> $file   
                ssh $j "grep -v ^# /var/adm/inetd.sec 2> /dev/null" | awk '{ for (i=1; i<= NF; i++) printf"%s ", $i; print"\n";}'  >> $file
                echo "#--- swlist\n" >> $file
                
                ## SSH key checker, #  27.4.2010, 14:59  Ralph Roth
                echo "#--- SSH stuff, keys" >> $file
#                 for si in /root/.ssh/{id_dsa.pub,id_rsa.pub}      ## authorized_keys,known_hosts,
#                 do
#                         ## echo $si; 
#                         [ -r $si ] && ssh $j "cksum $si" >> $file 
#                 done
                
                ssh $j "[ -r /etc/fstab.mon ] && (cat /etc/fstab.mon|grep -v /etc/fstab.mon|grep -v none$)" >> $file   ##  16.6.2010, 14:39  Ralph Roth
                ssh $j "echo #--- swlist; swlist | wc" >> $file
                echo "#--- /etc/rc.config.d/cmcluster\n" >> $file
                
                ssh $j "grep -v -E '^#|^$' /etc/rc.config.d/cmcluster" | sort -u >> $file        ## Autostart?
                [ "$GETPATCH" = "yes" ] && (ssh $j "what /stand/vmunix| awk ' { print \$1,\$3,\$4,\$8; } '| grep PHKL_|sort -u" >> $file)
                [ -x /usr/sbin/kctune ] && ssh $j /usr/sbin/kctune >> $file ## #  23.4.2010, 14:04  Ralph Roth

                ## Patches will be also grep'ed because they contain a date entry with / 
                ## e.g.:  vx_swap.c 2001/04/27 12:08:36 (PHKL_24026)
                
                ## Warning: vg00 and vg01 are always threated as local storage!
                ## This needs rewriting...
                #ssh $j " strings /etc/lvmtab /etc/lvmtab_p 2> /dev/null |grep /dev/vg | grep -v -e /dev/vg00 -e /dev/vg01 | sort -u" >> $file
				# Boot device no longer has to be named vg00 and vg01 is not always local storage.  (KL 26.10.11)
				boot=`lvlnboot -v 2>/dev/null | grep '^Boot Def' | awk -F'/' '{print $NF}' | tr -d ':'`
                ssh $j "strings /etc/lvmtab /etc/lvmtab_p 2>/dev/null | grep /dev/vg | grep -v /dev/$boot | sort -u" >> $file
                
                if [ $n -gt 1 ]
                then
                        echo "$CL.$i@$j:\t" ${nodes[1]} "--|--" ${nodes[${n}]}
                        sdiff -s "${nodes[1]}" "${nodes[${n}]}" | grep -e / -e "=" 
                fi        
                ## this is an easy work around, maybe [n-1] is a better approach :-)
                if [ $n -gt 0 ]
                then
                        echo "$CL.$i@$j:\t" ${nodes[0]} "--|--" ${nodes[${n}]} 
                        sdiff -s "${nodes[0]}" "${nodes[${n}]}" | grep -e / -e "="
                fi      
                (( n = n + 1 ))
           #fi      
           else
                echo "ERROR: SSH failed from $HOST to host $j" >> $file    
           fi
	done # j
	rm ${nodes[@]} > /dev/null 2> /dev/null
done # i    

echo "# Additional checks (no news are good news)..."
## node:rose-v00|interface:lan10|status=down
cmviewcl -f line -v 2>/dev/null |grep ^node: |grep status=down$
## PRIMARY      down (Link and IP)         1/0/12/1/0/6/0      lan7
# cmviewcl -v| grep " lan" | grep ") "

## additional SG check
# ---------------------------------------------------------------------------
if [ -x /usr/sbin/cmgetconf ]
then
  echo ""
  if (cmviewcl -l cluster | grep -q up)
  then 
     TMPF=$(mktemp)
     (/usr/sbin/cmgetconf > /dev/null 2> $TMPF)
     grep -v -e pvcreate $TMPF
     rm $TMPF 
  fi 
fi      
# Serviceguard mismatches? stderr redirect needs work!

# new stuff (Jan 2010) - check if a package is running on the alternate Node....

# Warning: Package ABC is running on alternate node host-v02!
# Warning: Package ADMIN is running on alternate node host-v00! 

for p in $(cmviewcl -l package | grep up | awk '{print $1}')
do
	A=$(cmviewcl -vp $p | grep Alter | grep current| awk ' { print $4; } ')
	if [ "$A" != "" ] ;
	then
		echo "Warning: Package $p is running on alternate node $A!"
	fi
done  

exit 0

# ToDo
# 
# for i in /etc/cmcluster/*/*.c{fg,ntl}
# do
#   grep start $i | grep -v ^# | awk '{ print $1; }' | grep ^/ | uniq
#   grep /sap  $i | grep -v ^# | awk '{ print $1; }' | grep ^/ | uniq
# done
## ---------------------------------------------------------------------------



# 
# ---------------------------------------------------------------------------
# Subversion merge/upstream history
# ---------------------------------------------------------------------------
# r671 | rothra | 2010-04-21 12:56:17 +0200 (Wed, 21 Apr 2010) | 1 line
# r668 | rothra | 2010-04-20 16:52:20 +0200 (Tue, 20 Apr 2010) | 1 line
# r667 | rothra | 2010-04-20 16:30:55 +0200 (Tue, 20 Apr 2010) | 1 line
# r645 | rothra | 2010-02-09 10:35:20 +0100 (Tue, 09 Feb 2010) | 1 line
# r629 | rothra | 2009-11-19 17:03:24 +0100 (Thu, 19 Nov 2009) | 1 line
# r621 | rothra | 2009-10-26 11:37:55 +0100 (Mon, 26 Oct 2009) | 1 line
# r620 | rothra | 2009-10-26 10:38:51 +0100 (Mon, 26 Oct 2009) | 1 line
# r618 | rothra | 2009-10-22 13:59:43 +0200 (Thu, 22 Oct 2009) | 1 line
# r583 | rothra | 2009-07-22 07:55:16 +0200 (Wed, 22 Jul 2009) | 1 line
# r547 | rothra | 2009-04-08 16:36:22 +0200 (Wed, 08 Apr 2009) | 1 line
# r500 | rothra | 2009-01-28 11:13:50 +0100 (Wed, 28 Jan 2009) | 1 line
# r499 | rothra | 2009-01-27 10:46:01 +0100 (Tue, 27 Jan 2009) | 1 line
# r495 | rothra | 2009-01-21 13:58:11 +0100 (Wed, 21 Jan 2009) | 1 line
# r493 | rothra | 2009-01-15 09:52:03 +0100 (Thu, 15 Jan 2009) | 1 line
# r485 | rothra | 2009-01-07 16:54:28 +0100 (Wed, 07 Jan 2009) | 1 line
# r463 | rothra | 2008-12-19 10:51:50 +0100 (Fri, 19 Dec 2008) | 1 line
# r462 | rothra | 2008-12-15 11:17:20 +0100 (Mon, 15 Dec 2008) | 1 line
# r460 | rothra | 2008-12-09 20:23:10 +0100 (Tue, 09 Dec 2008) | 1 line
# r458 | rothra | 2008-12-04 11:29:42 +0100 (Thu, 04 Dec 2008) | 1 line
# r450 | rothra | 2008-11-19 14:43:48 +0100 (Wed, 19 Nov 2008) | 1 line
# r440 | rothra | 2008-11-17 10:42:50 +0100 (Mon, 17 Nov 2008) | 1 line
# r432 | rothra | 2008-11-13 16:24:13 +0100 (Thu, 13 Nov 2008) | 1 line
# r417 | rothra | 2008-11-04 10:06:00 +0100 (Tue, 04 Nov 2008) | 1 line
# r414 | rothra | 2008-10-30 11:28:32 +0100 (Thu, 30 Oct 2008) | 1 line
# r413 | rothra | 2008-10-30 09:27:19 +0100 (Thu, 30 Oct 2008) | 1 line
# r389 | rothra | 2008-10-15 10:35:34 +0200 (Wed, 15 Oct 2008) | 1 line
# r382 | rothra | 2008-10-07 12:57:51 +0200 (Tue, 07 Oct 2008) | 1 line
# r378 | rothra | 2008-10-02 16:23:05 +0200 (Thu, 02 Oct 2008) | 1 line
# r375 | rothra | 2008-10-02 14:10:48 +0200 (Thu, 02 Oct 2008) | 1 line
# r362 | rothra | 2008-08-19 11:22:36 +0200 (Tue, 19 Aug 2008) | 1 line
# r361 | rothra | 2008-08-15 11:10:54 +0200 (Fri, 15 Aug 2008) | 1 line
# r356 | rothra | 2008-08-14 13:25:34 +0200 (Thu, 14 Aug 2008) | 1 line
# r355 | rothra | 2008-08-14 09:56:15 +0200 (Thu, 14 Aug 2008) | 1 line
# r354 | rothra | 2008-08-12 19:20:47 +0200 (Tue, 12 Aug 2008) | 1 line
# r346 | rothra | 2008-08-11 08:46:50 +0200 (Mon, 11 Aug 2008) | 1 line
# r345 | rothra | 2008-08-06 15:12:41 +0200 (Wed, 06 Aug 2008) | 1 line
# r344 | rothra | 2008-08-05 19:13:58 +0200 (Tue, 05 Aug 2008) | 1 line
# r343 | rothra | 2008-08-04 11:01:49 +0200 (Mon, 04 Aug 2008) | 1 line
# r341 | rothra | 2008-07-29 20:32:46 +0200 (Tue, 29 Jul 2008) | 1 line
# r335 | rothra | 2008-07-21 08:56:56 +0200 (Mon, 21 Jul 2008) | 1 line
# r331 | rothra | 2008-07-15 11:02:17 +0200 (Tue, 15 Jul 2008) | 1 line
# r329 | rothra | 2008-07-15 09:54:09 +0200 (Tue, 15 Jul 2008) | 1 line
# r317 | rothra | 2008-07-09 10:50:11 +0200 (Wed, 09 Jul 2008) | 1 line
# r316 | rothra | 2008-07-09 10:37:37 +0200 (Wed, 09 Jul 2008) | 1 line
# r314 | rothra | 2008-07-08 16:17:45 +0200 (Tue, 08 Jul 2008) | 1 line
# r313 | rothra | 2008-07-08 14:34:50 +0200 (Tue, 08 Jul 2008) | 1 line
# r312 | rothra | 2008-07-08 14:25:54 +0200 (Tue, 08 Jul 2008) | 1 line
# ---------------------------------------------------------------------------

# CVS history/log (cfg2html_hpux):
# ---------------------------------------------------------------------------
# $Log: sg_cluster_conf_checker.sh,v $
# Revision 5.14  2013-02-09 10:24:35  ralph
# replaced defect come.to redirector with rose.rult.at
#
# Revision 5.13  2011-12-28 09:33:26  ralproth
# Fix for buggy? (e)grep on HPUX
#
# Revision 5.12  2011-11-01 07:26:31  ralproth
# cfg5.19-31551: Many enhancements and SuperDome2 stuff submitted by Kathy Leslie
#
# Revision 5.11  2011-10-18 16:43:04  ralproth
# cfg5.18-31545: forced commit for troubleshooting syslog errors
#
# Revision 5.10.1.1  2011-02-15 14:29:04  ralproth
# Initial 5.xx import
#
# Revision 4.34  2010-12-22 21:28:55  ralproth
# cfg4.89-25248: TZ enhancements, Fixes for SG A.11.16/monfs
#
# Revision 4.33  2010-10-28 19:04:26  ralproth
# cfg4.86-25236: svn upstream, small enhancements
#
# Revision 4.12  2008/11/13 20:34:56  ralproth
# cfg4.13: fixes for mywhat utility (contrib)
#
# Revision 4.11  2008/11/13 13:27:51  ralproth
# cfg4.13: svn upstream (utilities)
#
# Revision 3.6  2008/10/14 14:12:38  ralproth
# cfg3.72: svn.14102008 upstream release
#
# Revision 3.4  2008/08/06 13:26:54  ralproth
# cfg3.70: svn upstream merge, WBEM, SFM enhancements
#

