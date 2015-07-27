
function topFDhandles {
    echo "Nr.OpenFileHandles  PID  Command+Commandline"
    (ls /proc/ | awk '{if($1+0==0) print " "; else
system("echo `ls /proc/"$1+0"/fd  |wc -l` \t  PID="$1" \t  CMD=`procfiles "$1+0"|head -1|cut -d: -f2` ")}' | \
sort -nr | head -25) 2> /dev/null
}

function HostNames {
    uname -a
    echo  "Domainname  = "`domainname 2>/dev/null `
    echo  "Hostname (short)= "`hostname -s`
    echo  "Hostname (FQDN) = "`hostname`
}

