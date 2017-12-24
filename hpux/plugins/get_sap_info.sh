# get_sap_info.sh
# @(#) $Id: get_sap_info.sh,v 1.3 2015/11/26 18:17:01 ralph Exp $
# -----------------------------------------------------------------------------

# Script written by Gratien D'haese

if [[ -x /usr/sap/hostctrl/exe/saphostexec ]]; then
    echo "*** /usr/sap/hostctrl/exe/saphostexec -version ***"
    /usr/sap/hostctrl/exe/saphostexec -version
    echo "*** /usr/sap/hostctrl/exe/saphostexec -status ***"
    /usr/sap/hostctrl/exe/saphostexec -status
fi

if [[ -x /usr/sap/hostctrl/exe/lssap ]]; then
    echo "*** /usr/sap/hostctrl/exe/lssap ***"
    /usr/sap/hostctrl/exe/lssap
fi
