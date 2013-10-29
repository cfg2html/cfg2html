# @(#) $Id: get_superdome2info.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# --=-----------------------------------------------------------------------=---
# (c) 1997 - 2013 by Ralph Roth  -*- http://rose.rult.at -*-
# Initial creation Oct. 2011 by Kathy Leslie

######################################################################
# exec_command Superdome2 "Superdome2 Configuration"
######################################################################

Superdome2Info( )
{
    echo "general overview"
    echo "----------------"
    parstatus                          # display general data
    echo ; echo ; echo

    echo "detailed complex data"
    echo "---------------------"
    parstatus -X                       # display complex data
    echo ; echo ; echo

    echo "detailed partition data"
    echo "-----------------------"
    for i in `parstatus -M -P | awk -F':' '{print $2}'`
    do
        parstatus -V -p $i             # display detailed partition data
    done
    echo ; echo ; echo

    echo "detailed cell data"
    echo "------------------"
    for i in `parstatus -M -C | awk -F':' '{print $2}'`
    do
        parstatus -V -c $i             # display detailed cell data
    done
    echo ; echo ; echo

    echo "detailed enclosure data"
    echo "-----------------------"
    for i in `parstatus -M -E | awk -F':' '{print $2}'`
    do
        parstatus -V -e $i             # display detailed enclosure data
    done
    echo ; echo ; echo

    echo "detailed i/o bay data"
    echo "---------------------"
    for i in `parstatus -M -I | awk -F':' '{print $2}'`
    do
        parstatus -V -i $i             # display detailed i/o bay data
    done
    echo ; echo ; echo

    echo "detailed hyperthreading data"
    echo "----------------------------"
    parstatus -T                      # display detailed hyperthreading data
    done
    echo
}
#################################################################

Superdome2Info
