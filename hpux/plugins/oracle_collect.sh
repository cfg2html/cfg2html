# @(#) $Id: oracle_collect.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# Oracle Configuration Collector 
# based on initial script made by Frank Grabner
# fixed onsite 22-Aug-2001 by Ralph Roth
# $Log: oracle_collect.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 19:53:44  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2003/01/21 10:33:34  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.10.1.1  2003/01/21 10:33:34  ralproth
# Initial 3.x stream import
#
# Revision 2.1.1.1  2003/01/21 10:33:34  ralproth
# Import from HPUX to cygwin
#
# Revision 1.2  2002/11/20 11:51:43  ralproth
# Changes for proper WinCVS function
#
# Revision 1.1  2001/08/23 14:41:32  root
# Initial revision
#

if [ -f /etc/oratab ]
then
	for DB in `grep -v -E '^#|^$|^\*' /etc/oratab`			
# Grep erweitert um * weil manche Ora-Apps dies eintragen
	do
		Ora_Home=`echo $DB | awk -F: '{print $2}'`
		Sid=`echo $DB | awk -F: '{print $1}'`
		Init=${Ora_Home}/dbs/init${Sid}.ora
		Cfg=${Ora_Home}/dbs/config${Sid}.ora		
		echo "\n---=[ Instance $Sid ($Ora_Home) ]=----------------------------------"|cut -c1-77
		echo "\n"
# Ist nicht festgelegt, kann im init$SID.ora festgelegt werden ;-(
		if [ -f $Init ]					
# wird aber fast immer mit diesem Namen uebernommen
		then
			cat $Init | grep -v -e ^$ -e ^#
		else
			echo "\n$Init not found"
		fi
		if [ -f $Cfg ]
		then
			cat $Cfg | grep -v -e ^$ -e ^#
		else
			echo "\n$Cfg not found"
		fi
	done
fi
