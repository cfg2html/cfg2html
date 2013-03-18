function SCM_collector {
    echo "SCM Nodes"
    mxnode -lt
    echo "\nSCM Users"
    mxuser -lt
    echo "\nSCM Authorization"
    mxauth -lt
    echo "\nSCM Installed Tools"
    mxtool -lt
}

function patch_stat {
    
    swlist -l product|grep '  PH'
    echo " "
    
    if [ -r /var/adm/sw/patch/PATCH.log ] ;
    then
        PATCHES=`grep ^PH /var/adm/sw/patch/PATCH.log`
        IPH=`echo "$PATCHES"|grep Installed|wc -l`
        SPH=`echo "$PATCHES"|grep 'Superseded by'|wc -l`
        USPH=`echo "$PATCHES"|grep 'Un-Superseded'|wc -l`
        RPH=`echo "$PATCHES"|grep Removed|wc -l`
        
        echo "Total patches ever installed by user ....... " $IPH
        echo "Superseded patches ......................... " $SPH
        echo "Unsuperseded patches ....................... " $USPH
        echo "Patches removed by user .................... " $RPH
        echo "Superseded patches cleaned by user ......... " `grep 'Removed backup' /var/adm/sw/patch/PATCH.log| wc -l`
        echo "-------------------------------------------------"
    fi
    if [ -x /usr/contrib/bin/show_patches ]
    then
        show_patches -a
        echo " "
        show_patches -s
        echo "\n"
        
    fi
    echo "Currently installed patches ................ " `swlist -l product|grep '  PH'| wc -l`
}

######################################################################
# ATM by sommersn (c) 28.5.1999, Stefan Sommer
######################################################################

function ATM_info {
    
    ATM_CARDS=`ls /etc/atm | grep atm_`
    
    for i in $ATM_CARDS
    do
        echo "\n------"
        echo Working on ATM-Adapter-Card $i
        CARD_INST_NUM=`echo $i | cut -c5-`
        
        atmmgr $CARD_INST_NUM show -p # Physical statistics and status
        atmmgr $CARD_INST_NUM show -c # ATM Cell statistics and status
        atmmgr $CARD_INST_NUM show -a # AAL5 statistics
        atmmgr $CARD_INST_NUM show -t # Current Traffic Parameter Configurations
        atmmgr $CARD_INST_NUM show -i # Classical IP ARP server
        
        
        echo Configured Lan Emulation
        LAN_EMULATIONS=`ls /etc/atm/${i} | grep el`
        
        for j in $LAN_EMULATIONS
        do
            elstat -n $j -v
            elstat -n $j -s
        done
        
    done
    
}

######################################################################

function perf_tools {
    if [ -x /usr/contrib/bin/monitor ]
    then
        print "/usr/contrib/bin/monitor      #Monitor (Contributed Tool)"
        flag=1
    fi
    if [ -x /usr/bin/top ]
    then
        print "/usr/bin/top                  #Top (shows top CPU hogs)"
        flag=1
    fi
    if  [ -x /usr/bin/glance ] || [ -x /usr/perf/bin/glance ] || [ -x /opt/perf/bin/glance ]
    then
        print "<perfdir>/bin/glance          #Glance (HP Performance Tool)"
        flag=1
    fi
    
    if  [ -x /opt/perf/bin/gpm ] || [ -x /usr/bin/gpm ] || [ -x /usr/perf/bin/gpm ]
    then
        print "<perfdir>/bin/gpm             #GPM (HP Performance Tool)"
        flag=1
    fi
    if [ -x /opt/perf/bin/scopeux ] || [ -x /usr/perf/bin/scopeux ]
    then
        print "<perfdir>/bin/scopeux         #Scopeux Performance Collector"
        flag=1
    fi
    if [ -x /usr/sbin/sar ] || [ -x /usr/bin/sar ]
    then
        print "/usr/[s]bin/sar               #System-Activity-Report Tool"
        flag=1
    fi
    [ -x /opt/perf/bin/perfstat ] && (echo "\nPERFSTAT:\n";/opt/perf/bin/perfstat)
    if [ $flag -eq 0 ]
    then
        echo "No Performance Monitors available!"
    fi
    echo
}

##################################################################
# get LIF info
##################################################################

function get_LIF {
    
    [ -x /usr/sbin/setboot ] && ((/usr/sbin/setboot -v || /usr/sbin/setboot); echo "\n")
    
    #  lvlnboot -v vg00 2>&1 | grep "Boot Disk"
    #         /dev/dsk/c0t6d0s2 (0/0/0/2/0.6.0) -- Boot Disk
    #         /dev/dsk/c2t6d0s2 (0/0/0/3/0.6.0) -- Boot Disk
    #  lvlnboot -v vg00 2>&1 | grep "Boot Disk"
    #         /dev/disk/disk20_p2 -- Boot Disk
    
    if [ -f /etc/lvmtab ]
    then
        # Boot device no longer has to be named vg00  (KL 26.10.11)
        #boot=`lvlnboot -v vg00 2>&1 | grep "Boot Disk" | awk ' {print $1} '`
        boot=`lvlnboot -v 2>/dev/null | grep '^Boot Def' | awk -F'/' '{print $NF}' | tr -d ':'`
        boot=`lvlnboot -v $boot 2>&1 | grep "Boot Disk" | awk '{print $1}'`
    else
        boot=`mount | grep "^/ " | awk '{ print $3 }'`
        Add_Text "Strange, this system seems NOT to have LVM configured!"
    fi
    
    #echo "Boot-Devices\n" $boot2
    
    for i in $boot
    do
        boot2=`echo $i|sed "s/dsk/rdsk/"|sed "s/disk/rdisk/"|grep /dev/`  #  20.11.2008, 15:52  Ralph Roth
        ## fixed for Itanium ## needs rework for HP-UX 11.31 MSS
        echo "\n"
        diskinfo $boot2 | fold
        echo "\n--- LIF and ODE contents of $i ---\n"
        lifls -l $i
        echo "\n--- LIF AUTO boot string of $i ---\n"
        lifcp $i:AUTO -
        echo "\n"
    done
    
    grep "Boot device" /var/adm/syslog/syslog.log | sort -u

} # get_LIF

