# FibreChannel Collector, Initial creation June 2013
# @(#) $Id: fc_collector.sh,v 6.2 2018/03/23 11:07:07 ralph Exp $
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4 -*- coding: utf-8 -*- http://rose.rult.at/ - Ralph Roth


for HBA in /sys/class/fc_host/*
do
  echo $HBA
  for i in npiv_vports_inuse  port_state  speed  supported_classes  system_hostname  \
    dev_loss_tmo  max_npiv_vports  port_id  port_type supported_speeds    \
    fabric_name   node_name port_name symbolic_name
  do
    echo "   $i:"$(cat $HBA/$i)
  done
  echo ""
done
