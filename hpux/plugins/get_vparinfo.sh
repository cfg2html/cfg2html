# @(#) $Id: get_vparinfo.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# ---------------------------------------------------------------------------
# This plugin is part of the cfg2html package for HP-UX
# ---------------------------------------------------------------------------
# $Log: get_vparinfo.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.5  2010-11-23 15:50:54  ralproth
# cfg4.87-25244: Added comments about plugin and contrib location
#
# Revision 4.4  2010-07-23 19:07:13  ralproth
# cfg4.82-24805: small upstream (svn) changes - vpar/ioscan/syslog stuff
#
# Revision 4.2  2009-05-08 12:32:50  ralproth
# cfg4.39-22660: Fixes for vPar, splitt of SuperDomeInfo collector
#
# Revision 4.1  2009-05-08 12:25:34  ralproth
# cfg4.39-22660: vParInfo splittet up
#
######################################################################
# exec_command VparInfo "Virtual Partitions Configuration"
# Added 04/17/03 -- Ralph Roth
######################################################################

VparInfo( )
{
	 echo "General Overview"
	 echo "--------------------------------------------------"
	 vparstatus -P
	 echo ""
	 vparstatus                         	# display general data
	 echo ""
	 echo ""
	 echo ""

	 echo "Detailed Partition Data"
	 echo "--------------------------------------------------"
	 vparstatus -v                		# display detailed partition data
	 echo ""
	 echo ""
	 echo ""

	 echo "Available Resources Currently Not Assigned"
	 echo "--------------------------------------------------"
	 vparstatus -A | sed "s/</\&lt;/g"      # display available resources data
	                                        # Found only need to convert one <
	                                        # to make html show correctly
	 echo ""
	 echo ""
	 echo ""

	 echo "Event Log"
	 echo "--------------------------------------------------"
	 vparstatus -e                		# display monitor's event log
	 echo ""
	 echo "Hint: vparstatus -e -V   or   vparstatus -R"
	 echo ""
}

#################################################################

# if [ -z "$CFG2HTML" ]           # only execute if not called from
# then                            # cfg2html directly!
#         VparInfo
# fi

VparInfo
