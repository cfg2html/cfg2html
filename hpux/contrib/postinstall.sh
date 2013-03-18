# postinstaller for SD depot
# @(#) $Id: postinstall.sh,v 5.10.1.1 2011-02-15 14:29:04 ralproth Exp $
# $Log: postinstall.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:04  ralproth
# Initial 5.xx import
#
# Revision 4.13  2008/11/13 21:51:38  ralproth
# cfg4.14: first working dist script
#
# Revision 4.12  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.11  2008/11/13 19:46:25  ralproth
# cfg4.13: changed cvs keywords for new _what_ utility
#
# Revision 4.10.1.1  2005/09/29 19:00:52  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2003/09/05 08:54:05  ralproth
# Initial 3.x stream import
#
# Revision 2.5  2003/09/05 08:54:05  ralproth
# Fixed DOS/UNIX CR/LF problem reported by GW
#
# Revision 2.1.1.1  2003/01/21 10:33:25  ralproth
# Import from HPUX to cygwin
#
# Revision 1.62  2002/02/25 09:23:28  ralproth
# chmod of *.sh
#
# 25.06.2001, rar, initial creation

(grep "/cfg2html" /etc/PATH > /dev/null) || (P=$(cat /etc/PATH); echo "$P:/opt/cfg2html">/etc/PATH)

# 04.10.2001, rar, kills old non SD installation
rm -f /usr/local/bin/cfg2html.sh > /dev/null
rm -f /usr/contrib/bin/cfg2html.sh > /dev/null
# remove obsolete MakeIndex Installation
rm -f /opt/cfg2html/contrib/MakeIndex.shar
# remove obsolete sap collector installation
rm -f /opt/cfg2html/cfg2html_hpux_sap.sh

# remove old 2.xx binaries 
rm -f /opt/cfg2html/plugins/getpwd
rm -f /opt/cfg2html/plugins/pvgfilter
rm -f /opt/cfg2html/plugins/dumplvmtab

# remove old BCS stuff
rm -f /opt/cfg2html/contrib/BCS_Config/*

### WARNING ####

# this can lead to a missmatching SD installation, so we skip it better
# { changed/added 04.09.2003 (12:29) by Ralph Roth }

## ERROR:   File "/opt/cfg2html/plugins/head01.html" should have mode
##          "644" but the actual mode is "755".
## ERROR:   File "/opt/cfg2html/plugins/head02.html" should have mode
##          "644" but the actual mode is "755".
## ERROR:   File "/opt/cfg2html/plugins/head03.html" should have mode
##          "644" but the actual mode is "755".
## ERROR:   Fileset "cfg2html.cfg2html,l=/,r=B.2.35" had file errors.

# change write protection for non root users, 25.02.2002, rar
# chmod 755 /opt/cfg2html/plugins/*
# c//C, 030203
# chmod 755 /opt/cfg2html/contrib/BCS_Config/BCS_config
# chmod 755 /opt/cfg2html/*.sh
