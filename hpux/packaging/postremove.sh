#!/bin/sh
# cfg2html postremove script

# keep a copy of previous active crontab file
cronfile=/var/tmp/cronfile.$(date +'%Y-%m-%d')
crontab -l > $cronfile
echo "       * current active crontab file saved as $cronfile"

# remove cfg2html entry
grep -v 'cfg2html' $cronfile  > $cronfile.new

# activate the new crontab file
crontab $cronfile.new

# cleanup
rm -f $cronfile.new

