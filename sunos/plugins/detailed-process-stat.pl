#!/bin/sh -- # Really perl
eval 'exec perl -S $0 ${1+"$@"} 2>/dev/null'
  if 0;

# Designed by:  Dusan U. Baljevic (dusan.baljevic@ieee.org)
# Coded by:     Dusan U. Baljevic (dusan.baljevic@ieee.org)

$ENV{'PATH'} = "/usr/bin:/usr/sbin:/sbin:/bin";

use strict;

my $psline   = q{};
my @userid   = ();
my @HEADLN   = ();
my @PSRUN    = (); 
my @PSSLEEP  = (); 
my @PSSTOP   = (); 
my @PSPAGE   = (); 
my @PSPROC   = (); 
my @PSZOMBIE = (); 
my @PSREST   = (); 
my $PSFLAG   = q{};
my $Hostname = q{};
my $Maj      = q{};
my $Version  = q{};
my $Major    = q{};
my $Minor    = q{};

if ( eval "require POSIX" ) {
   import POSIX 'uname';
   import POSIX qw(locale_h);
   ( undef, $Hostname, $Maj, $Version, undef ) = uname();
   if ("$Maj") {
      ( $Major, $Minor, undef ) = split( /\./, $Maj );
   }
}

if ( !"$Hostname" ) {
    my $VH = `uname -a 2>&1`;
    ( undef, $Hostname, $Maj, undef, undef, undef ) =
      split( /\s+/, $VH );
    $Version = $Maj;
    ( $Major, $Minor, undef ) = split( /\./, $Maj );
}

if ( "$Minor" >= 10 ) {
   $PSFLAG="Z";
}

if ( open( KM, "ps -efl${PSFLAG} |" ) ) {
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

      if ( $userid[2] =~ /^S/ ) {
         push(@PSSLEEP, "$psline\n");
      }
      elsif ( $userid[2] =~ /^R/ ) {
         push(@PSRUN, "$psline\n");
      }
      elsif ( $userid[2] =~ /^T/ ) {
         push(@PSSTOP, "$psline\n");
      }
      elsif ( $userid[2] =~ /^W/ ) {
         push(@PSPAGE, "$psline\n");
      }
      elsif ( $userid[2] =~ /^O/ ) {
         push(@PSPROC, "$psline\n");
      }
      elsif ( $userid[2] =~ /^Z/ ) {
         push(@PSZOMBIE, "$psline\n");
      }
      else {
         if ( "@userid" != 0 ) {
            push(@PSREST, "$psline\n");
         }
      }

      if ( "$Minor" >= 10 ) {
         if( $userid[4] =~ /^[0-9]+$/ ) {
            print "WARN: Process \"$psline\" without owner defined in password database (\"$userid[4]\")\n";
         }
      }
      else {
         if( $userid[3] =~ /^[0-9]+$/ ) {
            print "WARN: Process \"$psline\" without owner defined in password database (\"$userid[3]\")\n";
         }
      }
   }
   close(KM);
}

if ( @PSSLEEP ) {
   print "Processes in interruptible sleep\n";
   print "@HEADLN\n";
   print @PSSLEEP;
   print "\n";
}

if ( @PSSTOP ) {
   print "Stopped processes (job control or tracing)\n";
   print "@HEADLN\n";
   print @PSSTOP;
   print "\n";
}

if ( @PSPAGE ) {
   print "Processes waiting for CPU usage to drop to CPU-caps enforced limits\n";
   print "@HEADLN\n";
   print @PSPAGE;
   print "\n";
}

if ( @PSPROC ) {
   print "Processes running on a processor\n";
   print "@HEADLN\n";
   print @PSPROC;
   print "\n";
}

if ( @PSZOMBIE ) {
   print "Defunct (\"zombie\") processes\n";
   print "@HEADLN\n";
   print @PSZOMBIE;
   print "\n";
}

if ( @PSRUN ) {
   print "Runable processes (on run queue)\n";
   print "@HEADLN\n";
   print @PSRUN;
   print "\n";
}

if ( "@PSREST" ) {
   print "Processes in non-standard states\n";
   print "@HEADLN\n";
   print @PSREST;
}

exit(0);
