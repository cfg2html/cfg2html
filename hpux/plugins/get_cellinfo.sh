# @(#) $Id: get_cellinfo.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# $Log: get_cellinfo.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.11  2008/11/13 19:53:43  ralproth
# cfg4.13: cleanup of cvs keywords (2nd round)
#
# Revision 4.10.1.1  2007/11/26 19:03:34  ralproth
# Initial cfg2html_hpux 4.xx stream import
#
# Revision 3.1  2007/11/26 19:03:34  ralproth
# Added Files:
# 	get_cellinfo.sh get_cputype.sh
#
#
######################################################################
# exec_command SuperDome "SuperDome Configuration"
######################################################################

SuperDomeInfo( )
{
	 PAR=`parstatus -M -P |wc -l`      # number of partitions
	 CELL=`parstatus -M -C |wc -l`     # number of cells
	 CELL=`expr $CELL - 1`             # justify # of lines
	 CAB=`parstatus -M -B |wc -l`      # number of cabinets
	 CAB=`expr $CAB - 1`               # justify # of lines

	 echo "general overview"
	 echo "----------------"
	 parstatus                         # display general data
	 echo ""
	 echo ""
	 echo ""

	 echo "detailed partition data"
	 echo "-----------------------"
	 i=0
	 while [ i -lt $PAR ]
	 do
	  parstatus -V -p $i               # display detailed partition data
	  i=`expr $i + 1`
	 done
	 echo ""
	 echo ""
	 echo ""

	 echo "detailed cell data"
	 echo "------------------"
	 i=0
	 while [ i -lt $CELL ]
	 do
	  parstatus -V -c $i               # display detailed cell data
	  i=`expr $i + 1`
	 done
	 echo ""
	 echo ""
	 echo ""

	 echo "detailed cabinet data"
	 echo "---------------------"
	 i=0
	 while [ i -lt $CAB ]
	 do
	  parstatus -V -b $i               # display detailed cabinet data
	  i=`expr $i + 1`
	 done
	 echo ""
}
#################################################################

if [ -z "$CFG2HTML" ]           # only execute if not called from
then                            # cfg2html directly!
        SuperDomeInfo
fi

