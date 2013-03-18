# @(#) $Id: get_xpluns.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
############################################################################

##### Initial creation:  cfg2html@hotmail.com, ASO BBN, HPCS ##################
# $Log: get_xpluns.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.12  2008/11/13 19:53:44  ralproth
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
# Revision 3.10.1.1  2004/07/07 18:29:12  ralproth
# Initial 3.x stream import
#
# Revision 2.5  2004/07/07 18:29:12  ralproth
# Fixes for get_xp*.sh and option -1/-2. Misc docu. enhancements
#
# Revision 2.4  2004/01/13 18:20:35  ralproth
# ! Fixes for xplun stuff
#
# Revision 2.3  2003/12/18 13:12:02  ralproth
# + Added get-xp*.sh
#
# Revision 2.2  2003/12/18 12:39:49  ralproth
# Fixes for moved ASO web server
#
# Revision 2.1  2003/12/18 12:34:34  ralproth
# Initial import
#
# Revision 1.2  2003/12/12 10:34:40  ralproth
# onsite fixes and enhancements
#
# Revision 1.1  2003/11/27 15:40:54  ralproth
# Initial creation
############################################################################

#    1		      2   3   4   5     6       7                 8
# c35t0d3            d4  00  83  CL1B  01:1b   OPEN-E           00030502
# c35t0d4            d4  00  84  CL1B  01:2a   OPEN-E           00030502
# c4t0d0             ef  00  00  CL1A  00:f8   OPEN-3-CVS       00050176
# c4t0d1             ef  00  01  CL1A  00:08   OPEN-E           00050176

# 00:9f (00050176)         c4t7d1 c7t7d1 c10t7d1 c13t7d1


## cat $(hostname)_xpinfo.txt | grep dsk | cut -c11- | sort  -k 5,5|  awk ' \
# { changed/added 07.07.2004 (08:46) by RALPH Roth }
cat $1| grep dsk | cut -c11- | sort  -k 5,5|  awk ' \
BEGIN {
## not usefull, but....
	port["CL1A"]=0;
	port["CL1B"]=0;
	port["CL1C"]=0;
	port["CL1D"]=0;

	port["CL2A"]=0;
	port["CL2B"]=0;
	port["CL2C"]=0;
	port["CL2D"]=0;
}
{
  port[$5]++;
}

END {
 printf("cu:LUN (serial#)         ");
 for (t in port) { if (port[t]>0) printf("%s(%i) ", t, port[t]) };
 printf("(unsorted!)\n");
}
'

#cat $(hostname)_xpinfo.txt | grep dsk | cut -c11- | sort  -k 5,5|  awk ' \
# { changed/added 07.07.2004 (08:47) by RALPH Roth }
cat $1 | grep dsk | cut -c11- | sort  -k 5,5|  awk ' \
{
  a[$6" ("$8")"] =  a[$6" ("$8")"] $1 " ";
}

END {
 for (t in a) { printf("%s \t %s\n", t, a[t]); }
 printf("\n");
}
'
