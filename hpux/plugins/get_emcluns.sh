# @(#) $Id: get_emcluns.sh,v 5.12 2012-06-01 18:13:56 ralph Exp $
#  /home/CVS/cfg2html/release/plugins/get_emcluns.sh 2005/08/09 Steveriley
##### Initial creation:  Steve Riley, HP C&I UK       ##################

# stderr output from "/hzd_admin/tmp/cfg/./plugins/get_emcluns.sh":
#     EmcInfo[19]: sympd:  not found
#     EmcInfo[35]: symdg:  not found 

PATH=$PATH:/usr/symcli/bin
export PATH

SYMPD=$(which sympd 2>/dev/null)
SYMPG=$(which sympg 2>/dev/null) # not used anymore? #  01.06.2012, 11:03 modified by Ralph Roth #* rar *#
SYMDG=$(which symdg 2>/dev/null)

# checks

[ -x "$SYMPD" ] || exit 2
# [ -x "$SYMPG" ] || exit 3
[ -x "$SYMDG" ] || exit 4


######################################
#	EXAMPLE OUTPUT FROM SYMPD LIST
######################################

EmcInfo()
{	
	#Symmetrix ID: 000287970866
	#
	#        Device Name           Directors                  Device
	#--------------------------- ------------- -------------------------------------
	#                                                                           Cap
	#Physical               Sym  SA :P DA :IT  Config        Attribute    Sts   (MB)
	#--------------------------- ------------- -------------------------------------
	#    1		        2    3     4       5             6            7    8
	#/dev/rdsk/c16t0d0      0083 01C:0 16B:C8  2-Way Mir     Grp'd    (M) RW   34890
	#/dev/rdsk/c16t0d1      0087 01C:0 16A:C9  2-Way Mir     Grp'd    (M) RW   34890
	#/dev/rdsk/c16t0d2      008B 01C:0 16B:CA  2-Way Mir     Grp'd    (M) RW   34890
	#/dev/rdsk/c16t0d3      008F 01C:0 16A:CB  2-Way Mir     Grp'd    (M) RW   34890
	#
	# and on
	# and on
	# and on...
	
	sympd list
	
	######################################
	#	EXAMPLE OUTPUT FROM SYMDG LIST
	######################################
	
	#                          D E V I C E      G R O U P S
	#
	#                                                             Number of
	#    Name               Type     Valid  Symmetrix ID  Devs   GKs  BCVs  VDEVs
	#
	#    PUKE               REGULAR  Yes    000287979999     4     0     4      0
	#    QUKE               RDF2     Yes    000287979999     0     0    14      0
	#    TUKE               RDF2     Yes    000287979999     0     0    14      0
	#    PMS01              REGULAR  Yes    000287979999     3     0     3      0
	
	symdg list >/tmp/symdg.out
	cat /tmp/symdg.out
	
	grep "No Symmetrix" /tmp/symdg.out 2>&1 >/dev/null
	[[ $? -eq 0 ]] && rm /tmp/symdg.out && exit
	
	###########################################
	#	EXAMPLE OUTPUT FROM SYMDG SHOW PUKE
	###########################################
	
	#Group Name:  PUKE
	#
	#    Group Type                                   : REGULAR
	#    Valid                                        : Yes
	#    Symmetrix ID                                 : 000287979999
	#    Group Creation Time                          : Sat Jul  9 14:38:45 2005
	#    Vendor ID                                    : EMC Corp
	#    Application ID                               : SYMCLI
	#
	#    Number of STD Devices in Group               :    4
	#    Number of Associated GK's                    :    0
	#    Number of Locally-associated BCV's           :    4
	#    Number of Locally-associated VDEV's          :    0
	#    Number of Remotely-associated BCV's (STD RDF):    0
	#    Number of Remotely-associated BCV's (BCV RDF):    0
	#    Number of Remotely-assoc'd RBCV's (RBCV RDF) :    0
	#
	#    Standard (STD) Devices (4):
	#        {
	#        --------------------------------------------------------------------
	#                                                      Sym               Cap
	#        LdevName              PdevName                Dev  Att. Sts     (MB)
	#        --------------------------------------------------------------------
	#        DEV001                /dev/rdsk/c16t0d0       0083 (M)  RW     34890
	#        DEV002                /dev/rdsk/c16t0d1       0087 (M)  RW     34890
	#        DEV003                /dev/rdsk/c16t0d2       008B (M)  RW     34890
	#        DEV004                /dev/rdsk/c16t0d3       008F (M)  RW     34890
	#        }
	#
	#    BCV Devices Locally-associated (4):
	#        {
	#        --------------------------------------------------------------------
	#                                                      Sym               Cap
	#        LdevName              PdevName                Dev  Att. Sts     (MB)
	#        --------------------------------------------------------------------
	#        BCV001                /dev/rdsk/c16t1d2       0163 (M)  RW     34890
	#        BCV002                /dev/rdsk/c16t1d3       0167 (M)  RW     34890
	#        BCV003                /dev/rdsk/c16t1d4       016B (M)  RW     34890
	#        BCV004                /dev/rdsk/c16t1d5       016F (M)  RW     34890
	
	for DG in `awk '{ \
	if (NR>6){
		print $1}
	}' /tmp/symdg.out`
	do
		symdg show $DG
	done
	
	rm /tmp/symdg.out
}
if [ -z "$CFG2HTML" ] 		# only execute if not called from
then				# cfg2html directly!
	EmcInfo
fi 

#  /opt/emc/SYMCLI/V7.0.1/bin # ./sympd list
# 
# Symmetrix ID: 000290102460
# 
#         Device Name           Directors                  Device
# --------------------------- ------------- -------------------------------------
#                                                                            Cap
# Physical               Sym  SA :P DA :IT  Config        Attribute    Sts   (MB)
# --------------------------- ------------- -------------------------------------
# 
# /dev/rdisk/disk173     04A0 08A:1 16B:D3  2-Way Mir     N/Grp'd  VCM RW       3
# /dev/rdisk/disk174     04A0 09A:1 16B:D3  2-Way Mir     N/Grp'd  VCM RW       3
# /dev/rdisk/disk458     04A0 09C:0 16B:D3  2-Way Mir     N/Grp'd  VCM RW       3
# /dev/rdisk/disk459     1461 09C:0 12B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk460     15C1 09C:0 12B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk461     148D 09C:0 11D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk462     15ED 09C:0 11D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk463     14B9 09C:0 05D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk464     1619 09C:0 05D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk465     14E5 09C:0 06B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk466     1645 09C:0 06B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk467     1511 09C:0 12B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk468     1671 09C:0 12B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk469     153D 09C:0 11D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk470     169D 09C:0 11D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk471     1569 09C:0 05D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk472     16C9 09C:0 05D:D12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk473     1595 09C:0 06B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk474     16F5 09C:0 06B:C12 BCV+R-5       N/Asst'd (M) RW  193556
# /dev/rdisk/disk475     083E 09C:0 15C:D3  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk476     0875 09C:0 15A:D3  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk477     087E 09C:0 16C:C3  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk478     12A4 09C:0 05D:DE  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk479     1209 09C:0 06D:CA  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk480     121D 09C:0 12C:DE  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk481     123B 09C:0 11B:CB  RAID-5        N/Grp'd      RW   10753
# /dev/rdisk/disk482     1233 09C:0 12A:C3  RAID-5        N/Grp'd      RW   10753
