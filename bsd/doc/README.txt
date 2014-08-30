
This text should be formatted in DOS/Windows CR/LF format that it can be
mailed (and read) with Windows mail programs!


                        __       ____  _     _             _
                   ___ / _| __ _|___ \| |__ | |_ _ __ ___ | |
                  / __| |_ / _` | __) | '_ \| __| '_ ` _ \| |
                 | (__|  _| (_| |/ __/| | | | |_| | | | | | |
                  \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_|
                           |___/

READ ME for Cfg2Html (c) by ROSE SWE, Dipl.-Ing. Ralph Roth
-------------------------------------------------------------------------
Last updated: $Id: README.txt,v 1.2 2014/05/18 10:13:15 dusan Exp dusan $

cfg2html is the short for "Config to HTML".

Cfg2html is a UNIX shell script similar to check_config or get_config, except
that it creates a HTML (and plain ASCII) system documentation for HP- UX
10.xx/11.xx, SCO-UNIX, AIX, Sun OS and Linux systems. Plug-ins for SAP, Oracle,
Informix, MC/SG, Fibre Channel/SAN, TIP/ix, Mass Storage like EVA3000/EVA5000,
XP48/256/512/1024, Network Node Manager and OmniBack/DataProtector etc. are
included. The first versions of cfg2html were written for HP-UX. Meanwhile the
cfg2html 1.xx HP-UX stream was ported to major *NIX platforms. See below
"ported versions"!

This is the "Swiss army knife" for the Account Support Engineer, Customer
Engineer, sysadmin etc. I wrote it to get the necessary information to plan an
update, to perform basic troubleshooting or performance analysis. As a bonus
cfg2html creates a nice HTML and plain ASCII documentation. If you are missing
something, let us know it!

The newest versions are downloadable at:
  - http://come.to/cfg2html (all stuff)
  - www.cfg2html.com (only new betas)

To get a new version visit:         http://come.to/cfg2html
And subscribe to the cfg2html mailing list

Original HPUX Version:  Ralph Roth, ROSE SWE, http://come.to/rose_swe

INSTALLING

The HPUX version is in two distributions available:
 - GNU Zipped tar archive
   (gunzip cfg2html*.gz; tar xvf cfg2html*.tar)
 - Software Distributor format
   (gunzip cfg2html*.gz; swinstall -s $PWD/cfg2html*.depot)

The collector can then be found under /opt/cfg2html/cfg2html_hpux.sh

A wrapper script "/opt/cfg2html/cfg2html" is also provided that calls
cfg2html_hpux.sh with some common commandline options. We suggest that you use
cfg2html instead of cfg2html_hpux.sh (the cfg2html wrapper is also available
under Linux).

Please log off after installation with swinstall to make the PATH adjustments
active. Please REMOVE older versions before installing a new version (e.g.
swremove cfg2hmtl). To install from a software depot you can use: swinstall -s
sdserver:/depot/software CFG2HTML

This software DOES NOT require a reboot! :-))

cfg2html assumes that you have installed your HPUX system in a standard way,
e.g. vg00 for the root volume group and vg* for the other volume groups and lv*
for logical volumes.

Requirements: HP-UX 10.20 or higher, PA-RISC CPU PA 1.1 or higher or IA64.
cfg2html is not fully functional under HP-UX 10.xx (please consider to upgrade
such systems, because HP-UX 10.xx is at it end of support live!) but works fine.

Under HP-UX 10.20 you get the following errors that you can ignore:
	getconf MACHINE_MODEL: Invalid argument
	getconf MACHINE_SERIAL: Invalid argument

Patches: You should install recent Patches/Bundles e.g. the current Gold Bundle
or Quality Pack Bundle and the latest Hardware Enablement Bundles (HWE).
Diagnostics should be A.42.00 or higher. Please also check if you have
installed Diagnostics related patches, ESP.: PHKL_29798 (and it dependencies)!

  ___        _   _
 / _ \ _ __ | |_(_) ___  _ __  ___
