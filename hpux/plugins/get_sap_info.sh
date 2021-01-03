# get_sap_info.sh
# @(#) $Id: get_sap_info.sh,v 1.5 2018/05/25 19:19:21 ralph Exp $
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
#      sapcontrol -nr <nr> -function HAGetFailoverConfig
# etc. Feedback welcome
