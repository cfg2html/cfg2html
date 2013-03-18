# Collector for Ultra320 SCSI controllers and A7173A PCI-X Dual channel Host Bus Adapters 
# 21.7.2008, 15:49 modified by Ralph Roth
# @(#) $Id: get_mptinfo.sh,v 5.10.1.1 2011-02-15 14:29:05 ralproth Exp $
# ---------------------------------------------------------------------------

if [ -x /usr/sbin/mptconfig ]  
then
      for i in /dev/mpt*
      do
           if [ -c $i ]  
           then
                    echo "\n"
                    mptutil $i 2> /dev/null   | grep -v -e "^*" -e "^$" -e "/usr/sbin/ioscan"  -e "/sbin/init.d/mpt"
                    # mptconfig may need inprovements.... rr
                    mptconfig $i 2> /dev/null | grep -v -e "Scan For Devices" -e "/usr/sbin/ioscan"  -e "/sbin/init.d/mpt" -e "^$"
           fi
      done 
fi