| | | | '_ \| __| |/ _ \| '_ \/ __|
| |_| | |_) | |_| | (_) | | | \__ \
 \___/| .__/ \__|_|\___/|_| |_|___/
      |_|
------------------------------------------------------------------

Usage
  ./cfg2html            on *NIX
  cfg2html-linux        on TUX
  cfg2html_hpux.sh      on HPUX platforms
  cfg2html-SunOS.sh     on Sun Solaris
  cfg2html -h           prints a short help (LINUX and HPUX)

  /opt/cfg2html/contrib/check_errors_hpux.sh  - checks for serve errors!

  For older HPUX version (below 1.60) and on some of the ports to other
  platforms use cfg2thml.sh -x          # extract
  to extract the embedded JPG background pictures

------------------- new B.02.10++ command line support ----------------------


usage: cfg2html_hpux.sh [options]
creates HTML and plain ASCII host documentation

  -o path       directory to write (or use the environment variable)
                OUTDIR="/path/to/dir" (directory must exist)
  -0 (null)     append the current date+time to the output files (D-M-Y-hhmm)
  -1 (one)      append the current date to the output files (Day-Month-Year)
  -2 modifier   like option -1, you can use date +modifer, e.g. -2%d%m
                DO NOT use spaces for the filename, e.g. -2%c
  -v            output version information and exit
  -h            display this help and exit

