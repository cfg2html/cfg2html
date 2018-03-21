#!/bin/bash

# @(#)  $Id: infiniband.sh,v 2.4 2011-09-08 12:21:03 ralproth Exp $
# ---------------------------------------------------------------------------
# experimental plugin for cfg2html-linux. Ralph Roth

CollectMellanox()
{
  for hca in $hcas
  do
    echo "#####################"
    if [ -e /sbin/mstvpd ]
    then
      /sbin/mstvpd $hca
    else
      /usr/bin/mstvpd $hca
    fi
    # /usr/bin/mstflint -d $hca dc | grep ib_support
    # yum install -y mstflint
    /usr/bin/mstflint -d $hca dc
    /usr/bin/mstflint -d $hca q
    /usr/bin/mstflint -d $hca v
    echo "#####################"
  done
}


if [ -x /usr/bin/mstflint ]
then
  # 06:00.0 InfiniBand: Mellanox Technologies MT25208 InfiniHost III Ex (Tavor compatibility mode) (rev 20)
  # 04:00.0 InfiniBand: Mellanox Technologies MT26428 [ConnectX VPI PCIe 2.0 5GT/s - IB QDR / 10GigE] (rev a0)
  # 0b:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s] (rev b0)

  hcas=`/sbin/lspci | grep -i InfiniBand | grep -vi bridge | grep -vi QLogic | cut -d\  -f1`

  if [ -n "$hcas" ]
  then
    # e.g. 06:00.0
    CollectMellanox
  fi      # else echo "No Mellanox InfiniBand HCAs found..."

  # [QA] root@qb5utmen01a (/tmp)# lspci | grep Mell
  # 0b:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s] (rev b0)
  # 0e:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s] (rev b0)

  hcas=`/sbin/lspci | grep -i Mellanox | grep -i Ethernet | grep -vi QLogic | cut -d\  -f1`
  if [ -n "$hcas" ]
  then
    # e.g. 06:00.0
    CollectMellanox
  fi
fi

# Alternative stuff
# cat /sys/class/infiniband/mthca0/ports/1/state
# cat /sys/class/infiniband/mthca0/ports/1/rate
# cat /sys/class/infiniband/mthca0/ports/1/phys_state
# cat /sys/class/infiniband/mthca0/ports/2/phys_state

