# @(#) $Id: ixostool.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# generic driver for OpenText/IXOS/LEA/Archive Server, (c) by Ralph Roth

IXOS=/usr/ixos-archive

[ -h "$IXOS" ] || (echo "No IXOS installed/found! Exiting..."; exit 1)
[ -r "$IXOS/config/setup/profile" ] || (echo "No IXOS profile installed! Exiting!"; exit 2)

. $IXOS/config/setup/profile   2>&1 > /dev/null

# IXOS_ARCHIVE_USER=ixtadm
# IXOS_ARCHIVE_GRP=ixossys

TF=$(mktemp)

su - $IXOS_ARCHIVE_USER -c "($*  > $TF 2>&1)"   > /dev/null 2>&1

cat $TF

rm -f $TF

# ---------------------------------------------------------------------------
# $Log: ixostool.sh,v $
# Revision 6.10.1.1  2013-09-12 16:13:15  ralph
# Initial 6.10.1 import from GIT Hub, 12.09.2013
#
# Revision 5.10.1.1  2011-02-15 14:29:05  ralproth
# Initial 5.xx import
#
# Revision 4.1  2009/03/31 12:27:28  ralproth
# added IXOS helper tool
#
#
