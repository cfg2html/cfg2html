# @(#) $Id: get_superdomeinfo.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# ---------------------------------------------------------------------------
# $Log: get_superdomeinfo.sh,v $
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.1  2009-05-08 12:32:50  ralproth
# cfg4.39-22660: Fixes for vPar, splitt of SuperDomeInfo collector
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
#
# if [ -z "$CFG2HTML" ]           # only execute if not called from
# then                            # cfg2html directly!
#         SuperDomeInfo
# fi

SuperDomeInfo
