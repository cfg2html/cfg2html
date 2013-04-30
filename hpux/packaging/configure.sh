#!/sbin/sh
# @(#) $Id:$
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
    /usr/bin/echo "OUTPUT_URL=nfs://itsusravunx01.jnj.com/vol/itsusravunx01_its/unix_images/hpux" >> $CFGFILE
    /usr/bin/echo "       * Added OUTPUT_URL entry to $CFGFILE"
    /usr/bin/echo "        " $(/usr/bin/tail -1 $CFGFILE)
    }
}

######################################
####		M A I N 	  ####
######################################

### create a new /etc/cfg2html/local.conf from the template conf file
## /usr/newconfig/etc/cfg2html/local.conf according region
### advantage is that 'swverify' will not complain about changed files!!

CFGFILE="/etc/cfg2html/local.conf"


if [[ ! -f /usr/newconfig/etc/cfg2html/local.conf ]]
then
	/usr/bin/echo "       * Did not find the template /usr/newconfig/etc/cfg2html/local.conf file"
	exit 1
fi

if [[ -f $CFGFILE ]]
then
       /usr/bin/echo "       * $CFGFILE exists. We do not modify it."
else
       /usr/bin/cp /usr/newconfig/etc/cfg2html/local.conf $CFGFILE
       /usr/bin/echo "       * Created the $CFGFILE"
       _add_OUTPUT_URL_entry
fi

/sbin/chmod 640 $CFGFILE
/sbin/chown root:sys $CFGFILE

exit $exitval