function JetDirect {
    echo "JetDirect-\c"; cat /opt/hpnpl/version
    echo "\nJetDirect executable"
    /opt/hpnpl/bin/hpnpadmin
}

function JetAdmin {
    echo "JetAdmin-\c"; cat /opt/hpnp/version
    echo "\nJetAdmin executable"
    what /opt/hpnp/bin/jetadmin
}

function ob_lbin_version {
    for i in /opt/omni/lbin/?ma /opt/omni/lbin/??da      # a = agent!
    do
        [ -x $i ] && $i -version | head -1              # DP5.0 fix, sr by mk, 141102
    done
    echo "\nPatch level:"
    cat /opt/omni/.patch_* | sort
}

function ob_instanzen {
    cat /etc/opt/omni/cell/omni_info
}

function PrintModel {
    echo "Modelstring:    $mdl"
    echo "Number of CPUs: $ncpu"
    echo "CPU capable:    $HWBITS bits"
    echo "CPU Speed:      $MHZ MHz"
}

function HostNames {
    uname -a
    echo   "HP-UX 32/64 = $BITS bits"
    echo "\nDomainname  = "`domainname`
    echo   "Hostname    = "`hostname`
}

function posixversion {
    echo "POSIX Version:  \c"; getconf POSIX_VERSION
    echo "POSIX Version:  \c"; getconf POSIX2_VERSION
    echo "X/OPEN Version: \c"; getconf XOPEN_VERSION
    echo "LANG setting:   "$LANG
    echo "Time Zone (TZ): "$TZ
}

function extract_xpinfo_i {
   # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -i'
   # the CSV file contains the following:
   #device_file; target_id; LUN_id; port_id; CU:LDev; type; device_size; serial#; code_rev; subsystem; CT_group; CA_vol; BC0_vol; BC1_vol; BC2_vol; ACP_pair; RAID_level; RAID_group; disk1; disk2; disk3; disk4; model; port_WWN; ALPA; FC-AL Loop Id; SCSI Id; FC-LUN Id
   # for xpinfo -i we need:
   # device_file  ALPA  target_id  LUN_id  port_id   CU:LDev  type  serial#
   local CSVfile=$1
   local outf=$2
   [[ ! -f $CSVfile ]] && {
       echo "Error: xpinfo -i (did not find input file $CSVfile)"
       exit 1
   }
   cat > $outf <<-EOF
	Device File                 ALPA Tgt Lun Port  CU:LDev Type             Serial#
	================================================================================
	EOF
   grep "^/dev" $CSVfile | while read LINE
   do
       echo $LINE | awk -F";" '{printf "%-27s %-4s %-3s %-3s %-6s %-7s %-13s %s\n", $1, $25, $2, $3, $4, $5, $6, $8}' >>  $outf
   done
}

function extract_xpinfo_c {
   # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -c'
   # the CSV file contains the following:
   #device_file; target_id; LUN_id; port_id; CU:LDev; type; device_size; serial#; code_rev; subsystem; CT_group; CA_vol; BC0_vol; BC1_vol; BC2_vol; ACP_pair; RAID_level; RAID_group; disk1; disk2; disk3; disk4; model; port_WWN; ALPA; FC-AL Loop Id; SCSI Id; FC-LUN Id
   # for xpinfo -c  we need:
   # device_file  subsys  CT group   CA Vol   BC Volumes MU#0 MU#1 MU#2
   local CSVfile=$1
   local outf=$2
   [[ ! -f $CSVfile ]] && {
       echo "Error: xpinfo -i (did not find input file $CSVfile)"
       exit 1
   }
   cat > $outf <<-EOF
	                                   CT       CA        BC Volume
	Device File              Subsys    Group    Vol     MU#0 MU#1 MU#2
	==================================================================
	EOF
   grep "^/dev" $CSVfile | while read LINE
   do
      echo $LINE | awk -F";" '{printf "%-25s %-10s %-6s %-7s %-5s %-5s %s\n", $1, $10, $11, $12, $13, $14, $15}' >>  $outf
   done

}

function extract_xpinfo_r {
    # arg1: xpinfo CSV file, arg2: output should look like 'xpinfo -r'
    # for xpinfo -r  we need:
    # device_file   ACP Pair   Raid Level  RAID type  Raid group   disk Mechanisms
    # FIXME: RAID Type is pointing to which field in the CSV file?? I use now "---" as a replacement
    local CSVfile=$1
    local outf=$2
    cat > $outf <<-EOF
	                         ACP       RAID   RAID   RAID                      Disk
	Device File              Pair      Level  Type   Group                     Mechanisms
	===============================================================================================
	EOF
    grep "^/dev" $CSVfile | while read LINE
    do
        echo $LINE | awk -F";" '{printf "%-25s %-9s %-5s %-6s %-6s %-8s %-8s %-8s %s\n", $1, $16, $17, "---", $18, $19, $20, $21, $22}' >> $outf
    done
}

