# @(#) $Id: get_lan_desc.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# $Log: get_lan_desc.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 20:22:56  ralproth
# cfg4.13: fixes for mywhat utility
#
# Revision 4.10.1.1  2008/10/24 11:48:18  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.12  2008/10/24 10:48:18  ralproth
# cfg3.72: Fixes for HP-UX 11.31
#
# Revision 3.11  2007/08/02 11:09:10  ralproth
# 3.45: changes for big Superdomes
#
# Revision 3.10.1.1  2003/01/21 10:33:33  ralproth
# Initial 3.x stream import
#
# Revision 2.1.1.1  2003/01/21 10:33:33  ralproth
# Import from HPUX to cygwin
#
# Revision 1.1  2002/08/14 07:55:22  ralproth
# get_lan_desc - initial import, suggested by Thomas Brix and enhanced by Ralph
#

#From: BRIX,THOMAS (HP-Germany,ex2)
#Sent: Tuesday, August 13, 2002 17:43
#To: kcz Hpux (E-mail)
#Cc: Net-Forum (E-mail)
#Subject: A small script to get the description of all my interfaces w/lanadmin

##first use "lanscan -q" to get the ppa
##and build a string for lanadmin
##We use the commands l=lan, d=display, q=quit;
##for other lan cards p=PPA as desired.

# cat > get_lan_description.sh

export LANG=C

echo "l\n
$(for i in $(lanscan -q)
do
        echo "p\n$i\nd\n"
done)
q\n" | lanadmin 2> /dev/null | grep Desc | cut -f2 -d"="


echo "# NIC: "$(lanscan|grep 0x| wc -l)
# echo ""
#[ -x /usr/sbin/nwmgr ] && /usr/sbin/nwmgr
