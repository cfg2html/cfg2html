############################################################################
# Veritas/Symantec Volume Manager (VxVM) Collector for cfg2html
############################################################################
# @(#) $Id: VxVM_collect.sh,v 5.13 2012-12-28 11:00:04 ralph Exp $
############################################################################
# $Log: VxVM_collect.sh,v $
# Revision 5.13  2012-12-28 11:00:04  ralph
# (c) y2k13 by Ralph Roth
#
# Revision 5.12  2011-12-28 09:41:36  ralproth
# cfg5.23-32068: Consolidated the (C)opyright messages to one common format, y2k12 header
#
# Revision 5.11  2011-12-28 09:33:48  ralproth
# cfg5.22-32061: y2k11 - changed the copyright
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.14  2010-12-22 21:36:59  ralproth
# cfg4.89-25250: Changed y2k10 to y2k11 :-)
#
# Revision 4.13  2010-08-17 03:57:57  ralproth
# cfg4.84-24814: added Logs cvs keyword
#
# Revision 4.12  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2004/07/15 12:07:40  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2004/07/15 11:07:40  ralproth
# Initial 3.x stream import
#
# Revision 2.2  2004/07/15 11:07:40  ralproth
# Changed paths to documentation
#
# Revision 2.1.1.1  2003/01/21 10:33:32  ralproth
# Import from HPUX to cygwin
#
# Revision 1.2  2002/02/06 09:10:17  ralproth
# VxVM collector added
#
# Revision 1.1  2002/02/05 12:41:33  ralproth
# Initial CVS import
# Initial VxVM collector
############################################################################
# (C)opyright 04.02.2002- 2013 by ROSE SWE, Ralph Roth, All Rights Reserved!
############################################################################


#for i in `vxdg list |awk '{print ($1)}'|grep -v DEVICE`
#	do
#	echo "Volumegroup $i\n"
#	vxdg list $i
#	done

echo "VxPrint\n"
vxprint -rth

echo "\n"
echo "VxStat"

vxstat -d 2>&1 | tail +3 | awk '
    BEGIN { 
	printf ("                                OPERATIONS             BLOCKS       AVG TIME(ms)\n");
	printf ("TYP NAME                      READ     WRITE       READ      WRITE  READ  WRITE\n");
     }
	{
	    v  = $1
	    n  = $2
	    or = $3
	    ow = $4
	    br = $5
	    bw = $6
	    ar = $7
	    aw = $8
	    printf ("%s %-20s %9s %9s %10s %10s %5.1f  %5.1f\n", v,n,or,ow,br,bw,ar,aw)

	}'                             

