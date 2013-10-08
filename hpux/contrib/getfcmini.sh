# ---------------------------------------------------------------------------
# Quick and Dirty hack to get all WWN IDs of a host, useful when used
# with scripts like doall.sh, getfc.sh or
# lrm -c "/hzd_admin/admin/getfcmini.sh" PUT sap omscl | tee /home/rroth/fcmini.txt
# ---------------------------------------------------------------------------
# @(#) $Id: getfcmini.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# IC/Copyright: 13.07.2006 by Ralph Roth, http://rose.rult.at
# ---------------------------------------------------------------------------
# 25.04.2008, 09:26, rr - Merge svn.217+cvs 3.3
# r463 | rothra | 2008-12-19 10:51:50 +0100 (Fri, 19 Dec 2008) | 1 line
# r456 | rothra | 2008-11-24 14:22:34 +0100 (Mon, 24 Nov 2008) | 1 line
# r440 | rothra | 2008-11-17 10:42:50 +0100 (Mon, 17 Nov 2008) | 1 line
# r412 | rothra | 2008-10-29 16:29:44 +0100 (Wed, 29 Oct 2008) | 1 line
# r391 | rothra | 2008-10-16 10:55:24 +0200 (Thu, 16 Oct 2008) | 1 line
# r363 | rothra | 2008-08-19 14:16:36 +0200 (Tue, 19 Aug 2008) | 1 line
# r362 | rothra | 2008-08-19 11:22:36 +0200 (Tue, 19 Aug 2008) | 1 line
# r342 | rothra | 2008-08-01 13:09:13 +0200 (Fri, 01 Aug 2008) | 1 line
# r254 | rothra | 2008-05-14 09:30:50 +0200 (Wed, 14 May 2008) | 1 line
# r253 | rothra | 2008-05-14 09:21:19 +0200 (Wed, 14 May 2008) | 1 line
# r241 | rothra | 2008-05-09 15:39:56 +0200 (Fri, 09 May 2008) | 1 line
# r236 | rothra | 2008-05-09 15:15:07 +0200 (Fri, 09 May 2008) | 1 line
# r232 | rothra | 2008-05-02 14:59:31 +0200 (Fri, 02 May 2008) | 1 line
# r229 | rothra | 2008-05-02 09:24:04 +0200 (Fri, 02 May 2008) | 1 line
# r224 | rothra | 2008-04-30 13:00:58 +0200 (Wed, 30 Apr 2008) | 1 line
# r219 | rothra | 2008-04-29 11:03:23 +0200 (Tue, 29 Apr 2008) | 1 line
# r217 | rothra | 2008-04-24 14:57:51 +0200 (Thu, 24 Apr 2008) | 1 line
# r173 | rothra | 2008-03-17 13:16:49 +0100 (Mon, 17 Mar 2008) | 1 line
# r147 | rothra | 2008-03-11 09:41:39 +0100 (Tue, 11 Mar 2008) | 1 line
# r146 | rothra | 2008-03-10 16:49:01 +0100 (Mon, 10 Mar 2008) | 1 line
# ---------------------------------------------------------------------------
# Hints/Tipps
# echo "scl q fibre;cds;wait;done" | cstm
#
# hpux: FC HBA: find local nport id
# Thursday, March 3, 2011
# # ioscan -funC fc | grep dev | awk ‘{print "echo " $1  ";fcmsutil " $1 }’ | sh | grep -e dev -e "Local N_Port_id is"
#
# Enhancementrequest: + SerialNumber

PATH=$PATH:/usr/contrib/bin/    ## inq

# check if you are root, if not terminate the script!
[ $(id -u) -ne 0 ] && (echo "Error: Get ROOT!"; exit 1) # root check

# gets cluster name, e.g. nvscl2
CL=$(cmquerycl 2>/dev/null | grep -v -e ^"  " -e ^$ | tail +2| awk '{if ($1 =="") print("Standalone"); else print $1;}')
   
H=$(hostname);
REV=$(uname -r)
HW=$(uname -m)
MODEL=$(model)          # -D (description))
SNR=$(getconf MACHINE_SERIAL)
#SG=$(swlist -l product  ServiceGuard|grep ServiceGuard|awk '{ print $2; }')
SG=$(/usr/sbin/cmversion 2>/dev/null)
OE=$(swlist OE |grep '  OE.OE'|awk '{printf("%s;%s", $1, $2);}')

## /hzd_admin/admin/getfcmini.sh[28]: inq:  not found. -> Arnold
INQ=$(which inq 2> /dev/null)
EMCDRV="n/a"
[ -x "$INQ" ] && EMCDRV=$($INQ -no_dots| grep ":EMC"|wc -l)       # number of EMC drives

