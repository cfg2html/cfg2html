#!/bin/sh
# @(#) $Id:$
# -------------------------------------------------------------------------
# cfg2html postinstall script

# keep a copy of previous active crontab file
cronfile=/var/tmp/cronfile.$(date +'%Y-%m-%d')
crontab -l > $cronfile
echo "       * current active crontab file saved as $cronfile"

# remove old redundant entries
egrep -i -v 'cfg2html' $cronfile  > $cronfile.new
# add new entry (built in a sleep up to 600 seconds to avoid traffic jams)
echo "$((RANDOM % 55)) $((RANDOM % 5)) * * $((RANDOM % 5))  /usr/bin/sleep \$((RANDOM % 600)) ; /usr/sbin/cfg2html -2%Y%m%d > /dev/null 2>&1" >> $cronfile.new

# activate the new crontab file
crontab $cronfile.new

# show the added line
echo "       * Added line to crontab:"
echo "         $(crontab -l | grep cfg2html)"

# cleanup
rm -f $cronfile.new

