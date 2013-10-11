###################################################################
# lpstat replacement plug in, (c) 20-july-2001 by ralph roth
# @(#) $Id: getlp.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
###################################################################
# $Log: getlp.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 19:53:44  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2003/01/21 10:33:34  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2003/01/21 10:33:33  ralproth
# Initial 3.x stream import
#
# Revision 2.1.1.1  2003/01/21 10:33:33  ralproth
# Import from HPUX to cygwin
#
# Revision 1.3  2002/11/20 11:51:36  ralproth
# Changes for proper WinCVS function
#
# Revision 1.2  2001/07/20 15:26:56  root
# cfg2html 1.52
#
# Revision 1.1  2001/07/20  15:29:31  15:29:31  root (Guru Ralph)
# Initial revision
# 
###################################################################
/usr/sam/lbin/lpmgr -l | awk -F":" '{
	if (NF > 3) {
	for (t = 1; t < 4; t++)
		{ printf("%-20s ", $t); };
	printf("%s\n", $5);
	}
}' 
