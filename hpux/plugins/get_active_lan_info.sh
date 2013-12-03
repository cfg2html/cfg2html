# @(#) $Id: get_active_lan_info.sh,v 6.13 2013/12/03 16:08:24 ralph Exp $
# script: get_active_lan_info.sh
# to be used on HP-UX 11.xx (except for 11.31 as get_qlan*.sh scripts give better output...)

for i in $( netstat -i | awk '{print $1}' | grep ^lan | cut -d: -f1 | sed -e 's/*//' | sort -u | sed -e 's/lan//' )
do
    echo lan$i
    if [[ $i -ge 900 ]]; then
        lanadmin -x -i $i
        for j in $( lanscan -q | grep $i | awk '{print $2, $3}' )
        do
            echo lan$j
            lanadmin -ma $j
            lanadmin -x $j
        done
    else
        lanadmin -ma $i
        lanadmin -x $i
    fi
    echo
done

