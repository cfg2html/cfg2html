# replacement script for qlan.pl -v
# @(#) $Id: get_bootdisk.sh,v 5.11 2017/03/18 14:54:26 ralph Exp $

function get_qlan_details_1131 {
    /usr/sbin/nwmgr > /tmp/nwmgr_cfg2html.txt
    for lan in $(grep ^lan /tmp/nwmgr_cfg2html.txt | grep UP | awk '{print $1}')
    do
        /usr/sbin/nwmgr -q vpd  -c $lan
        /usr/sbin/nwmgr -q info  -c $lan
	echo "#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    done
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

case $(uname -r) in
    "B.11.31") get_qlan_details_1131 ;;
    *) ;;
esac

# cleanup
rm -f /tmp/nwmgr_cfg2html.txt
