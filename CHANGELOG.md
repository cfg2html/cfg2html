Changelog
=========


(unreleased)
------------

Changes
~~~~~~~
- Headers bumped, ReadMe changed. [roseswe]
- MakeIndex - ShellCheck fixes. [roseswe]
- Reformated/documented issue #166. [roseswe]
- Hint about gitchangelog.rc-path added. [roseswe]
- Updated Changelog (by Makefile) [roseswe]
- Debian Chnagelog bumped to version 6.44 for upcoming release. [Ralph
  Roth]
- Bumped version number for upcoming release 6.44. [Ralph Roth]
- Copyright changed to 2023 :-) [roseswe]

Fix
~~~
- Regression CLI -?, issue #165. [roseswe]
- Tried to fix some shellcheck errors. [roseswe]
- Markdown lints. [roseswe]
- Copyright notice, shellcheck fixes. [roseswe]
- Authselect patch from j0hn-c0nn0r 27/01/22 applied. [roseswe]

Other
~~~~~
- Merge branch 'master' of https://github.com/cfg2html/cfg2html.
  [roseswe]

  * 'master' of https://github.com/cfg2html/cfg2html:
    chg: Bumped version number for upcoming release 6.44
- Try to fox OBS build as well #35. [Gratien D'haese]
- #164 fix build on ubunto/debian. [gdha]
- #35 fix the debiam package biuilds. [Gratien D'haese]
- More minor updates to RPM spec file template (#163) [Frank Crawford]

  * Update License field in RPM spec file

  * Correct minor issues with spec file
- Update License field in RPM spec file (#162) [Frank Crawford]
- Add: stale action handler (experimental) [roseswe]


6.43.2 (2022-11-28)
-------------------

Changes
~~~~~~~
- Updated Changelog (by Makefile) [roseswe]

Fix
~~~
- Shellcheck fixes. [roseswe]


6.43.1 (2022-11-17)
-------------------

Changes
~~~~~~~
- Updated Changelog (by Makefile) [roseswe]

Fix
~~~
- Debian build run fixes, prettyfied progs_using_swap.sh. [roseswe]

Other
~~~~~
- Ci(lint): Add differential-shellcheck action (#159) [Jan Macku]

  It performs differential ShellCheck scans and report results directly in pull request.

  documentation: https://github.com/redhat-plumbers-in-action/differential-shellcheck
- Fix date command in netbackup bcpimagelist (#158) [Christian Ramseyer]

  * date +%d/%m/%Y is not expected format, should be m/d/Y
   * fixes crash with these messages:
    * `date: invalid date '19/07/2022'`
    * `cfg2html-linux.sh: line xxx: (1658233237 - ) /86400 : syntax error: operand expected (error token is ") /86400 ")`


6.42.1 (2022-06-27)
-------------------

Changes
~~~~~~~
- Small changes for upcoming SUSE Hackweek. [roseswe]
- Y2k21, AppArmor. [roseswe]
- Fix "is.valid", added SUSE TID. [roseswe]
- Small enhancements and changes to supplemental shell scripts.
  [roseswe]
- Copyright add:  check for modules. [roseswe]
- Linux/packaging/rpm/cfg2html.spec. [Ed Drouillard]

  fix: Turn off the shebang checking in our scripts.
         On version 8 Redhat-based systems, proper shebang (#!) settings are now required.
         Since our scripts are callable by bash or ksh by various operating
         systems, having an empty shebang is deemed necessary.  This change
         undefines the verification macro that rpmbuild uses.
- Applied !MR#147, deleted cfg2html.html (empty). [roseswe]
- Linux/cfg2html-linux.sh. [Ed Drouillard]

  chg: don't put stderr messages in the logfile for lsb_release and lsof commands
     chg: don't put stderr messages in the logfile for setserial command if missing
     chg: use the --sort option on the ps command to get properly sorted output
- Cfg2html. [Ed Drouillard]

  fix: repair re-invocation of the program to ensure the proper shell is used
- Cfg2html-linux.sh. [Ed Drouillard]

  - fix: determine if a physical or virtual host
  - fix: display of locale information
  - fix: update ps command to show processes consuming the most time
  - fix: confirm presence of executable files to eliminate errors in log file
  - fix: limit the number of run level changes or reboots listed to 25
  - fix: use sfdisk or sgdisk depending on version and availability
  - fix: properly display any defined routing files
  - chg: add each network interface in turn to the mii-tool and mii-diag commands
- Dnsdomainname cmd in lib/linux-functions.sh. [Ed Drouillard]
- Updated CHANGELOG.md, maybe corrupted by rebase/merge? [roseswe]
- Merged all enhancements by JW. [roseswe]
- To build with the correct anotated tag. [Ralph Roth]

Fix
~~~
- Regression in building RPM after deleting .html file.  Tested on Azure
  SLES15SP2 and CentOS8.2. [roseswe]

Other
~~~~~
- Small changes where MS-Code or ShellCheck complains about (#157)
  [Ralph Roth]
- Update compat. [Gratien D'haese]
- Find sources for RPM building (#156) [Frank Crawford]
- Update README.md. [Ralph Roth]

  Should fix issue #152
- Added GRUB2 configuration (#150) [Frank Crawford]

  Yes, there is GRUB 1 and 2 boot manager depending on the distro. Thanks for the enhancements!
- Numactl fix (#149) [Frank Crawford]

  * Added GRUB2 configuration

  * Fix html call for numactl
- Fix debian installation so default.conf goes into the right place
  (#148) [edrulrd]

  * fix_duplicate_lsof_display

  * chg: linux/packaging/debian/rules

    fix: the destination for the default.conf file when installed.
         The debian rules were checking for the existence of the default.conf file
         in one directory, and storing it elsewhere.  The default.conf file is
         now set up to be installed in both /usr/share/cfg2html/etc/ and in
         /usr/share/cfg2html/etc/cfg2html, in case SUSE needs it there.

  * chg: linux/packaging/rpm/cfg2html.spec

    fix: Turn off the shebang checking in our scripts.
         On version 8 Redhat-based systems, proper shebang (#!) settings are now required.
         Since our scripts are callable by bash or ksh by various operating
         systems, having an empty shebang is deemed necessary.  This change
         undefines the verification macro that rpmbuild uses.
- Add: *.diff *.patch. [roseswe]
- Fix_duplicate_lsof_display. [Ed Drouillard]
- Testmaster (#146) [Ralph Roth, edrulrd]

  * chg: cfg2html

    fix: repair re-invocation of the program to ensure the proper shell is used

  * chg: linux/cfg2html-linux.sh

     chg: don't put stderr messages in the logfile for lsb_release and lsof commands
     chg: don't put stderr messages in the logfile for setserial command if missing
     chg: use the --sort option on the ps command to get properly sorted output

  * chg: linux/cfg2html-linux.sh

    chg: address issue #45 concerning the use of /etc/alternatives.
         This change lists the executable files in the PATH that are referenced by
         /etc/alternatives, but much more.  Given that the requester implied
         that what was desired to be seen were the files that are referenced
         in the PATH, the implemented change does the following:
         a) Shows the PATH that the cfg2html program was invoked with.  This is
           deemed to be useful in case the sysadmin running the program
           wants to document what the usual path for the invoking user (i.e root)
           normally has.
         b) Then the PATH that this program is using internally is shown. The
            internal PATH command is constructed using directories that are
            usually on every system (core path), followed by directories that
            are found on this particular system (secondary path list).
         c) If the LOCALPATH variable is set to a colon separated list of
           directories, the definition of this variable is next shown.
         d) Following this, all the executable files in the PATH or LOCALPATH,
           if defined, are listed in the order that they would be found.  Thus
           if a filename appears in the PATH directories more than once, only
           the first instance of the file is listed.  This effectively mimics
           the $(which) command on every executable file in the PATH (or LOCALPATH).
    fix: since /usr/kerberos/sbin is not present on all systems, it was removed
         from the core path that root uses, and added to the optional secondary
         list and added to the PATH only if it is present.
    chg: 2 new switches were added as options when the program is invoked.
         -x and -O can now be specified to not show the list of executable files
         in the PATH in case this is not desired, and the ability now exists to
         not display the list of files that have been deleted but are still open.
    fix: adjusted the options (while getopts) switches to not require that an
         argument be supplied for the -A (Altiris) collection.  Even if an
         argument was supplied, the program ignored it.
    fix: don't generate an error message if the hplog command is not present when
         switch -p is enabled.

  chg: linux/etc/default.conf

    chg: added 2 new switches
         -x - don't display the list of files in the PATH
         -O - don't display the list of files that are open but deleted
    fix: recover the ability to set the output location for the generated
         files by using environment variable "OUTDIR"
    fix: change the specification of some variables from $xyz to ${xyz}

  chg: linux/etc/local.conf

    chg: added a commented example entry defining the LOCALPATH variable

  chg: linux/lib/help-functions.sh

    chg: updated usage function (-h)

  * chg: linux/doc/cfg2html.8

    chg: enhanced the cfg2html.8 man page
- Feature request by AB implemented. [roseswe]
- 1 Fixes for make_index.sh (see issue #144) package 2 Fixes for
  regression in cfg2html-linux and crontab collecting. [roseswe]
- Update cfg2html-linux.sh. [unclethom42]

  fix curly brackets on variables in custom plugins section
- Merge branch 'master' into master. [Ralph Roth]


6.41.1 (2020-06-17)
-------------------

Changes
~~~~~~~
- Bumped to version 6.41.1 (annotated tag) [roseswe]


6.41.0 (2020-06-17)
-------------------

Changes
~~~~~~~
- Merged all enhancements by JW. [roseswe]
- Small changes to ReadMe file. [roseswe]

Other
~~~~~
- Changes in the version number. [roseswe]
- Bumped version number for Debian. [Ralph Roth]
- ChangeLog for release 6.35.1. [roseswe]


6.35.1 (2020-05-27)
-------------------

New
~~~
- Added a small Debian check. [roseswe]
- Added who -b, suggested by JetiNite. [roseswe]

Changes
~~~~~~~
- Small cleanup after PR merged. [roseswe]
- Enhancements around saptune(1). Readme.md enhanced. [roseswe]
- Small HPUX man page enhancements. [roseswe]
- Updated copyright. [roseswe]
- Sourcecode indentation beautyfied. [roseswe]
- Different return codes for better troubleshooting. [roseswe]

Other
~~~~~
- Added file progs_using_swap.sh, other: Updated headers, year etc.
  [roseswe]
- Debian package builds now with version number cfg2html_6.34.8_all.deb.
  [Ralph Roth]
- Merge branch 'vk2cot-master' (based on cvs.master 6.61) * vk2cot-
  master:   modified:   cfg2html-linux.sh   modified:   linux/cfg2html-
  linux.sh. [roseswe]
- Merge branch 'master' of https://github.com/vk2cot/cfg2html into
  vk2cot-master. [roseswe]

  * 'master' of https://github.com/vk2cot/cfg2html:
    modified:   linux/cfg2html-linux.sh
    modified:   cfg2html-linux.sh
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Merge pull request #1 from cfg2html/master. [Dusan Baljevic]

  Update repository
- Latest version (6.61) before merging the pull request. [roseswe]
- #35: also change the Build-Depends line in debian/control. [Gratien
  D'haese]
- Add: /var/log/warn, diagnostic lines. [roseswe]
- Major changes and enhancements around check4errors-linux.sh. [roseswe]
- Only changed CVS headers and comments. [roseswe]
- Added details for fclp Fibre Channel devices. [JediNite]
- Added entries for fclp Fibre Channel Devices. [JediNite]
- Sync with upstream (copyright/year, CVS tags, etc.) [roseswe]
- Update cfg2html-linux.sh. [Jeff Petitt]
- Update cfg2html-linux.sh. [Jeff Petitt]

  correct mispelled command
- Update cfg2html-linux.sh. [Jeff Petitt]

  Provide missing DOMAIN name to sssctl domain-status command
- Signed-off-by: roseswe <3810660+roseswe@users.noreply.github.com>
  [roseswe]


6.34.8 (2018-06-27)
-------------------
- Hopefully a fix or workaround for issue #6. [roseswe]


6.34.6 (2018-06-18)
-------------------

Changes
~~~~~~~
- Mainly bumped the versions number etc. But I need to commit the code
  for building! [roseswe]
- ReadMe (about commit messages) [roseswe]
- Fixed shell script indent/beautified them. [roseswe]

Other
~~~~~
- Closes issue #26 - zcat /boot/initrd | cpio -t | grep \.ko$ [roseswe]
- Another try to fix building Debian packages, see issue #35 Help needed
  here! [roseswe]
- This should fix issue #131. [roseswe]
- Mentioned issue #131. [roseswe]
- Added saptune. [roseswe]
- Added systemd-cgls, updated ChangeLog. [roseswe]
- Update cfg2html-linux.sh. [Jeff Petitt]

  The SSSD logic hangs when the SSSDCONF (3 S's) variable is referenced, because SSDCONF (2 S's) was defined
- Small fixes after beautifing the code (wrong indentation etc.)
  [roseswe]
- # Version 6.34.4  -  This is an workaround for issue #129 - roseswe  -
  Chg: Mainly bumped the versions number etc. But I need to commit the
  code for building! - roseswe  -  Releasor: Changed the CHANGELOG file
  from Windows to Linux formatting - roseswe. [roseswe]
- This is an workaround for issue #129. [roseswe]
- Releasor: Changed the CHANGELOG file from Windows to Linux formatting.
  [roseswe]
- # Version 6.34.3  -  chg: ReadMe (about commit messages) - roseswe  -
  chg: Fixed shell script indent/beautified them - roseswe  -  Fix all
  MD issues that VScode flagged - roseswe  -  Bumped the CVS version
  number - roseswe  -  reformatted, cleanup, tabs -> spaces - roseswe  -
  Cleanup     UTF8+UNIX LF     Won't fix comments             roseswe  -
  Man page updates. Can we close issue #16? - roseswe  -  remove bad
  trailing line in changelog of debian packagaing - Gratien D'haese  -
  Changed Debian Changelog using dch, builds to cfg2html_6.34.2_all.deb
  under Debian9 - Ralph Roth  -  Playing around with the ChangeLogs to
  fix the OBS build failure - roseswe  -  added cat
  /sys/kernel/mm/transparent_hugepage/enabled - roseswe. [roseswe]
- Fix all MD issues that VScode flagged. [roseswe]
- Bumped the CVS version number. [roseswe]
- Reformatted, cleanup, tabs -> spaces. [roseswe]
- Cleanup UTF8+UNIX LF Won't fix comments. [roseswe]
- Man page updates. Can we close issue #16? [roseswe]
- Remove bad trailing line in changelog of debian packagaing. [Gratien
  D'haese]
- Changed Debian Changelog using dch, builds to cfg2html_6.34.2_all.deb
  under Debian9. [Ralph Roth]
- Playing around with the ChangeLogs to fix the OBS build failure.
  [roseswe]
- Added cat /sys/kernel/mm/transparent_hugepage/enabled. [roseswe]
- # Version 6.34.2  -  Releasor: 6.34.1-1-g227e333:, 20180222 - roseswe
  -  Cleanup of CHANGELOG.md - roseswe. [roseswe]
- Releasor: 6.34.1-1-g227e333:, 20180222. [roseswe]
- Cleanup of CHANGELOG.md. [roseswe]
- # Version 6.34.1. [roseswe]


6.34.0 (2018-02-22)
-------------------

Fix
~~~
- Awk: cmd. line:1:  ((+1) > 1) {print ./cfg2html;}     awk: cmd.
  line:1:                                 ^ unexpected newline or end of
  string. [Ralph Roth]

Other
~~~~~
- # Version 2.0.0  -  Added CHANGELOG.md and metadata.json - roseswe.
  [roseswe]
- Added CHANGELOG.md and metadata.json. [roseswe]
- # Version 1.0.0 Bumped version number. [roseswe]
- # Version 0.1.0  -  Tweak/beautified the VCS collector for issue #111
  - roseswe  -  should fix one part of issue #124 - roseswe  -  Add
  comments about issue #38 - roseswe  -  Hopefully the next fix for
  issue #35     Regression from OBS build:     [   79s] dpkg-source:
  warning: extracting unsigned source package     (/usr/src/packages/SOU
  RCES.DEB/cfg2html_6.33_8_gfed2d16-0git201802082250.dsc)     [   79s]
  dpkg-source: error: version number contains illegal character `_'
  roseswe  -  enhanced the issue tracker section - roseswe  -
  Experimental build nummer using git describe - roseswe  -
  Successfully builds on a standalone Debian 8 box =>
  cfg2html_6.33-3_all.deb - Ralph Roth  -  Hopefully a bug fix for issue
  #35 - roseswe  -  Delete gitupdate.sh     Not related to be project
  GitHub  -  GPG sign test v2, bumped version number - roseswe  -  Fixed
  Vim modeline, test for signed GPG commits #3 (GPG2) - roseswe  -
  Fixed Vim modeline, test for signed GPG commits - roseswe  -  remove
  the empty line from debian/compat - Gratien D'haese  -  Bumped package
  file to 6.33 - Ralph Roth  -  try to fix issue #35 - roseswe  -  tabs
  -> spaces     small reformatting             roseswe  -  TODO added.
  Spelling fixes.             roseswe  -  bumped release date - roseswe
  -  CVS keyword bumped to major version 6.33 - roseswe  -  Small
  changes, mainly spelling errors - Ralph Roth  -  fixes for wrong URL -
  Ralph Roth  -  Added an comment about pre-build releases. - Ralph Roth
  -  Improved the README, also adding more MD formatting - Ralph Roth  -
  Fixes (hopefully for which commands)     Source beautified     Changed
  CVS header & Year     Signed-off-by: Ralph Roth <rroth>
  Ralph Roth  -     modified:   linux/cfg2html-linux.sh - Ralph Roth  -
  modified:   linux/cfg2html-linux.sh - Ralph Roth  -     modified:
  cfg2html-linux.sh - Ralph Roth  -   modified:   linux/cfg2html-
  linux.sh - Ralph Roth  -  added zypper patch log     fixes for vim
  merged into CVS stream             Ralph Roth  -  Reference to Issue
  #6 added - Ralph Roth. [roseswe]
- Tweak/beautified the VCS collector for issue #111. [roseswe]
- Should fix one part of issue #124. [roseswe]
- Add comments about issue #38. [roseswe]
- Hopefully the next fix for issue #35. [roseswe]

  Regression from OBS build:
  [   79s] dpkg-source: warning: extracting unsigned source package
  (/usr/src/packages/SOURCES.DEB/cfg2html_6.33_8_gfed2d16-0git201802082250.dsc)
  [   79s] dpkg-source: error: version number contains illegal character `_'
- Enhanced the issue tracker section. [roseswe]
- Experimental build nummer using git describe. [roseswe]
- Successfully builds on a standalone Debian 8 box =>
  cfg2html_6.33-3_all.deb. [Ralph Roth]
- Hopefully a bug fix for issue #35. [roseswe]
- Delete gitupdate.sh. [Ralph Roth]

  Not related to be project
- GPG sign test v2, bumped version number. [roseswe]
- Fixed Vim modeline, test for signed GPG commits #3 (GPG2) [roseswe]
- Fixed Vim modeline, test for signed GPG commits. [roseswe]
- Remove the empty line from debian/compat. [Gratien D'haese]
- Bumped package file to 6.33. [Ralph Roth]
- Try to fix issue #35. [roseswe]
- Tabs -> spaces small reformatting. [roseswe]
- TODO added. Spelling fixes. [roseswe]
- Bumped release date. [roseswe]
- CVS keyword bumped to major version 6.33. [roseswe]
- Small changes, mainly spelling errors. [Ralph Roth]
- Fixes for wrong URL. [Ralph Roth]
- Added an comment about pre-build releases. [Ralph Roth]
- Improved the README, also adding more MD formatting. [Ralph Roth]
- Fixes (hopefully for which commands) Source beautified Changed CVS
  header & Year Signed-off-by: Ralph Roth <rroth> [Ralph Roth]
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Added zypper patch log fixes for vim merged into CVS stream. [Ralph
  Roth]
- Reference to Issue #6 added. [Ralph Roth]
- Added CVS tag, added gut tag (6.31) [Ralph Roth]
- Check centent of etc for issue #35 (debian builds fails on obs)
  [Gratien D'haese]
- Retrieve LAN vpd data - close #125. [Gratien D'haese]
- Small changes to build under Debian 8.x. [Ralph Roth]
- Small fixes and updated CVS headers. [Ralph Roth]
- Added get_io_scheduler. [Ralph Roth]
- First cleanup of cfg2html-linux versus cfg2html of the man page. See
  issue #16. [Ralph Roth]
- Adding timeout 60 before the cmscancl command; issue #121. [Gratien
  Dhaese]
- Empty template file "files" - issue #122. [Gratien Dhaese]
- Small enhancements on cfg2html driver (year) Complete rewrite of teh
  README. [Ralph Roth]
- Added "files", needs to be configured in the makefile Fix for
  /etc/cfg2html/files handling (Linux) [Ralph Roth]
- Fix provided by John Emmert applied. [Ralph Roth]
- Mainly supressing error messages to *.err Updated Cluster check
  script. [Ralph Roth]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Ralph Roth]
- Bumped debian versions number to 6.30. [Ralph Roth]
- Added KSH as default shell Updated HTML. [Ralph Roth]
- Check pwd. [Gratien D'haese]
- Another check. [Gratien D'haese]
- Check now debian directory structure. [Gratien D'haese]
- Added a 'ls -l etc/' to the debian rules to check what the content is
  of etc/ [Gratien D'haese]
- URL added, fixed Vim tagline Signed-off-by: Ralph Roth <rroth> [Ralph
  Roth]
- Merge pull request #116 from frankcrawford/master. [Ralph Roth]

  Further MTA updates for Linux version
- Further update to mail testing in cfg2html-linux. [Frank Crawford]

  Remove use of alternatives command, by testing the symlink directly.
- Merge pull request #2 from cfg2html/master. [Frank Crawford]

  Sync with upstream
- Add SAP HANA discovery stuff close #109. [Gratien D'haese]
- Small enhancements for AIX. Date checker if cfg2html is older than two
  years (prints a small warning) [Ralph Roth]
- Merge pull request #115 from frankcrawford/master. [Ralph Roth]

  MTA updates for Linux version
- Update to mail testing in cfg2html-linux. [Frank Crawford]

  This patch modifies how cfg2html tests the MTA, including handling alternative

  It also incorporates a number of tests from the HP-UX version.
- Merge pull request #1 from cfg2html/master. [Frank Crawford]

  Sync with upstream
- Changed copyright year. [Ralph Roth]
- Merge pull request #113 from frankcrawford/patch-1. [Ralph Roth]

  Correctly Generate Output for Processes without anamed owner
- Correctly Generate Output for Processes without anamed owner. [Frank
  Crawford]

  The existing line doesn't escape awk arguments, so they are substituted as shell variables rather than passed to awk.
- Removed Michael Meifert mail adress Changed copyright year (2016)
  Fixed old/wrong web URLs Misc. documentation updates Updated CVS
  version numbers. [Ralph Roth]
- Changed version number and copyright. cfg2html -h now as non-root user
  possible. [Ralph Roth]
- Correct some inc/decrement issues. [Gratien D'haese]
- Disable the cron entry of cfg2html on Linux by default close #108.
  [Gratien D'haese]
- Adding a paragraph section for HP DP - item #107 (not yet finished)
  [Gratien D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Add timeout to bpclimagelist cmd (Linux doen & tested); issue #106.
  [Gratien D'haese]
- Netbackup timeout added by bpclimagelist (hpux); issue #106. [Gratien
  D'haese]
- Add netbackup tests for Linux; issue #106. [Gratien D'haese]
- Fixed a logical error with netbackup include/exclude_list test; add
  last 10 backups; issue #106. [Gratien D'haese]
- Fix the man page - was compressed after failed make depot run.
  [Gratien D'haese]
- -removed the secure_path script from psf file -reduced the information
  displayed by cprop and if status != Normal show more details (issue
  #105) [Gratien D'haese]
- Limit the output to 100 lines of evweb logviewer close #104. [Gratien
  D'haese]
- Show more detailed information about memory (if possible) close #79.
  [Gratien D'haese]
- Show the HP-UX IPFilter configuration if present close #72. [Gratien
  D'haese]
- Remove the plugin script get_secure_path_info.sh - has been added as
  /sbin/autopath display all in cfg2html directly (less overhead). close
  #68. [Gratien D'haese]
- Add COPYING file to PSF file (HPUX) [Gratien D'haese]
- Add COPYING GNU v3 license. [Gratien D'haese]
- Added Conflict rule in rpm - see issue #33. [Gratien D'haese]
- Systeminfo added; close #102. [Gratien D'haese]
- Update man page for HPUX; issue #16. [Gratien D'haese]
- Added knwoledge about centrify samba ; close #48. [Gratien D'haese]
- * lib/global-functions.sh: added TimeOut function * etc/default.conf:
  defined TIMEOUTCMD to TimeOut function for HPUX * cfg2html-hpux.sh:
  implemented TimeOut call before ioscan commands. [Gratien D'haese]
- Use TIMEOUTCMD instead of timeout with df. [Gratien D'haese]
- Small changes on the Linux Makefiles. [Ralph Roth]
- CVS keyword updated. Small text only changes. [Ralph Roth]
- Fix space output when LVOLs of a VG are not mounted close #101.
  [Gratien D'haese]
- * added new function findproc in lib/global-functions.sh * fixed the
  multiple samba instances running colelctgion - issue #48. [Gratien
  D'haese]
- Securepath display all command added instead of running
  plugins/get_secure_path_info.sh script. We can delete
  plugins/get_secure_path_info.sh afterwards if we are satistied with
  the result. See issue #68. [Gratien D'haese]
- Add /etc/hosts entry for HP-UX - issue #91. [Gratien D'haese]
- Fix false decrement within the HP-UX Table of Contents Close #100.
  [Gratien D'haese]
- Correct the display of SGLX version. [Gratien D'haese]
- Correct typo in dev_lssap; issue #99. [Gratien D'haese]
- Redirect dev_lssap to TMP_DIR; issue #99. [Gratien D'haese]
- Debian rules - link to debian dir. [Gratien D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Change /tmp to $TMP_DIR. [Gratien D'haese]
- Fix the puppet status master command - issue #95. [Gratien D'haese]
- Added TIMEOUTCMD - issue #92 and #95. [Gratien D'haese]
- Simplify mail version check with postconf; issue #94. [Gratien
  D'haese]
- Merge pull request #96 from bitfree/master. [Gratien D'haese]

  needed directories for make debian
- Needed directories for make deb. [bitfree]
- CVS id updated, small enhancements and remarks. [Ralph Roth]
- Rules stuff. [Gratien D'haese]
- Ifconfig corrections. [Gratien D'haese]
- Security - maje sure no passwords are listed in /etc/shadow. close
  #83. [Gratien D'haese]
- Added suggestions and issues from the cfg2html mailing list and from
  github. [Ralph Roth]
- Merge pull request #90 from jose1711/master. [Ralph Roth]

  partitions are empty anyway on aix
- Partitions are empty anyway on aix. [jose1711]
- Merge pull request #89 from jose1711/master. [Ralph Roth]

  all tested on aix 7.1tl3
- Some fixes and enhancements. [jose1711]
- Make file integrity checks on aix consistent with linux ones.
  [jose1711]
- Merge pull request #88 from jose1711/master. [Ralph Roth]

  fixed parsing of ps (top load procs) on aix
  Should close issues #86, #87 and #88
- Fix topfdhandles() on aix. [jose1711]
- Fixed parsing of ps (top load procs) on aix. [jose1711]
- Hopefully this fixes issue #86? Cleanup of Linux code/remarks. [Ralph
  Roth]
- Created readme.md. [Ralph Roth]

  Initial creation
- Removed some quotation marks and spaces, cleanup. [Ralph Roth]
- Should close issue #82 (hwinfo) [Ralph Roth]
- Lsssci for all Linux brands now (fixed) lsscsi -s (size, added)
  Signed-off-by: Ralph Roth. [Ralph Roth]
- Enhanced from Gratien's HPUX SAP collector. [Ralph Roth]
- Added changelog + CVS version. [Ralph Roth]
- Updated the plugins/get_sap.sh script and added a new one
  plugins/get_sap_info.sh and made it active within cfg2html-hpux.sh See
  issues #40 and #38. [Gratien D'haese]
- Enhanced the usage of the last command (reboots, runlevel changes,
  etc.) [Ralph Roth]
- Merge pull request #81 from mavit/master. [Ralph Roth]

  Add #! line to script
- Add missing #! line. [Peter Oliver]
- Hopefully fixes issue #80 A few bug fixes added [ -n ] && [ -x ]
  [Ralph Roth]
- Moved in debian/rules the final destination of default.conf from
  /etc/cfg2html to /usr/share/cfg2html/etc (to be on the same page as
  RHEL) - perhaps related to issue #35. [Gratien D'haese]
- End postinstall with chmod 755 /opt/cfg2html. [Gratien D'haese]
- Added kdumptool Fixed a few command not found issues Fixed SuSE
  spelling with SUSE :-) [Ralph Roth]
- Bumped the package spec from 6.12/6.16 to 6.24 Added more
  dependencies... [Ralph Roth]
- Updated year, release date and CVS keyword to reflect a newer
  version... [Ralph Roth]
- Added journalctl --list-boots. [Ralph Roth]
- Updated copyright/year. Fixed a few typos. [Ralph Roth]
- Merge branch 'patch-1' of https://github.com/frangdlt/cfg2html. [Ralph
  Roth]

  setsebool fix?
- Fix Selinux's getsebool path. [Fran Garcia]
- Remark about reboots, before accepting the setsebool patch. Signed-
  off-by: Ralph Roth <rroth@suse.com+cfg2html@hotmail.com> [Ralph Roth]
- ? hopefully this fixes the new timeout command? + CVS keyword updated
  + comments added, some whitespace removed. Signed-off-by: Ralph Roth
  <rroth@suse.com+cfg2html@hotmail.com> [Ralph Roth]
- To avoid stale NFS hangs we use timeout command in combination with df
  - see issue #51. [Gratien D'haese]
- Merge pull request #77 from vk2cot/master. [Ralph Roth]

  modified:   linux/cfg2html-linux.sh
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- Added upload section into Makefile for HPUX - see issue #75. [Gratien
  D'haese]
- Adding lscpu (CPU architecture) - see issue #52. [Gratien D'haese]
- Added /usr/sbin/nstat command - see issue #47. [Gratien D'haese]
- Make safe copy of /opt/cfg2html/etc/local.conf during upgrade of
  version see issue #50. [Gratien D'haese]
- Remove plugins/getpwd.hppa from cfg2html.psf file related to issue
  #49. [Gratien D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Only the CVS header bumped the latest version. Signed-off-by: Ralph
  Roth. [Ralph Roth]
- Remove the plugins/getpwd.hppa executable as we now use pwget/grget
  instead close #49. [Gratien D'haese]
- Exec_command "pwget" "User accounts" [Gratien D'haese]
- Tune2fs/dumpext2 gitignore. [Ralph Roth]
- Merge pull request #74 from vk2cot/master. [Gratien D'haese]

  Added checks for VirtualBox and systemd Virtual Machines and Containers for Linux
- Modified:   linux/cfg2html-linux.sh. [Dusan Baljevic]
- New file:   aix/Makefile        new file:   aix/packaging/Makefile
  new file:   aix/packaging/rpm/cfg2html.spec     new file:
  bsd/doc/cfg2html_html_65218e6e.jpg  new file:
  bsd/doc/cfg2html_html_698bc9a2.jpg  new file:
  hpux/doc/cfg2html_html_65218e6e.jpg         new file:
  hpux/doc/cfg2html_html_698bc9a2.jpg         new file:
  linux/contrib/cfg2html.cron         new file:
  sunos/doc/cfg2html_html_65218e6e.jpg        new file:
  sunos/doc/cfg2html_html_698bc9a2.jpg. [Dusan Baljevic]
- Modified:   Makefile    modified:   aix/lib/global-functions.sh
  modified:   bsd/doc/README.txt  modified:   bsd/doc/cfg2html.html
  modified:   bsd/doc/cfg2html_Development_Tree.jpg       modified:
  cfg2html    modified:   hpux/Makefile       modified:
  hpux/doc/cfg2html.html      modified:
  hpux/doc/cfg2html_Development_Tree.jpg      modified:   linux/Makefile
  modified:   linux/cfg2html-linux.sh     modified:   linux/contrib/bdf
  modified:   linux/doc/cfg2html_Development_Tree.jpg     modified:
  linux/lib/html-functions.sh         modified:   sunos/doc/README.txt
  modified:   sunos/doc/cfg2html.html     modified:
  sunos/doc/cfg2html_Development_Tree.jpg     typechange:
  sunos/lib/global-functions.sh       aix/Makefile    aix/packaging/
  bsd/doc/cfg2html_html_65218e6e.jpg
  bsd/doc/cfg2html_html_698bc9a2.jpg
  hpux/doc/cfg2html_html_65218e6e.jpg
  hpux/doc/cfg2html_html_698bc9a2.jpg     linux/contrib/cfg2html.cron
  sunos/doc/cfg2html_html_65218e6e.jpg
  sunos/doc/cfg2html_html_698bc9a2.jpg. [Dusan Baljevic]
- Merge pull request #73 from didacog/master. [Gratien D'haese]

  Added Packaging - AIX RPM
- Added Packaging - AIX RPM. [Didac Oliveira]
- Added Packaging - AIX RPM. [Didac Oliveira]
- Added Packaging - AIX RPM. [Didac Oliveira]
- Added Packaging - AIX RPM. [Didac Oliveira]
- Added Packaging - AIX RPM. [Didac Oliveira]
- Added Packaging - AIX RPM. [Didac Oliveira]
- Small fixes for erros reported/y2k14 copyright Signed-off-by: Ralph
  Roth. [Ralph Roth]
- Fix for /usr/sbin/cfg2html: line 1: $'\357\273\277#': command not
  found. [Ralph Roth]
- Closes issue #53. [Ralph Roth]
- CVS keywords. Increment of version number. Fix for BASH. [Ralph Roth]
- Signed-off-by: Ralph Roth <rroth@suse.com+cfg2html@hotmail.com> [Ralph
  Roth]
- Merge branch 'master' of https://github.com/vk2cot/cfg2html. [Ralph
  Roth]

  Merged request from Dusan
- Modified:   cfg2html    modified:   linux/cfg2html-linux.sh
  modified:   linux/contrib/Linux-Cluster-check.pl        modified:
  linux/contrib/Linux-check-IO-scheduler-and-discard-support.pl. [Dusan
  Baljevic]
- Merge pull request #70 from vinzent/master. [Ralph Roth]

  Add a title for cluster services information
- Add a new top level paragraph for the cluster services. [Thomas
  Mueller]
- Merge pull request #69 from vk2cot/master. [Ralph Roth]

  Dusan Baljevic VK2COT Linux updates for RHEL/CentOS 7 and various contri...
- Dusan Baljevic VK2COT Linux updates for RHEL/CentOS 7 and various
  contrib scripts in Perl and Python. [Dusan Baljevic]
- More files added that should be ignored. [Ralph Roth]
- Signed-off-by: Ralph Roth <rroth@suse.com+cfg2html@hotmail.com> [Ralph
  Roth]
- + journalctl command Signed-off-by: Ralph Roth
  <rroth@suse.com+cfg2html@hotmail.com> [Ralph Roth]
- Updated the readme's and otehr documentation Signed-off-by: Ralph Roth
  <rroth@suse.com+cfg2html@hotmail.com> [Ralph Roth]
- Merge pull request #67 from vk2cot/master. [Ralph Roth]

  Dusan Baljevic VK2COT BSD tree
- Dusan Baljevic VK2COT BSD tree. [Dusan Baljevic]
- Changed the HP-UX Makefile to save the man page as .save instead of
  .txt (which may become the asccidoc source file over time) [Gratien
  D'haese]
- Merge pull request #66 from vk2cot/master. [Ralph Roth]
- Modified:   Makefile    new file:   doc/cfg2html.8. [Dusan Baljevic]
- Modified:   Makefile    modified:   cfg2html-SunOS.sh   modified:
  etc/default.conf    modified:   lib/help-functions.sh       modified:
  lib/html-functions.sh. [Dusan Baljevic]
- Deleted:    RCS/AUTHORS,v       deleted:    RCS/Makefile,v
  deleted:    RCS/cfg2html-SunOS.sh,v     deleted:
  etc/RCS/default.conf,v      deleted:    lib/RCS/global-functions.sh,v
  deleted:    lib/RCS/help-functions.sh,v         deleted:
  lib/RCS/html-functions.sh,v. [Dusan Baljevic]
- Cvs_keywords. [Ralph Roth]
- Merge pull request #65 from vk2cot/master. [Gratien D'haese]

  Dusan Baljevic Solaris simplified detailed-process-stat.pl plugin, added...
- Dusan Baljevic Solaris simplified detailed-process-stat.pl plugin,
  added diskinfo verbosity and Solaris 8 command devreserv. [Dusan
  Baljevic]
- Merge branch 'vk2cot-master' [Ralph Roth]

  deleted 2 RCS files. 3 modified files merged back
- Merge branch 'master' of https://github.com/vk2cot/cfg2html into
  vk2cot-master. [Ralph Roth]

  Conflicts (deleted by Ralph):
  	sunos/RCS/cfg2html-SunOS.sh,v
  	sunos/lib/RCS/html-functions.sh,v
- Dusan Baljevic Solaris detailed-process-stat.pl plugin, top-level
  Makefile change, and MTA tests. [Dusan Baljevic]
- Gitignore: Added RCS files to be ignored. [Ralph Roth]
- Replaced old documentation. [Ralph Roth]
- Old stuff, updated with new version        modified:
  sunos/doc/cfg2html.html        modified:
  sunos/doc/cfg2html_Development_Tree.jpg Symbolic link:
  typechange: sunos/lib/global-functions.sh. [Ralph Roth]

  Untracked files:
         sunos/doc/cfg2html_html_65218e6e.jpg
         sunos/doc/cfg2html_html_698bc9a2.jpg
- Removing the RCS files and sub-dirs. [Gratien D'haese]
- Merge pull request #62 from vk2cot/master. [Gratien D'haese]

  Dusan Baljevic VK2COT SunOS/Solaris tree
- Dusan Baljevic VK2COT SunOS/Solaris tree. [Dusan Baljevic]
- CVS inc:  AIX pull merge, #59, small fixes, RR, fixes issue #59.
  [Ralph Roth]
- Merge pull request #59 from didacog/master. [Gratien D'haese]

  New AIX Collectors for version 6.XX
- Update Makefile. [Didac Oliveira]
- Update README. [Didac Oliveira]
- New cfg2html collectors for AIX, rewriten for version 6.XX. [Didac
  Oliveira]
- Backports from Dusan, added to CVS. [Ralph Roth]
- Added the file from Dusan which enhances the requests around - systemd
  - issue #56 - systemd bootchart - issue #32 - evainfo/hp3parinfo added
  - issue #57. [Gratien D'haese]
- Added LOM devices /dev/fcoc* (blade i4) as suggested by Marc close
  #58. [Gratien D'haese]
- Enhancements for the SLE-HAE-EXT11 cluster suite. [Ralph Roth]
- Bug 853982 - puppet resource service causes system restart. [Ralph
  Roth]
- Fixes for puppet crash and zypper hangs Signed-off-by: Ralph Roth
  <cfg2html@hotmail.com> [Ralph Roth]
- Puppet: fixes and backported from Linux 2.90 stream. [Ralph Roth]
- Hiding the errors from multipath (not useful at all) [Gratien D'haese]
- Add the -T explanation in the -h output (linux and hp-ux) [Gratien
  D'haese]
- 2.87 backport of systemd, enhanced systemd stuff etc. [Ralph Roth]
- Fix to remove stderr messages. [Ralph Roth]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Ralph Roth]
- Used the _check_cmd_already_running function with ioscan to avoid
  ioscan hangs (HP-UX only) In issue #46 Dusan suggested this precaution
  check. [Gratien D'haese]
- Adding a new function (in global lib directory)
  _check_cmd_already_running to check if a command is already running or
  not. [Gratien D'haese]
- Fixes for chef/puppet stuff CFEngine added by Dusan (2.85 backport)
  Fixes for CFEngine. [Ralph Roth]
- Added puppet and chef collection (backported from Dusan 2.84
  enhancements) [Ralph Roth]
- Added authconfig by Dusan. [Ralph Roth]
- Added diffs from Dusan. Added SAP backport by Ralph. [Ralph Roth]
- Adding timing of commands (output will be written into the err, txt
  and html file). Behavior is exactly the same as with HP-UX. Option -T.
  Related to issue #46. [Gratien D'haese]
- * modified df commands to only work on local FS and added an extra
  check for NFS mounted FS * work-around only for HP-UX - linked to
  issue #51. [Gratien D'haese]
- Dd more FC info in plugin script get_fc.sh - close #36. [Gratien
  D'haese]
- When we define in local.conf: CFG_TRACETIME="yes" then we will
  timestamp the commands we execute in $(hostname).[err|txt|html] (for
  the moment only tested on HP-UX) [Gratien D'haese]
- Added Centrify AD stuff. [Gratien D'haese]
- CVS keywords + header added TODO: AWS added. First AWS backports
  added. [Ralph Roth]
- Comment out hp-info command - close #39. [Gratien D'haese]
- Add changed lines in local.conf file (hpux track) issue #42. [Gratien
  D'haese]
- Add number of changed lines in local.conf file close #42. [Gratien
  D'haese]
- Adding some knowledge about AMazon AWS - see issue #43. [Gratien
  D'haese]
- CVS keyword, fixed wrong comment in systeminfo etc. [Ralph Roth]
- Cfg2html 2.80 backports. [Ralph Roth]
- Small fix for sles11 sp2 - pidtstat doesn't have -l option. [Ralph
  Roth]
- Added the recommendation mentioned in issue #25. [Gratien D'haese]
- Explicit mention the conf files files instead of using wildcard.
  [Gratien D'haese]
- Adding contrib directory to rules. [Gratien D'haese]
- Rules update 25111 or something like that. [Gratien D'haese]
- Rules: keep fingers crossed ;-) [Gratien D'haese]
- Testing OBS BUILS area. [Gratien D'haese]
- Rules saga still goes on... [Gratien D'haese]
- The rules saga continues... [Gratien D'haese]
- Give rules another hang-over for OBS. [Gratien D'haese]

  https://build.opensuse.org/package/show/home:gdha/cfg2html
- New file:   linux/contrib/anonhugepage_collector.sh. [Ralph Roth]
- Added linux/contrib/fc_collector.sh Updated contrib collectors from
  2.78 cfg2html-linux ("upstream") [Ralph Roth]
- Small enhancements (e.g. Copyright, year, etc.), added comments.
  [Ralph Roth]
- Add basename to CURDIR check. [Gratien D'haese]
- Change the if block for the PWD rule. [Gratien D'haese]
- * cfg2html: remove the respawn file asap after the respawn * global-
  functions.sh: OUTDIR if-block * debian/control: remove empty lines
  before Description which prevented building. [Gratien D'haese]
- Small enhancements for Debian builds. [Ralph Roth]
- Should close issue #31 (hponcfg) Small enhancements (THP etc.) [Ralph
  Roth]
- Fix cp conf/* to etc/* in debian.rules. [Gratien D'haese]
- Fix the issue with a ` too much. [Gratien D'haese]
- Adding an if-clause to check if we're in the linux directory, if not,
  do cd linux first (this is to make obs build to work) [Gratien
  D'haese]
- Changes around netstat commands. removed some old stuff. added new ss
  (socket statistics) command. [Ralph Roth]
- Added memory collection (slabinfo, zone, page cache etc.) Source
  indented & cleaned up. [Ralph Roth]
- Modified conf/* into etc/* [Gratien D'haese]
- Modified:   linux/cfg2html-linux.sh     cleanup of code, removed a few
  sleep 2 commands. [Ralph Roth]
- Added CVS keywords, added noarch.prm to ignore list. [Ralph Roth]
- The crontab entry of cfg2html is now commented out by default; added
  an extra line of comment to explain the options; close #30. [Gratien
  D'haese]
- Improve performance of script get_diskfirmware.sh (factor 2) - issue
  #28. [Gratien D'haese]
- Added 2 new plugins: file -m 755 -o root -g sys get_active_lan_info.sh
  file -m 755 -o root -g sys get_secure_path_info.sh. [Gratien D'haese]
- Added SecurePath info for HP-UX 11.11/23 (autopath command output)
  [Gratien D'haese]
- Improve NIC/LAN details on HP-UX 11.xx (new script for HP-UX 11.11/23)
  For HP-UX 11.31 we now use only the get_qlan*.sh scripts (which us
  nwmgr) [Gratien D'haese]
- Small fixes to the man page Updated CVS keyowrds. [Ralph Roth]
- Added the build tar.gz. [Ralph Roth]
- Avoid html to be deleted in linux/doc. [Gratien D'haese]
- Get the doc/*.txt and doc/*.html in line (in git) [Gratien D'haese]
- Added the dsc.orig and spec.orig files. [Ralph Roth]
- Modified files, due to build process (.dsc, .spec), small changes for
  troubleshooting. [Ralph Roth]
- Added comments. [Ralph Roth]
- Added 2.73 backport stuff. [Ralph Roth]
- Cntrl-C removes $TMP_DIR when we escape from a hanging plugin - see
  issue #29. [Gratien D'haese]
- Added Raid manager section and improved identation of VxVM, oracle and
  dataprotector. [Gratien D'haese]
- Adding new pluging to get an overview of all HORCM instances (should
  work on HP-UX and Linux) [Gratien D'haese]
- Added a preinstall.sh script to remove (and make an archive) of an old
  (previous) cfg2html version. [Gratien D'haese]
- To avoid asciidoc requirements for the developers (you need too much
  additional program to be able to run asciidoc) see issue #19. [Gratien
  D'haese]
- Align linux with hpux: changed conf/ into etc/ subdir related to issue
  #22. [Gratien D'haese]
- Added additional signals to trap close #23. [Gratien D'haese]
- Added some last modification in main script (cfg2html) to deal with
  new HP-UX structure and still work with linux. Also, some
  modifications required in configure.sh (SD script) to remove old
  default.conf file when found under /etc/cfg2html. [Gratien D'haese]
- Make sure to copy the saved cfg2html back related to issue #22.
  [Gratien D'haese]
- Several fixes needed to the new /opt/cfg2html HP-UX hierachy working
  again. [Gratien D'haese]
- Changed the HP-UX directory structure from /usr/share/cfg2html to
  /opt/cfg2html/ Still one thing to do (SHARE_DIR must be modified by
  Makefile from /usr/share/$PROGRAM to /opt/$PROGRAM) For the background
  see issue #22. [Gratien D'haese]
- Read the version number from the CVS tag from main cfg2html script
  Depot will get now correct version nr. close #20. [Gratien D'haese]
- Overrule VAR_DIR in cfg2html in default.conf (and added comment in
  local.conf) related to issue #22. [Gratien D'haese]
- Updated the doc relocation in the psf file. [Gratien D'haese]
- Moved the doc directory from top dir to hpux/doc (was the hp doc
  anyway); update makefile (hpux) to adapt the doc relocation and to add
  the correct version number intothe psf file (not yet tested) [Gratien
  D'haese]
- Hpux/contrib/cfg2html_admin_jobs.sh Typo, CVS keywords, Header. [Ralph
  Roth]
- Administrative script to clean up all archives, and make monthly
  overviews, and make new index.html files Script can be used on HP-UX,
  Linux, and other UNIX alikes close #21. [Gratien D'haese]
- CVS keywords added/checked in for history. [Ralph Roth]
- Added the (hpux) plugins directory with current updated CVS keywords.
  [Ralph Roth]
- Simplify the changelog; became too long; lintian was not particular
  happy with it. [Gratien D'haese]
- Make /var/lib/cfg2html back /var/log/cfg2html (the same as HPUX)
  [Gratien D'haese]
- Fix the gawk depends on for debian pkg building; copy the cron entry
  to /etc/cron.d; fix /var/log into /var/lib. [Gratien D'haese]
- Added cron to debian package. [Gratien D'haese]
- If rules added to go around the linux dir... [Gratien D'haese]
- Comment out the make doc line (for OBS) [Gratien D'haese]
- OBS need MAKE -C linux/doc to build the documentation. [Gratien
  D'haese]
- Add linux/doc knowledge in main Makefile (for OBS) [Gratien D'haese]
- Format=3.0 is not very much appreciated by OBS (use back 1.0) [Gratien
  D'haese]
- Added CVS keyword. [Ralph Roth]
- Updated tree/grafic. [Ralph Roth]
- To make the documentation correctly. [Gratien D'haese]
- Added correct encoding attribute for the non-UTF-8 characters - see
  http://www.methods.co.nz/asciidoc/chunked/aph.html#X54. [Gratien
  D'haese]
- Initial import of the cfg2html.txt file. [Gratien D'haese]
- Added compatibility file to debian packaging. [Gratien D'haese]
- Updating the debian rules sets - still need some testing. [Gratien
  D'haese]
- Yet another round struggling with deb package building. [Gratien
  D'haese]
- Change the OUTPUT_URL for new NAS location within our organization.
  [Gratien D'haese]
- Reviewed, spelling, small enhancements (cfg2html) rest of files: CVS
  keyword added. [Ralph Roth]
- Added proper relative path finding close #18. [Gratien D'haese]
- CVS keywords on all Linux files fixed (hopefully) bugs introduced with
  the CVS keyword in "cfg2html"  -> makefiles. [Ralph Roth]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Ralph Roth]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Commented out script firmware_collect.sh close #3. [Gratien D'haese]
- Git stash/MASTER. [Ralph Roth]
- Added more files from CVS. [Ralph Roth]
- CVS keywords, spelling/typos, small comments added. [Ralph Roth]
- OBS build works for RPM; started with debian rules... [Gratien
  D'haese]
- Trying to get cfg2html to build on OBS - still some issues with
  cfg2html.cron. [Gratien D'haese]
- Correcting some loose ends with spec file like missing
  linux/conf/local.conf. [Gratien D'haese]
- CVS keyword added + checked in. [Ralph Roth]
- Fix some minor cosmetic formatting. [Gratien D'haese]
- More CVS keywords added. [Ralph Roth]
- Wrong syntax. [Ralph Roth]
- CVS keywords added .gitignore to handle CVS stuff Signed-off-by: Ralph
  Roth. [Ralph Roth]
- CVS keyword. [Ralph Roth]
- Signed-off-by: Ralph Roth <rroth@suse.com> [Ralph Roth]
- Signed-off-by: Ralph Roth <rroth@suse.com> [Ralph Roth]
- Typos fixed, enhanced and beautified for Linux and HPUX. [Ralph Roth]
- Remove the echo/debug statement with create_dirs. [Gratien D'haese]
- Fix the OUTDIR being empty in some cases; fix postfix/sendmail version
  display; fix zypper hang (issue #6) [Gratien D'haese]
- Adding get_qlan.sh and get_qlan_details.sh to HP-UX psf file. [Gratien
  D'haese]
- Added HP 3PARInfo scanning. [Gratien D'haese]
- BuildArch=noarch added in the spec file as requested by issue #14.
  [Gratien D'haese]
- Put the default values for TGV and BCSCONFIG to no (was yes before)
  [Gratien D'haese]
- Fixed wrong bugfix by me  m) [Ralph Roth]
- Getopt()  A:  is without additional argument? [Ralph Roth]
- Increased for test build the version number to 6.0.1. [Ralph Roth]
- Added the man page for HP-UX in Makefile (rule) and psf file. [Gratien
  D'haese]
- Contributed man page cfg2html.8 for HP-UX. [Gratien D'haese]
- Added a trap to be able to run DoExiTasks (cleanup temp dir) [Gratien
  D'haese]
- Fix the -2 option (getopts) and added the missing help around new
  opts. [Gratien D'haese]
- Fix the linux clean statement. [Gratien D'haese]
- Fix the all rule (should have been on next line) [Gratien D'haese]
- Added options [012] for Linux and correct cron entry for cfg2html.
  [Gratien D'haese]
- Modified top Makefile (all statement and added clean statement) - it
  detects HP-UX and Linux automatically. [Gratien D'haese]
- Remove --noclean option with rpmbuild (SLES doesn't know this option)
  [Gratien D'haese]
- Upstream cfg2html-linux 2.67, difficult to sync, meanwhile 6.xx and
  2.xx differs * CVS header * indenting and cleanup * lsblk -ta. [Ralph
  Roth]
- Remove the HPsupport lines to mail your tar ball to. close #12.
  [Gratien D'haese]
- Revision 5.11  2013-06-28 07:16:29  ralph  Enhanced by GDH - splitted
  into a HPUX 11.31 and the rest of the world part  to better handle
  ioscan.  Cleanup of comments by Ralph Roth. [Ralph Roth]
- For the '$' before the PLUGINS with the qlan script close #1. [Gratien
  D'haese]
- Qlan.pl replacement scripts come in two-foild: - get_qlan.sh for an
  overview of LAN interface (incl. IP address) - get_qlan_details.sh for
  an in-depth LAN overview ==> both scripts will only return output for
  HP-UX 11.31. Did not bother for older versions (yet) -
  plugins/get_lan_desc.sh: comment out the nwmgr call as it is now
  redundant --> linked to issue #1. [Gratien D'haese]

  plugins/firmware_collect.sh: make it work for HP-UX 11.31 (issue #3)
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Remove the exit statement at the end of script linux/cfg2html-linux.sh
  because it terminated the main script cfg2html too soon. [D'Haese]
- Remove the exit statement at the end of script linux/cfg2html-linux.sh
  because it terminated the main script cfg2html too soon. [Gratien
  D'haese]
- Create_dirs was missing in the main script (linux part) [D'Haese]
- Make sure the VAR_DIR gets created the first time cfg2html runs. close
  issue #11. [D'Haese]
- Add the missing \ before %signs for crontab (HP-UX) close #10.
  [Gratien D'haese]
- Added a cron entry for cfg2html into Makefile and spec file (rpm)
  [Gratien D'haese]
- Introduced MY_OS variable (tip from Bill Hassell) to use a different
  mktemp according OS type. [Gratien D'haese]
- Modify the which into a type command for XPINFO. [Gratien D'haese]
- Modify the mktemp command and created a generic mktempDir function.
  [Gratien D'haese]
- Add a template local.conf file with comments only. [Gratien D'haese]
- Hide the xpinfo not found error with the "which xpinfo" command.
  [Gratien D'haese]
- Fix the TMP_DIR name with mktemp command and use .tmp extension for
  temporary filenames. [Gratien D'haese]
- Fix the linux makefile for building a valid RPM package. [Gratien
  D'haese]
- Were able to generate a valid rpm but still needs some work on the
  missing links in the lib dir. [Gratien D'haese]
- Add COPYING file (copy of gpl v3 license) [Gratien D'haese]
- Add pvgfilter.sh to the PSF file. [Gratien D'haese]
- Correct the pvgfilter.sh entry in our hpux main script which should
  work now on all versions. [Gratien D'haese]
- Pvgfilter.sh script replaces the 2 executables for hppa/ia64 and does
  the same close #8. [Gratien D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- CVS keyword, new grafic tree. [Ralph Roth]
- Fix the 'stderr output from "grepand_grep /etc/my.cnf":' error
  grepand_grep should be cut_and_grep. [Gratien D'haese]
- Removed the pvgfilter.* from the PSF file. [Gratien D'haese]
- Removed the hpux/plugins/pvgfilter.* executables. [Gratien D'haese]
- Started with RPM spec and Makefiles. [Gratien D'haese]
- Rename man page from cfg2html-linux.8 -> cfg2html.8. [Gratien D'haese]
- More files without CVS keywords. [Ralph Roth]
- CVS keywords added. Added some comments on the functions. [Ralph Roth]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Ralph Roth]
- Made some final customization of HP-UX SD depot creation process The
  crontab entry will start on a random hour:minute and day. [Gratien
  D'haese]
- Improved the help message on basic cfg2html usage. [Gratien D'haese]
- Ioscan on HP-UX 11.11/11.23 does not understand the -m lun option.
  [Gratien D'haese]
- Makefiles to create the depots and rpm. [Gratien D'haese]
- The HP-UX packaging scripts and psf file. [Gratien D'haese]
- Defined the OUTDIR in linux/conf/default.conf; start using function
  define_outfile to define the HTML_OUTFILE etc. [Gratien D'haese]
- Made sure that the -o flag is respected by cfg2html; removed the exit
  0 from cfg2html-hpux.sh in order to process the
  CopyFilesAccordingOutputUrl function; made several plugins executable;
  changed the error reported at the end of cfg2html. [Gratien D'haese]
- Removed all "local" definitions to avoid errors with ksh. [Gratien
  D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Ralph Roth]
- Link the hpux shell-function.sh to the common shell-functions.sh.
  [Gratien D'haese]
- Finxed name of function _banner (was previously Banner) [Gratien
  D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Fixed the kerberos keytab read-out. [Gratien D'haese]
- Send testparm -s stderr to stdout too. [Gratien D'haese]
- Comment out the qlan.pl script (see issue #1) [Gratien D'haese]
- Chmod   geändert:   cfg2html. [Ralph Roth]
- Find . -name *.sh -exec chmod +x {} \; [Ralph Roth]
- Added Gratien D'haese as a author. Fixed banner command
  ./linux/lib/html-functions.sh: line 49: _banner: command not found.
  [Ralph Roth]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Ralph Roth]

  Conflicts:
  	hpux/lib/shell-functions.sh
- - fixed the opcagt reporting, jetdirect and adding the OUTPUT_URL
  stuff. [Gratien D'haese]
- Added 'what' before the jetdirect executable. [Gratien D'haese]
- Did some minor cleanups and added some place-holders as reminders.
  [Gratien D'haese]
- Change ERROR_FILE into ERROR_LOG. [Gratien D'haese]
- Re-arrange the hpux/lib and linux/lib functions - global-functions.sh,
  input-output-functions.sh and shell-functions.sh are now common by
  both arch. [Gratien D'haese]
- Adding command library functions for hpux/linux. [Gratien D'haese]
- Remove default directory in base (a common lib is a better naming I
  guess) [Gratien D'haese]
- Adding some global functions to assist in better IO and OUTPUT_URL
  settings (still needs to be cleaned up before we can use these)
  [Gratien D'haese]
- Chmod Errors? [Ralph Roth]
- Added gdha as author. [roseswe (Ralph Roth)]
- Initial import of the linux version of cfg2html. [Gratien D'haese]
- Created new dirs: bin and SourceCode + gitupdate.sh. [roseswe]
- Some fixes and cut_and_grep and added extract_my_xpinfo fucntion.
  [Gratien D'haese]
- Merge branch 'master' of github.com:cfg2html/cfg2html. [Gratien
  D'haese]
- Chmod +x *.sh -qlan.sh. [roseswe]
- Qlah.sh must be removed (+ GIT Test) [roseswe]
- Added new function extract_my_xpinfo which looks like xpinfo -i but
  with Vgsize and VG info included. [Gratien D'haese]
- Initial checkin of cfg2html for HP-UX. [Gratien D'haese]


