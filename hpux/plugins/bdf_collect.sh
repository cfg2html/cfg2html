# @(#) $Id: bdf_collect.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# bdf summary for HPUX, Ralph Roth, 5-feb-2001
# $Log: bdf_collect.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2006/02/02 08:24:42  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.11  2006/02/02 08:24:42  ralproth
# Changed email adress
#
# Revision 3.10.1.1  2003/01/21 10:33:32  ralproth
# Initial 3.x stream import
#
# Revision 2.1.1.1  2003/01/21 10:33:32  ralproth
# Import from HPUX to cygwin
#
# Revision 1.4  2002/11/20 11:43:54  ralproth
# Changes for proper WinCVS function
#
# Revision 1.3  2001/04/20 10:34:40  root
# First working standalone collector version
#
# Revision 1.2  2001/04/18  14:51:34  14:51:34  root (Guru Ralph)
# initial working version for cfg2html
# 

bdf_collect ()
{
echo "Total used local diskspace\n"
bdf -l|grep ^/|awk '
{
alloc += $2;
used  += $3;
avail += $4;

}

END {
print  "Allocated\tUsed \t \tAvailable\tUsed (%)";
printf "%ld \t%ld \t%ld\t \t%3.1f\n", alloc, used, avail, (used*100.0/alloc);
}'
} # bdf_collect


if [ -z "$CFG2HTML" ] 		# only execute if not called from
then				# cfg2html directly!
	bdf_collect
fi
