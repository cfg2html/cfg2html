#!/usr/bin/env perl
#
# Description: Linux Cluster status verification
#              Results are displayed on stdout or redirected to a file
#
# Last Update:  13 February 2016
# Designed by:  Dusan U. Baljevic (dusan.baljevic@ieee.org)
# Coded by:     Dusan U. Baljevic (dusan.baljevic@ieee.org)
#
# Copyright 2009-2016 Dusan Baljevic
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# There are not many comments throught the script and that
# is not best practices for writing good code. However,
# I view this script as a learning tool for system administrators
# too so lack of comments is partially left as an exercise.
#
# Like all scripts and programs, this one will continue to
# change as our needs change.

# Define important environment variables
#
$ENV{'PATH'} = "/bin:/usr/sbin:/sbin:/usr/bin:/usr/local/bin";
$ENV{'PATH'} = "$ENV{PATH}:/usr/local/qs/bin:/opt/qs/bin:/etc/init.d";

# Define Shell
#
$ENV{'SHELL'} = '/bin/sh' if $ENV{'SHELL'} ne '';
$ENV{'IFS'}   = ''        if $ENV{'IFS'}   ne '';

use strict;

#use diagnostics;
#use warnings;

# Global variables
#
my $RACLCFG = '/etc/cluster/cluster.conf';
my $PVGconf = "/etc/lvm/lvm.conf";
my $INFOSTR = "INFO:";
my $WARNSTR = "WARN:";
my $PASSSTR = "PASS:";
my $ERRSTR = "FAIL:";
my @MYVGS   = ();
my @CMANA   = ();
my @MYCLUST = ();
my @LVarr   = ();
my @cmanarr = ();
my @pvlist  = ();
my @lvlist  = ();
my @mkqdisk = ();
my @qdsk    = ();
my $pvdisk  = q{};
my $maxpv   = q{};
my $curpv   = q{};
my %VGfpe   = ();
my %VGpes   = ();
my %MAXPV   = ();
my $pesize  = q{};
my $vgname  = q{};
my $lvdisk  = q{};
my $NODECNT = q{};
my $TOTVOTES = q{};
my @DNAMEARR = ();
my @LVMCFGARR = ();
my $THRESHOLD_MAX_PV = q{};
my $LOCKTYPE = q{};
my $LOCKLIB  = q{};
my $WAITLOCK = q{};
my $LOCKDIR  = q{};
my $THRESHOLD = q{};
my @cmannode = ();
my $vgformat = q{};
my @VGCHKARR = ();

my $Hostname2 = `hostname -s 2>/dev/null`;
chomp($Hostname2);

my $Hostname3 = q{};

my $VH = `uname -a 2>&1`;
my ( $System, $Hostname3, $Maj, undef, $Hardware, undef ) = split( /\s+/, $VH );
my $Version = $Maj;

my $Hostname = $Hostname2 || $Hostname3;

# Delay and count values for commands vmstat, ioscan, and sar...
#
my $ITERATIONS = 10;
my $DELAY      = 2;

# LVM Locking types
#
my %LVMLOCKARR = ( "0", "locking disabled (risk of corrupting metadata)",
                   "1", "locking mechanims is flock",
                   "2", "locking through provided through external locking_library",
                   "3", "Global File System (GFS) cluster-wide locking",
                   "4", "locking enforces read-only metadata",
               );

sub print_header {
   my $lline = shift;
   print "$lline\n";
   print "\n";
}

# Create syslog entry about Cluster checks
#
`clulog -s 5 "Brief Linux Cluster verification tests underway"`;

print_header("*** LOGICAL VOLUME MANAGER STATUS ***");

my @lsblk = `lsblk -f 2>/dev/null`;
if ( "@lsblk" ) {
    print "$INFOSTR File systems and raids\n";
    print @lsblk;
}

my @lsblkdet = `lsblk -t 2>/dev/null`;
if ( "@lsblkdet" ) {
    print "\n$INFOSTR: Block devices\n";
    print @lsblkdet;
}

my @lvscanv = `lvscan --version 2>/dev/null`;
if ( @lvscanv != 0 ) {
   print "\n$INFOSTR LVM summary\n";
   print @lvscanv;
}

