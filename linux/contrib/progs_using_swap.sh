#!/bin/bash
## $Header: /home/cvs/cfg2html/cfg2html_git/linux/contrib/progs_using_swap.sh,v 1.2 2020/04/28 14:10:05 ralph Exp $
# -------------------------------------------------------------------------------
## Which programs use swap? Determine current swap usage for all running processes
## 28.04.2020, rr, initial creation

echo "-------------------------------------------------------------------------------"
echo "Name, Pid, VmSwap (KB)"
# Output: ProgramName, PID, Swap used in KB
for i in /proc/*/status
do
  awk '
  /Name:/       { Name = $2;}
  /VmSwap:/     { Swap = $2; }
  /^Pid:/       { Pid = $2+0; }
  END { if (Swap > 0) { printf ("%s (%d) %8d\n",  Name,Pid,Swap); }}
  ' ${i} 2> /dev/null
done | sort -k 3 -n -r

#########################
echo "-------------------------------------------------------------------------------"
free -tk
