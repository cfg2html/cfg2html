# $Header: /home/cvs/cfg2html_cvs/cfg2html_git/linux/contrib/get_io_scheduler.sh,v 6.6 2025/02/20 09:07:13 ralph Exp $

# devices: Works for pre 6.x, 5.x Kernels? (no multi-queue scheduler)
for i in $(find /sys/devices/  /sys/block | grep /queue/scheduler)
do
  echo $i": "$(cat $i)|grep -E "noop|none"
done

# -----------------------------------------------------------------------------

# Another approach:

# 1.)
# sles12sap2:~ # for i in $(find /sys/devices/ | grep /queue/scheduler | grep -v -e /loop -e /block/ram)
# > do
# >     echo $i": "$(cat $i)
# > done

# 2.)
# grep -o '\[.*\]' /sys/block/*/queue/scheduler

# $ cat /sys/block/nvme1n1/queue/scheduler
# [none] mq-deadline

# 3.)
# /bin/lsblk -o 'NAME,KNAME,MAJ:MIN,FSTYPE,LABEL,RO,RM,MODEL,SIZE,OWNER,GROUP,MODE,ALIGNMENT,MIN-IO,OPT-IO,PHY-SEC,LOG-SEC,ROTA,SCHED,MOUNTPOINT' | grep -v "/snap/"
