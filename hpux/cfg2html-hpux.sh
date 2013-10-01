# @(#) $Id: cfg2html-hpux.sh,v 6.11 2013-09-24 18:57:44 ralph Exp $ 
# -------------------------------------------------------------------------
# vim:ts=8:sw=4:sts=4 -*- 

####################################################################
# getopt

#ADFHLSYabcdefhklno:stvx2:10UM
while getopts ":ADFHLPSTabcdefhklno:stv2:10UM" Option
do
    case $Option in
        A     ) CFG_SAP="yes";;
        D     ) set | grep -e CFG_ -e OUTDIR ;;
        F     ) CFG_FIBRECHANNEL="no";;
        H     ) CFG_HARDWARE="no";;
        L     ) CFG_STINLINE="no";;
        P     ) CFG_PLUGINS="yes";;
        S     ) CFG_SOFTWARE="no";;
        T     ) CFG_TRACETIME="yes";;	# show each exec_command with timestamp
        a     ) CFG_APPLICATIONS="no";;
        b     ) CFG_BCSCONFIG="no";;   ## obsolete, remove in 6.xx stream!
        c     ) CFG_CRON="no";;
        d     ) CFG_DIAG="no";;
        e     ) CFG_ENHANCEMENTS="no";;
        f     ) CFG_FILESYS="no";;
        h     ) usage ; exit 12;;
        k     ) CFG_KERNEL="no";;
        l     ) CFG_LVM="no";;
        n     ) CFG_NETWORK="no";;
        o     ) OUTDIR=$OPTARG;;	## OPTARG ##
        s     ) CFG_SYSTEM="no";;
        t     ) CFG_TGV="no";;         ## obsolete, remove in 6.xx stream!
        v     ) echo $PROGRAM $VERSION"//"$(uname -mrs); exit 13;;
        2     ) CFG_DATE="_"$(date +$OPTARG) ;;	## OPTARG ##
        1     ) CFG_DATE="_"$(date +%d-%b-%Y) ;;
        0     ) CFG_DATE="_"$(date +%d-%b-%Y-%H%M) ;;
        U     ) CFG_SECURITY="yes" ;;
        M     ) CFG_MCSG="no" ;;
        *     ) echo "Unimplemented option ($Option) chosen! OPTARG=$OPTARG";
                echo "Try -h for a short online help!"
                exit 14;;   # DEFAULT
    esac
done

shift $(($OPTIND - 1))
# Decrements the argument pointer so it points to next argument.


typeset -i HEADL=0                       # Headinglevel, Original=0

_echo "\n"

#####################################################################
#         Check that you are running the script as root user
#####################################################################
check_root

# define the HTML_OUTFILE, ERRORFILE
define_outfile

######### Check if /plugin dir is there #############################
check_plugins_dir

# create our VAR_DIR, OUTDIR before we continue
create_dirs

# create a lock file
check_lock

