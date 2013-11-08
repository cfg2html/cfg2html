#!/bin/sh
# @(#) $Id: postinstall.sh,v 6.10.1.1 2013-09-12 16:13:15 ralph Exp $
# -------------------------------------------------------------------------
# cfg2html postinstall script

# keep a copy of previous active crontab file
cronfile=/var/tmp/cronfile.$(date +'%Y-%m-%d')
crontab -l > $cronfile
echo "       * current active crontab file saved as $cronfile"

# remove old redundant entries
egrep -i -v 'cfg2html' $cronfile  > $cronfile.new
# add new entry (built in a sleep up to 600 seconds to avoid traffic jams)
echo "$((RANDOM % 55)) $((RANDOM % 5)) * * $((RANDOM % 5))  /usr/bin/sleep \$((RANDOM \% 600)) ; /usr/sbin/cfg2html -2\%Y\%m\%d > /dev/null 2>&1" >> $cronfile.new

# activate the new crontab file
crontab $cronfile.new

# show the added line
echo "       * Added line to crontab:"
echo "         $(crontab -l | grep cfg2html)"

# cleanup
rm -f $cronfile.new

# make symlink from /opt/cfg2html/bin/cfg2html to /usr/sbin/cfg2html
[[ -f /usr/sbin/cfg2html ]] && rm -f /usr/sbin/cfg2html   # probably an old version (rm it 1st)
ln -s /opt/cfg2html/bin/cfg2html  /usr/sbin/cfg2html
echo "       * Create a symbolic link from /opt/cfg2html/bin/cfg2html to /usr/sbin/cfg2html"

# copy /opt/cfg2html/doc/cfg2html.8 to /usr/share/man/man8.Z/cfg2html.8 (compressed file)
[[ -f /usr/share/man/man8.Z/cfg2html.8 ]] && rm -f /usr/share/man/man8.Z/cfg2html.8
cp /opt/cfg2html/doc/cfg2html.8  /usr/share/man/man8.Z/cfg2html.8
chmod 644 /usr/share/man/man8.Z/cfg2html.8
echo "       * Create man page under /usr/share/man/man8.Z/cfg2html.8"
