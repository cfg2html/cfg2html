#!/bin/bash

# @(#) $Id: ib_hca_info.sh,v 6.13 2018/01/04 22:25:33 ralph Exp $
# --=-----------------------------------------------------------------------=---
# (c) 1997 - 2018 by Ralph Roth  -*- http://rose.rult.at -*-

# Source = wget ftp://ftp.qlogic.com/support/Hidden/scripts/ib/ib_hca_info.sh
# http://kb.qlogic.com/KanisaPlatform/Publishing/392/1559_f.SAL_Public.html

hcas=`/sbin/lspci | grep -i InfiniBand | grep -vi bridge | grep -vi QLogic | cut -d\  -f1`

if [ -z "$hcas" ]
then
        echo "No Mellanox HCAs found."
else
        for hca in $hcas
        do
                echo "#####################"
                if [ -e /sbin/mstvpd ]
                then
                        /sbin/mstvpd $hca
                else
                        /usr/bin/mstvpd $hca
                fi
#                /usr/bin/mstflint -d $hca dc | grep ib_support
				/usr/bin/mstflint -d $hca dc
                /usr/bin/mstflint -d $hca q
                /usr/bin/mstflint -d $hca v
                echo "#####################"
        done
fi
