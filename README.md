# cfg2html (Config to HTML)

## Overview

**cfg2html** is a small utility for collecting the necessary system configuration files and system setup into an ASCII file and an HTML file. Easy to use and very useful in disaster recovery situations. cfg2html is written entirely in the native language of system administration: as shell scripts. Experienced users and system administrators can adapt or extend the cfg2html scripts to suit their particular needs, either by using the plugin framework or by modifying the source code.

## Purpose

cfg2html collects the system configuration into one HTML and one text file. cfg2html is the sysadmin's Swiss Army knife. It was written to get all the information needed to plan an update, do basic troubleshooting or performance analysis. As a bonus, cfg2html produces a nice HTML and simple plain ASCII documentation of your system.

This includes the collection of cron and at, installed hardware, installed software, file systems, dump and swap configuration, LVM, network settings, kernel, system extensions, applications and subsystems.

## Where to get cfg2html

The first versions of cfg2html were written for HP-UX. Meanwhile the cfg2html HP-UX stream has been ported to all major *NIX platforms and small embedded systems. cfg2html works on Linux, HP-UX, SunOS, AIX etc. The HP-UX version is now deprecated!

See our GitHub Source development tree <https://github.com/cfg2html/cfg2html> and clone it to your system via:

    git clone git@github.com:cfg2html/cfg2html.git
    cd cfg2html
    make help

NOTE:  You need an annotated git tag on your local build system, else the build will fail.
git describe --long should output something like "7.0.1-4-g6cef5f2"

If you do not want to build cfg2html by your own, we have pre-build installations that you can download from <http://www.cfg2html.com> and also from the github release page <https://github.com/cfg2html/cfg2html/releases>

## Issue Tracker

If you find a problem or bug, want to discuss feature requests, or have some bright new ideas, please create a new issue on our GitHub project page <https://github.com/cfg2html/cfg2html/issues>
When using it, please ensure that any criticism you provide is constructive. Please do not use the issue tracker for general help and assistance with using cfg2html.

Feel free to open a pull request to fix a problem yourself or to contribute to a new feature.

## Contributing on GitHub

To contribute to a project that is hosted on GitHub, you can fork the project on github.com, then clone your fork locally, make a change, push back to GitHub and then send us a merge request for your pull, which will email the maintainer.

Please consider to give a star on github to show your support! +1

Please try to keep pull requests as small as possible - one new feature or fix set per pull request is preferred. This makes it easier to review and discuss your contribution.

Fork project on github:

    git clone https://github.com/my-user/cfg2html
    cd cfg2html
    repeat (edit files),(testing) until OK
    git add (modified files)
    git commit -m 'Explain what I changed'
    git push origin master

Then go to github and click the ‘pull request’ button!

## ChangeLog and Tags

NOTE: This is only a suggestion!

- Semantic Versioning <http://semver.org/> e.g. 1.0.19
- For ChangeLog use ruby.gem.releasor or something like <https://keepachangelog.com> or <https://pypi.python.org/pypi/gitchangelog>
- Use Annotated tags (-a)!
- Don't use hash signs (#) in the git commit message, they might get headlines with MarkDown in the ChangeLog.md
- See also <https://keepachangelog.com/en/1.0.0/>
- If possible use this git commit format:
    {new|chg|fix}: [{dev|use?r|pkg|test|doc}:] COMMIT_MESSAGE [!{minor|refactor} ... ]
    To see a full documentation of such commit message convention, please look up the reference file gitchangelog.rc.reference, see <https://github.com/vaab/gitchangelog/blob/master/src/gitchangelog/gitchangelog.rc.reference>

----
<!--  $Id: README.md,v 6.17 2023/08/31 07:56:06 ralph Exp $ -->
<!-- vim:set fileencoding=utf8 fileformat=unix filetype=md tabstop=4 expandtab: -->
