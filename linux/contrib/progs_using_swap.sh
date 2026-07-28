#!/bin/bash
#
## @(#) $Id: progs_using_swap.sh,v 1.8 2026/07/28 16:13:46 ralph Exp $
## $Header: /home/cvs/cfg2html_cvs/cfg2html_git/linux/contrib/progs_using_swap.sh,v 1.8 2026/07/28 16:13:46 ralph Exp $
# -------------------------------------------------------------------------------
## Should be run as root, otherwise some processes will not be accessible and will not be listed
#
## This script is designed to determine the current swap usage for all running processes on a Linux system.
## This script helps in identifying which processes are using swap space, which can be useful for system monitoring and performance tuning

## 28.04.2020, Ralph Roth, initial creation, 06.08.2024 added comments, nicer+formatted output
## 29.01.2026, Ralph Roth, Hint:  grep -A 15 "Swap" /proc/$PID/smaps

#    012345678901234567890123456789012345678901234567890123456789012345678901234567890
echo "Program (name)                        Pid      VmSwap (KB)"
echo "-------------------------------------------------------------------------------"
## Which programs use swap? Determine current swap usage for all running processes
## Output: ProgramName, PID, Swap used in KB
for i in /proc/*/status
do
  awk '
  /Name:/       { Name = $2;}
  /VmSwap:/     { Swap = $2+0; }
  /^Pid:/       { Pid = $2+0; }
  END { if (Swap > 0) { printf ("%-30s\t %8d \t%10d\n",  Name,Pid,Swap); }}
  ' ${i} 2> /dev/null
done | sort -k 3 -n -r

#########################
echo ""
echo "Overall memory details taken from free command (Total/KB):"
echo "-------------------------------------------------------------------------------"
free -tk
