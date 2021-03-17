# get_sap_info.sh
# @(#) $Id: get_sap_info.sh,v 1.7 2021/02/05 11:15:59 ralph Exp $
# -----------------------------------------------------------------------------

# See also issue #38, can be consolidated with get_sap.sh
# Script written by Gratien D'haese

if [[ -x /usr/sap/hostctrl/exe/saphostexec ]]; then
    echo "*** /usr/sap/hostctrl/exe/saphostexec -version ***"
    /usr/sap/hostctrl/exe/saphostexec -version
    echo "*** /usr/sap/hostctrl/exe/saphostexec -status ***"
    /usr/sap/hostctrl/exe/saphostexec -status
fi

if [[ -x /usr/sap/hostctrl/exe/lssap ]]; then
    echo "*** /usr/sap/hostctrl/exe/lssap ***"
    /usr/sap/hostctrl/exe/lssap -F stdout               ## issue #131 ??
fi

# Also we can add new stuff like
# As SIDadm do
#      sapcontrol -nr <nr> -function HAGetFailoverConfig
# (GetProcessList HAGetFailoverConfig HACheckConfig HACheckFailoverConfig)  etc. Feedback welcome
