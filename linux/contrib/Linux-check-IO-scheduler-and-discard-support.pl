#!/usr/bin/env perl
#
# Description: Basic check if I/O scheduler and discard option on Linux servers
#              Results are displayed on stdout or redirected to a file
#
# Last Update:  13 June 2014
# Designed by:  Dusan U. Baljevic (dusan.baljevic@ieee.org)
# Coded by:     Dusan U. Baljevic (dusan.baljevic@ieee.org)
# 
# Copyright 2006-2014 Dusan Baljevic
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
# The script has been developed over several hectic days, so errors
# (although not planned) might exist. Please use with care.
# 
# There are not many comments throught the script and that
# is not best practices for writing good code. However,
# I view this script as a learning tool for system administrators
# too so lack of comments is partially left as an exercise.
#

$ENV{'PATH'} = "/bin:/usr/sbin:/sbin:/usr/bin:/usr/local/bin";

use strict;

my @lsblk = `lsblk -f 2>/dev/null`;
if ( "@lsblk" ) {
    print "INFO: File systems and raids\n";
    print @lsblk;
}

my @lsblkdet = `lsblk -t 2>/dev/null`;
if ( "@lsblkdet" ) {
    print "\nINFO: Block devices\n";
    print @lsblkdet;
}

my $DISKTYPE = q{};
my $DISCARD  = q{};

if ( open( LSBK, "lsblk -io KNAME,TYPE,SCHED,ROTA,DISC-GRAN,DISC-MAX |" ) ) {
    print "\nINFO: I/O elevator (scheduler) and discard support summary\n";
    while (<LSBK>) {
       next if ( grep( /^$/, $_ ) );
       chomp($_);
       my @LSLN = split( /\s+/, $_ );

       # Default Ubuntu virtual machine does not set scheduler:
       #
       # lsblk -io KNAME,TYPE,SCHED,ROTA,DISC-GRAN,DISC-MAX
       # KNAME TYPE SCHED    ROTA DISC-GRAN DISC-MAX
       # sr0   rom  deadline    1        0B       0B
       # vda   disk             1        0B       0B
       # vda1  part             1        0B       0B
       # vda2  part             1        0B       0B
       # vda5  part             1        0B       0B
       # dm-0  lvm              1        0B       0B
       # dm-1  lvm              1        0B       0B
       #
       # cat /sys/block/vda/queue/scheduler 
       # none
       #
       # ... which is different from SUSE 13:
       #
       # lsblk -io KNAME,TYPE,SCHED,ROTA,DISC-GRAN,DISC-MAX
       # KNAME TYPE SCHED ROTA DISC-GRAN DISC-MAX
       # sr0   rom  cfq      1        0B       0B
       # vda   disk cfq      1        0B       0B
       # vda1  part cfq      1        0B       0B
       # vda2  part cfq      1        0B       0B
       # dm-0  lvm           1        0B       0B
       # dm-1  lvm           1        0B       0B
       #
       # ... and Oracle Linux 6
       #
       # KNAME TYPE SCHED    ROTA DISC-GRAN DISC-MAX
       # sr0   rom  deadline    1        0B       0B
       # vda   disk deadline    1        0B       0B
       # vda1  part deadline    1        0B       0B
       # vda2  part deadline    1        0B       0B
       # dm-0  lvm              1        0B       0B
       # dm-1  lvm              1        0B       0B
 
       my $DTYPE = $LSLN[1];
       if ( "$DTYPE" eq "disk" ) {
           my $DISCMAX = $LSLN[$#LSLN];
           my $DISCGRAN = $LSLN[$#LSLN - 1];
           my $ROTATION = $LSLN[$#LSLN - 2];
           my $DNAME = $LSLN[0];
           my $DNAMECNF = "/sys/block/${DNAME}/queue/scheduler";
           my $SCHED = $LSLN[$#LSLN - 3];
           my $SCHED2 = q{};
           if ( "$ROTATION" == 0 ) {
               $DISKTYPE = "SSD";
           }
           else {
               $DISKTYPE = "Hard Disk";
           }

           if ( ("$DISCMAX" > 0) && ("$DISCGRAN" > 0) ) {
               $DISCARD = "supports discard operation";
           }
           else {
               $DISCARD = q{};
           }

           if ( "$SCHED" eq "disk" ) {
               $SCHED = "UNDEFINED";
               $SCHED2 = `cat $DNAMECNF 2>/dev/null`;
               chomp($SCHED2);
           }

           print "INFO: $DISKTYPE $DNAME configured with I/O scheduler \"$SCHED\" $DISCARD\n";
           if ( "$SCHED2" ) {
               print "INFO: $DNAMECNF contents: \"$SCHED2\"\n";
           }
        }
    }
    close(LSBK);
}

exit(0);
