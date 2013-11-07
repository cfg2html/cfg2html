
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
Last updated: @(#) $Id: README_hpux.txt,v 6.10.1.1 2013-09-12 16:13:19 ralph Exp $

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
  - http://www.cfg2html.com (all stuff)
  - www.cfg2html.com (only new betas)

To get a new version visit:         http://www.cfg2html.com
And subscribe to the cfg2html mailing list

Original HP-UX Version:  Ralph Roth, ROSE SWE, http://rose.rult.at

For HP-UX 11.31 and better you need at last cfg2html-hpux version 3.74/4.29
All 11.31 (v3) issues should be fixed with version 4.41 or higher - any feedback
is welcome.

 ___           _        _ _       _   _
|_ _|_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __
 | || '_ \/ __| __/ _` | | |/ _` | __| |/ _ \| '_ \
 | || | | \__ \ || (_| | | | (_| | |_| | (_) | | | |
|___|_| |_|___/\__\__,_|_|_|\__,_|\__|_|\___/|_| |_|
---------------------------------------------------------------------------

To install and to execute cfg2html you must be root! A normal user account
will not work!

The HP-UX version is in two distributions available:
 - GNU Zipped tar archive
   (gunzip cfg2html*.gz; tar xvf cfg2html*.tar)
 - Software Distributor format
   (gunzip cfg2html*.gz; swinstall -s $PWD/cfg2html*.depot)
   Gurus: swinstall -s /tmp/cfg2html_hpux_3.27-20060515.depot cfg2html

The collector can then be found under /opt/cfg2html/cfg2html_hpux.sh

A wrapper script "/opt/cfg2html/cfg2html" is also provided that calls
cfg2html_hpux.sh with some common command line options. We suggest that you use
cfg2html instead of cfg2html_hpux.sh (the cfg2html wrapper is also available
under Linux).

Please log off after installation with swinstall to make the PATH adjustments
active. Please REMOVE older versions before installing a new version (e.g.
swremove cfg2hmtl). To install from a software depot you can use:

swinstall -s sdserver:/depot/software CFG2HTML

To install from a NFS share/local filesystem, you can use:

swinstall -s /share/software/cfg2html_hpux_3.61-20080624.depot CFG2HTML


This software DOES NOT require a reboot! :-))

cfg2html assumes that you have installed your HPUX system in a standard way,
e.g. vg00 for the root volume group and vg* for the other volume groups and lv*
for logical volumes.

Requirements:
Version 3.xx - HP-UX 10.20 or higher, PA-RISC CPU PA 1.1 or higher or IA64.
Version 4.xx - HP-UX 11.11 or higher, PA-RISC CPU PA 2.0 or IA64
Version 5.xx - HP-UX 11.11 or higher, PA-RISC CPU PA 2.0 or IA64 -- optimized for HP-UX 11.31/Itanium!

cfg2html is not fully functional under HP-UX 10.xx (please consider to upgrade
such systems, because HP-UX 10.xx is at its end of support live!) but works fine.

Under HP-UX 10.20 you get the following errors that you can ignore:
	getconf MACHINE_MODEL: Invalid argument
	getconf MACHINE_SERIAL: Invalid argument

Patches: You should install recent Patches/Bundles e.g. the current Gold Bundle
or Quality Pack Bundle and the latest Hardware Enablement Bundles (HWE).
Diagnostics should be A.42.00 or higher. Please also check if you have
installed Diagnostics related patches, ESP.: PHKL_29798 (and it dependencies)!

Notes from Bill on SW Depots:

Having the code in depot format solves a lot of issues:
•	Easier to install (swinstall does everything, tar requires creating /opt/cfg2html and manual fixup of /etc/PATH)
•	swlist shows cfg2html as a product
•	swlist -l product also shows the version directly
•	Standard way to remove (swremove)
•	Matches previous releases


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
  cfg2html_hpux.sh      on HP-UX platforms
  cfg2html_sun.sh       on Sun Solaris
  cfg2html -h           prints a short help (LINUX and HP-UX)

  /opt/cfg2html/contrib/check_errors_hpux.sh  - checks for serve errors!

  For older HP-UX version (below 1.60) and on some of the ports to other
  platforms use cfg2thml.sh -x          # extract
  to extract the embedded JPG background pictures

-------------------=[]  command line support  []=----------------------

# ./cfg2html_hpux.sh -h

usage: cfg2html_hpux.sh [options]
creates HTML and plain ASCII host documentation
Output modifier:
  -o path       directory to write (or use the environment variable)
                OUTDIR="/path/to/dir" (directory must exist)
  -0 (null)     append the current date+time to the output files (D-M-Y-hhmm)
  -1 (one)      append the current date to the output files (Day-Month-Year)
  -2 modifier   like option -1, you can use date +modifier, e.g. -2%d%m
                DO NOT use spaces for the filename, e.g. -2%c
Help:
  -v            output version information and exit
  -h            display this help and exit

use the following options to enable/disable collectors
  -A            enable:  SAP collector (#)
  -D            enable:  Debug, dumps settings to stdout
  -F            disable: Fibre channel
  -H            disable: Hardware
  -L            disable: Screen tips inline
  -S            disable: Software
  -M            disable: MC/Serviceguard and Quorum Server collector
  -U            disable: User accounts/security sensitive data
  -P            enable: cfg2html plugin architecture

  -a            disable: Applications
  -b            enable:  BCS_Config, external collector (#*)    (obsolete)
  -c            disable: Cron
  -d            disable: Diagnostics (cstm, obsolete 03/2009 #)
  -e            disable: Enhancements
  -f            disable: Filesystem
  -k            disable: Kernel/Boot
  -l            disable: LVM
  -n            disable: Network
  -s            disable: System
  -t            enable:  TGV Volumegroup/LVM collector (#)      (obsolete)

(#) these collectors create a lot of information!
(*) collector not included into this package!
Example:  ./cfg2html_hpux.sh -ALbt -o/tmp/hp     to collect EVERYTHING
A shell wrapper with handy options is included into this distribution,
simply try: cfg2html  (calls cfg2html_hpux.sh -0 -o/tmp)


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
Read this if you are a developer and interested in enhancing cfg2html! Please
note that all contribution to cfg2html must be copyright free, because in the
future cfg2html will be put under a Open Source License (e.g. GPL v2/v3)!

OK, I fixed a bug and enhanced cfg2html, how do I make a diff for upstream
enhancement?

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
   5. Now send the compressed diff to my email address:
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

	bash-3.2$ patch -p0 < cfg2html_4.73.diff
	patching file cfg2html_473/cfg2html_hpux.sh
	Hunk #1 succeeded at 1204 (offset 3 lines).
	Hunk #2 succeeded at 1571 (offset 3 lines).
	patching file cfg2html_473/plugins/get_lvm_info.sh

---------------------------------------------------------------------------

Building a depot from the tar archive?
If you can show me the packaging steps, I can package it and send it back for you.

That's easy, if you got the swpackage.sh SHAR archive from me.
You need for example:
	swpackage.sh
	cfg2html_hpux_5.13-20110621-33156.tar
Steps:
1.) unpack the SHAR archive:  sh swpackage.sh
	x - extracting prodspec.dat (text)
	x - extracting tar2depot.sh (text)
2.) build the .depot file as root under HP-UX: sh tar2depot.sh
3.) Depot is build using swpackage



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

SCO port           :  Jan Damen, Support Specialist, jdamen@triple-p.nl

AIX port           :  Gert Leerdam, Gert.Leerdam@getronics.com

Win32              :  Better use GetConfig:  www.getconfig.com


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
SkyPe           Ralph.Roth

Twitter         rose_swe
XING            https://www.xing.com/profile/Ralph_Roth


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
CFG2HTML C.02.66.20040512 Config To HTML System Documentation Tool (cfg2html)
for HP-UX by ROSE SWE

Starting with the HP-UX release 4.xx I also have added a build number to the
tar/depot archive. The higher the build number the better :-)
The build number is calculated from the CVS/RCS id keywords.

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
- easier maintaining and testing of collectors
- smaller cfg2html main script

Drawbacks:
- requires plug-in/ sub directory
- due to this reason, you MUST install cfg2html_hpux via TAR ball or swinstall

Future:
- Move all integrated collectors from cfg2html to the plug-in directory


Plug-ins not used (see also contrib directory for more scripts):
- get_cpu_speed
- evainfo
- get_san_ns.sh  (21. Dezember 2009)
- find_non_inq_luns.sh (10.03.2010)


 _____      _                 _
| ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
|  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
| |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
|_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/
---------------------------------------------------------------------------

"user plug-ins"

cfg2html can be easily extended  by writing small scripts and configuring them
as plug-ins in /etc/cfg2html/plugins. You can do whatever you want in your
plug-in and all of stdout will be included in the output file.

There are two rules you'll have to follow to make your script run as a plug-in
within cfg2html:

1. Assign your desired paragraph title to a variable named CFG2HTML_PLUGINTITLE
2. Run all your program logic in a function called "cfg2html_plugin".

Examples of cfg2html plug-ins can be found in the contrib/plugins/ directory
of the cfg2html distribution (LINUX) or plugins/custom (HP-UX).



       __       ____  _     _             _   _                          ___
  ___ / _| __ _|___ \| |__ | |_ _ __ ___ | | | |__   __ _ _ __   __ _ __|__ \
 / __| |_ / _` | __) | '_ \| __| '_ ` _ \| | | '_ \ / _` | '_ \ / _` / __|/ /
| (__|  _| (_| |/ __/| | | | |_| | | | | | | | | | | (_| | | | | (_| \__ \_|
 \___|_|  \__, |_____|_| |_|\__|_| |_| |_|_| |_| |_|\__,_|_| |_|\__, |___(_)
          |___/                                                 |___/
------------------------------------------------------------------------------

Tape devices do sequential I/O and may experience problems when commands like
ioscan are executed, direct access devices (DAS) like disk drives are not
sensitive to this. For that reason we advise never to run this script when a
backup is running on any of the tape drives that are connected to the system
directly or in a zone in the Storage Area Network (SAN).

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

If Diagnostics (cstm) hangs try the following and fix the errors cstm reports:

# cstm
Diag
Map
SelAll
Information
wait
InfoLog
Done
Exit
OK
#


cfg2html changes by Bill Hassell
--------------------------------
cfg source = 5.25 - 20111229

Change list:

1. Added: -s to print_manifest (hardware and software info is redundant here)
   This can remove 10 to 50 seconds off the total run time

2. Added: bdfmegs.sh to the plugins directory
   Replaced bdf -i with bdfmegs.sh -c 1 -vls:

     File-System         Mbytes    Used   Avail %Used   Type Vr Lrg VGv Mounted on
     /dev/vg00/lvol3       1048     449     599   43%   vxfs  6 yes 1.0  /
     /dev/vg00/lvol1       1835     519    1305   28%   vxfs  5  no 1.0  /stand
     /dev/vg00/lvol8       8912    5615    3297   63%   vxfs  6 yes 1.0  /var
     /dev/vg00/lvol7       4554    3322    1222   73%   vxfs  6 yes 1.0  /usr
     /dev/vg00/lvol4        524     286     236   55%   vxfs  6 yes 1.0  /tmp
     /dev/vg00/lvol6       10.8g   9283    1485   86%   vxfs  6 yes 1.0  /opt
     memfs                  262       0     262    0%  memfs na  -- n/a  /memfs
     /dev/vg00/lvol5        131       8     122    6%   vxfs  6 yes 1.0  /home
     /dev/vgbig/lvol1     655.4g  490.2g  154.9g  76%   vxfs  7 yes 1.0  /atl1bk
     /dev/vg2.1/lvol2.1   102.4g   22.5g   74.9g  23%   vxfs  6 yes 2.1  /mnt2
     -- sum totals ----   785.8g  532.1g  238.3g  --- sum totals ---

   This list is sorted by VGname, handles all types of filesystems and for 11.31+
   will show version 2.xx VGs.

3. RECHNER=$(hostame)
   Rather than `uname -n` to handle long hostnames properly

4. Add separation headers for 2 ioscans and add ioscan -kF

5. Fix get_mirror_missmatch.sh plugin to handle any names for VGs
   In the plugin, the code was:

      for i in /dev/vg*/lv*

   which will not handle non-standard naming conventions
   The replacement line (to handle any naming convention) is:

      for i in $(/usr/sbin/vgdisplay -v |grep "LV Name" |awk '{print $3}')

6. Modified plug_ins/check_space.sh by reducing redundant LVM and bdf calls, time reduced by 1/2

7. Changed ps|grep to UNIX95 ps -C exact_match
     exec_command "UNIX95= ps -f -C biod,nfsd" "NFSD and BIOD utilization"

   Removed export UNIX95=yes to prevent global side effects
   Added UNIX95= to the -Hef (hierarchical) listing

8. Replaced cat_and_grep with awk one-liner
   Replaced various grep -v ^#...etc with cat_and_grep

9. Changed osrev code, added osrevdot
     osrevdot=$(uname -r | cut -d. -f 2,3)	# 11.31
     osrev=$(echo $osrevdot | cut -d . -f1)	# 11
     osrev100=$(echo $osrevdot | tr -d ".")	# 1131

10. Added -T option to trace each command (exec_command) and show elapsed time.
    Modified paragraph() and exec_command() with CFG_TRACETINE

11. Removed the ISEE section and warning. It is not clear how to remove the services (swlist name?)



/* end */
