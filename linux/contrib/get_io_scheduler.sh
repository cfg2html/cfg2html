

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


