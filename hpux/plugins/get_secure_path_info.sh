# @(#) $Id: $
# get_secure_path_info.sh
[[ ! -x /sbin/autopath ]] && exit 0        # no secure path executable found

/sbin/autopath display all > /tmp/autpath_display_all.$$
# possible output could be something like:


#==================================================================
# HPswsp Version        : A.3.0F.04F.01F
#==================================================================
# Auto Discover         : ON
#==================================================================
# Array Type            : XP
# Array WWN             : 1139-3
# Path Verification Period : 00:10
#==================================================================
# Lun WWN               : 50_0-2C81-0C88
# Virtual Device File   : /hpap/dsk/hpap0
# Load Balancing Policy : Shortest Service Time
# Lun Timeout           : Infinite Retry (-1)
#==================================================================
# Device Path                    Status
#==================================================================
# /dev/dsk/c12t0d0               Active
# /dev/dsk/c14t0d0               Active

grep -v "====" /tmp/autpath_display_all.$$
rm -f /tmp/autpath_display_all.$$
