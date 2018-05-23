# Version 6.34.5
 -  Mentioned issue #131 - roseswe
 -  Added saptune - roseswe
 -  Added systemd-cgls, updated ChangeLog - roseswe
 -  Update cfg2html-linux.sh  
    The SSSD logic hangs when the SSSDCONF (3 S's) variable is referenced, because SSDCONF (2 S's) was defined  
            Ralph Roth
 -  Small fixes after beautifing the code (wrong indentation etc.) - roseswe
 -  chg: Releasor: Changed the CHANGELOG file from Windows to Linux formatting !minor - roseswe

# Version 6.34.4
 -  This is an workaround for issue #129 - roseswe
 -  Chg: Mainly bumped the versions number etc. But I need to commit the code for building! - roseswe
 -  Releasor: Changed the CHANGELOG file from Windows to Linux formatting - roseswe

# Version 6.34.3
 -  chg: ReadMe (about commit messages) - roseswe
 -  chg: Fixed shell script indent/beautified them - roseswe
 -  Fix all MD issues that VScode flagged - roseswe
 -  Bumped the CVS version number - roseswe
 -  reformatted, cleanup, tabs -> spaces - roseswe
 -  Cleanup
    UTF8+UNIX LF
    Won't fix comments - roseswe
 -  Man page updates. Can we close issue #16? - roseswe
 -  remove bad trailing line in changelog of debian packagaing - Gratien D'haese
 -  Changed Debian Changelog using dch, builds to cfg2html_6.34.2_all.deb under Debian9 - Ralph Roth
 -  Playing around with the ChangeLogs to fix the OBS build failure - roseswe
 -  added cat /sys/kernel/mm/transparent_hugepage/enabled - roseswe

# Version 6.34.2
 -  Releasor: 6.34.1-1-g227e333:, 20180222 - roseswe
 -  Cleanup of CHANGELOG.md - roseswe

# Version 6.34.1

 - first working version with releasor

# Version 6.33.0
 - Bumped version number
 -  Tweak/beautified the VCS collector for issue #111 - roseswe
 -  should fix one part of issue #124 - roseswe
 -  Add comments about issue #38 - roseswe
 -  Hopefully the next fix for issue #35
    Regression from OBS build:
    [   79s] dpkg-source: warning: extracting unsigned source package
    (/usr/src/packages/SOURCES.DEB/cfg2html_6.33_8_gfed2d16-0git201802082250.dsc)
    [   79s] dpkg-source: error: version number contains illegal character `_'
 -  enhanced the issue tracker section - roseswe
 -  Experimental build nummer using git describe - roseswe
 -  Successfully builds on a standalone Debian 8 box => cfg2html_6.33-3_all.deb - Ralph Roth
 -  Hopefully a bug fix for issue #35 - roseswe
 -  Delete gitupdate.sh Not related to be project GitHub
 -  GPG sign test v2, bumped version number - roseswe
 -  Fixed Vim modeline, test for signed GPG commits #3 (GPG2) - roseswe
 -  Fixed Vim modeline, test for signed GPG commits - roseswe
 -  remove the empty line from debian/compat - Gratien D'haese
 -  Bumped package file to 6.33 - Ralph Roth
 -  try to fix issue #35 - roseswe
 -  tabs -> spaces small reformatting roseswe
 -  TODO added.
    Spelling fixes.  roseswe
 -  bumped release date - roseswe
 -  CVS keyword bumped to major version 6.33 - roseswe
 -  Small changes, mainly spelling errors - Ralph Roth
 -  fixes for wrong URL - Ralph Roth
 -  Added an comment about pre-build releases. - Ralph Roth
 -  Improved the README, also adding more MD formatting - Ralph Roth
 -  Fixes (hopefully for which commands)
    Source beautified
    Changed CVS header & Year
    Signed-off-by: Ralph Roth <rroth>
 -  modified:   linux/cfg2html-linux.sh - Ralph Roth
 -  modified:   linux/cfg2html-linux.sh - Ralph Roth
 -  modified:   cfg2html-linux.sh - Ralph Roth
 -  modified:   linux/cfg2html-linux.sh - Ralph Roth
 -  added zypper patch log
    fixes for vim
    merged into CVS stream
 -  Reference to Issue #6 added - Ralph Roth

No CHANGELOG available for release 6.32 and lower. See history*.txt files!
