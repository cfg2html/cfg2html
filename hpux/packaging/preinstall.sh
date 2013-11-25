#!/bin/sh
# @(#) $Id:
# preinstall.sh script - A preinstall script is called during the Execution Phase of the swinstall
# command. Useful to cleanup old (obsolete) files.
if [[ -d /opt/cfg2html ]]; then
    # probably containing old content? make a backup first
    tar cpf /tmp/cfg2html_old_version.tar /opt/cfg2html
    /usr/bin/echo "       * Created a backup archive /tmp/cfg2html_old_version.tar containing content of /opt/cfg2html"
    rm -rf /opt/cfg2html
    /usr/bin/echo "       * Removed old content of /opt/cfg2html"
fi
