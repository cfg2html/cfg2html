#!/bin/sh
# ---------------------------------------------------------------------------
# @(#)  DRD plugin, provided by Thomas Brix, 02. Feb 2011
# ---------------------------------------------------------------------------

# @(#) $Id: get_drd.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# -----------------------------------------------------------------------------------------
# (c) 1997 - 2013 by Ralph Roth  -*- http://rose.rult.at -*-


CFG2HTML_PLUGINTITLE="Dynamic Root Disk (DRD) Plugin"
F=/opt/drd/bin/drd
L=/var/opt/drd/drd.log

#function cfg2html_plugin {
        [ -x $F ] && /usr/bin/what $F
        if [ -r $L ]
        then
                echo wc -l $L; wc -l $L
                echo \\ntail -100 $L; tail -100 $L
        else
		        echo no $L found
        fi
        #echo "The PID of this plugin run was " $$
#}
