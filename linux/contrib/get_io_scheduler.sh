# $Header: /home/cvs/cfg2html/cfg2html_git/linux/contrib/get_io_scheduler.sh,v 6.2 2017/08/30 11:26:52 ralph Exp $

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