my @VGCK = `vgck 2>/dev/null`;
if ( @VGCK != 0 ) {
   print "\n$WARNSTR LVM volume group metadata check\n";
}
else {
   print "\n$PASSSTR LVM volume group metadata check successful\n";
}

my @LVMDUMP = `lvm dumpconfig 2>/dev/null`;
if ( @LVMDUMP != 0 ) {
   print "\n$INFOSTR LVM dumpconfig\n";
   print @LVMDUMP;
}

my @VGS = `vgs 2>/dev/null`;
if ( @VGS != 0 ) {
   print "\n$INFOSTR LVM volume group status\n";
   print @VGS;
}

my @PVSCAN = `pvscan 2>/dev/null`;
if ( @PVSCAN != 0 ) {
   print "\n$INFOSTR LVM physical volume status\n";
   print @PVSCAN;
}

my @LVSCANALL = `lvs -o+seg_all 2>/dev/null | cat -s -`;
if ( @LVSCANALL != 0 ) {
   print "\n$INFOSTR LVM logical volume status\n";
   print @LVSCANALL;
}
else {
   my @LVSCANALL = `lvs 2>/dev/null | cat -s -`;
   print "\n$INFOSTR LVM logical volume status\n";
   print @LVSCANALL;
}

my @LVMDSCAN = `lvmdiskscan 2>/dev/null | cat -s -`;
if ( @LVMDSCAN != 0 ) {
   print "\n$INFOSTR LVM disk scan\n";
   print @LVMDSCAN;
}

