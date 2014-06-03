#!/bin/sh -- # Really perl
eval 'exec perl -S $0 ${1+"$@"} 2>/dev/null'
  if 0;

# Designed by:  Dusan U. Baljevic (dusan.baljevic@ieee.org)
# Coded by:     Dusan U. Baljevic (dusan.baljevic@ieee.org)

$ENV{'PATH'} = "/usr/bin:/usr/sbin:/sbin:/bin";

use strict;

my $psline       = q{};
my @userid       = ();
my @HEADLN       = ();
my @PSRUN        = (); 
my @PSLSLEEP     = (); 
my @PSUNINTWAIT  = (); 
my @PSSSLEEP     = (); 
my @PSSTOP       = (); 
my @PSLOCK       = (); 
my @PSPAGE       = (); 
my @PSPROC       = (); 
my @PSZOMBIE     = (); 
my @PSREST       = (); 
my $PSFLAG       = q{};

if ( open( KM, "ps augxww |" ) ) {
   while (<KM>) {
      $_ =~ s/\s+$//g;
      $psline = $_;
      chomp $psline;

      if ( $psline =~ /TIME.*CMD/ ) {
         @HEADLN = $psline;
      }
      else {
         @userid = split(/\s+/, $psline);
      }

      if ( $userid[7] =~ /^S/ ) {
         push(@PSSSLEEP, "$psline\n");
      }
      elsif ( $userid[7] =~ /^R/ ) {
         push(@PSRUN, "$psline\n");
      }
      elsif ( $userid[7] =~ /^T/ ) {
         push(@PSSTOP, "$psline\n");
      }
      elsif ( $userid[7] =~ /^W/ ) {
         push(@PSPAGE, "$psline\n");
      }
      elsif ( $userid[7] =~ /^D/ ) {
         push(@PSUNINTWAIT, "$psline\n");
      }
      elsif ( $userid[7] =~ /^I/ ) {
         push(@PSLSLEEP, "$psline\n");
      }
      elsif ( $userid[7] =~ /^L/ ) {
         push(@PSLOCK, "$psline\n");
      }
      elsif ( $userid[7] =~ /^Z/ ) {
         push(@PSZOMBIE, "$psline\n");
      }
      else {
         if ( "@userid" != 0 ) {
            push(@PSREST, "$psline\n");
         }
      }
   }
   close(KM);
}

if ( @PSSSLEEP ) {
   print "\nProcesses in interruptible sleep less than 20 seconds\n";
   print "@HEADLN\n";
   print @PSSSLEEP;
}

if ( @PSLSLEEP ) {
   print "\nProcesses in interruptible sleep longer than 20 seconds\n";
   print "@HEADLN\n";
   print @PSLSLEEP;
}

if ( @PSSTOP ) {
   print "\nStopped processes (job control or tracing)\n";
   print "@HEADLN\n";
   print @PSSTOP;
}

if ( @PSPAGE ) {
   print "\nProcesses in idle interrupt thread\n";
   print "@HEADLN\n";
   print @PSPAGE;
}

if ( @PSUNINTWAIT ) {
   print "\nProcesses in uninterruptible wait\n";
   print "@HEADLN\n";
   print @PSUNINTWAIT;
}

if ( @PSZOMBIE ) {
   print "\nDefunct (\"zombie\") processes\n";
   print "@HEADLN\n";
   print @PSZOMBIE;
}

if ( @PSLOCK ) {
   print "\nProcesses waiting to acquire a lock\n";
   print "@HEADLN\n";
   print @PSLOCK;
}

if ( @PSRUN ) {
   print "\nRunable processes (on run queue)\n";
   print "@HEADLN\n";
   print @PSRUN;
}

if ( "@PSREST" ) {
   print "\nProcesses in non-standard states\n";
   print "@HEADLN\n";
   print @PSREST;
}

exit(0);
