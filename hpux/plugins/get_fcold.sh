# @(#) $Id: get_fcold.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
############################################################################

##### Initial creation:  cfg2html@hotmail.com, ASO BBN, HPCS ##################
# $Log: get_fcold.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.12  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2006/02/02 08:24:42  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.11  2006/02/02 08:24:42  ralproth
# Changed email adress
#
# Revision 3.10.1.1  2004/10/19 14:10:40  ralproth
# Initial 3.x stream import
#
# Revision 2.2  2004/10/19 14:10:40  ralproth
# Fixes by Marc Heinrich for new FC cards
#
# Revision 2.1  2003/07/25 09:13:11  ralproth
# Old FibreChannel collector, initial import
#
#
############################################################################

#####################################################################
# hacked for cfg2html by Ralph Roth, 7-dec-99, based on fct_util.sh
# The fcmsutil command is a diagnostic tool to be used for the
# A3591A, A3404A, and A3636A Fibre Channel Host Bus Adapters
#
# bug fixed 8-dec-99 on site with Thomas Saur
# changed 08.05.2000, req. by Cristoph Hauser -> Tachyon Lite
# fixed in March-2001: /dev/td*
# tdX - > HP Tachyon TL/TS Fibre Channel Mass Storage
#####################################################################

FibreChannelInfo() {

fcmsutil_path='/opt/fcms/bin'


# fetch ww names
echo "World Wide Names and misc. statistics"
for device_file in /dev/fcms* /dev/td* /dev/fcd*
do
    	echo "FC device file: " $device_file
    	$fcmsutil_path/fcmsutil $device_file
	echo ""
done

echo "FC Statistics\n"
echo " Loss  Bad R/TX Loss  Recvd   Gend    Bad Resets Resets FM_Intr  Device"
echo "Signal   Char!  Sync   EOFa   EOFa   CRC! Inited Cmpltd Count    File"
echo "-----------------------------------------------------------------------------"

for device_file in /dev/fcms* 		# fixed, 05-02-2001,rar
do

   # ---------------------------------------
   # Find keywords and print numerical
   # values belonging to them.
   # ---------------------------------------
   $fcmsutil_path/fcmsutil $device_file stat  |		  \
   awk '
        BEGIN {                                           \
           loss_signal = "???";                           \
           bad_rx    = "???";                             \
           loss_sync = "???";                             \
           rcvd_eofa = "???";                             \
           gend_eofa = "???";                             \
           bad_crc   = "???";                             \
           rsts_init = "???";                             \
           rsts_comp = "???";                             \
	   fm_inits  = "???";                             \
        }
	         /Loss of signal Count/    { loss_signal = $5 }
	         /Bad [RT]x Char Count/    { bad_rx = $10 }
	         /Loss of Sync Count/      { loss_sync = $5 }
	         /Received EOFa/           { rcvd_eofa = $3 }
	         /Generated EOFa/          { gend_eofa = $6 }
	         /Bad CRC Count/           { bad_crc = $4 }
	         /num_resets_initiated/    { rsts_init = $2 }
	         /num_resets_completed/    { rsts_comp = $4 }
		 /fm_ints/                 { fm_inits = $4 }
        END {                                             \
              printf("%6s %6s %6s %6s %6s %6s %6s %6s %6s  ", \
              loss_signal, bad_rx, loss_sync, rcvd_eofa, gend_eofa, bad_crc, \
              rsts_init, rsts_comp, fm_inits);                      \
            }
       '
	echo $device_file
done
echo "-----------------------------------------------------------------------------"
echo "\n"
}


if [ -z "$CFG2HTML" ] 		# only execute if not called from
then				# cfg2html directly!
	FibreChannelInfo
fi
