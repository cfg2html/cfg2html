# EFI bootdevice collector, written by Ralph Roth
# @(#) $Id: get_efi.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
########################################################################
# $Log: get_efi.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.11  2011-11-01 07:26:31  ralproth
# cfg5.19-31551: Many enhancements and SuperDome2 stuff submitted by Kathy Leslie
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.17  2010-08-09 19:47:09  ralproth
# cfg4.83p1-24812: small enhancements for HPVMs and EFI
#
# Revision 4.16  2010-02-02 13:35:37  ralproth
# cfg4.63-23633: + vparefiutil
#
# Revision 4.15  2010-01-19 18:22:59  ralproth
# cfg4.63-23628: EFI Auto Boot fixes
#
# Revision 4.14  2009-12-11 09:21:13  ralproth
# cfg4.59-23617: EFI device path
#
# Revision 4.13  2009-11-18 16:32:20  ralproth
# cfg4.57-23612: + ioscan, + CIM/RSP stuff
#
# Revision 4.12  2008/11/20 14:46:01  ralproth
# cfg4.15-21330: fixed EFI stuff for HPUX 11.31 (s2/p2)
#
# Revision 4.10.1.1  2007/08/08 10:27:56  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.2  2006/05/14 10:52:50  ralproth
# added CVS keywords
#
#########################################################################
#
# stderr output from "/opt/cfg2html/plugins/get_efi.sh":
#     efi_ls: invalid efi device
#     efi_ls: invalid efi device
#     Invalid EFI partition: /dev/disk/disk5_p2
#     efi_cp: invalid efi device
#     cat: Cannot open /tmp/AUTO.11541: No such file or directory
#     rm: /tmp/AUTO.11541 non-existent
#     efi_ls: invalid efi device
#     efi_ls: invalid efi device
#     Invalid EFI partition: /dev/disk/disk4_p2
#     efi_cp: invalid efi device
#     cat: Cannot open /tmp/AUTO.11541: No such file or directory
#     rm: /tmp/AUTO.11541 non-existent
#
#########################################################################

# Added support for Superdome2 servers  (KL 26.10.11)
model | grep -q Superdome2
if [ $? -eq 0 ] ; then
    MODEL="Superdome2"
fi

                                                                          # HPUX 11iv1, v2 # HPUX 11iv3
for disk in $(lvlnboot -v 2>/dev/null | grep "Boot Disk"|awk {'print $1;'}|sed "s/s2$/s1/"|sed "s/p2$/p1/")
do
  echo "---=[ EFI contents of $disk ]=-------------------------------"|cut -c1-72
  efi_ls -d $disk
  for a in EFI EFI/HPUX EFI/diag EFI/tools EFI/Intel_Firmware EFI/hp
  do
	echo "Files in $disk/$a"
	efi_ls -d $disk $a|grep -v -e "total space" -e "^\."
  done
  efi_cp -d $disk -u EFI/HPUX/AUTO /tmp/AUTO.$$
  echo "--------------------\nEFI/HPUX/AUTO string = $(cat /tmp/AUTO.$$)"
  rm /tmp/AUTO.$$
  echo "\n"
done

# Add stuff like this
# # ioscan -ek -H 0/0/1/1/0/4/0.0x8.0x0
# H/W Path  Class                            Description
# ======================================================
# 0/0/1/1/0/4/0.8.0                           disk    HP 146 GMAX3147NC
#         Acpi(HWP0002,PNP0A03,1)/Pci(1|0)/Pci(4|0)/Scsi(Pun8,Lun0)/HD(Part1,Sig8B933FA2-7D9C-11DE-8002-D6217B60E588)/\EFI\HPUX\HPUX.EFI

echo "EFI device path for the boot disks"
echo ""

# # setboot | grep /dev/ | grep bootpath | awk ' { print $4; } '
# 0/0/1/1/0/4/0.0x2.0x0
# 0/0/2/1/0/4/0.0x0.0x0

# Need to allow for 'HA Alternate bootpath' result from setboot command  (KL 26.10.11)
#for i in $(setboot | grep /dev/ | grep bootpath | awk ' { print $4; } ')
for i in $(setboot | grep /dev/ | awk -F'bootpath :' '{print $2}' | awk '{print $1}' | sort -u)
do
    # Added support for Superdome2 servers  (KL 26.10.11)
    if [ "$MODEL" = Superdome2 ] ; then
        i=`ioscan -km hwpath | grep $i | awk '{print $NF}'`
    fi
        ioscan -ke -H $i
        echo ""
done
echo "Disk with EFI/PA device paths"
ioscan -e -Cdisk | grep EFI    # how does this look under PA-RiSC?

#  02.02.2010, 14:34 modified by Ralph Roth ----
echo ""
if [ -x /usr/sbin/vparefiutil ]
then
	echo "HP-UX hardware path to EFI path mapping (vpareutil)"
        /usr/sbin/vparefiutil
fi
