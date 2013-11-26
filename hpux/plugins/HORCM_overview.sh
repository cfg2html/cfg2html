# @(#) $Id:
# HORCM information and overview
# Author: Gratien D'haese <gratien.dhaese@gmail.com>

# check if we find some configuration files
ls /etc/horcm* >/dev/null 2>/dev/null
[[ $? -gt 0 ]] && exit

# list the conf files
for cnf in $( ls /etc/horcm*.conf )
do
    [[ "$cnf" = "/etc/horcm.conf" ]] && continue   # is the template config file
    echo "*** Beginning of HORCM configuration file $cnf"
    cat $cnf
    echo "*** End of HORCM configuration file $cnf"
    echo ""
done

# do a pairdisplay of running horcmd instances
PID=$$
for INST in $( ps -ef | grep horcmd_ | grep -v grep | cut -d"_" -f2 | awk '{printf "%d\n",$0}' )
do
    for i in `awk '/HORCM_INST/ {section=1}
         section == 1 && $1 != "HORCM_INST" && $1 !~ "^#.*" {print $1}' /etc/horcm${INST}.conf | sort -u`
    do
        pairdisplay -IBC${INST} -g $i -fcxe > /tmp/pairdisplay_BC${INST}_group_${i}.${PID}
        grep -q "\-\-\-\-" /tmp/pairdisplay_BC${INST}_group_${i}.${PID} && rm -f /tmp/pairdisplay_BC${INST}_group_${i}.${PID}
        pairdisplay -ICA${INST} -g $i -fcxe > /tmp/pairdisplay_CA${INST}_group_${i}.${PID}
        grep -q "\-\-\-\-" /tmp/pairdisplay_CA${INST}_group_${i}.${PID} && rm -f /tmp/pairdisplay_CA${INST}_group_${i}.${PID}
        if [[ -f /tmp/pairdisplay_BC${INST}_group_${i}.${PID} ]]; then
            echo "*** Business Copy overview of instance ${INST} of group ${i}"
            cat /tmp/pairdisplay_BC${INST}_group_${i}.${PID}
            echo
        elif [[ -f /tmp/pairdisplay_CA${INST}_group_${i}.${PID} ]]; then
            echo "*** Continous Access overview of instance ${INST} of group ${i}"
            cat /tmp/pairdisplay_CA${INST}_group_${i}.${PID}
            echo
        else
            echo "pairdisplay: problem with displaying instance ${INST} of group ${i}"
            echo
        fi
    done
    rm -f /tmp/pairdisplay_*.${PID}
done
