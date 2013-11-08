#!/sbin/sh
# @(#) $Id: configure.sh,v 6.11 2013/10/29 23:11:26 ralph Exp $
# -------------------------------------------------------------------------
# cfg2html configure.sh

########

    UTILS="/usr/lbin/sw/control_utils"
    if [[ ! -f $UTILS ]]
    then
        /usr/bin/echo "ERROR: Cannot find $UTILS"
        exit 1
    fi
    . $UTILS
    exitval=$SUCCESS                           # Anticipate success


################################################################################

function _add_OUTPUT_URL_entry {
    # function specific for J&J -- maybe we should remove this? rr
    /usr/bin/grep -q jnj /etc/resolv.conf && {
    /usr/bin/echo "OUTPUT_URL=nfs://itsbebevcorp01.jnj.com/vol/itsbebevcorp01_cfg2html/cfg2html/hpux" >> $CFGFILE
    /usr/bin/echo "       * Added OUTPUT_URL entry to $CFGFILE"
    /usr/bin/echo "        " $(/usr/bin/tail -1 $CFGFILE)
    }
}

######################################
####		M A I N 	  ####
######################################

### create a new local /opt/cfg2html/etc/local.conf from the template conf file
### advantage is that 'swverify' will not complain about changed local.conf file!!

CFGFILE="/opt/cfg2html/etc/local.conf"


if [[ ! -f /opt/cfg2html/newconfig/local.conf ]]
then
	/usr/bin/echo "       * Did not find the template /opt/cfg2html/newconfig/local.conf file"
	exit 1
fi

if [[ -f $CFGFILE ]]
then
       /usr/bin/echo "       * $CFGFILE exists. We do not modify it."
else
       /usr/bin/cp /opt/cfg2html/newconfig/local.conf $CFGFILE
       /usr/bin/echo "       * Created the $CFGFILE"
       _add_OUTPUT_URL_entry
fi

/sbin/chmod 640 $CFGFILE
/sbin/chown root:sys $CFGFILE

exit $exitval