touch $HTML_OUTFILE
[ -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

exec 2> $ERROR_LOG

if [ ! -f $HTML_OUTFILE ]  ;
then
    _banner "Error"
    line
    _echo "You have not the rights to create the file $HTML_OUTFILE! (NFS?)\n"
    exit 6
fi

## osrev=`uname -r|awk -F. '{ print $2 }'`
## osrev100=$(uname -r | cut -d "." -f2- | awk  ' { printf "%d", $1*100; }')

   osrevdot=$(uname -r | cut -d. -f 2,3)        # 11.31
   osrev=$(echo $osrevdot | cut -d . -f1)       # 11
   osrev100=$(echo $osrevdot | tr -d ".")       # 1131

if [ "$osrev100" -lt 1111 ]
then
    _banner "Sorry"
    line
    _echo "$0: Requires HP-UX 11.11 or better! Use the 3.xx stream instead for $osrevdot\n"
    _echo "WARNING! HP-UX 10.xx and 11.00 is obsolete, cfg2html may not work as supposed!"
    _echo "Do not ask for a HP-UX 9.xx port - we never will port it back!"
    exit 7
# else
    # supported OS :)
    #    echo "Using HP-UX $osrev100"   # for debugging support :)    
fi


#######################################################################
##################### C O L L E C T O R S #############################
#######################################################################

if [ -z "$CFG2HTML" ]           # only execute if not called from
then                            # cfg2html directly!
    SCM_collector
fi


######################################################################
#######################  M A I N  ####################################
######################################################################

LANG_C

# ---------------------------------------------------------------------------

line
echo "Starting          "$PROGRAM $VERSION" on a "$(model) box
echo "Path to cfg2Html  "$0
echo "Path to plug-ins  "$PLUGINS "Arch=$CFG_ARCH"
echo "HTML Output File  "$HTML_OUTFILE
echo "Text Output File  "$TEXT_OUTFILE
echo "Errors logged to  "$ERROR_LOG
[[ -f $CONFIG_DIR/local.conf ]] && {
    echo "Local config      "$CONFIG_DIR/local.conf
    }
echo "Started at        "$DATEFULL
echo "Command line used "$CFG_CMDLINE
if [ "$CFG_DIAG" = "yes" ] ; then
    echo "Problem           If cfg2html hangs on Hardware, press twice ENTER, Ctrl-D or"
    echo "                  Crtl-\\. Then check your Diagnostics (A.42++ and PHKL_29798)!"
fi
line
echo "USE AT YOUR OWN RISK! (for details read $BASE_DIR/doc/cfg2html.html)"
echo "Online help: run $0 -h for help or look at the ~/doc directory"
line

# ------------ thomas brix ----------------------------------------
if [ -f /etc/rc.config ] ; then
    . /etc/rc.config
else
    echo "ERROR: the /etc/rc.config defaults file is MISSING"
    exit 8
fi
# ------------ thomas brix ----------------------------------------

logger "Start of $VERSION"
open_html

# Quick Overview

inc_heading_level
AddText "Hint: Use /opt/cfg2html/contrib/check_errors_hpux.sh to check your systems for misconfiguration and errors"
######################################################################
if [ "$CFG_SYSTEM" != "no" ]
then # else skip to next paragraph
    
    paragraph "HP-UX/System"
    inc_heading_level
    
    ##### A hack for 10/11 only, maybe 12? ###########  rar 16.03.99 #####
    # according to K-Mine A4500835 use better:
    if [ $osrev -gt 10 ] ;
    then
        # from 11.20 on adb checks whether IA (-n) or PA (-o)
        # Dmitry Kasilov, 24.01.2005 fix for 11.23 IA64 to show CPU speed correctly
        if model | grep -qi IA64
        then ADBOPT="-o"
            #if what /usr/bin/adb | grep -q IA64; then ADBOPT="-o"
        else ADBOPT="";
        fi
        #cut needs a -d: now, maybe there's a bug according to OS, 20110119
        HZ=`echo itick_per_tick/D|adb $ADBOPT /stand/vmunix /dev/kmem|grep tic|tail -1|cut -d: -f2`
    else
        HZ=`echo itick_per_tick/D|adb -k /stand/vmunix /dev/kmem|tail -1|cut -f2`
    fi
    
    ((MHZ=(($HZ+1)/10000)))
    
    BITS=`getconf KERNEL_BITS`
    HWBITS=`getconf HW_CPU_SUPP_BITS`
    
    #((ncpu = `sar -M 1 1 | wc -l` - 5 )) ####### cpus: 04.05.2000, rar
    #((ncpu = `sar -M 1 1 | grep -v system | wc -l` - 4 )) # bugfix for sar patch with new sar output by Peter Krueger, 31.07.2001
    # more easier, use ioscan :), ralph - 20.05.2003
    ncpu=$(ioscan -k|grep processor|wc -l)  ## or syssmall.hppa
    
    mdl=$(model -D || model) ## rar, 06052005
    # fix provided 12.06.2001 by Stefan Fournier
    mdl1=`model|cut -f2 -d/`
    if [ `echo $mdl1 | grep -c "^7"` -gt 0 ]
    then
        # machine is 7XX model
        mdls=$mdl1
    else
        mdls=`model|cut -f3 -d/`
    fi
    
    mdls=`model|cut -f3 -d/`
    [ -z "$mdls" ] && mdls="^"`model|cut -f2 -d/`   # e.g. 9000/720
    
    exec_command PrintModel "Model"  ##  14.07.2005, 18:56 modified by Ralph.Roth
    if [ $(uname -m) = "ia64" ]
    then
        ## Itanium
        :
    else
        if [ -f /usr/lib/sched.models ] ; then
            exec_command "(grep \"$mdls\" /usr/lib/sched.models)" "PA-RISC Type (10.x)"
        fi
        if [ -f /usr/sam/lib/mo/sched.models ] ; then
            exec_command "(grep \"$mdls\" /usr/sam/lib/mo/sched.models)" "PA-RISC Type (11.x)"
        fi
    fi
    if [ -f /etc/.supported_bits ] ; then
        suppbits=`grep $mdl /etc/.supported_bits`
        [ -z "$suppbits" ] &&   AddText "WARNING: Model string does not match /etc/.supported_bits - An update of HP-UX may fail!"
        exec_command "grep $mdl /etc/.supported_bits" "Supported Bits (32/64)"
    fi
    
    exec_command  HostNames "uname and hostname"
    
    exec_command posixversion "POSIX Standards/Settings"
    exec_command "locale" "Locale"
    
    ########################################################
    exec_command "cat /etc/PATH | tr ':' '\n'" "/etc/PATH"
    exec_command "cat /etc/MANPATH | tr ':' '\n'" "/etc/MANPATH"
    exec_command "ulimit -aS" "Soft User limits"	#  12.07.2007, 11:34 modified by Ralph Roth
    exec_command "ulimit -aH" "Hard User limits"	#  12.07.2007, 11:34 modified by Ralph Roth
    AddText "Hint: See http://www.faqs.org/faqs/hp/hpux-faq/section-144.html for details about ulimit"
    exec_command "uptime;sar 1 9" "Uptime, Load and SAR"
## UNIX95 affects a number of processes. It is best to set the variable only for
##    the desired command.
##  export UNIX95=yes                                       # hint by Gert Leerdam

    # Dieses Script prueft, ob in der Prozesstabelle noch Platz besteht, um neue
    # Prozesse zu starten. Heiko Koebert, Hewlett-Packard GmbH, Supportzentrum
    # Ratingen - Unix Competency Center
    # Heavy modified by Ralph Roth, 28-Jan-2002
    # Definition der Variablen V mit dem aktuellen Wert von proc-sz (z.B. 89/532)
    #
    sarV=`sar -v 1 1|tail -1|awk '{print $4}'`
    #
    # Definition der Variablen v in % (aktueller Wert / Maximal Wert * 100)
    #
    VSAR=$(echo $sarV *100|bc -l|awk '{ printf "\nProcess table: %3.2f percent used.\n", $1}')
    exec_command "UNIX95= ps -Hef; echo $VSAR" "Hierarchical Process View"  # 25.02.2002, rar
    exec_command "ps -efP" "Process View, incl. PRM Groups"		#  11.10.2007, 11:09 modified by Ralph Roth
    exec_command "ps -ef | cut -c42- | sort -nr | head -25 | awk '{ printf(\"%10s   %s\\n\", \$1, \$2); }'" "Top 25 CPU Processes"
    TopMemProcs()
    {
        echo "VSZ(KB)   PID RUSER   CPU    TIME  COMMAND"
        UNIX95= ps -e -o 'vsz pid ruser cpu time args' |sort -nr|head -25
    }
    exec_command TopMemProcs "Top 25 Memory Processes"
    
    #exec_command "echo $VSAR" "Process Table"
    top -f /tmp/topcfg.$$
    exec_command "cat /tmp/topcfg.$$" "Top output"
    rm -f /tmp/topcfg.$$
    exec_command "sar -b 1 9" "Buffer Activity"
    exec_command "vmstat -dnS;vmstat -f" "VM-Statistics"
    
    [ -r /var/adm/shutdownlog ] && (exec_command "tail /var/adm/shutdownlog" "Reboots")
    #exec_command "alias"  "Alias"
    
    # CFG_CRON
    #
    if [ "$CFG_CRON" != "no" ]
    then # else skip to next paragraph paragraph "Cron and At"
        exec_command $PLUGINS/crontab_collect.sh "Crontab and AT scheduler"
    fi
    exec_command "cat /etc/inittab" "inittab"
    cat_and_grep "/etc/rc.config.d/* | grep '=[/0-9]'" "Runlevel Settings"
    
    if [ "$CFG_SECURITY" != "yes" ]
    then    #  31.08.2005, 15:37 modified by Ralph Roth
        exec_command "$PLUGINS/getpwd.hppa" "User accounts"
        exec_command "$PLUGINS/getpwd.hppa -g" "Groups"
    fi
    dec_heading_level
    
fi # terminates CFG_SYSTEM wrapper

###########################################################################

if [ "$CFG_HARDWARE" != "no" ]
then # else skip to next paragraph
    
    paragraph "Hardware"
    inc_heading_level
    
    if [ -f /usr/sbin/ioscan ] ; then
#       exec_command "ioscan -fnk; echo; ioscan -fk" "Hardware with H/W-Path"
        exec_command "ioscan -fk" "Hardware with H/W-Path"
        exec_command "ioscan -fnk" "Hardware including device files"
        exec_command "ioscan -Fk" "Hardware in parseable format"
        
    fi
    
    ## 11.31 only stuff ## LVM ##
    if [ $osrev100  -ge 1131  ] ; then         	    # added by Marc Heinrich, July 2008
        AddText "Last ioscan="$(ioscan -t)
        exec_command "ioscan -fNnk" "HP-UX $osrevdot Hardware with Agile View"
        exec_command "ioscan -m hwpath" "Legacy and LUN Mapping"
        exec_command "ioscan -km dsf" "HP-UX $osrevdot Map Legacy and Agile DSFs"   # -k added, # <c/m/a>  14.08.2008 - Ralph Roth
        AddText "Legacy/Agile devices files usage? "$(insf -Lv)                 #  19.03.2010, 14:52 modified by Ralph Roth
        exec_command "$PLUGINS/get_path_1131.sh" "HP-UX 11.31 Disk and Tape Information"
	# 3 ER by TB, 11. März 2011
        exec_command "ioscan -P health" "Full list of I/O health status"
        exec_command "ioscan -P health | grep -v -e online -e N/A" "Short list of I/O health status"
        exec_command "ioscan -s" "List the stale entries present in the system"
    fi
    ### stefan introduced here a bug with formating
    #exec_command "echo 'Physical: \c' ; /usr/sam/lbin/getmem | tr '\012' ' ' ; echo 'MBytes'" "Physical Memory"
    ## on a big fat keystone+xp128 this entry is at line 847!! ## rar, 08082003
    # exec_command " head -l -n 1200 /var/adm/syslog/syslog.log|grep Physical|grep avail|cut -c 35-|dos2ux" "Physical Memory"
    MEM="Total Memory: "$($PLUGINS/syssmall.hppa|cut -f2 -d\;)" GB"
    exec_command "echo ${MEM};echo '';$PLUGINS/meminfo.hppa" "Physical Memory Overview" 
    
    if [ -x /usr/bin/graphinfo ] ; then
        [ -r /dev/crt ] && exec_command "/usr/bin/graphinfo" "Graphic Hardware"
    fi
    
    ## you need here a line feed, rar 03-aug-99
    [ -r /etc/kbdlang ] && exec_command "cat /etc/kbdlang;echo" "Console Keyboard Layout"
    
    # feb 1999
    if [ "$CFG_DIAG" = "yes" ] ; then
        AddText "Informational note only: You should have Diagnostics (Online Diagnostics) Version A.29.00/HP-UX 10.20, A.44.00/HP-UX 11.00+11i and higher installed!"
        
        if [ ! -x /usr/sbin/cstm ]
        then
            if [ -x /usr/sbin/sysdiag ]
            then
                AddText "Note: The old sysdiag utilities are no longer supported!"
                exec_command "( echo sysmap; echo cpumap; echo exit ; echo exit )|/usr/sbin/sysdiag|grep -v -E '^\*|SYSMAP|HELP|Please|see|elcome|DUI'|tail +7" "Processor and Firmware (sysdiag)"
                sleep 3
                exec_command "( echo sysmap; echo memmap; echo exit; echo exit )|/usr/sbin/sysdiag|grep -v -E '^\*|SYSMAP|HELP|Please|see|elcome|DUI'|tail +7" "Memory Layout (sysdiag)"
                sleep 3
                exec_command "(echo sysmap; echo modulemap; echo exit; echo exit)|/usr/sbin/sysdiag|grep -v -E '^\*|SYSMAP|HELP|Please|see|elcome|DUI'|tail +7" "Hardwaremoduls (sysdiag)"
            fi
            # AddText "Note: You should install Online Diagnostics (STM, B6191A)! "
            
            # NOTE: Starting with HP-UX 11i v3 March 2009 release, OnlineDiag (including
            # STM) will be in support mode. Moving forward, no new enhancements will be
            # made to OnlineDiag (including STM). Only Critical / Serious defects will be
            # analyzed. For the most current information about OnlineDiag obsolescence,
            # see the following document at
            # http://www.docs.hp.com/en/diag.html#2%20Online%20Diagnostics     
        fi # not cstm
        
        if [ -x /usr/sbin/cstm ]
        then
            [ -r /var/stm/logs/tool_stat.txt ] && exec_command "cat /var/stm/logs/tool_stat.txt" "Diagnostics Tool Statistics" #  13.02.2008, 09:57 modified by Ralph Roth
            
            ps -ef | grep diagmond | grep -q -v grep     #  13.02.2008, 10:23 modified by Ralph Roth, UNIX95: ps -C diagmond
            if [  $? -eq 0 ]
            then
                #     cstm>SelAll
                #     cstm>Information
                #     -- Error --
                #     Failed to execute the information tool.
                #     An unexpected failure occurred in the Support Tool system.
                #
                #     The User Interface is disconnecting from the Unit Under Test.
                #     Please Refer to the UI Activity Log for more details.
                #
                echo "\nCollecting:  Diagnostics .\c"                                               ## 2x exit for buggy diags
                echo "Map\nSelAll\nInformation\nwait\nInfoLog\nDone\n\n\nExit\nOK\n\n\nExit\nOK\n">cstm_i.$$
                
                #KillOnHang "bin/stm " 10
                #exec_command "/usr/sbin/cstm -f cstm_i.$$  > cstm_res.$$"
                /usr/sbin/cstm -f cstm_i.$$  > cstm_res.$$
                #CancelKillOnHang
                cat cstm_res.$$|grep -v -e "cstm>" -e "^Running" -e "^-- " -e "^View" -e "^Print" -e "^SaveAs" -e "^Enter" -e "^Are" -e "^Updateing" -e "^Preparing" > cstm_res2.$$
                
                #KillOnHang "bin/stm " 10
                #exec_command "/usr/sbin/cstm -f cstm_c.$$ > cstm_res.$$"
                #/usr/sbin/cstm -f cstm_c.$$ > cstm_res.$$
                #CancelKillOnHang
                
                exec_command "cat cstm_res2.$$" "Installed Hardware (cstm)"
                
                cat cstm_res.$$|grep -v -e "cstm>" -e "^-- " -e "^Running" -e "^View" -e "^Print" -e "^SaveAs" -e "^Enter" -e "^Are" -e "^Updateing" -e "^Preparing" > cstm_res2.$$
                
                #       exec_command "cat cstm_res2.$$" "CPU (cstm)"
                rm -f cstm_i.$$ cstm_c.$$ cstm_res.$$ cstm_res2.$$
            else
                AddText "ERROR: Diagnostics installed, but not running! Run /usr/sbin/stm/uut/bin/sys/diagmond"
            fi     # -eq 0
        else
            AddText "Warning: No Diagnostics installed! This is OK on new systems installed after Summer 2009"
        fi # cstm
    fi
    
    [ -x /usr/contrib/bin/machinfo ] && exec_command "/usr/contrib/bin/machinfo" "Additional CPU Information"
    [ -x /usr/bin/mpsched ] && exec_command "/usr/bin/mpsched -s " "Local Hardware Domains"	#  23.08.2007, 09:11 modified by Ralph Roth
    [ -r /var/tombstones/ts99 ] && exec_command "dos2ux /var/tombstones/ts99" "Last PDCINFO Tombstone"
    ### enhancements by Eric Watson
    [ -r /var/tombstones/ts98 ] && exec_command "dos2ux /var/tombstones/ts98" "Previous PDCINFO Tombstone"
    
    ### commented out, creates 2 MB additionally dump, rar-24102002
    ### [ -r /var/stm/logs/os/ccerrlog ] && exec_command "/usr/sbin/diag/contrib/cclogview /var/stm/logs/os/ccerrlog" "Chassis Code Error Log"
    [ -r /var/opt/resmon/log/event.log ] && exec_command "grep -e 'Event data from monitor' -e 'Event Time.' -e 'Severity.' -e 'Monitor.............: ' -e 'Event #.' /var/opt/resmon/log/event.log | dos2ux | grep -v Version | tail -35" "EMS Event Log"
    
    # predictive
    
    get_pred() {
        /opt/pred/bin/psconfig print configuration 2>/dev/null | /usr/bin/grep -v "^----------"
    }
    if [ -x /opt/pred/bin/psconfig ] ;
    then
        exec_command get_pred "Predictive Configuration"
        AddText "WARNING: Predictive is OBSOLETE and should be removed/purged from your system!"
    fi
    
##  if [ -r /opt/hpservices/etc/motprefs ]
##  then
##      exec_command "cat /opt/hpservices/etc/motprefs" "ISEE Configuration"
##      AddText "WARNING: ISEE is OBSOLETE and should be removed/purged (/opt/hpservices) from your system!"
##  fi
    
    # CIM/SFM/RSP/SIM stuff
    # ---------------------------------------------------------------------------
    if [ -x /opt/wbem/bin/cimprovider ]     ##  15.4.2009, 12:00  Ralph Roth
    then    # RSP/CIM
        logger "$VERSION: CIM Stuff starts"
        exec_command "swlist -l product OnlineDiag SysMgmtWeb SysFaultMgmt WBEMServices OpenSSL 2>/dev/null" "Required/Optional Software for System Fault Management (SFM)"
        exec_command "what /opt/wbem/bin/*" "CIM Binaries and their Patchlevel"
        exec_command "/opt/wbem/bin/cimprovider -s -l" "Installed CIM $(/opt/wbem/sbin/cimserver -v) Providers" ## see CR- QXCR1000944158 for cimserver -v messages in syslog.log
        exec_command "/opt/wbem/bin/cimprovider -l -m SFMProviderModule" "Details of the SFM Provider Module"
        
        if [ -x /opt/wbem/sbin/cimtrust ] ## fix for oldest HP-UX 11.11 installations
        then
            exec_command "cimconfig -l -p" 		"CIM Configuration"                     ## cimconfig -l -c
            exec_command "cimauth -l" 		    "CIM Users and Authentication"
            exec_command "cimtrust -l" 		    "CIM Trusts/Certificates"
        fi
        ## --- meid.sh ---- stuff ---- # #  06.01.2010, 15:26 modified by Ralph Roth
        
        if [ -x /opt/wbem/bin/cimsub ]  ## fix for oldest HP-UX 11.11 installations
        then
            exec_command "/opt/wbem/bin/cimsub -lh" "CIM Indication Handlers"
            AddText "Hint: There should be exactly one unique WBEM subscription (MEId=)"
            exec_command "/opt/wbem/bin/cimsub -ls" "CIM Indication Subscriptions"
            exec_command "/opt/wbem/bin/cimsub -lf" "CIM Indication Filters"
        fi
        # ---------------------------------------------------------------------------
        
        if [ -x /opt/sfm/bin/evweb ]
        then    # 11.23 ++!
            #logger "EVWEB Stuff starts"
            exec_command "/opt/sfm/bin/evweb logviewer -L" 		"EVWEB Log Viewer"
            exec_command "/opt/sfm/bin/evweb eventviewer -L" 	"EVWEB Event Viewer"
            AddText "Use /opt/sfm/bin/evweb eventviewer -L -x -f to get the full/detailed event logs!"
            exec_command "/opt/sfm/bin/evweb subscribe -L -b internal; /opt/sfm/bin/evweb subscribe -L -b external" "EVWEB Subscriptions"
            AddText "At least there must be a HP* and a WEBES* subscription for communication with HP-SIM"
            #logger "EVWEB Stuff stop"
        fi
        ##  02.09.2009, 11:36 modified by Ralph Roth
        if [ -x /opt/sfm/bin/sfmconfig ]
        then
            exec_command "/opt/sfm/bin/sfmconfig -a -L" 	"SFM - list of operational status"
            exec_command "/opt/sfm/bin/sfmconfig -m list" 	"SFM - filters present in the repository"
            [ -r /var/opt/sfm/log/sfm.log ] && exec_command " grep -v ^$ /var/opt/sfm/log/sfm.log|tail" "Last lines of the SFM log"
        fi
        exec_command "smhstartconfig" "SMH Startup Configuration"
        [ -x /opt/hpsmh/bin/smhassist ] && (exec_command "/opt/hpsmh/bin/smhassist" "Quick Check of SMH"; AddText "see /opt/hpsmh/logs/smhassist.log for details")
        exec_command "osinfo" "WBEM OS Info"
        
        if [ -x /opt/propplus/bin/cprop ]       #  30.06.2010, 08:51 modified by Ralph Roth
        then
            exec_command "/opt/propplus/bin/cprop -list" "HP-UX Property Page Plus (List)"
            exec_command "/opt/propplus/bin/cprop -summary -a" "HP-UX Property Page Plus (Summary)"
        fi
        logger "$VERSION: CIM Stuff stop"
    fi
    
    ##### EMS HW Monitors, 23.Feb.99
    if [ -x /opt/resmon/bin/resls ] ;
    then
        exec_command "/opt/resmon/bin/resls /" "EMS Hardware Monitors"
    fi

# Der moncheck braucht total lang - kann der per default "aus" sein und bei Bedarf per command line eingeschaltet werden?
# ---------------------------------------------------------------------------
    if [ -x /etc/opt/resmon/lbin/moncheck ] ;
    then
        exec_command "echo q | /etc/opt/resmon/lbin/monconfig | grep Version" "EMS/STM Version"
        exec_command "/etc/opt/resmon/lbin/moncheck" "EMS Hardware Monitor Setup"                       #  13.12.2007, 12:43 modified by Ralph Roth
        [ -x /etc/opt/resmon/lbin/set_fixed ] && exec_command "/etc/opt/resmon/lbin/set_fixed -Lv" "EMS Down States"
    fi
# ---------------------------------------------------------------------------
    
    ## HP SIM, SFM, WBEM, CIM .....
    [ -x  /opt/sfm/bin/sfmconfig ] && exec_command "/opt/sfm/bin/sfmconfig -w -q" "Current SFM Diagnostics Mode"
    
    # The deprecated icod_stat command performs the identical functions and is maintained for backward compatibility.
    # -> /usr/sbin/icapstatus, fixes: # <c/m/a>  28.04.2009 - Ralph Roth
    if  [ -x /usr/sbin/icapstatus ]
    then
        /usr/sbin/icapstatus -z
        if [[ $? = 4 ]]
        then
            AddText "Note: iCAP is not supported on this system!"
        else
            exec_command /usr/sbin/icapstatus "iCAP"
        fi
    else
        if [ -x /usr/sbin/icod_stat ]
        then
            exec_command /usr/sbin/icod_stat "iCOD/iCAP"
        fi
    fi
    [ -x /usr/sbin/icapmanage ] && exec_command "/usr/sbin/icapmanage -sv" "GiCAP Status"           # <c/m/a>  12.08.2008 - Ralph Roth
    
    [ "$CFG_HWDISK" = "no" ] || exec_command $PLUGINS/firmware_collect.sh "Disk Firmware Collect with Hardware Path"
    [ "$CFG_HWDISK" = "no" ] || exec_command $PLUGINS/get_diskfirmware.sh "Disk Firmware Collect with Device Files"
    
    ## exec_command "$PLUGINS/check_elroy.sh" "L+N Class Elroy Check" # 17032004, I thinks this is obsolete?, rr
    [ -x /usr/symcli/bin/sympd ] && exec_command "$PLUGINS/get_emcluns.sh" "EMC Disk Array Configuration"
    
    ## we want to display EMCPower Path configurations
    ## Author: Mleo, outputs which EMC node controls each disk which is very useful.
    if [ -x /sbin/powermt ] ;
    then
        exec_command "/sbin/powermt display dev=all" "EMC Power Path"
    fi
    
    ######### April 2000 - new XP256 Titan Release #############
    #XPINFO=$(which xpinfo)          ## /usr/contrib/bin/xpinfo
    if  [ -f $XPINFO ] && [ -x $XPINFO ]
    then
        XPINFOFILE="$OUTDIR/$BASEFILE"_xpinfo.csv
	# write header to the xpinfo CSV file (easier to interprete later on)
	echo "device_file; target_id; LUN_id; port_id; CU:LDev; type; device_size; serial#; code_rev; subsystem; CT_group; CA_vol; BC0_vol; BC1_vol; BC2_vol; ACP_pair; RAID_level; RAID_group; disk1; disk2; disk3; disk4; model; port_WWN; ALPA; FC-AL Loop Id; SCSI Id; FC-LUN Id" > $XPINFOFILE
        $XPINFO -d";" | grep -v "Scanning" >> $XPINFOFILE
        AddText "The XP-Info configuration was additionally dumped as CSV format into the file <b>$XPINFOFILE</b> for further usage"
        XPINFOFILE=$OUTDIR/$BASEFILE"_xpinfo.txt"

	extract_xpinfo_i "$OUTDIR/$BASEFILE"_xpinfo.csv $XPINFOFILE
        ##$XPINFO -i | grep -v "Scanning">$XPINFOFILE
        AddText "The XP-Info configuration was additionally dumped as plain text format into the file <b>$XPINFOFILE</b> for further usage"
        exec_command "cat $XPINFOFILE" "SureStore E Disk Array XP Identification Information"

	extract_my_xpinfo "$OUTDIR/$BASEFILE"_xpinfo.csv $TMP_DIR/my_xpinfo.txt
	exec_command "cat $TMP_DIR/my_xpinfo.txt" "SureStore E Disk Array XP Identification Information with VG info added"

        ##exec_command "$XPINFO -r|grep -v Scanning" "SureStore E Disk Array XP Disk Mechanisms"
	extract_xpinfo_r "$OUTDIR/$BASEFILE"_xpinfo.csv $TMP_DIR/xpinfo_r.txt
        exec_command "cat $TMP_DIR/xpinfo_r.txt" "SureStore E Disk Array XP Disk Mechanisms"

	extract_xpinfo_c "$OUTDIR/$BASEFILE"_xpinfo.csv $TMP_DIR/xpinfo_c.txt
        ##exec_command "$XPINFO -c|grep -v Scanning" "SureStore E Disk Array XP (Continuous Access and Business Copy)"
        exec_command "cat $TMP_DIR/xpinfo_c.txt" "SureStore E Disk Array XP (Continuous Access and Business Copy)"
        
        exec_command "$PLUGINS/find_non_lvm_luns.sh" "XP LUNs visible/not mapped"
        AddText "This is a list of LUNs visible to this host, but not mapped using LVM. WARNING: This script may fail on mixed Legacy and Agile devices!"
        AddText "Possible cause: Command Devices, no SecureManager usage or deleted LUNs, not deleted on the XP..."
        
        # { changed/added 07.07.2004 (08:45) by RALPH Roth }
        exec_command "$PLUGINS/get_xpsum.sh $XPINFOFILE" "SureStore E Disk Array XP (Port Summary)"    # { changed/added 13.01.2004 (10:14) by Ralph Roth }
        exec_command "$PLUGINS/get_xpluns.sh $XPINFOFILE" "SureStore E Disk Array XP (LUNs Summary)"
        
        AddText "Note: xpinfo version $($XPINFO -v) installed"
    else
        [ -x /usr/contrib/bin/inquiry256.ksh ] && exec_command "/usr/contrib/bin/inquiry256.ksh" "SureStore E Disk Array XP256 Mapping (inquiry/obsolete!!)"
    fi
    
    # HP 3PAR info
    [ -x /usr/bin/HP3PARInfo ] && exec_command "/usr/bin/HP3PARInfo -i" "HP 3PAR Disk Array Information"

    [ -x /opt/hparray/bin/arraydsp ] && exec_command "/opt/hparray/bin/arraydsp -i 2>/dev/null" "HP SureStore 12 AutoRAID"
    [ -x /opt/hparray/bin/amdsp ] && exec_command "/opt/hparray/bin/amdsp -i 2>/dev/null" "HP SureStore FC60 Disk Array"
    
    
    [ -x /opt/sas/bin/sasmgr ] && exec_command $PLUGINS/get_sasinfo.sh 	"Serial Attached SCSI (SAS) Mass Storage" 	# 21.07.2008, 14:13, rr
    [ -x /usr/sbin/mptconfig ] && exec_command $PLUGINS/get_mptinfo.sh 	"Ultra320 SCSI Controller/MPT Driver" 		# 21.07.2008, 14:13, rr
    [ -x /usr/sbin/sautil ]    && exec_command $PLUGINS/get_cissinfo.sh "HP SmartArray RAID Controller Family"          # 02.02.2011, 12:45 by Ralph Roth
    
    if [ -x /opt/sanmgr/commandview/client/sbin/armdsp ]
    then
        VAID=$(armdsp -i | sort -u | grep ^Serial|cut -f2 -d":")
        
        for i in $VAID
        do
            exec_command "armdsp -a -r $i" "VA Configuration ($i)"
            exec_command "armfeature -r $i" "VA Installed Features ($i)"
        done
        
        exec_command "armtopology" "VA Topology"
        AddText "Note: If you need more detailed VA7x00 logs execute $PLUGINS/getVAlogs.sh"
        
    fi  # va collect, 26.02.02, rar
    
    # ------------------------------------------------------------------------------
    [ -x /sbin/irdisplay ] && exec_command "/sbin/irdisplay" "Internal RAID" # 21.07.2008, 14:13, rr
    
    ########  Securepath ######  (EVA 3000/5000) ######
    if [ -x /sbin/spmgr ]
    then
        exec_command "/sbin/spmgr display" "SecurePath Information"
        exec_command "/sbin/spmgr display|grep -i active|sort" "SecurePath Active Paths"
        #  06.04.2005, 15:26 modified by Ralph.Roth
        exec_command "/sbin/spmgr display|grep c | grep t | grep d| grep '-' | grep -v Auto" "SecurePath Devicefiles and UUID"
    fi
    ######## ende  Securepath ######

    # If evainfo is installed get its output  (KL 26.10.11)
    ########  EVA Info ######
    if [ -x /usr/local/bin/evainfo ]
    then
        exec_command "/usr/local/bin/evainfo -aPu GB" "EVA Info Output"
    fi
    ######## end  EVA Info ######
    
    ### new olrad stuff, sr by MarcHeinrich    # { changed/added 19.11.2003 (18:46) by Ralph Roth }
    ## olrad:ERROR:Command only for internal use -> use rad instead, hpux 11v1
    if [ -x /usr/bin/olrad ] ; then
        exec_command "olrad -q" "OLA/R Status (`olrad -n` Slots)"
        exec_command "ll /usr/sbin/olrad.d" "OLRAD Scripts"
    else            ## obsolete!! ##
        [ -x /usr/bin/rad ] && exec_command "rad -q" "OLA/R Status (`rad -n` Slots)"
        [ -x /usr/bin/rad ] && exec_command "ll /usr/sbin/olrad.d" "OLRAD Scripts"
    fi
    
    dec_heading_level
    
fi # terminates CFG_HARDWARE wrapper

######################################################################

parstatus -s 2> /dev/null # partitions supported/avail, rar 24.04.2001
if [ $? -ne 0 ];then
    echo ".\c"
else
    paragraph "Cellboard Information/Hardpartition Information" # changed 171002 sr by milg
    
    inc_heading_level
    
    SuperDome_Serials()
    {
        echo "Machine Ident:   \c"; getconf _CS_MACHINE_IDENT;
        echo "Partition Ident: \c"; getconf _CS_PARTITION_IDENT;
        echo "Machine Serial:  \c"; getconf _CS_MACHINE_SERIAL;
    }
    
    exec_command SuperDome_Serials "Hardpartition Serial Numbers"
    # Added plugin for Superdome2 server  (KL  26.10.11)
    if [ "$MODEL" = Superdome2 ] ; then
        exec_command "$PLUGINS/get_superdome2info.sh" "Hardpartition Configuration (`model`)"
    else
        exec_command "$PLUGINS/get_superdomeinfo.sh" "Hardpartition Configuration (`model|cut -f3 -d/`)"
        exec_command "frupower -d -C" "Current Power Status - All Cells"
        exec_command "frupower -d -I" "Current Power Status - All I/O Chassis"
    fi
    
    # { changed/added 06.11.2003 (16:51) by Ralph Roth }
    [ -r /var/adm/hotplugd.log ] && exec_command "tail -25 /var/adm/hotplugd.log" "DoorBell logs"
    
    dec_heading_level
    
fi # end of if superdome system

######################################################################
# shamelessly copied from superdome routine,  added M.Evans 4/16/03

# vparstatus -V 2> /dev/null > /dev/null  # fixed onsite, ralph
[ -x /usr/sbin/vecheck ] && vecheck             #  08.05.2009, 14:23 modified by Ralph Roth
if [ $? -ne 0 ];then
    echo ".\c"
else
    paragraph "Virtual Partition Information (vPar)"
    inc_heading_level
    
    AddText "Hint: "'vpar_status -w'"!" 						#  08.09.2004, 15:42 modified by Ralph.Roth
    exec_command "swlist vParManager VirtualPartition|tail +6" "vPar Software Version"  #  11.08.2005, 10:06 modified by Ralph Roth
    exec_command "$PLUGINS/get_vparinfo.sh" "vPar Configuration (`model|cut -f3 -d'/'`)"  #  08.05.2009 - Ralph Roth
    [ -x /usr/sbin/vparenv ] && exec_command /usr/sbin/vparenv "vPar Environment (vPar/nPar)"
    exec_command "what /stand/vpmon | fmt " "vPar Monitor - Patch Level"        	#  01.09.2004, 11:40 by cfg2html@hotmail.com
    
    dec_heading_level
    
fi # end of if vpar system

######################################################################

HPVMInfo ()
{
    for i in `hpvmstatus |grep -v -e "Virtual Machine"  -e "==========" |awk '{print $2}' |sort`
    do
        hpvmstatus -p $i
        echo "\n"
        hpvmstatus -d -p $i    ## mh: zeigt die IO Konfiguration im Format der hpvm Befehle an.
        
        echo "\n\n\n"
    done
    
}

######################################################################
# HPVM Information
# collect Host OS Information, fixes/enhancements by rr, 221008 for HPVM 4.0
hpvmstatus -V 2> /dev/null > /dev/null
if [ $? -ne 0 ];then
    echo ".\c"
else
    paragraph "HP Virtual Machine Host OS Information (HPVM)"
    
    inc_heading_level
    exec_command "swlist  |grep  -E 'T2767|integrity vm' " "HPVM Software Version"
    
    [ -x /opt/hpvm/bin/hpvminfo ] && exec_command "hpvminfo -v;hpvmstatus" "HPVM General Overview"  # if inside a guest!
    
    exec_command HPVMInfo "HPVM Detailed Configuration"
    
    exec_command "hpvmnet"  "HPVM Network Configuration"
    
    exec_command "hpvmdevmgmt -l all"   "HPVM Device Database"
    exec_command "hpvmdevmgmt -r"       "HPVM Device Database Repair Script"  #  9.8.2010, 15:14  Ralph Roth
    
    [ -x  /opt/hpvm/bin/hpvmsar ] && exec_command " /opt/hpvm/bin/hpvmsar -an 1" "HPVM sar of all guests"  ## HPVM 4.0++
    
    exec_command "hpvmstatus -m" "HPVM Multi Server Environment"
    
    exec_command "kctune base_pagesize" "BPS - Base Page Size"
    AddText "BPS should be 4kb for HPVM 4.10. See also patch PHKL_39114 and CR QXCR1000868519 and QXCR1000907205!" # 20100624, Reinhard Lubos, Changed AddTest to AddText
    
    dec_heading_level
    
fi # end of if HPVM Host OS

# as this outside a block we need to incr/dec the heading level
inc_heading_level
# more VSE stuff here #  30.08.2007, 15:38 modified by Ralph Roth
[ -x /opt/gwlm/bin/gwlmstatus ] && exec_command "/opt/gwlm/bin/gwlmstatus --verbose" "gWLM Status"
dec_heading_level

# collect Client Information
model |grep "Integrity Virtual Machine" 2> /dev/null > /dev/null
if [ $? -ne 0 ];then
    echo ".\c"
else
    paragraph "HP Virtual Machine Guest OS Information (HPVM)"
    inc_heading_level
    
    exec_command "swlist  |grep  HPVM-Guest " "HPVM Guest Software Version"
    exec_command "hpvminfo -V " "HPVM Host Information"
    
    dec_heading_level
fi # end of if HPVM Guest OS


######################################################################

if [ "$CFG_SOFTWARE" != "no" ]
then # else skip to next paragraph
    
    paragraph "Software"
    inc_heading_level
    
    if [ -x /usr/sbin/swlist ] ; then
        exec_command "swlist -l depot 2>/dev/null|grep -v Initiali" "Registered Depots"
        exec_command "swlist|tail +6" "Installed Software"
        exec_command "swlist -l fileset|tail +6" "Installed Filesets" 	#  10.08.2009, 08:53 modified by Ralph Roth
        exec_command "swlist -a date -a title -a revision|tail +6" "Software Installation Date"
        exec_command "swjob | tail" "Last Software Jobs"    		# <c/m/a>  06.08.2008 - Ralph Roth
        exec_command "swlist -l product | tail +6|grep -v -e PHNE_ -e PHSS_ -e PHKL_ -e PHCO_" "Installed Products" ###    changed/added 12.08.2004:17:09: by Ralph Roth
        exec_command "swlist -a state  -l fileset | grep -v -e configured -e ^#" "Unconfigured/Corrupted Software"
        
        AddText "1.) Hint: man swverify, man swconfig to reconfigure corrupted software! swmodify -u PHxx_##### to remove patch references"
        AddText "2.) Hint: man check_patches (HP-UX 11.xx);; swlist -a state  -l fileset | grep -v -e configured -e ^# | awk '{print $1;}'|xargs swconfig"
        AddText "Gurus only: swlist -l fileset - state | grep installed | awk '{print $1;}'>/tmp/sw.tmp; swmodify -a state=configured -f /tmp/sw.tmp"
        AddText "These useful tools are not delivered with HP-UX core, but as a patch:
PHCO_27780 (or newer) for HP-UX 11.11 (replaces PHCO_24630)

Use cleanup under HP-UX 10.20 and cleanup -c 1 under 11.xx
        "
        
        [ -r /var/adm/sw/needs_config ] && exec_command "cat /var/adm/sw/needs_config" "Software that needs Reconfiguration"
        exec_command patch_stat "Patches and Patch Statistic"
    fi

    [ -r /var/adm/sw/.codewords ] && exec_command "cat /var/adm/sw/.codewords" "Installed Codewords"
    
    dec_heading_level
    
fi # terminates CFG_SOFTWARE wrapper

######################################################################
if [ "$CFG_FILESYS" != "no" ]
then # else skip to next paragraph
    
    paragraph "Filesystems, Dump and Swap Configuration"
    inc_heading_level
    
#   exec_command "bdf -i" "Filesystems and Usage"
    exec_command "$PLUGINS/bdfmegs.sh -c 1 -v" "Filesystems and Usage"

# inode count not useful anymore
#   AddText "Hint: VxFS has unlimited inodes, ninode limit is only valid for HFS file systems!"

    exec_command "df -g" "Filesystem Settings"
    cat_and_grep "/etc/fstab" "Mountpoints (fstab)"
    AddText "Hint: Available file system types: $(fstyp -l|fmt)"	#  28.11.2007, 09:44 modified by Ralph Roth

# Add bdfmegs sorted by mountpoint with sum total
    exec_command "$PLUGINS/bdfmegs.sh -c 6 -ls" "Active Local Mountpoints (sorted by mountpoint)"

    exec_command "mount -lp|sort -u" "Active Local Mountpoints (sorted by source)"
    AddText "Hint: /sbin/vxtunefs mount_point to get JFS parameters"
    
    [ -s /etc/vx/tunefstab ] && exec_command "cat /etc/vx/tunefstab" "JFS/VXFS tuneable parameters"
    
    if [ -f /etc/exports ] ; then
        cat_and_grep "/etc/exports" "NFS Filesystems"
    fi
    cat_and_grep "/etc/dfs/dfstab" "NFS sharing resources"
    cat_and_grep "/etc/dfs/sharetab" "Local resources shared by the share command"

    if [ -f /usr/sbin/swapinfo ] ; then
        exec_command "swapinfo -tam" "Swap Info"
        #exec_command "swapinfo -adftm" "Swap" # changed, sr by (Arie Mooij)
    fi
    
    [ -x /sbin/crashconf ] && (exec_command "/sbin/crashconf" "Dump Configuration")
    [ -s /var/adm/sbtab ] && (exec_command "cat /var/adm/sbtab" "HFS Superblocks")
    dec_heading_level
    
fi # terminates CFG_FILESYS wrapper

###########################################################################
if [ "$CFG_LVM" != "no" ]
then # else skip to next paragraph
    
    paragraph "LVM"
    inc_heading_level
    
    # bm: I checked your wonderful script on HP-UX 11.31 1003 with LVM 2.0 groups
    # only. In such configuration /etc/lvmtab is empty in the terms your script
    # treats it ([ -f /etc/lvmtab ] && if `strings /etc/lvmtab |grep -q dev` ;
    # then ...) so no LVM information gets to output file. With LVM 2.0 all
    # configuration is stored in /etc/lvmtab_p.
    
    if  `strings /etc/lvmtab* |grep -q ^/dev/d`
    then
        AddText "The system file layout is configured using the LVM (Logical Volume Manager)"
        
        exec_command $PLUGINS/check_space.sh "LVM Volumegroup and Filesystem Quick Overview"
        [ "$CFG_TGV" = "yes" ] && exec_command $PLUGINS/get_vg.sh "LVM/VG for TGV"
        
        exec_command $PLUGINS/get_lvm_info.sh  "LVM Overview" # PrintLVM
        AddText "Hint: mkfs -m /dev/vgXX/rlvolYY - displays the command line which created the file system. fsadm -F vxfs /mountpoint to get VxFS details of a filesystem"
        [ -r /etc/lvmpvg ] && AddText "WARNING: Volume groups may be reported several times, due to use of of Physical Volume Group (/etc/lvmpvg)"
        
        exec_command $PLUGINS/dumplvmtab.hppa "LVM Tab Dump"
        exec_command "vgdisplay -v" "Detailed Volumegroups"
        exec_command "ll /dev/*/group|sort -k 6" "VG Group Device Files" # { changed/added 25.02.2004 (11:04) by Ralph Roth }
        exec_command "$PLUGINS/pvgfilter.sh" "Physical Volume Group Filter"
        [ -r /etc/lvmpvg ] && exec_command "cat /etc/lvmpvg" "LVM Physical Volume Group Information (/etc/lvmpvg)"
        cat_and_grep "/etc/lvmrc" "Auto VG Activation (/etc/lvmrc)"
        # Boot device no longer has to be named vg00  (KL 26.10.11)
        #exec_command "lvlnboot -v vg00" "Boot LVs (lvlnboot)"
        boot=`lvlnboot -v 2>/dev/null | grep '^Boot Def' | awk -F'/' '{print $NF}' | tr -d ':'`
        exec_command "lvlnboot -v $boot" "Boot LVs (lvlnboot)"
        
        ## honi:roothp:/root swlist -l fileset | grep MIRROR
        ##  LVM-MirrorDisk.LVM-MIRROR             B.11.31        HP-UX support for the MirrorDisk/UX
        #  08.08.2007, 14:46 modified by Ralph Roth
        
        MIRRORSW=$(swlist -l fileset | grep -e LVM.LVM-MIRROR-RUN -e LVM-MirrorDisk.LVM-MIRROR)	#  12.03.2007, 15:39 modified by Ralph Roth
        if [ -n "$MIRRORSW" ];
        then
            exec_command $PLUGINS/get_mirror_missmatch.sh "Detailed Mirror/UX Overview/Mismatch"
            AddText "Check the following lines that your mirror (RAID1) is setup properly!"
        else
            AddText "Mirror/UX (Software RAID1) seems not to be installed!"
        fi
        
        # grep after pvdisplay cuts info line 'PV Status' in file cfg2html_hpux.sh. Thus, instead of
        # pvdisplay -v $disk|grep -v -E 'current|stale|free|Physical|Status';
        # use better (Regards! Michael)
        # pvdisplay -v $disk|grep -v -E 'current|stale|free|Physical|Status LV';
        
        PVDisplay() {
            #################### roth, 25.06.99 ######################################
            for disk in $(strings /etc/lvmtab|grep -e '/dev/dsk' -e '/dev/disk') ;
            do
                pvdisplay -v $disk|grep -v -E 'current|stale|free|Physical|Status LV';
                disk2=$(echo $disk| sed 's/dev\/d/dev\/rd/')  # /p - rar 05082002	## needs rework for HP-UX 11.31 MSS
                # echo $disk2
                /usr/sbin/diskinfo $disk2
                echo "\n\n"
            done
        }
        
        exec_command PVDisplay "Physical Devices used for LVM"
	exec_command "$PLUGINS/get_disk_data.sh" "Physical Devices used by Volume Group"

        exec_command get_LIF "Boot Information/LIF"
        AddText "To get the current installed ODE version execute: lifls -l /usr/sbin/diag/lif/updatediaglif2 on 64 bit systems"
        cat_and_grep "/stand/bootconf" "Boot Device Configuration Table"
        AddText "/stand/bootconf should contain all boot devices (mirrored). If not, swinstall may fail after boot from the mirrored disk!"

        [ -x /usr/sbin/lvmadm ] && exec_command "/usr/sbin/lvmadm -l" "LVM/VG Limits"       #  12.1.2009, 11:22  Ralph Roth
        
    else
        AddText "This system seems to be configured with whole disk layout (WDL)"
    fi
    
    [ -x /usr/sbin/efi_ls ] && exec_command "$PLUGINS/get_efi.sh" "EFI Filesystem Layout" # 1205-2006, rar
    exec_command "iostat" "IO Statistics (iostat)"
    exec_command "sar -d 10 1" "IO Statistics (sar)"
    AddText "Rule of thumb (baseline): avwait ~ 5 ms, avque ~ 0.5, avserv << 10 ms"
    dec_heading_level

fi # terminates CFG_LVM wrapper

#### rar, 16.06.99  lan speed, address etc.################################

LanSpeed () {

	for i in `lanscan -n`
	do
	echo "NetMgntID \t\t\t= $i"
	lanadmin -mas $i
	lanadmin -x $i 2> /dev/null
	echo " "
	done
}

###########################################################################
if [ "$CFG_NETWORK" != "no" ]
then # else skip to next paragraph

	paragraph "Network Settings/Network Interface Cards"
	inc_heading_level

    [ $osrev -gt 10 ] && exec_command "$PLUGINS/get_lan_desc.sh" "NIC Description"
    LANG_C ## 11.31 fixes
    PERL=$(which perl 2>/dev/null)
    # qlan.pl has been removed (issue #1)
    #[ -x "$PERL" ] && exec_command "$PERL $PLUGINS/qlan.pl" "NIC Overview" # (opt?)
    #[ -x "$PERL" ] && exec_command "$PERL $PLUGINS/qlan.pl -v" "NIC Details"
    exec_command "$PLUGINS/get_qlan.sh" "NIC Overview"
    exec_command "$PLUGINS/get_qlan_details.sh" "NIC Details" 

    cat_and_grep "/etc/rc.config.d/netconf" "Netconf Settings"
    [ -r /etc/rc.config.d/hp_apaconf ] &&  exec_command "(cat_and_grep /etc/rc.config.d/hp_apa*conf);echo LanScan -q:;lanscan -q" "Autoport Aggregation"
    # not valid for 11.31!
    [ -r /usr/conf/lib/liblan.a ] && exec_command "what /usr/conf/lib/liblan.a" "LAN Core Patch Level"
    exec_command "netstat -r;echo;netstat -rnv" "Routing Tables"    # <m>  26.02.2008, 1516 -  Ralph Roth
    exec_command "netstat -gin;echo;netstat -s;echo;netstat -Ms" "TCP/IP Stack and Protocol Statistics"
    
    exec_command "netstat -an | grep tcp | awk '{print \$6}' | sort | uniq -c" "Number of TCP/IP Sockets in the same State" # 07010021, rar
    dec_heading_level
    
    # ---------------------------------------------------------------------------
    paragraph "Network Subsystems"
    inc_heading_level
    
    # Montag, 3. Mai 2010
    [ -x /usr/sbin/nettl ] && exec_command "/usr/sbin/nettl -status" "Nettl Status"
    [ -x /usr/sbin/nettlconf ] && exec_command "/usr/sbin/nettlconf -s" "Nettl Conf Settings"
    
    if [ -f /etc/gated.conf ] ; then
        cat_and_grep "/etc/gated.conf" "Gate Daemon Settings"
    fi
    
    exec_command "what /usr/lbin/*pd" "Networking Daemon Patchlevel" # wu-ftp, 28012002. rar, 11022003: tftp/dm, rar
    
    if [ -f /etc/bootptab ] ; then
        cat_and_grep "/etc/bootptab" "BOOTP Daemon Configuration"
    fi
    
    cat_and_grep "/etc/inetd.conf" "Internet Daemon Configuration"
    
    if [ -f /var/adm/inetd.sec ] ; then
        cat_and_grep "/var/adm/inetd.sec" "Internet Daemon Security"
    fi
    [ -d /usr/lib/security ] && exec_command "ll /usr/lib/security" "Files in /usr/lib/security (PAM Kerberos)"
    [ -r /etc/pam.conf ] && cat_and_grep "/etc/pam.conf" "PAM Configuration"
    [ -r /etc/krb5.conf ] && cat_and_grep "/etc/krb5.conf" "Kerberos 5 Configuration"
    [ -r /etc/krb5.keytab ] && {
	 [ -x /usr/sbin/ktutil ] && exec_command "echo \"rkt /etc/krb5.keytab \\n l -e \\n q\" | ktutil" "Kerberos 5 Keytab Configuration"
	}
    
    cat_and_grep "/etc/services" "Internet Daemon Services"
    
    if [ -f /etc/resolv.conf ] ; then
        exec_command "cat /etc/resolv.conf;echo; ( [ -f /etc/nsswitch.conf ] && cat /etc/nsswitch.conf)" "DNS and Names"
    fi
    [ -r /etc/named.boot ] && exec_command "cat /etc/named.boot|grep -v '^;'"  "DNS/Named" # 050802-mv
    
    # sendmail stuff
    exec_command "(what /usr/sbin/sendmail|grep -i version);  grep ^DZ /etc/mail/sendmail.cf /usr/newconfig/etc/mail/sendmail.cf" "Sendmail Versions"
    SMARTHOST=$(grep -e "^DS" /etc/mail/sendmail.cf | sed s/^DS//g)
    exec_command "echo \$Z|/usr/sbin/sendmail -bt -d; echo Smart Relay Host=$SMARTHOST" "Detailed Sendmail Configuration" ## sendmail -d0 -bt < /dev/null
    exec_command "praliases" "Sendmail Aliases local"
    exec_command "cat $(grep -e "^Kmailertable" /etc/mail/sendmail.cf | cut -d ' ' -f 4) /dev/null" "Sendmail Mailertable"     #  17.11.2009 # onndras/MiMe - Montag, 14. Dezember 2009
    (ypwhich 2>/dev/null>/dev/null) && (grep aliases /etc/nsswitch.conf>/dev/null) && exec_command "ypcat -k mail.aliases" "Sendmail Aliases NIS/YP" # sr by wj
    
    cat_and_grep "/etc/rc.config.d/nfsconf" "NFS settings"
#   exec_command "ps -ef|grep -e nfsd -e biod | grep -v grep" "NFSD and BIOD utilization"
    exec_command "UNIX95= ps -f -C biod,nfsd" "NFSD and BIOD utilization"

    exec_command "rpcinfo -u 127.0.0.1 100003" "NSFD responds to RPC requests"
    exec_command "showmount -a" "Mounted NFS File Systems"
    [ -x /usr/sbin/setoncenv ] && exec_command "/usr/sbin/setoncenv -l nfs"  "Detailed NFS Settings"    #  09.06.2009, 13:50 modified by Ralph Roth
    [ -r /etc/auto_master ] && cat_and_grep "/etc/auto_master" "NFS Automounter Settings"
    [ -r /etc/auto.direct ] && cat_and_grep "/etc/auto.direct" "NFS Automounter MAPS"                 # with dots?
    [ -r /etc/auto_direct ] && cat_and_grep "/etc/auto_direct" "NFS Automounter MAPS"   
    exec_command "nfsstat;echo ;nfsstat -m;echo;netstat -an|grep -e Proto -e 2049" "NFS Statistics"
    [ -r /usr/conf/lib/libnfs.a ]  && exec_command "what /usr/conf/lib/libnfs.a" "NFS Core Patch Level"		## needs to be fixed under v3
    exec_command "rpcinfo -p " "Registered RPC programs (portmapper protocol)"
    exec_command "rpcinfo -s " "Registered RPC programs"
    exec_command "rpcinfo -m " "RPC Statistics"
    exec_command "ipcs -mobs" "IPC Status"   # changed from ipcs (sr by vg) #  14.10.2009, 10:11 modified by Ralph Roth
    
    (ypwhich 2>/dev/null>/dev/null) && \
    (exec_command "what /usr/lib/netsvc/yp/yp*; ypwhich" "NIS/Yellow Pages")
    
    # ------- Thomas Brix --------------------------------------------------
    if [ "$XNTPD" -eq 1 ]; then
        exec_command "ntpq -p" "XNTP Time Protocol Daemon"
    fi
    
    if [ -d /opt/ifor ]; then
        [ -x /opt/ifor/ls/bin/i4lbfind ] && exec_command "/opt/ifor/ls/bin/i4lbfind -q" "GLB Server Daemons"
    fi
    
    [ -r /etc/shells ] && cat_and_grep "/etc/shells" "FTP Login Shells"
    ######### SNMP ############
    
    [ -r /etc/SnmpAgent.d/snmpd.conf ] && (cat_and_grep "/etc/SnmpAgent.d/snmpd.conf" "Simple Network Management Protocol (SNMP)")
    
    ######### DTC: updated 16-june-2000 by Raimund Martl ###########
    ######### DTC16RX: added 03-May-2001 by Ralph Roth #############
    ######### { changed/added 04.09.2003 (12:35) by Ralph Roth }
    
    for dtc in /opt/dtcmgr/sbin/dtclist /opt/rdtcmgr/sbin/rdtclist
    do
        
        DtcInfo() {
            liste_dtc=`$dtc -c`
            echo "$dtc"|grep rdtc  > /dev/null
            [ $? -eq 0 ]  && liste_dtc=`$dtc -d`
            
            echo "List of DTCs\n" $liste_dtc
            echo "\n"
            
            for i in `echo $liste_dtc | cut -d" " -f 1`
            do
                echo "---=[ $i ]=----------------------------------------------------------"
                $dtc -c $i | dos2ux | tr \x0c " "| grep -v ^$
                echo "\n\nRDC Status\n"
                [ -x /opt/rdtcmgr/sbin/rdtcstat ] && /opt/rdtcmgr/sbin/rdtcstat $i | dos2ux | tr \x0c " "
                echo "\n"
            done
        }
        
        if [ -x $dtc ] ; then
            #exec_command "$dtc -C|dos2ux|grep -v ^\$" "Default DTC User Configuration ($dtc)"
            exec_command DtcInfo "Managed DTC Configuration (via $dtc)"
        fi
        
    done # for loop
    
    [ -r /etc/ddfa/dp ] && cat_and_grep "/etc/ddfa/dp" "DDFA Dedicated Ports"
    HF=$(what /stand/vmunix | grep HyperFabric)
    [ -n "$HF" ] && exec_command "echo $HF\n;/opt/clic/bin/clic_stat -S" "HyperFabric Version"
    
    dec_heading_level
fi # terminates CFG_NETWORK wrapper

#---------------------------------------------------------------------------

if [ "$CFG_FIBRECHANNEL" != "no" ]
then # else skip to next paragraph
    
    if [ -x /opt/fcms/bin/fcmsutil ] ; then
        paragraph "Fibre Channel" "Fibre Channel Components"
        inc_heading_level
        [ -f /usr/conf/lib/libfcms.a ] && exec_command "what /usr/conf/lib/libfcms.a" "Fibre Channel Driver"
        
        ([ -c /dev/fcms* ] || [ -c /dev/td* ]) && exec_command $PLUGINS/get_fcold.sh "Fibre Channel Card Statistics (old Adapter)"
        
        if [ `ls /dev/td* /dev/fcd*  /dev/fcms* 2>/dev/null | wc -l` != 0 ]
        then
            exec_command $PLUGINS/get_fc.sh "Fibrechannel Interface Information" # changed/added 25.07.2003 (11:17) by Ralph Roth, HP, ASO SW
        fi
        exec_command "what /opt/fcms/bin/fcmsutil" "FCMS Util Revision"
        [ -x /opt/fcms/bin/tdlist ] && exec_command "/opt/fcms/bin/tdlist" "Detailed TD List"	#  12.07.2007, 13:43 modified by Ralph Roth
        [ -x /opt/fcms/bin/fcdlist ] && exec_command "/opt/fcms/bin/fcdlist" "Detailed FCD List"	#  24.06.2010, 10:09 added by Reinhard Lubos
        dec_heading_level
    fi
    
fi # terminates CFG_FIBRECHANNEL wrapper

###########################################################################
if [ "$CFG_KERNEL" != "no" ]
then # else skip to next paragraph
    
    paragraph "Kernel" "Kernel parameters and Settings"
    inc_heading_level
    
    exec_command "dmesg | tail -150" "Last 150 lines of dmesg(1m)" #  26.07.2005, 15:31 modified by Ralph.Roth
    exec_command "vmstat -s" "Kernel paging events"
    exec_command "sar -v 1 5" "Status Kernel Processes"
    
    if [ -f /stand/system ] ; then
        exec_command "cat /stand/system|grep -v -E \"^\*\"|pr -2t" "Kernel Parameter from /stand/system"
    fi
    if [ -x /usr/sbin/sysdef ] ; then
        exec_command "/usr/sbin/sysdef" "Current Kernel Parameters"
    fi
    
    ## only available under hpux11i
    if [ -x /usr/sbin/kctune ] ; then    # { changed/added 19.11.2003 (18:43) by Ralph Roth, sr by Marc Heinrich }
        exec_command "/usr/sbin/kctune -g" "All kctune(1) System Parameter"
        exec_command "/usr/sbin/kctune -Sg" "Nonstandard kctune(1) System Parameter"  #  02.07.2007, 14:03 modified by Ralph Roth
    else
        [ -x /usr/sbin/kmtune ] && exec_command "/usr/sbin/kmtune" "kmtune(1) System Parameter"
    fi
    [ -x /usr/sbin/kmsystem ] && exec_command "/usr/sbin/kmsystem" "Kernel Module Configuration"
    [ -x /usr/sbin/kconfig ] && exec_command "/usr/sbin/kconfig" "Available Kernel Configuration"  	## sr by m.h. - 2504-2005
    [ -x /usr/sbin/kcusage ] && exec_command "/usr/sbin/kcusage" "Query of the Kernel Resources"   	## 03.08.2009, 15:54 modified by Ralph Roth
    [ -x /usr/sbin/kcmodule ] && exec_command "/usr/sbin/kcmodule" "Kernel Modules"                 ## 05.08.2009, 09:26 modified by Ralph Roth
    [ -x /usr/sbin/kcalarm ] && exec_command "/usr/sbin/kcalarm" "Kernel Modules Alarms"
    
    if [ -x /usr/sbin/lsdev ] ; then
        exec_command "/usr/sbin/lsdev" "Current Device Drivers"
    fi
    # not valid for HP-UX 11.31
    [ -r /usr/conf/lib/libhp-ux.a ] && exec_command "what /usr/conf/lib/libhp-ux.a" "HP-UX Core Patch Level"
    [ -r /usr/lib/hpux32/aries32.so ] && exec_command "what /usr/lib/hpux??/aries??.so" "ARIES Emulator Patch Level"  ## IA64 only!
    [ -r /etc/syslogd.conf ] && cat_and_grep "/etc/syslogd.conf" "Syslogd Facility Configuration"

    if [ -x /usr/sbin/audsys ]      #  22.11.2011, 17:36 modified by Ralph Roth #* rar *#
    then
        exec_command "/usr/sbin/audsys" "Audit Sub System Status"
        AddText "Hints:  audevent -l  and  audisp  auditing_file"
    fi # auditing
    
    dec_heading_level
    
fi # terminates CFG_KERNEL wrapper
######################################################################

if [ "$CFG_ENHANCEMENTS" != "no" ]
then # else skip to next paragraph
    
    paragraph "System Enhancements"
    inc_heading_level
    
    if [ -f /usr/bin/dcnodes ] ; then
        exec_command "/usr/bin/dcnodes -Slh" "Diskless Cluster Nodes"
    fi
    
    ######## SAM, 03-may-1999, rar #######################################
    [ -x /usr/sbin/sam ] && exec_command "what /usr/sbin/sam;what /usr/sam/lib/C/sam.ui" "SAM version"
    [ -x /usr/sbin/update-ux ] && exec_command "what /usr/sbin/update-ux" "update-ux Version"
    [ -x /opt/ssh/sbin/sshd ] && exec_command "what /opt/ssh/sbin/sshd" "SSH" ###    changed/added 01.09.2004:16:56 by cfg2html@hotmail.com
    
    # X11 + FontServer, 04-march-99, rar
    [ -x /usr/contrib/bin/X11/xdpyinfo ] && [ -n "$DISPLAY" ] && exec_command "/usr/contrib/bin/X11/xdpyinfo" "X11"
    [ -x /usr/contrib/bin/X11/fsinfo ] && [ -n "$FONTSERVER" ] && exec_command "/usr/contrib/bin/X11/fsinfo" "Font-Server"
    
    ## async/sybase
    exec_command "getprivgrp" "Special Group Attributes"
    [ -c /dev/async ] && exec_command "ll /dev/async; lssf /dev/async" "async Device Driver"
    
    ######################################################################
    if [ -x /usr/bin/x25stat ] ; then
        paragraph "X.25" "X.25 Configuration"
        inc_heading_level
        
        exec_command "/usr/bin/x25stat" "x25stat"
        exec_command "/usr/bin/x25stat -c" "x25stat -c"
        exec_command "/usr/bin/x25stat -a" "x25stat -a"
        
        dec_heading_level
    fi
    
    ###########################################################################
    if [ -d /usr/lib/sna ] ; then
        paragraph "SNA" "SNA Konfiguration"
        inc_heading_level
        
        exec_command "/usr/bin/what /usr/lib/sna/sdlc.??? /usr/lib/sna/download" "SNA Version"
        
        cat-and_grep "/usr/lib/sna/sna.ini" "SNA Init Settings"
        
        if [ -x /usr/bin/snapkinfo ] ; then
            exec_command "/usr/bin/snapkinfo" "SNA KInfo"
        fi
        
        if [ -x /usr/bin/snapshownet ] ; then
            exec_command "/usr/bin/snapshownet -d" "SNA Network"
        fi
        exec_command "snapwhat" "SNAP"
        dec_heading_level
    fi
    
    
    dec_heading_level
    
fi # terminates CFG_ENHANCEMENTS wrapper


###########################################################################

if [ "$CFG_APPLICATIONS" != "no" ]
then # else skip to next paragraph
    
    paragraph "Applications And Subsystems"
    inc_heading_level
    
    ### COMMON ################################################################
    exec_command "ls -lisa /usr/local/bin" "Files in /usr/local/bin"
    exec_command "ls -lisa /usr/lbin" "Files in /usr/lbin"
    
    if [ -d /opt/ifor ]; then
        
        i4_collect()
        {
            echo 'Machine ID: \c';uname -i
            /opt/ifor/ls/bin/i4target -v|grep ID|head -2
            
        }
        #### this is a fix for Thomas Brix inline screentips ####
        iforver="iFOR ID number "`cat /opt/ifor/ls/VERSION.ARK`
        
        [ -x /opt/ifor/ls/bin/i4target ] && exec_command i4_collect $iforver
    fi # [ -d /opt/ifor ]
    
    [ -x /opt/CoCreate/mels/mels ] && exec_command "/opt/CoCreate/mels/mels -t" "ME10 Lisence Server"
    
    exec_command perf_tools "Installed Performance Software"
    
    if [ -x /opt/ignite/bin/print_manifest ]
    then
        exec_command "/opt/ignite/bin/print_manifest -s 2>/dev/null" "Ignite/UX - Print_Manifest"
    fi
    
    [ -x /opt/wt/bin/SharedX ] && exec_command "what /opt/wt/bin/SharedX" "SharedX/MPower Web"
    [ -x /opt/SharedX/bin/SharedX ] && exec_command "what /opt/SharedX/bin/SharedX" "SharedX/Old Version"
    
    ######### socks ############### 10.02.2000, rar ##########
    
    [ -r /etc/opt/socks/sockd.conf ] && cat_and_grep "/etc/opt/socks/sockd.conf" "SOCKS: sockd Configuration"
    [ -r /etc/opt/socks/socks.conf ] && cat_and_grep "/etc/opt/socks/socks.conf" "SOCKS: socks Configuration"
    
    ShowMakeRecovery () {
        
        (cat /var/opt/ignite/logs/makrec.log1; echo Started) | \
        awk '
	################ 21.06.99 by Ralph Roth #############
	# determines the make_recovery sessions
	# bug fixed by rar, 12.01.2000

	/^Started/ {
	  if (ENDE != "")
	  {
	        printf("%33s / %s\n", START, ENDE);
	        ENDE = "";
	  }
	   if (START != "")
	   {
	        START = ""; ENDE = "";
	   }

	   START = $0; ENDE = "";
	}
	/^If the system/ { ENDE = "Cold installed via make_recovery"; }
	/^Ended/   { ENDE = $0; }
	/^Completed/ { ENDE = $0; }

	{}
        '
    }
    
    if [ -r /var/opt/ignite/logs/makrec.log1 ]
    then
        exec_command ShowMakeRecovery "Make_Recovery Sessions"
        AddText "Warning: make_tape_recovery sessions are NOT collected in this logs anymore!"
    fi      ##  05.04.2005, 16:07 modified by Ralph.Roth
    
    [ -r /var/opt/ignite/local/recovery.log ] && exec_command "tail -50 /var/opt/ignite/local/recovery.log" "Ignite/UX Logs" # sr by Thomas Brix, 08072003
    
    [ -x /opt/drd/bin/drd ] && exec_command $PLUGINS/get_drd.sh "Dynamic Root Disks" #  03.02.2011, 09:58 modified by Ralph Roth, DRD by Thomas Brix

    if [ -f /etc/casqit.ini ] ; then
        cat_and_grep "/etc/casqit.ini" "CASQ-it Configuration"
    fi
    
    [ -x /opt/mx/bin/mxnode ] && exec_command SCM_collector "Service Control Manager"
    
    ############ netscape - rar 1-apr-99 ################
    
    ns=`whence netscape`
    if [ -z "$ns" ]
    then
        [ -x /opt/ns-navigator/netscape ] && ns=/opt/ns-navigator/netscape
        [ -x /opt/netscape/netscape ] && ns=/opt/netscape/netscape
    fi
    [ -n "$ns" ] && exec_command "what $ns" "Netscape"
    
    ############ Samba and Swat ########################
    SWAT=`grep swat /etc/services /etc/inetd.conf`
    [ -n "$SWAT" ] && exec_command  "echo $SWAT" "Samba: SWAT-Port"
    [ -x /opt/samba/bin/findsmb ] && exec_command "/opt/samba/bin/findsmb" "Samba Neighbourhood"
    ## [ -x /opt/samba/bin/smbd ] && exec_command "/opt/samba/bin/smbd -V" "Samba version"
    [ -x /opt/samba/bin/smbstatus ] && exec_command "/opt/samba/bin/smbstatus 2>/dev/null" "Samba (smbstatus)"
    [ -x /opt/samba/bin/testparm ] && exec_command "/opt/samba/bin/testparm -s 2>&1" "Samba Configuration"
    [ -x /opt/samba/bin.org/testparm ] && exec_command "/opt/samba/bin.org/testparm -s" "Samba Configuration (bin.org)" ## ????
    [ -f /sbin/init.d/samba ] && exec_command "ps -ef | grep -e swat -e smb -e nmb|grep -v grep" "Samba Daemons"
    
    ########### OpenView, OV, OpC etc. #################
    [ -x /opt/OV/bin/OpC/opcagt ] && {
    exec_command "/opt/OV/bin/OpC/opcagt -version" "HP OpenView Operations Agent Version"
    exec_command "/opt/OV/bin/OpC/opcagt -status 2>&1" "HP OpenView Operations Agent Status"
    }
    #  21.01.2005, 12:47 modified by Ralph.Roth
    [ -x /opt/OV/bin/OpC/install/opclic ] && exec_command "/opt/OV/bin/OpC/install/opclic -list" "HP OpenView IT/Operations license"
    ############ OpenView NNM, 1-july-99 ###############
    [ -x /opt/OV/bin/ovstatus ] && exec_command "/opt/OV/bin/ovstatus -c" "Network Node Manager/ITO"
    ### 25.02.2002, sr by maurice
    [ -x /opt/OV/bin/OpC/opctemplate ] && exec_command "/opt/OV/bin/OpC/opctemplate -l" "ITO Enterprise Templates"
    ####### 10.may.2000, ralph ########
    [ -x /opt/OV/bin/ovobjprint ] && exec_command "/opt/OV/bin/ovobjprint -S" "Contents of OVW Database"
    [ -x /opt/OV/bin/OpC/utils/opcsystst ] && exec_command "/opt/OV/bin/OpC/utils/opcsystst -ro" "ITO Client Settings"
    
    ########### Process Resource Manager, 28-03-2000 ########### #  11.10.2007, 11:08 modified by Ralph Roth
    [ -r /etc/prmconf ] && exec_command "cat /etc/prmconf; prmlist 2>&1 " "PRM - Resource Process Manager"
    
    ############ JetDirect - rar 29-apr-99 ##############
    #exec_command "lpstat -td" "Printer Spooler and Printers"
    exec_command "$PLUGINS/getlp.sh" "Printer Spooler and Printers"
    
    [ -s /var/adm/lp/lpana.log ] && exec_command "lpana" "Printer Statistics"
    
    ##------------------------------------------------------------------------------
    
    if [ -x /usr/openv/netbackup/exclude_list ] ;
    then
        exec_command "cat /usr/openv/netbackup/exclude_list" "Symantec Netbackup exclude_list"
    fi
    if [ -x /usr/openv/netbackup/include_list ]
    then
        exec_command "cat /usr/openv/netbackup/include_list" "Symantec Netbackup include_list"
    fi
    
    ##------------------------------------------------------------------------------
    
    [ -r /opt/hpnp/version ] && [ -x /opt/hpnp/bin/jetadmin ] && exec_command JetAdmin "JetAdmin"
    [ -r /opt/hpnpl/version ] && [ -x /opt/hpnpl/bin/hpnpadmin ] && exec_command JetDirect "JetDirect"
    
    ### System Health Check (SHC), 04.08.2004, rar #########################################
    [ -x /opt/hpsmc/shc/bin/shc ] && exec_command "(/opt/hpsmc/shc/bin/shc -V; /opt/hpsmc/shc/bin/shc -q)" "System Health Check Version"
    
    dec_heading_level
    ########### Below everything is a "sub-chapter" ############################
    
    
    ### VxVM ####################################################################
    ### Symantec licenses  #######################################################
    
    inc_heading_level
    paragraph "Symantec Licenses/Symantec Volume Manager (VxVM)"
    #             if [ -x /sbin/vxlicense ] ; then
    #                 exec_command "/sbin/vxlicense -p" "Licenses"
    #             fi
    exec_command "/usr/sbin/vxlicrep -e" "Symantec License Keys"        ##  12.07.2010, 11:43 modified by Ralph Roth
    if [ -x /usr/sbin/vxdg ]
    then
        exec_command 'swlist "*vxvm*" "*VXVM*"' "VxVM Version"
        exec_command "vxdisk list" "VxVM Disk Overview"
        exec_command "\
        echo $(vxdg list |sed 1d| awk '{print $1} END {print NR }') diskgroups in total | adjust" "VxVM DiskGroup Overview"
        exec_command $PLUGINS/VxVM_collect.sh "VxVM Collector"
        for f in /var/opt/vmsa/logs/command /var/vx/isis/command.log
        do
            if [ -r $f ] ; then
                exec_command "tail -100 $f" "VxVM GUI log end"
            fi
        done
    fi
    # WTEC #358 stuff/VxFS and VxVM, #  19.04.2010, 12:55 modified by Ralph Roth
    # kcmodule -v vxfs vxportal vxfs50 vxportal50|grep -E 'Module|State'
    [ -x /usr/sbin/kcmodule ] && exec_command "/usr/sbin/kcmodule -v vxfs vxportal vxfs50 vxportal50|grep -E 'Module|State'" "VxFS Kernel Modules"
    # /sbin/fs/vxfs/subtype [-v]
    [ -x /sbin/fs/vxfs/subtype ] && exec_command "/sbin/fs/vxfs/subtype;/sbin/fs/vxfs/subtype -v " "VxFS Subtype"
    exec_command "echo Bundles:; swlist -l bundle |grep -iE 'vxvm|vxfs'; echo Products:;swlist -l product|grep -iE 'vxvm|vxfs'" "VxFS/VxVM installed Software"
    
    dec_heading_level
    
    ### OB (DataProtector) #################################################################
    if [ -f /opt/omni/lbin/dbsm ]
    then
        
        paragraph "DataProtector Cell Server Configuration"
        inc_heading_level
        exec_command "/opt/omni/bin/omnicc -version;/opt/omni/sbin/omnisv -version"  	"DataProtector Version (CC/SV)"
        exec_command "/opt/omni/sbin/omnisv -status"        "DataProtector Status"
        exec_command "/opt/omni/bin/omnicc -query"    	"DataProtector Cell Server License"
        exec_command "/opt/omni/bin/omnicheck -patches;  /opt/omni/bin/omnicheck -patches -host client" "Installed DP Patches"
        
        if [ -r /etc/opt/omni/cell/lic.dat ]; then
           cat_and_grep "/etc/opt/omni/cell/lic.dat" "Licence file"
	   exec_command "/opt/omni/bin/omnicc -password_info" "License File and License Keys"
	fi
        [ -r /var/opt/ifor/nodelock ] && exec_command "cat /var/opt/ifor/nodelock" "Old 2.x Nodelock License Key" #  08.03.2005, 14:59 modified by Ralph.Roth
        [ -r /etc/opt/omni/options/global ] && cat_and_grep "/etc/opt/omni/options/global" "Nonstandard Global Options"
        exec_command "/opt/omni/bin/omnicellinfo -dev -detail"  "Configured Devices"
        exec_command "/opt/omni/bin/omnicellinfo -mm"           "Configured Media Pools"
        exec_command "/opt/omni/bin/omnicellinfo -dlinfo"       "Configured Data- and Barlists"
        exec_command "/opt/omni/bin/omnicellinfo -schinfo"      "Data- and Barlists Scheduling "
        exec_command "/opt/omni/bin/omnidb -object"             "List of all DataProtector Objects"
        exec_command "/opt/omni/bin/omnidb -session -last 30"   "Session Status of the last 30 Days"
        exec_command "/opt/omni/sbin/omnidbutil -info"          "DataProtector Database Usage"
        exec_command "/opt/omni/sbin/omnidbutil -extendinfo"    "DataProtector Database Extend Usage"
        
        AddText "Hint:  cat /var/opt/omni/log/inet.log | awk '{print $6;}'| sort -u | grep @ # INet DP users"
        dec_heading_level
        
    fi
    
    ### NetBackup Section ####################################################################
    # Reserve server part



    # first try to spot DataProtector crashes reported by Stefan Gehring
    if [ -x /opt/omni/lbin/bma ]
    then
        exec_command ob_lbin_version "DataProtector Agent Versions and Patch Level"
    fi
    
    [ -r /opt/omni/.omnirc ] && cat_and_grep "/opt/omni/.omnirc" "Local DataProtector Client Setting"  # rar, 18.11.2003
    if [ -r /etc/opt/omni/cell/cell_server ] ; then
        exec_command "cat /etc/opt/omni/cell/cell_server" "DataProtector II Cell Server"
        exec_command "cat /etc/opt/omni/cell/omni_info" "Installed DataProtector Instances"
    fi

    ### NetBackup Section ####################################################################
        # Reserve client part



    ###########################################################################
    
    [ -r /etc/my.cnf ] && exec_command "cat_and_grep /etc/my.cnf" "MySQL Settings"    #  15.02.2008, 13:30 modified by Ralph Roth
    
    ###########################################################################
    if [ -f /etc/oratab ]
    then
        paragraph "Oracle"
        inc_heading_level
        
        # exec_command "cat_and_grep /etc/oratab" "Configured Oracle Databases"
        exec_command $PLUGINS/oracle_collect.sh "Oracle Databases"
        AddText "Hint: Try also the standalone Oracle collector:  Oracle to HTML collector - http://sourceforge.net/projects/ora2html/"
        dec_heading_level
    fi
    ###########################################################################
    if [ "$(grep 'informix' /etc/passwd)" != "" ] ; then
        paragraph "Informix"
        inc_heading_level
        # { changed/added 02.08.2004 (16:32) by Ralph Roth }
        # From:  "geyix" <murat.yildiz@arcor.de> - Date:  Mon Aug 2, 2004  12:56 pm - Subject:  Informix Information
        exec_command "su - informix -c \"echo Informix Home=$INFORMIXDIR\"" "Informix Home"
        exec_command "su - informix -c \"onstat -d\"" "Informix Databases"
        dec_heading_level
    fi
    #### TIP/ix, 30.06.99 #####################################################
    # a hack using absolute paths/names, change accordingly!
    
    if [ "$(grep 'tipadm' /etc/passwd)" != "" ] ; then
        paragraph "TIP/ix"
        inc_heading_level
        exec_command "/usr/tipix/bin/tipinstall -u" "TIP/ix Settings"
        exec_command "su - tipadm -c \"pingtip\"|grep Server" "TIP/ix Daemons"
        dec_heading_level
    fi
    
    
    ###########################################################################
    
    if [ "$CFG_SAP" = "yes" ]
    then # else skip to next paragraph
        
        if [ -d /usr/sap ] ; then
            paragraph "SAP R3"
            inc_heading_level
            exec_command $PLUGINS/get_sap.sh "SAP R3 Configuration"
            [ -f /etc/sapconf ] && exec_command "cat /etc/sapconf" "Local configured SAP R3 Instances"
            dec_heading_level
        fi
    fi # terminates CFG_SAP wrapper
    
    dec_heading_level	## Application
    
fi # terminates CFG_APPLICATIONS wrapper

###########################################################################
if [ "$CFG_MCSG" != "no" ]
then
    if [ -x /usr/sbin/cmscancl ] ; then	# may need fixes on Linux?
        #### fetch Serviceguard Environment ####
        . /etc/cmcluster.conf
        LANG_C
        MCSGVER=$(cmversion)
        
        paragraph "Serviceguard ($MCSGVER)"
        inc_heading_level
        AddText "Hint: Use /opt/cfg2html/contrib/sg_cluster_conf_checker.sh to check your cluster for misconfiguration and errors"
        exec_command "what /usr/lbin/cmcld|head; what /usr/sbin/cmhaltpkg|head" "Real Serviceguard Version"
        exec_command "cmquerycl -v" "Serviceguard Configuration"
        exec_command "cmviewcl -v -f line 2>/dev/null || cmviewcl -v" "Serviceguard Nodes and Packages"     ## A.11.19?||A.11.16
        [ -x /usr/sbin/cmviewconf ] && exec_command "/usr/sbin/cmviewconf" "Serviceguard Cluster Configuration Information"  ## ! A.11.20
	## cmquerystg, cmcheckdg, cmcheckvx, comcompare ## A.11.20 ##
        exec_command "cmscancl -s" "Serviceguard scancl - Detailed Node Configuration"
        exec_command "ll $SGCONF" "Files in $SGCONG (Default=/etc/cmcluster)"

        [ -x /usr/sbin/cmmakepkg ] && exec_command "/usr/sbin/cmmakepkg -l" "Available Serviceguard Modules"
        exec_command "netstat -inw" "Serviceguard Network Subnets"         # <m>  2602-2008, 1514  Ralph Roth
        exec_command "netstat -a |fgrep hacl" "Serviceguard Sockets"
        AddText "Hint: Serviceguard was formerly also known as MC/ServiceGuard or MC/SG"
        dec_heading_level
    fi
    if [ -x /usr/lbin/qsc ] ; then		# should now be common stuff for HP-UX, RHAS, SLES
        paragraph "QuorumServer"
        inc_heading_level
        #  06.04.2005, 13:44 modified by Ralph.Roth
        [ -x /usr/lbin/qsc ] && exec_command "what /usr/lbin/qsc" "Quorum Server (qs)"
        [ -x /opt/qs/bin/qsc ] && exec_command "what /opt/qs/bin/qsc" "Quorum Server (qs)"
        [ -x /usr/local/qs/bin/qsc ] && exec_command "what /usr/local/qs/bin/qsc" "Quorum Server (qs)"
        [ -r /etc/cmcluster/qs_authfile ] && exec_command "cat /etc/cmcluster/qs_authfile" "Quorum Server Authorization"
        [ -r /var/adm/qs/qs.log ] && exec_command "tail -20 /var/adm/qs/qs.log" "last 20 lines of Quorum Server Logfile"
        [ -r /var/log/qs/qs.log ] && exec_command "tail -20 /var/log/qs/qs.log" "last 20 lines of Quorum Server Logfile"
        dec_heading_level
    fi
fi # MC/SG Collector

if [ -h /usr/ixos-archive ]
then
    paragraph "OpenText/IXOS LEA"
    inc_heading_level
    exec_command "cat /usr/ixos-archive/patch/version.txt" "Installed and patched Software"                 # as root
    exec_command "$PLUGINS/ixostool.sh env|grep -E 'ORA|ixos|IXOS|NLS|TNA'" "Environmental Settings"
    exec_command "/usr/ixos-archive/bin/ixutils.ksh -printprodlist" "Installed Software"                    # as root
    exec_command "$PLUGINS/ixostool.sh spawncmd status" "IXOS Spawner Demon Status"
    exec_command "$PLUGINS/ixostool.sh dbtest" "Database test results"
    dec_heading_level
    
fi

dec_heading_level # needed?

#
# execute custom plugins   -- anaumann 2009/08/24
# this section is currently under work and needs a rewrite!, rr - Mittwoch, 14. Oktober 2009

if [ "$CFG_PLUGINS" != "no" ];
then # else skip to next paragraph
    #####    if [ -f /etc/cfg2html/plugins ]; then
    #YI: for future use only
    /usr/bin/touch /tmp/pluginlist  #YI
    
    if [ -f /tmp/pluginlist ]; then
        paragraph "Custom plugins"
        
        # include plugin configuration
        #####        . /etc/cfg2html/plugins
        . /tmp/pluginlist
        
        #YI: All Custom Plugins will be included by default!
        #YI: Selective Custom plugin for future use only..
        CFG2HTML_PLUGINS="all" #YI: variable forced
        
        #YI: default Custom plugin directory is used
        #YI: Selective Custom plugins directory for future use only..
        # use the default plugin directory if not configured otherwise
        #YI:	if [ -z "$CFG2HTML_PLUGIN_DIR" -a -n "$CFG2HTML_PLUGINS" ]; then    #statement not used
        CFG2HTML_PLUGIN_DIR="$PLUGINS/custom"
        #YI:	fi
        
        if [ -n "$CFG2HTML_PLUGIN_DIR" -a -n "$CFG2HTML_PLUGINS" ]; then
            # only run plugins when we know where to find them and at least one of them is enabled
            
            inc_heading_level
            
            if [ "$CFG2HTML_PLUGINS" = "all" ]; then
                # include all plugins
                CFG2HTML_PLUGINS="$(ls -1 $CFG2HTML_PLUGIN_DIR)"
            fi
            
            for CFG2HTML_PLUGIN in $CFG2HTML_PLUGINS; do
                if [ -f "$CFG2HTML_PLUGIN_DIR/$CFG2HTML_PLUGIN" ]; then
                    . $CFG2HTML_PLUGIN_DIR/$CFG2HTML_PLUGIN
                    exec_command cfg2html_plugin "$CFG2HTML_PLUGINTITLE"
                else
                    AddText "Configured plugin $CFG2HTML_PLUGIN not found in $CFG2HTML_PLUGIN_DIR"
                fi
            done
            dec_heading_level
        fi
    fi
fi

## end of plugin processing


###########################################################################
close_html
###########################################################################

[ "$CFG_BCSCONFIG" = "yes" ] && /opt/cfg2html/contrib/BCS_Config/BCS_config

logger "End of $VERSION"
echo "\n"
line

rm -f core > /dev/null

########## remove the error.log if it has size zero #######################
[ ! -s "$ERROR_LOG" ] && rm -f $ERROR_LOG 2> /dev/null

