# $Header: /home/cvs/cfg2html/cfg2html_git/linux/contrib/get_io_scheduler.sh,v 6.3 2018/03/23 11:07:07 ralph Exp $

for i in $(find /sys/devices/ | grep /queue/scheduler)
do
  echo $i": "$(cat $i)|grep noop
done

# -----------------------------------------------------------------------------

# Another approach:
# sles12sap2:~ # for i in $(find /sys/devices/ | grep /queue/scheduler | grep -v -e /loop -e /block/ram)
# > do
# >     echo $i": "$(cat $i)
# > done


