# cfg2html (Config to HTML)

## Overview

**cfg2html** is a little utility to collect the necessary system configuration files and system set-up to an ASCII file and HTML file. Simple to use and very helpful in disaster recovery situations. cfg2html is written entirely in the native language for system administration: as bash scripts. Experienced users and system admins can adapt or extend the cfg2html scripts to make it work for their particular cases.

## Purpose

cfg2html collects the system configuration into an HTML and a text file. cfg2html is the "Swiss Army knife" for the sysadmins. It was written to get all the information needed to plan an update, do basic troubleshooting or performance analysis. As a bonus, cfg2html creates a nice HTML and simple plain ASCII documentation of your system.

This include the collection of Cron and At, installed Hardware, installed Software, Filesystems, Dump- and Swap-configuration, LVM, Network Settings, Kernel, System enhancements and Applications, Subsystems.

## Where to get cfg2html

The first versions of cfg2html were written for HP-UX. Meanwhile the cfg2html HP-UX stream was ported to all major *NIX platforms and small embedded systems. cfg2html works on Linux, HP-UX, SunOS, AIX etc.

See our GitHub Source development tree <https://github.com/cfg2html/cfg2html> and clone it to your system via:

    git clone git@github.com:cfg2html/cfg2html.git
    cd cfg2html
    make help

If you do not want to build cfg2html by your own, we have pre-build installations you can download from <http://www.cfg2html.com>

## Issue Tracker

If you find a problem or bug, want to discuss feature requests, or have some bright new ideas, please create a new issue on our GitHub project page <https://github.com/cfg2html/cfg2html/issues.>
When using it, please ensure that any criticism you provide is constructive. Please do not use the issue tracker for general help and assistance with using cfg2html.

## Contributing on GitHub

To contribute to a project that is hosted on GitHub you can fork the project on github.com, then clone your fork locally, make a change, push back to GitHub and then send us a pull request, which will email the maintainer.

Fork project on github:

    git clone https://github.com/my-user/project
    cd project
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
> $Id: README.md,v 6.11 2020/04/28 14:37:07 ralph Exp $

<!-- Atom:set encoding=utf8 lineEnding=unix grammar=md tabLength=4 useSoftTabs: -->
<!-- vim:set fileencoding=utf8 fileformat=unix filetype=md tabstop=4 expandtab: -->