echo "GetFCMini0;Cluster;Hostname;OS_Version;OperEnv;OE_Version;Hardware;HW_Model;SerialNumber;LinkSpeed;ServiceGuardVersion;Nr_of_EMC_Drives;FC_Device;N-Port_Port_WWN;N-Port_Node_WWN;HW_Path;HW_Slot;PartNumber;RemoteDevices;SW0;DRV0;SW1;DRV1;SW2;DRV2;VPD_Part;VPD_Version;VPD_Engine;;;"

for i in /dev/td* /dev/fc*
do
     if [ -c "$i" ]
     then
          WWP=$(/opt/fcms/bin/fcmsutil $i | grep "N_Port Port World Wide Name"|cut -f2 -d= | awk '{ print $1; }')
          WWN=$(/opt/fcms/bin/fcmsutil $i | grep "N_Port Node World Wide Name"|cut -f2 -d= | awk '{ print $1; }')
          HWP=$(/opt/fcms/bin/fcmsutil $i | grep "Hardware Path is"|cut -f2 -d= | awk '{ print $1; }')  # 
          ## olrad > 11.11??
          SLOT=$(olrad -q 2>/dev/null | grep Yes | awk '{ if (match("'${HWP}'",$2)==1) print $1; }') # >0 versus =1
          PROD=$(/opt/fcms/bin/fcmsutil $i vpd  | grep "Part number"|cut -f2 -d: | tr -d " \"") # ";"$PROD
          SPEED=$(/opt/fcms/bin/fcmsutil $i | grep "Link Speed"|cut -f2 -d=|awk '{print $1;}')
          REMDEVS=$(/opt/fcms/bin/fcmsutil $i get remote all| grep "Symbolic Port Name " |sort|awk '{ a[$5]++; }END { for (i in a) printf ("%s:%d,", i, a[i]); }')
          
          echo "GetFCMini1;"$CL";"$H";"$REV";"$OE";"$HW";"$MODEL";"$SNR";"$SPEED";"$SG";"$EMCDRV";"$i";"$WWP";"$WWN";"$HWP";"$SLOT";"$PROD";"$REMDEVS";\c"
          for j in FibrChanl-00 FibrChanl-01 FibrChanl-02
          do
                  SW=$(swlist $j 2>/dev/null| grep -v ^# | grep -e FibrChanl)
                  [ -z "$SW" ] && SW="n/a n/a"
                  echo $SW| tr -d \" |awk '{ printf("%s;%s;", $1,$2); }'    
          done            
          for line in $(/opt/fcms/bin/fcmsutil $i vpd |sort | grep ":" | grep -e Part -e version -e Engineering  | cut -f2 -d:)
          do
                echo $line";\c" | tr -d \"
          done 
 
          echo ""
     fi
done

exit 0

# /opt/fcms/bin/fcmsutil /dev/fcd1 vpd | grep "Part number"|cut -f2 -d:
#  AD193-60001

# nry0: /var/adm/syslog # fcmsutil /dev/fcd1 get fabric
# Fabric Port World Wide Name = 0x200400051e34ea00
# Fabric Node World Wide Name = 0x100000051e34ea00

#  fcmsutil /dev/fcd1 sfp

# sd1-v01: /home/rroth # /opt/fcms/bin/fcmsutil /dev/fcd1 vpd | grep ":" | grep -e Part -e version -e Product -e Engineering
#  Product Description    : "HP 2Gb Fibre Channel FC/GigE Combo Adapter                 "
#  Part number            : "A9782-60001"
#  Engineering Date Code  : "A-4411"
#  Part Serial number     : "PR1050306B"
#  EFI version            : "001.30"
#  ROM Firmware version   : "003.002.168"

# sd1-v01: /home/rroth # /opt/fcms/bin/fcmsutil /dev/fcd9 vpd | sort -u

#                 V I T A L   P R O D U C T   D A T A
#                 ---------   -------------   -------
# 
# 
#  Asset Tag              : "NA"
#  Check Sum              : 0x2a
#* EFI version            : "001.30"
#* Engineering Date Code  : "A-4411"
#  Mfd. Date              : "4507"
#  Misc. Information      : "PW=15W;PCI 66MHZ;PCI-X 133MHZ"
#* Part number            : "A9782-60001"
#* Part Serial number     : "PR1050706A"
#* Product Description    : "HP 2Gb Fibre Channel FC/GigE Combo Adapter                 "
#* ROM Firmware version   : "003.002.168"

# New idea:
# fcmsutil /dev/fcd4 get remote all| grep "Symbolic Port Name " | awk ' { print $5; } '| sort -u

# nka1-v01: /root # olrad   -q | grep Yes | awk '{ print $1, $2; }'
# 0-0-0-5 0/0/6/1
# 0-0-0-6 0/0/4/1
# 0-0-0-7 0/0/2/1
# 0-0-0-8 0/0/1/1

## olrad   -q | grep Yes | awk '{ if (match("'$a'",$2)>0) print $1; }'