if ( open( NN, "vgdisplay -vv --partial 2>/dev/null |" ) ) {
   print "\n$INFOSTR Volume group scan\n";
   while (<NN>) {
      print $_;
      chomp;
      if ( grep( /VG Name/, $_ ) ) {
         $_ =~ s/^\s+//g;
         ( undef, undef, $vgname ) = split( /\s+/, $_ );
         chomp($vgname);
         if ( ! grep(/\Q$vgname\E/, @MYVGS ) ) {
            push(@MYVGS, $vgname);
         }
         undef $VGfpe{$vgname};
         undef $VGpes{$vgname};
      }

      if ( grep( /Format/, $_ ) ) {
         $_ =~ s/^\s+//g;
         ( undef, $vgformat ) = split( /\s+/, $_ );
         chomp($vgformat);
      }

      if ( grep( /Max PV/, $_ ) ) {
         $_ =~ s/^\s+//g;
         ( undef, undef, $maxpv ) = split( /\s+/, $_ );
         chomp($maxpv);
         $MAXPV{$vgname} = $maxpv;
         if ( $vgformat eq "lvm2" ) {
            if ( $maxpv == 0 ) {
               push( @VGCHKARR, "$PASSSTR Max PV not limited for lvm2 volume group $vgname\n");
            }
         }
         else {
            if ( $maxpv < $THRESHOLD_MAX_PV ) {
               push( @VGCHKARR, "$WARNSTR Max PV ($maxpv) below the threshold ($THRESHOLD_MAX_PV) for volume group $vgname\n");
            }
            else {
               push( @VGCHKARR, "$PASSSTR Max PV ($maxpv) satisfies the threshold (minimum $THRESHOLD_MAX_PV) for volume group $vgname\n");
           }
        }
     }

     if ( grep( /Cur PV/, $_ ) ) {
        $_ =~ s/^\s+//g;
        ( undef, undef, $curpv ) = split( /\s+/, $_ );
        chomp($curpv);

        if ( $vgformat ne "lvm2" ) {
           my $pvthresh = int( $curpv / $maxpv ) * 100;
           if ( $curpv == $maxpv ) {
              push( @VGCHKARR, "$ERRSTR Current PV ($curpv) reached Max PV threshold in volume group $vgname\n");
           }
           elsif ( $pvthresh == $THRESHOLD ) {
              push( @VGCHKARR, "$WARNSTR Current PV ($curpv) reached 90% of Max PV ($maxpv) in volume group $vgname\n");
           }
           elsif ( $pvthresh > $THRESHOLD ) {
              push( @VGCHKARR, "$WARNSTR Current PV ($curpv) exceeds 90% of Max PV ($maxpv) in volume group $vgname\n");
           }
           else {
              push( @VGCHKARR, "$PASSSTR Current PV ($curpv) below 90% of Max PV ($maxpv) in volume group $vgname\n");
          }
       }
    }

    if ( grep( /VG Status/, $_ ) ) {
       $_ =~ s/^\s+//g;
       ( undef, undef, my $vgstat ) = split( /\s+/, $_ );
       chomp($vgstat);
       if ( $vgstat eq "resizable" ) {
          push( @VGCHKARR, "$PASSSTR Volume group $vgname is resizable\n");
       }
       else {
          push( @VGCHKARR, "$WARNSTR Volume group is not resizable\n");
       }
    }

    if ( grep( /^Free  PE|Free PE/, $_ ) ) {
       $_ =~ s/^\s+//g;
       ( undef, undef, my $freepe2 ) = split( /\//, $_ );
       $freepe2 =~ s/^\s+//g;
       $freepe2 =~ s/\s+$//g;
       ( undef, my $freepe ) = split( /\s+/, $_ );
       chomp($freepe);
       if ( $freepe == 0 ) {
          push( @VGCHKARR, "$ERRSTR No free PEs available in volume group $vgname\n");
       }
       else {
          push( @VGCHKARR, "$PASSSTR $freepe free PEs available in volume group $vgname\n");
       }
       $VGfpe{$vgname} = $freepe;
    }

    if ( grep( /^PE Size/, $_ ) ) {
       $_ =~ s/^\s+//g;
       ( undef, undef, $pesize, undef ) = split( /\s+/, $_ );
       chomp($pesize);
       $VGpes{$vgname} = $pesize;
    }

    if ( grep( /PV Name/, $_ ) ) {
       $_ =~ s/^\s+//g;
       ( undef, undef, $pvdisk ) = split( /\s+/, $_ );
       if ( !grep( /\Q$pvdisk\E/, @pvlist ) ) {
          push( @pvlist, $pvdisk );
       }
    }

    if ( grep( /LV Name/, $_ ) ) {
       $_ =~ s/^\s+//g;
       push( @LVarr, "$_\n" );
       ( undef, undef, $lvdisk ) = split( /\s+/, $_ );
       push( @lvlist, $lvdisk );
    }

    if ( grep( /LV Status/, $_ ) ) {
       $_ =~ s/^\s+//g;
       push( @LVarr, "$_\n" );
    }

    if ( grep( /LV Size/, $_ ) ) {
       $_ =~ s/^\s+//g;
       push( @LVarr, "$_\n" );
    }

    if ( grep( /Current LE/, $_ ) ) {
       $_ =~ s/^\s+//g;
       push( @LVarr, "$_\n" );
    }

    if ( grep( /Allocated PE/, $_ ) ) {
       $_ =~ s/^\s+//g;
       push( @LVarr, "$_\n" );
    }

    if ( grep( /Used PV/, $_ ) ) {
       $_ =~ s/^\s+//g;
       push( @LVarr, "$_\n" );
    }
  }
  close(NN);

   if ( @VGCHKARR ) {
      print @VGCHKARR;
   }
  foreach my $vgnn ( @MYVGS ) {
  my @vgcfgr = `vgcfgrestore -l $vgnn 2>/dev/null | cat -s -`;
     if ( "@vgcfgr" ) {
        print "\n$INFOSTR vgcfgrestore status for volume group $vgnn\n";
        print @vgcfgr;
     }
     else {
        print "\n$WARNSTR Unknown vgcfgrestore status for volume group $vgnn\n";
     }
  }
}
else {
   print "$WARNSTR Cannot run vgdisplay\n";
}

print_header("*** GLOBAL FILE SYSTEM (GFS) STATUS ***");

my @gfstool  = `gfs_tool list 2>/dev/null`;
my @gfstool2 = `gfs2_tool list 2>/dev/null`;
my @gfssvc   = `service gfs status 2>/dev/null`;
my @gfssvc2  = `service gfs2 status 2>/dev/null`;
my @mline    = ();
my $fsreal   = q{};
my $fsdev    = q{};
my $fstype   = q{};
my @GFSARR   = ();
my @GFS2ARR  = ();
my @GFSDEVARR  = ();
my @GFS2DEVARR = ();

if ( open( MM, "mount | sort |" ) ) {
   while (<MM>) {
      next if ( grep( /^$/, $_ ) );
      chomp($_);
      @mline = split(/\s+/, $_);
      $fsreal = $mline[2];
      $fsdev = $mline[0];
      $fstype = $mline[4];
      if ( $fstype eq "gfs" )  {
         push( @GFSARR, $fsreal );
         push( @GFSDEVARR, $fsdev );
      }
      else {
         if ( $fstype eq "gfs2" )  {
            push( @GFS2ARR, $fsreal );
            push( @GFS2DEVARR, $fsdev );
         }
      }
   }
   close(MM);
}

if (@gfstool) {
   print "$INFOSTR GFS file system listing\n";
   print @gfstool;

   my @gfstooldf  = `gfs_tool df 2>/dev/null`;
   if (@gfstooldf) {
      print "\n$INFOSTR GFS file system status\n";
      print @gfstooldf;
   }

   foreach my $gfsfs ( @GFSARR ) {
      my @gfstoolext  = `gfs_tool gettune $gfsfs 2>/dev/null`;
      if (@gfstoolext) {
         print "\n$INFOSTR GFS file system $gfsfs tunables\n";
         print @gfstoolext;
      }

      my @gfstoolcnt  = `gfs_tool counters $gfsfs 2>/dev/null`;
      if (@gfstoolcnt) {
         print "\n$INFOSTR GFS file system $gfsfs counters\n";
         print @gfstoolcnt;
      }
   }

   foreach my $gfsdev ( @GFSDEVARR ) {
      my @gfsdevchk  = `gfs2_edit -p sb inum statfs master $gfsdev 2>/dev/null`;
      if (@gfsdevchk) {
         print "\n$INFOSTR GFS device $gfsdev selected internal structures\n";
         print @gfsdevchk;
      }
   }

   if (@gfssvc) {
      print "\n$INFOSTR GFS service status\n";
      print @gfssvc;
   }
}
else {
   print "$INFOSTR GFS not installed or unused on local node\n";
}

if (@gfstool2) {
   print "$INFOSTR GFS2 file system listing\n";
   print @gfstool2;

   my @gfstooldf2  = `gfs2_tool df 2>/dev/null`;
   if (@gfstooldf2) {
      print "\n$INFOSTR GFS2 file system status\n";
      print @gfstooldf2;
   }

   foreach my $gfs2fs ( @GFS2ARR ) {
      my @gfstool2ext  = `gfs2_tool gettune $gfs2fs 2>/dev/null`;
      if (@gfstool2ext) {
         print "\n$INFOSTR GFS2 file system $gfs2fs tunables\n";
         print @gfstool2ext;
      }
   }

   foreach my $gfs2dev ( @GFS2DEVARR ) {
      my @gfs2devchk  = `gfs2_edit -p sb inum statfs master $gfs2dev 2>/dev/null`;
      if (@gfs2devchk) {
         print "\n$INFOSTR GFS2 device $gfs2dev selected internal structures\n";
         print @gfs2devchk;
      }
   }

   if (@gfssvc2) {
      print "\n$INFOSTR GFS2 service status\n";
      print @gfssvc2;
   }
}
else {
   print "$INFOSTR GFS2 not installed or unused on local node\n";
}

print "\n";
print_header("*** SYSTEM PERFORMANCE STATUS ON CURRENT NODE ***");

my @USED = `free -t`;
print @USED;

my @pcpu = `ps -e -o pcpu,cpu,nice,state,cputime,args --sort -pcpu 2>/dev/null`;
if ( "@pcpu" ) {
   print "\n$INFOSTR List processes by CPU activity\n";
   print @pcpu;
}

my @cpupoweri = `cpupower idle-info 2>/dev/null`;
if ( "@cpupoweri" ) {
   print "\n$INFOSTR CPU idle kernel information\n";
   print @cpupoweri;
}

my @pmem = `ps -e -o rss,args --sort -rss | pr -TW\$COLUMNS 2>/dev/null`;
if ( "@pmem" ) {
   print "\n$INFOSTR List processes by memory usage\n";
   print @pmem;
}
else {
   @pmem = `ps aux --sort pmem 2>/dev/null`;
   if ( "@pmem" ) {
      print "\n$INFOSTR List processes by memory usage\n";
      print @pmem;
   }
}

my @TOP = `top -n 1 2>/dev/null`;
if ( "@TOP" ) {
   print "\n$INFOSTR Top activity\n";
   print @TOP;
}

my @VMSTATS = `vmstat -s 2>/dev/null`;
if ( "@VMSTATS" ) {
   print "\n$INFOSTR Virtual memory counters\n";
   print @VMSTATS;
}

my @AASTAT = `aa-status 2>/dev/null`;
if ( "@AASTAT" ) {
   print "\n$INFOSTR Programs confined to limited set of resources in AppArmor\n";
   print @AASTAT;
}

my @VMSTAT = `vmstat $DELAY $ITERATIONS 2>/dev/null`;
if ( "@VMSTAT" ) {
   print "\n$INFOSTR Virtual memory statistics\n";
   print @VMSTAT;
}

my @SARD = `sar -d $DELAY $ITERATIONS 2>/dev/null`;
if ( "@SARD" ) {
   print "\n$INFOSTR SA Disk activity\n";
   print @SARD;
}

my @IOSTATD = `iostat -dxNhtz $DELAY $ITERATIONS 2>/dev/null`;
if ( "@IOSTATD" ) {
   print @IOSTATD;
}

my @MPSTAT = `mpstat -P ALL $DELAY $ITERATIONS 2>/dev/null`;
if ( "@MPSTAT" ) {
   print @MPSTAT;
   print "\n";
}

print_header("*** LINUX CLUSTER STATUS ***");

if ( -s $PVGconf ) {
   if ( open( PVGC, "awk NF $PVGconf 2>/dev/null |" ) ) {
      print "$INFOSTR LVM configuration file $PVGconf\n";
      while (<PVGC>) {
         next if ( grep( /#/, $_ ) );
         print $_;
         $_ =~ s/^\s+//g;
         $_ =~ s/\s+$//g;

         if ( grep(/locking_type/i, $_ ) ) {
            ( undef, $LOCKTYPE ) = split( /=/, $_ );
            $LOCKTYPE =~ s/^\s+//g;
            $LOCKTYPE =~ s/\s+$//g;
            push(@LVMCFGARR, "\n$INFOSTR LVM \"locking_type\" is $LOCKTYPE ($LVMLOCKARR{$LOCKTYPE})\n");
         }

         if ( grep(/wait_for_locks/i, $_ ) ) {
            ( undef, $WAITLOCK ) = split( /=/, $_ );
            $WAITLOCK =~ s/^\s+//g;
            $WAITLOCK =~ s/\s+$//g;
            if ( "$WAITLOCK" eq 1 ) {
               push(@LVMCFGARR, "\n$INFOSTR LVM tools wait if a lock request cannot be satisifed immediately (\"wait_for_locks\" set to $WAITLOCK)\n");
            }
            else {
               if ( "$WAITLOCK" eq 0 ) {
                  push(@LVMCFGARR, "\n$INFOSTR LVM tools abort operation if a lock request cannot be satisifed immediately (\"wait_for_locks\" set to $WAITLOCK)\n");
               }
            }
         }

         if ( grep(/locking_library/i, $_ ) ) {
            ( undef, $LOCKLIB ) = split( /=/, $_ );
            $LOCKLIB =~ s/^\s+//g;
            $LOCKLIB =~ s/\s+$//g;
            $LOCKLIB =~ s/"//g;
            if ( "$LOCKTYPE" eq 2 ) {
               if ( "$LOCKLIB" ) {
                  push(@LVMCFGARR, "\n$INFOSTR LVM \"locking_library\" set to $LOCKTYPE\n");
               }
            }
         }

         if ( "$LOCKTYPE" eq 1 ) {
            if ( grep(/locking_dir/i, $_ ) ) {
               ( undef, $LOCKDIR ) = split( /=/, $_ );
               $LOCKDIR =~ s/^\s+//g;
               $LOCKDIR =~ s/\s+$//g;
               $LOCKDIR =~ s/"//g;
               if ( -d "$LOCKDIR" ) {
                  push(@LVMCFGARR, "\n$INFOSTR LVM \"lock_dir\" $LOCKDIR exists\n");
               }
               else {
                  push(@LVMCFGARR, "\n$WARNSTR LVM \"lock_dir\" $LOCKDIR does not exist\n");
               }
            }
         }
      }
      close(PVGC);
   }
   else {
      print "\n$INFOSTR $PVGconf cannot be opened\n";
   }
}

if ( @LVMCFGARR ) {
   print @LVMCFGARR;
}

if ( -s $RACLCFG ) {
   if ( open( FROM, "awk NF $RACLCFG 2>/dev/null |" ) ) {
      print "\n$INFOSTR Cluster configuration file $RACLCFG\n";
      while (<FROM>) {
         next if ( grep( /#/, $_ ) );
         print $_;
      }
      close(FROM);
   }
   else {
      print "\n$INFOSTR $RACLCFG cannot be opened\n";
   }
}
else {
   print "\n$INFOSTR $RACLCFG does not exist or empty\n";
}

my @clustat = `clustat 2>/dev/null | awk NF`;
if ( @clustat ) {
   print "\n$INFOSTR Linux Cluster status\n";
   print @clustat;
}

my @clusval = `ccs_config_validate 2>/dev/null`;
if ( @clusval ) {
   print "\n$INFOSTR Linux Cluster configuration validation\n";
   print @clusval;
}

my @FENCECAP = `ccs -h localhost --lsfenceopts 2>/dev/null`;
if ( @FENCECAP ) {
   print "\n$INFOSTR Linux Cluster fence device options on local node\n";
   print @FENCECAP;
}

if ( open( CMANC, "cman_tool status 2>/dev/null |" ) ) {
   while (<CMANC>) {
      next if ( grep( /#/, $_ ) );
      push(@MYCLUST, $_);
      $_ =~ s/^\s+//g;
      $_ =~ s/\s+$//g;
      if ( grep(/^Nodes:/i, $_ ) ) {
         ( undef, $NODECNT ) = split( /:/, $_ );
         $NODECNT =~ s/^\s+//g;
         $NODECNT =~ s/\s+$//g;
      }

      if ( grep(/^Total votes:/i, $_ ) ) {
         ( undef, $TOTVOTES ) = split( /:/, $_ );
         $TOTVOTES =~ s/^\s+//g;
         $TOTVOTES =~ s/\s+$//g;
      }
   }
   close(CMANC);
}

my @CMANVER = `cman_tool version 2>/dev/null`;
if ( @CMANVER ) {
   print "\n$INFOSTR Linux Cluster version\n";
   print @CMANVER;
}

my @CMANSER = `cman_tool services 2>/dev/null`;
if ( @CMANSER ) {
   print "\n$INFOSTR Linux Cluster services\n";
   print @CMANSER;
}

if ( "@MYCLUST" ) {
   print "\n$INFOSTR Linux Cluster vote status\n";
   print @MYCLUST;
}

my @CHKCONF = `ccs -h localhost --checkconf 2>/dev/null`;
if ( @CHKCONF ) {
   print "\n$INFOSTR Linux Cluster check configuration\n";
   print @CHKCONF;
}

if ( "$NODECNT" eq 1 ) {
   printf "\n$ERRSTR Linux Cluster has 1 node (there is no redundancy in services)\n";
}

if ( "$NODECNT" eq 2 ) {
   printf "\n$WARNSTR Linux Cluster has %s node%s (recommended to set up Quorum Disk in addition to fencing)\n", $NODECNT, $NODECNT == 1 ? "" : "s";
}

if ( "$TOTVOTES" lt "$NODECNT" ) {
   print "\n$WARNSTR Linux Cluster has less votes that number of nodes ($TOTVOTES and $NODECNT respectively)\n";
   print "$INFOSTR Best practice recommends at least one vote for each node\n";
}

if ( open( CMANC, "mkqdisk -L 2>/dev/null | awk NF |" ) ) {
   while (<CMANC>) {
      push(@mkqdisk, $_);
      $_ =~ s/^\s+//g;
      $_ =~ s/\s+$//g;
      if ( grep(/^\//, $_ ) ) {
         chomp($_);
         $_ =~ s/://g;
         @qdsk = split( /\//, $_ );
         my @DNAME = `lsblk -io KNAME,TYPE,SCHED,ROTA,DISC-GRAN,DISC-MAX | grep "^$qdsk[$#qdsk]"`;
         if ( "@DNAME" ) {
            push(@DNAMEARR, @DNAME);
         }
      }
   }
}

if ( @mkqdisk ) {
   print "\n$INFOSTR Linux Cluster lock disk status\n";
   print @mkqdisk;

   if ( @DNAMEARR ) {
      print "\n$INFOSTR Linux Cluster lock disk IO elevator\n";
      print "\n$INFOSTR Recommended to use \"deadline\" scheduler or \cfq\" scheduler with realtime priority (ionice -c 1 -n 0 -p \`pidof qdiskd\`)\n";
      print @DNAMEARR;
   }
}

my @ccstooll = `ccs_tool lsnode 2>/dev/null | awk NF`;
if ( @ccstooll ) {
   print "\n$INFOSTR Linux Cluster node status\n";
   print @ccstooll;
}

my @ccstoolf = `ccs_tool lsfence 2>/dev/null`;
if ( @ccstoolf ) {
   print "\n$INFOSTR Linux Cluster fence device status\n";
   print @ccstoolf;

   my @fencearr = grep { !(/Name.*Agent/) } @ccstoolf;
   if ( ! @fencearr ) {
      print "\n$ERRSTR Linux Cluster has no fence devices\n";
   }
}

my @grouptool = `group_tool ls 2>/dev/null | awk NF`;
if ( @grouptool ) {
   print "\n$INFOSTR Linux Cluster fence group status\n";
   print @grouptool;
}

my @victim = grep(/victim/, @grouptool);
if ( @victim ) {
   print "\n$INFOSTR Linux Cluster victim status\n";
   print @victim;
}

my @wait = grep(/wait state|change/, @grouptool);
if ( @wait ) {
   print "\n$INFOSTR Linux Cluster wait and change summary\n";
   print @wait;
}

if ( open( CMANC, "cman_tool nodes 2>/dev/null |" ) ) {
   while (<CMANC>) {
      push(@cmannode, $_);
      chomp($_);
      $_ =~ s/^\s+//g;
      $_ =~ s/\s+$//g;
      @cmanarr = split( /\s+/, $_ );
      if ( $cmanarr[1] eq "X" ) {
         push(@CMANA, "$WARNSTR Node $cmanarr[$#cmanarr] is not a member of the cluster\n");
      }
      elsif ( $cmanarr[1] eq "d" ) {
         push(@CMANA, "$WARNSTR Node $cmanarr[$#cmanarr] is a member of the cluster but access to it is disallowed\n");
      }
      else {
         if ( $cmanarr[1] eq "M" ) {
            push(@CMANA, "$PASSSTR Node $cmanarr[$#cmanarr] is an active member of the cluster\n");
         }
      }
   }
}

if ( @cmannode ) {
   print "\n$INFOSTR Linux Cluster nodes and last time each was fenced\n";
   print @cmannode;
}

if ( ! grep(/$Hostname.*fence*/i, @ccstooll) ) {
   my @clusvcadm = `clusvcadm -S 2>/dev/null`;
   if ( @clusvcadm ) {
      print "\n$INFOSTR Linux Cluster lock state\n";
      print @clusvcadm;
   }
}

if ( @CMANA ) {
   print "\n$INFOSTR Linux Cluster nodes membership status\n";
   print @CMANA;
}

exit(0);