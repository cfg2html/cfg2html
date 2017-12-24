#!/bin/sh
# @(#) $Id:
# preinstall.sh script - A preinstall script is called during the Execution Phase of the swinstall
# command. Useful to cleanup old (obsolete) files.
if [[ -d /opt/cfg2html ]]; then
    # probably containing old content? make a backup first
    tar cpf /tmp/cfg2html_old_version.tar /opt/cfg2html
    /usr/bin/echo "       * Created a backup archive /tmp/cfg2html_old_version.tar containing content of /opt/cfg2html"

    # if local.conf exists and has a size greater than zero; then make a safe copy
    # the template local.conf file lives under /opt/cfg2html/newconfig
    [[ -s /opt/cfg2html/etc/local.conf ]] && /usr/bin/cp -p /opt/cfg2html/etc/local.conf /tmp/local.conf.$(date +'%Y-%m-%d')
    /usr/bin/echo "       * Saved a copy of /opt/cfg2html/etc/local.conf" 

    rm -rf /opt/cfg2html
    /usr/bin/echo "       * Removed old content of /opt/cfg2html"
fi
