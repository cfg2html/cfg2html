# @(#) $Id: get_san_ns.sh,v 5.11 2012-06-01 18:13:56 ralph Exp $
# initial creation 10.09.2008, 13:38, rr, (c) by Ralph Roth
# ---------------------------------------------------------------------------
# usage: get_san_nameservice [N_port_ID]

[ $# -ne 0 ] &&  (grep "Device at device id" /var/adm/syslog/syslog.log|grep "$1" |tail)

for TD in /dev/fcd* /dev/td*
do
    if [ -c "$TD" ]     # device or "td*"?
    then
        echo $TD
        echo "---------------------------------------------------------------------------"
        # Throw out a summary
        fcmsutil $TD | grep -E 'Port|Speed|Driver state|Topology'
        echo "---------------------------------------------------------------------------"
        
        if [ $# -ne 1 ]
        then
#              # fcmsutil /dev/fcd1 ns_query_ports
#             The following is the list of nport ids and their WWPNs:
#               1.  20400     0x5001438000b5f03a
#               2.  30400     0x5006016041e071de
#               3.  31200     0x5006016941e071de
#               4.  11a00     0x5006016041e0dfe0
#               5.  11b00     0x5006016941e0dfe0
#                                                                               $2 = NPort, $3 = WWN
            NID=$(fcmsutil $TD ns_query_ports|grep -v -E 'following|ERROR' | awk '{ print $3; }')
            
            for i in $NID
            do
                    # fcmsutil $TD get remote 0x$i | grep -E 'Symbolic|Port|Target'
                    fcmsutil $TD get remote -w $i | grep -E 'Symbolic|Port|Target'
                    echo ""
            done
        else
                 fcmsutil $TD get remote $* | grep -E 'Symbolic|Port|Target'
        fi    
        echo ""
    fi
done

# 
# EMS:
# 
#    Port World-wide name for device id 0x70c26 has changed OR
#    the device id has disappeared from Name Server GPN_FT (FCP type) response.
#  
#    Port World-wide name for device id 0x3cf007 has changed OR 
#    the device id has disappeared from Name Server GPN_FT (FCP type) response.
#
# ---------------------------------------------------------------------------
# SAN Troubleshooting
# 
# Installiert:  PHKL_36790 -  Fibre Channel Mass Storage Patch
# 
# Problem
# fcmsutil /dev/fcd1 get remote 0x011a00
# 
#             Target N_Port_id is = 0x011a00
#             Target port is in invalid state
# 
# Workaround
# fcmsutil /dev/fcd1 get remote all
# ::
# 
# fcmsutil /dev/fcd1 get remote -w 0x5006016941e071de
# 
#                     Target N_Port_id is = 0x031200
#                            Target state = DSM_READY
#                      Symbolic Port Name = DGC     LUNZ            0326
#                      Symbolic Node Name =
#                               Port Type = N_PORT
#                           FCP-2 Support = NO
#             Target Port World Wide Name = 0x5006016941e071de
#             Target Node World Wide Name = 0x50060160c1e071de
# 
# fcmsutil /dev/fcd1 get remote 0x031200
# 
#                     Target N_Port_id is = 0x031200
#             Target Port World Wide Name = 0
#             Target port is in invalid state
# 
# Siehe
# QXCR1000815634 / PHKL_36790 -> http://forums11.itrc.hp.com/service/forums/questionanswer.do?admit=109447626+1261396073988+28353475&threadId=1235956
# dynamic voltage scaling (DVS)
# dynamic link shutdown (DLS)
