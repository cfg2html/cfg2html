# get_sap_info.sh
# @(#) $Id: get_sap_info.sh,v 1.4 2018/02/16 15:27:06 ralph Exp $
# -----------------------------------------------------------------------------

# See also isse #38, can be consolidated with get_sap.sh
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
