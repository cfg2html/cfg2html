# cfg2html (Config to HTML)

## Overview

**cfg2html** is a little utility to collect the necessary system configuration files and system set-up to an ASCII file and HTML file. Simple to use and very helpful in disaster recovery situations.

## Purpose

cfg2html collects the system configuration into a HTML and a text file. cfg2html is the “Swiss army knife” for the sysadmins. It was written to get the necessary information to plan an update, to perform basic trouble shooting or performance analysis. As a bonus cfg2html creates a nice HTML and plain ASCII documentation from your System.

This include the collection of Cron and At, installed Hardware, installed Software, Filesystems, Dump- and Swap-configuration, LVM, Network Settings, Kernel, System enhancements and Applications, Subsystems.

## Where to get cfg2html

The first versions of cfg2html were written for HP-UX. Meanwhile the cfg2html HP-UX stream was ported to all major *NIX platforms and small embedded systems. cfg2html works on Linux, HP-UX, SunOS, AIX etc.

See our GitHub Source development tree <https://github.com/cfg2html/cfg2html> and clone it to your system via:

    git clone git@github.com:cfg2html/cfg2html.git
    cd cfg2html
    make help

If you do not want to build cfg2html by your own, we have pre-build installations you can download from <http://www.cfg2html.com>

## Issue Tracker

If you find a problem, a bug, want to discuss feature requests or have some bright new ideas please create a new issue  at our GitHub project pages <https://github.com/cfg2html/cfg2html/issues.> When using it, please ensure that any criticism you provide is constructive. Please do not use the issue tracker for general help and support on how to use cfg2html.

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
$Id: README.md,v 6.8 2018/03/23 11:09:37 ralph Exp $

<!-- Atom:set encoding=utf8 lineEnding=unix grammar=md tabLength=4 useSoftTabs: -->
<!-- vim:set fileencoding=utf8 fileformat=unix filetype=md tabstop=4 expandtab: -->