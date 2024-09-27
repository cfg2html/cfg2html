#!/bin/bash
## $Header: /home/cvs/cfg2html_cvs/cfg2html_git/linux/contrib/progs_using_swap.sh,v 1.4 2024/08/06 12:17:17 ralph Exp $
# -------------------------------------------------------------------------------
## This script is designed to determine the current swap usage for all running processes on a Linux system.
## This script helps in identifying which processes are using swap space, which can be useful for system monitoring and performance tuning

## 28.04.2020, rr, initial creation, 06.08.2024 added comments, nicer+formatted output

echo "Program (name)                Pid      VmSwap (KB)"
echo "-------------------------------------------------------------------------------"
## Which programs use swap? Determine current swap usage for all running processes
## Output: ProgramName, PID, Swap used in KB
for i in /proc/*/status
do
  awk '
  /Name:/       { Name = $2;}
  /VmSwap:/     { Swap = $2; }
  /^Pid:/       { Pid = $2+0; }
  END { if (Swap > 0) { printf ("%-20s\t %8d \t%10d\n",  Name,Pid,Swap); }}
  ' ${i} 2> /dev/null
done | sort -k 3 -n -r

#########################
echo ""
echo "Overall memory details taken from free command (Total/KB):"
echo "-------------------------------------------------------------------------------"
free -tk
