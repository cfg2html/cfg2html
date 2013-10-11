# @(#) $Id: get_xpsum.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
############################################################################

##### Initial creation:  cfg2html@hotmail.com, ASO BBN, HPCS ##################
# $Log: get_xpsum.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.14  2009/02/17 12:12:57  ralproth
# cfg4.22-22222: small fixes and enhancements for EMC arrays
#
# Revision 4.13  2009/01/13 15:04:51  ralproth
# EMC/inq stuff added/changed
#
# Revision 4.12  2008/11/13 19:53:44  ralproth
# Revision 4.10.1.1  2006/02/02 08:24:42  ralproth
# Revision 3.11  2006/02/02 08:24:42  ralproth
# Revision 3.10.1.1  2004/07/07 18:29:12  ralproth
# Revision 2.4  2004/07/07 18:29:12  ralproth
# Revision 2.1  2003/12/18 12:34:35  ralproth
# Revision 1.1  2003/11/27 15:40:54  ralproth
############################################################################

#cat $(hostname)_xpinfo.txt | grep dsk | sort |  awk ' \
# 
# Device File                 ALPA Tgt Lun Port  CU:LDev Type             Serial#
# ================================================================================
# /dev/rdsk/c101t1d0           00  01  00  CL1M  02:b5  OPEN-V*15        00060013
# /dev/rdsk/c101t1d1           00  01  00  CL1M  06:b5  OPEN-V*15        00060013
# /dev/rdsk/c101t1d2           00  01  00  CL1M  02:a1  OPEN-V*15        00060013

# dsk -> dev HPUX 11.31
cat $1 | grep /dev/ | sort |  awk '
{
  a[$5" ("$8")"]++;
  b[$7" ("$8")"]++;
}

END {
 for (t in a) { printf("Port %s \t # LUNS %s\n", t, a[t]); }
 print"";
 for (t in b) { printf("%14s\t # %s\n", t, b[t]); }
}
'
