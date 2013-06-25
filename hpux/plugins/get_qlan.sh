# replacement script for qlan.pl

function get_ip {
    /usr/sbin/ifconfig $1 2>/dev/null > /tmp/ifconfig_cfg2html.txt
    if [ $? -eq 1 ]; then
       echo "  N/A"
    else
       grep -q inet /tmp/ifconfig_cfg2html.txt
       if [ $? -eq 0 ]; then
          echo "  \c"
          grep inet /tmp/ifconfig_cfg2html.txt | grep inet | awk '{print $2}'
       else
          echo "  N/A"
       fi
    fi
}

function get_qlan {
    /usr/sbin/nwmgr > /tmp/nwmgr_cfg2html.txt
    for lan in $(grep ^lan /tmp/nwmgr_cfg2html.txt | awk '{print $1}')
    do
        get_ip $lan >> /tmp/ip_cfg2html.txt
    done
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat > /tmp/ip_cfg2html.txt <<EOF
  
  IP
  Address
  =============
EOF

case $(uname -r) in
    "B.11.31") get_qlan ;;
    *) ;;
esac

# paste the 2 files
paste /tmp/nwmgr_cfg2html.txt /tmp/ip_cfg2html.txt

# cleanup
rm -f /tmp/nwmgr_cfg2html.txt /tmp/ifconfig_cfg2html.txt /tmp/ip_cfg2html.txt
