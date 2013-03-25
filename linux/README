For details see cfg2html.html
@(#) $Header: /home/cvs/cfg2html/cfg2html_linux/README,v 2.12 2012-12-17 13:08:33 ralph Exp $


This is the READ ME for cfg2html-linux version 2.xx (c) by ROSE SWE, Dipl.-Ing. Ralph Roth

!! WARNING, USE the cfg2html-linux script AT YOUR OWN RISK !!
-------------------------------------------------------------


This text should be formatted in DOS/Windows CR/LF format that it can be
mailed (and read) with Windows mail programs!

This is the "Swiss army knife" for the Account Support Engineer, Customer
Engineer, Sysadmin etc. I wrote it to get the necessary information to plan
an update, to perform basic trouble shooting or performance analysis. As a
bonus cfg2html creates a nice HTML and plain ASCII documentation. If you are
missing something, let me know it!

cfg2html is a UNIX shell script similar to check_config or get_config,
except that it creates a HTML (and plain ASCII) system documentation for HP-
UX 10.xx/11.xx, SCO-UNIX, AIX, Sun OS and Linux systems. Plugins for SAP,
Oracle, Informix, MC/SG, FibreChannel, TIP/ix, Mass Storage like
XP48/256/512, Network Node Manager and DataProtector etc. are included.


 ___           _        _ _       _   _
|_ _|_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __
 | || '_ \/ __| __/ _` | | |/ _` | __| |/ _ \| '_ \
 | || | | \__ \ || (_| | | | (_| | |_| | (_) | | | |
|___|_| |_|___/\__\__,_|_|_|\__,_|\__|_|\___/|_| |_|
---------------------------------------------------------------------------

To install and to execute cfg2html you must be root! A normal user account
will not work!

tar ball: To install the script, edit the Makefile and type make install.
If you use the packages, read the man pages for dpkg or rpm to install.

On SLES/OpenSUSE

# zypper in cfg2html_linux-2.*.rpm

On the other RPM boxes where cfg2html is already installed do this:

# rpm -hiv cfg2html-linux-1.24-7.noarch.rpm
Preparing...                ########################################### [100%]
        file /usr/bin/cfg2html-linux from install of cfg2html-linux-1.24-7 conflicts with file from package cfg2html-linux-1.23-11
        file /usr/share/man/man8/cfg2html-linux.8.gz from install of cfg2html-linux-1.24-7 conflicts with file from package cfg2html-linux-1.23-11
# rpm -hiv --freshen cfg2html-linux-1.24-7.noarch.rpm
Preparing...                ########################################### [100%]
   1:cfg2html-linux         ########################################### [100%]

hklinx01:~/cfg> sudo rpm -hiv cfg2html-linux-1.74-1.noarch.rpm
Password:
Preparing...                ########################################### [100%]
        file /etc/cfg2html/plugins from install of cfg2html-linux-1.74-1 conflicts with file from package cfg2html-linux-1.61-2
        file /usr/bin/cfg2html from install of cfg2html-linux-1.74-1 conflicts with file from package cfg2html-linux-1.61-2
        file /usr/bin/cfg2html-linux from install of cfg2html-linux-1.74-1 conflicts with file from package cfg2html-linux-1.61-2
        file /usr/share/man/man8/cfg2html-linux.8.gz from install of cfg2html-linux-1.74-1 conflicts with file from package cfg2html-linux-1.61-2




 ____       _       _     _
|  _ \ __ _| |_ ___| |__ (_)_ __   __ _
| |_) / _` | __/ __| '_ \| | '_ \ / _` |
|  __/ (_| | || (__| | | | | | | | (_| |
|_|   \__,_|\__\___|_| |_|_|_| |_|\__, |
                                  |___/
------------------------------------------------------------------
Read this if you are a developer and interested in enhancing cfg2html!

OK, I fixed a bug and enhanced cfg2html, how do I make a diff for upstream
enhancement?

That is quite easy. First, get yourself GNU diff. The other diffs will work,
too, but this tutorial only applies to GNU diff. We want unified diffs!

   1. If you change cfg2html-linux, please mark your changes with for example
      # <name>. Do not forgot to remove all backup files from your editor.
   2. Rename the directory with your new, patched cfg2html-linux-x.xx to, say,
      cfg2html-linux-x.xx.patched
   3. Unpack the original distribution tar ball.
   4. Now type:

      cd cfg2html-linux-x.xx.patched
      make clean
      cd ..
      diff -uNr cfg2html-linux-x.xx cfg2html-linux-x.xx.patched | gzip -c \
       > cfg2html-linux-x.xx.diff.gz

      This is for GNU diff. You vendor's diff may not know the -u option, in
      which case you should try -c instead.
   5. Now send the compressed diff to my email address:
      cfg2hthml@hotmail.com (subject [cfg2html] + your text)


The "-u" creates a unified diff, which has 3 lines of context per default.
This has the advantage that patches can be applied to other versions of
cfg2html-linux, too.

The "-N" treats new files as empty. That means if you add a file, diff will
put it in the diff, too. This has the advantage that your file is not lost.
It has the disadvantage that "Makefile" and so on are put into the diff,
too. So for patches where you don't add new files, you can omit the "-N".

The "-r" means recursive. For cfg2html-linux this is only important if you change
stuff in subdirectories. But it is good habit to use it.

------------------------------------------------------------------------------

How to apply the Patches/Diffs?

	$ gunzip delta-1-14-3rar.gz
	$ patch -p0 < delta-1-14-3rar
	patching file cfg2html-linux-1.14/cfg2html-linux
	patching file cfg2html-linux-1.14/cfg2html_urls.html

 _____      _                 _
| ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
|  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
| |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
|_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/
---------------------------------------------------------------------------
cfg2html can be extended easily by writing small scripts and configuring them
as plugins in /etc/cfg2html/plugins.  You can do whatever you want in your
plugin and all of stdout will be included in the output file.

There are two rules you'll have to follow to make your script run as a plugin
within cfg2html:

1. Assign your desired paragraph title to a variable named CFG2HTML_PLUGINTITLE
2. Run all your program logic in a function called "cfg2html_plugin".

Examples of cfg2html plugins can be found in the contrib/plugins/ directory
of the cfg2html distribution.


 ____                       _ _
/ ___|  ___  ___ _   _ _ __(_) |_ _   _
\___ \ / _ \/ __| | | | '__| | __| | | |
 ___) |  __/ (__| |_| | |  | | |_| |_| |
|____/ \___|\___|\__,_|_|  |_|\__|\__, |
                                  |___/
---------------------------------------------------------------------------
For security reasons it is better to store the HTML and ASCII files
in a safe place where only root user have access. Then remove the
files from your file system.

  Usage: cfg2html_linux [OPTION]
  creates HTML and plain ASCII host documentation

  -o            set directory to write or use the environment
                variable OUTDIR="/path/to/dir" (directory must
                exist
  -v            output version information and exit
  -h            display this help and exit

  use the following options to disable collections:

  -s            disable: System
  -c            disable: Cron
  -S            disable: Software
  -f            disable: Filesystem
  -l            disable: LVM
  -k            disable: Kernel
  -e            disable: Enhancements
  -n            disable: Network
  -a            disable: Applications
  -H            disable: Hardware
  -x            don't create background images


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

-------------------------------------------------------------------

2.) Email: I do spam filtering with various tools, so put only me in the
"To:" field, not in the "CC:" or "BCC:" field! No Subjects and text that
could be flag by a rule based or fuzzy logic spam filter!

The email address is           	cfg2html@hotmail.com
Subject must begin with		[cfg2html]


 _____ _    ___      ____  __ _
|  ___/ \  / _ \    / /  \/  (_)___  ___
| |_ / _ \| | | |  / /| |\/| | / __|/ __|
|  _/ ___ \ |_| | / / | |  | | \__ \ (__
|_|/_/   \_\__\_\/_/  |_|  |_|_|___/\___|
---------------------------------------------------------------------------

ulmpc014:/tmp # rpm -hiv cfg2html-linux-1.18.3-1.noarch.rpm
error: failed dependencies:
        rpmlib(PayloadFilesHavePrefix) <= 4.0-1 is needed by cfg2html-linux-1.18.3-1
        rpmlib(CompressedFileNames) <= 3.0.4-1 is needed by cfg2html-linux-1.18.3-1
ulmpc014:/tmp # uname -a
Linux ulmpc014 2.2.14 #1 Mon Mar 13 10:51:48 GMT 2000 i686 unknown


Known Problems
--------------

Executing cfg2html
------------------

1.) If Firestarter is running, you may get long timeouts on the command iptables --list.
2.) what (1) is missing - please install the what command
3.) cfg2html-linux depends on bash. Don't execute cfg2html with sh ./cfg2html-linux

If cfg2html hangs
-----------------

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


Building cfg2html
-----------------

0.) sudo aptitude install alien fakeroot devscripts lintian gawk

1.) pack+go.sh
dh_builddeb
dpkg-deb: building package `cfg2html-linux' in `../cfg2html-linux_1.37-2_all.deb'.
tar: -: file name read contains nul character
 signfile cfg2html-linux_1.37-2.dsc
dpkg-genchanges



2.) Alien and the file: Copyright

error: Legacy syntax is unsupported: copyright
error: line 6: Unknown tag: Copyright: see /usr/share/doc/cfg2html-linux/copyright

Ralph: Changed: Copyright: xxx to License: xxx

--> But this didn't work either :-((

---
alien version 8.56
Linux ob5700ctx 2.6.16-1-486 #2 Fri May 5 04:53:12 UTC 2006 i586 GNU/Linux

/* end */
:wq!

 _____     ____
|_   _|__ |  _ \  ___
  | |/ _ \| | | |/ _ \
  | | (_) | |_| | (_) |
  |_|\___/|____/ \___/

---------------------------------------------------------------------------
Proliant (not Ubuntu)
sysinfo -a