use the following options to enable/disable collectors

  -A            enable:  SAP collector (#)
  -D            enable:  Debug, dumps settings to stdout
  -F            disable: Fibre channel
  -H            disable: Hardware
  -L            disable: Screen tips inline
  -S            disable: Software
  -Y            enable:  Y2K checks
  -a            disable: Applications
  -b            enable:  BCS_Config, external collector (#*)
  -c            disable: Cron
  -d            disable: Diagnostics (cstm #)
  -e            disable: Enhancements
  -f            disable: Filesystem
  -k            disable: Kernel/Boot
  -l            disable: LVM
  -n            disable: Network
  -s            disable: System
  -t            enable:  TGV Volumegroup/LVM collector (#)

(#) these collectors create a lot of information!
(*) collector not included into this package!
Example:  ./cfg2html_hpux.sh -ALbt -o/tmp/hp     to collect EVERYTHING

 ____                       _ _
/ ___|  ___  ___ _   _ _ __(_) |_ _   _
\___ \ / _ \/ __| | | | '__| | __| | | |
 ___) |  __/ (__| |_| | |  | | |_| |_| |
|____/ \___|\___|\__,_|_|  |_|\__|\__, |
                                  |___/
------------------------------------------------------------------

For security reasons it is better to store the HTML and ASCII files in a
safe place where only root user have access. Then remove the files from
your file system.


 ____       _       _     _
|  _ \ __ _| |_ ___| |__ (_)_ __   __ _
| |_) / _` | __/ __| '_ \| | '_ \ / _` |
|  __/ (_| | || (__| | | | | | | | (_| |
|_|   \__,_|\__\___|_| |_|_|_| |_|\__, |
                                  |___/
------------------------------------------------------------------

OK, I fixed a bug, how do I make a diff?

That is quite easy. First, get yourself GNU diff. The other diffs will work,
too, but this tutorial only applies to GNU diff. We want unified diffs!

   1. If you change cfg2html, please mark your changes with for example
      # <name>,<date>. Do not forget to remove all backup files from your editor.
   2. Rename the directory with your new, patched cfg2html-x.xx to, say,
      cfg2html-x.xx.patched
   3. Unpack the original distribution tar ball. DO NOT LEAVE in this directory
      files e.g. from a cfg2html run. Only the original distribution!
   4. Now type:

       diff -uNr cfg2html-x.xx cfg2html-x.xx.patched | gzip -c \
       > cfg2html-x.xx.diff.gz

      This is for GNU diff. You vendor's diff may not know the -u option, in
      which case you should try -c instead.
   5. Now send the compressed diff to my e-mail address:
      cfg2hthml@hotmail.com (subject [cfg2html] + your text)


The "-u" creates a unified diff, which has 3 lines of context per default. This
has the advantage that patches can be applied to other versions of cfg2html,
too.

The "-N" treats new files as empty. That means if you add a file, diff will put
it in the diff, too. This has the advantage that your file is not lost. It has
the disadvantage that "Makefile" and so on are put into the diff, too. So for
patches where you do not add new files, you can omit the "-N".

The "-r" means recursive. For cfg2html this is only important if you change
stuff in subdirectories. But it is good habit to use it.

------------------------------------------------------------------------------

How to apply the Patches/Diffs?

$ gunzip delta-1-14-3rar.gz
$ patch -p0 < delta-1-14-3rar
patching file cfg2html-linux-1.14/cfg2html-linux
patching file cfg2html-linux-1.14/cfg2html_urls.html


 ___         _          _  __   __          _
| _ \___ _ _| |_ ___ __| | \ \ / /__ _ _ __(_)___ _ _  ___
|  _/ _ \ '_|  _/ -_) _` |  \ V / -_) '_(_-< / _ \ ' \(_-<
|_| \___/_|  \__\___\__,_|   \_/\___|_| /__/_\___/_||_/__/
------------------------------------------------------------------

For your information, there are also ported *NIX versions available
on the web page for free downloading!

Maintainer of the different versions

HP-UX              :  Ralph Roth
                      Contributors: Thomas Brix, Martin Kalmbach

Linux port         :  Michael Meifert dk3hg@users.sourceforge.net
                      Contributors: Michael Meier,
                      Linux (debian/hppa): Ralph Roth

To check the rpm use:
        rpm -qpl cfg2html-linux-1.16-2.noarch.rpm
To check the deb use:
        dpkg -c cfg2html-linux_1.16-2_all.deb

Sun Solaris port   :  Trond Eirik Aune [teaune@online.no]
                      Testing: Gert.Leerdam@getronics.com
                      Version 1.7++: Van Laethem, Marc (hp)

                      New Release 6.x: Dusan.Baljevic@ieee.org

SCO port           :  Jan Damen, Support Specialist, jdamen@triple-p.nl

AIX port           :  Gert Leerdam, Gert.Leerdam@getronics.com

Win32              :  Ralph Roth, beta version, NOT USEABLE YET
          	      Better use GetConfig:  www.getconfig.com


 _   _               ____   ____            _             _
| | | | _____      _|___ \ / ___|___  _ __ | |_ __ _  ___| |_
| |_| |/ _ \ \ /\ / / __) | |   / _ \| '_ \| __/ _` |/ __| __|
|  _  | (_) \ V  V / / __/| |__| (_) | | | | || (_| | (__| |_
|_| |_|\___/ \_/\_/ |_____|\____\___/|_| |_|\__\__,_|\___|\__|
------------------------------------------------------------------

You can contact me (Ralph Roth) the following ways

1.) Instant Messenger   (preferred)
2.) Email

1.) I have the following accounts:

ICQ:    	22 11 20 58   (rose_swe)
AIM:    	rose69swe (69 is the year of my birth :)
MSN:    	cfg2html//rose_swe
Yahoo:  	rose_swe
IRC:    	rose_swe, r0se_swe on #virus
Jabber/Org:	cfg2html@jabber.org


2.) Email: I do spam filtering with various tools, so put only me in the
"To:" field, not in the "CC:" or "BCC:" field! No Subjects and text that
could be flag by a rule based or fuzzy logic spam filter!

The email address is           	cfg2html@hotmail.com
Subject must begin with		[cfg2html]


__     __            _
\ \   / /__ _ __ ___(_) ___  _ __  ___
 \ \ / / _ \ '__/ __| |/ _ \| '_ \/ __|
  \ V /  __/ |  \__ \ | (_) | | | \__ \
   \_/ \___|_|  |___/_|\___/|_| |_|___/
------------------------------------------------------------------

A note on the version numbering... there is none of that odd/even numbering
nonsense you find in Lin*xland. The numbers are based on

      Major.Minor-Micro

- A bump in Major means a milestone or set of milestones has been reached.

- A bump in Minor means some piece of functionality has been added, or a
major bug was fixed.

- A bump in Micro (normally characters like a,b,c) usually means bug fixes
or in-house releases (no public releases).

These numbers go from 0-99, and are not necessarily continuous or
monotonically increasing (but they are increasing). What you consider major
and what I consider major are probably two different things. It is possible
that there will be no changes between final release candidate and release.
Sometimes due to the nature of the changes a release will be marked
development. This usually means some core functionality was changed.

To keep thing easier, the HP-UX releases have now the date (YYYYMMDD) in the
archives names. I also renamed the .sd to .depot The "B." is now omitted

e.g.:

12.05.2004     138.290    cfg2html_hpux_2.66-20040512.depot.gz
12.05.2004     135.246    cfg2html_hpux_2.66-20040512.tar.gz

The Software Distributor format also changed from release "B.0" to "C.0" to fix
updating problems plus I put now the also the date to the version number.

CFG2HTML B.02.65  Config To HTML System Documentation Tool by ROSE SWE
to
CFG2HTML C.02.66.20040512 Config To HTML System Documentation Tool (cfg2html) for HP-UX by ROSE SWE


 ____  _             _
|  _ \| |_   _  __ _(_)_ __  ___
| |_) | | | | |/ _` | | '_ \/ __|
|  __/| | |_| | (_| | | | | \__ \
|_|   |_|\__,_|\__, |_|_| |_|___/
               |___/
----------------------------------------------------------------

Starting with cfg2html_hpux 1.49, I introduced a new plug-in concept. cfg2html
uses then external plug-ins for collecting system information.

The plug-ins are stored in CFG2HTML_HOME/plugins. For this reason you must
untar the complete tar ball.

Benefits:
- fast adding of external collectors
-easier maintaining and testing of collectors
- smaller cfg2html main script

Drawbacks:
- requires plug-in/ sub directory
- due to this reason, you MUST install cfg2html_hpux via TAR ball or swinstall

Future:
- Move all integrated collectors from cfg2html to the plug-in directory


       __       ____  _     _             _   _                          ___
  ___ / _| __ _|___ \| |__ | |_ _ __ ___ | | | |__   __ _ _ __   __ _ __|__ \
 / __| |_ / _` | __) | '_ \| __| '_ ` _ \| | | '_ \ / _` | '_ \ / _` / __|/ /
| (__|  _| (_| |/ __/| | | | |_| | | | | | | | | | | (_| | | | | (_| \__ \_|
 \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_| |_| |_|\__,_|_| |_|\__, |___(_)
          |___/                                                 |___/
------------------------------------------------------------------------------

cfg2html_hpux seems to hang sometimes, especially at "Hardware" and "MC/SG".
On a KeyStone, cfg2html needs for example more than 36 minutes to complete!

To get the first impression where cfg2html hangs, change to the /tmp directory
and issue an "ls -ltr". Depending on your hostname(1) you should see some files
beginning with your hostname, e.g.:

-rw-r--r--   1 root       sys           6713 Apr 28 10:37 test_neu.html
-rw-r--r--   1 root       sys           1343 Apr 28 10:37 test_neu.txt
-rw-r--r--   1 root       sys         761532 Apr 28 10:37 test_neu.txt.13320
-rw-r--r--   1 root       sys         763810 Apr 28 10:37 test_neu.html.13320

Do a "tail test_neu.txt" to see the last successful run command (headlines).

Do a "test_neu.txt.13320" to see the output of last command, this gives you
often a hint where cfg2html hangs, for example waits for a keystroke etc.


/* end */

