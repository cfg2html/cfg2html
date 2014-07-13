#!/usr/bin/env perl

# Program:     Linux-audit-account-password-hashing.pl
#
# Description: Linux account password hashing checks 
#              Results are displayed on stdout or can be redirected to a file
#
# If you obtain this script via Web, convert it to Unix format. For example:
# dos2unix -n Linux-audit-account-password-hashing.pl.txt Linux-audit-account-password-hashing.pl
#
# Last Update:  30 May 2014
# Designed by:  Dusan U. Baljevic (dusan.baljevic@ieee.org)
# Coded by:     Dusan U. Baljevic (dusan.baljevic@ieee.org)
# 
# Copyright 2014 Dusan Baljevic
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# The script has been developed over several hectic days, so errors
# (although not planned) might exist. Please use with care.

# Contrary to popular belief, the account password entries in /etc/shadow
# can have more than three "$" separators (hint: when one uses SHA256|512
# hashing and non-default number of rounds).

# Here are some examples of valid accounts on my CentOS 6.5 server:
#
# SHA256 hashing
#
# user1:$5$Y4HhzEPz$mXSHm95E/4MQPp.3X4Km5R/ysct0WT45FzdX2mPkon.:16156::::::
#
# SHA512 hashing account with non-default rounds
#
# user2:$6$rounds=85000$pA/kjrZS$wo0980kwEuE28ER6moiaHzuDqO/VZMoxfvbXK1i/cW2BdJjI8xH/1WgD7RH7UaxM1SDLYsPtPgiMF9orb1Iwi.:16156:0:99999:7:::
#
# SHA512 hashing account
#
# user3:$6$zgpfWfGc$ACfCZLTLeJzLhiC1gyO0Bj5JlD337zAW.L25FpYz07QalwRQJYAJ8AIFL69PxK2XwoDehTLzPT64AsrMUsL1o0:15955:0:99999:7:::
#
# MD5 hashing account
#
# user4:$1$6tAaCsfx$E2amS8ko4ks1lxz7izSL//:16156::::::
#
# Blowfish hashing account on Suse 11 
#
# user5:$2y$05$Z4taSkam70Vc9mMqtrAby25ixpstvJUf49gqzPtjhkscGgu4Zvd6c:15894:0:120:7:::
#
# I acknowledge contributions for testing on Suse servers by Ralph Roth
# of cfg2html fame.

#
# Define important environment variables
#
$ENV{'PATH'} = "/bin:/usr/sbin:/sbin:/usr/bin:/usr/local/bin";
$ENV{'PATH'} = "$ENV{PATH}:/usr/local/sbin";

# Define Shell
#
$ENV{'SHELL'} = '/bin/sh' if $ENV{'SHELL'} ne '';
$ENV{'IFS'}   = ''        if $ENV{'IFS'}   ne '';

use strict;

# Hashing algorithms
#
my %PWHASHARR = ( "1", "hashing-algorithm=MD5",
                 "2a", "hashing-algorithm=Blowfish-system-specific-handling-8bit-chars",
                 "2y", "hashing-algorithm=Blowfish-with-correct-handling-8bit-chars",
                 "5",  "hashing-algorithm=SHA-256",
                 "6",  "hashing-algorithm=SHA-512",
               );

# String lengths for encrypted part of the pasword string
#
my %PWLEN     = ( "1",  "22",
                  "2a", "53",
                  "2y", "53",
                  "5",  "43",
                  "6",  "86",
                );

my @entry           = ();
my $SHADOW          = "/etc/shadow";
my $SHADOWBCK       = "/etc/shadow-";
my @SHADOWDIFF      = (); 
my $passwdarr       = q{};
my $pwdhash         = q{};
my $LOGINDEFS       = '/etc/login.defs';
my $SUSEDEFPASSWD   = '/etc/default/passwd';
my $PAMDIR          = '/etc/pam.d';
my $UBUNTUDEFPASSWD = '${PAMDIR}/common-password';
my $AUDCONF         = '/etc/auditd.conf';
my $AUDCONF2        = '/etc/audit/auditd.conf';
if ( ! -s "$AUDCONF" ) {
    $AUDCONF = $AUDCONF2;
}

# String lengths for DES-encrypted pasword string
#
my $DESLENGTH       = 13;

if ( -s $SUSEDEFPASSWD ) {
    if ( open( sauthc, "awk NF $SUSEDEFPASSWD 2>/dev/null |" ) ) {
        print "\nINFO: Enabled features in configuration file $SUSEDEFPASSWD\n\n";
        while (<sauthc>) {
            print $_;
            chomp($_);
            if ( grep( /^CRYPT=/, $_ ) ) {
                $_ =~ s/^\s+//g;
                $_ =~ s/\s+$//g;
                my @pwdhash = split(/=/, $_);
                $pwdhash = $pwdhash[1];
            }
        }
        close(sauthc);
    }
}

if ( -s $UBUNTUDEFPASSWD ) {
    if ( open( uauthc, "awk NF $UBUNTUDEFPASSWD 2>/dev/null |" ) ) {
        print "\nINFO: Enabled features in configuration file $UBUNTUDEFPASSWD\n\n";
        while (<uauthc>) {
            print $_;
            chomp($_);
        }
        close(uauthc);
    }
}

if ( -s $LOGINDEFS ) {
    if ( open( lauthc, "awk NF $LOGINDEFS 2>/dev/null |" ) ) {
        print "\nINFO: Enabled features in configuration file $LOGINDEFS\n\n";
        while (<lauthc>) {
            print $_;
            chomp($_);
            if ( grep( /^ENCRYPT_METHOD/, $_ ) ) {
                $_ =~ s/^\s+//g;
                $_ =~ s/\s+$//g;
                my @pwdhash = split(/\s+/, $_);
                $pwdhash = $pwdhash[1];
            }
        }
        close(lauthc);
    }
}

if ( open( authc, "authconfig --test 2>/dev/null |" ) ) {
    print "\nINFO: Global system authentication resources\n";
    while (<authc>) {
        print $_;
        if ( grep( /hashing/, $_ ) ) {
            $_ =~ s/^\s+//g;
            $pwdhash = $_;
        }
    }
    close(authc);
}
else {
    print
"WARN: System authentication resources status unknown or command \"authconfig\" missing in this distribution\n";
}

if ( "$pwdhash" ) {
    print "\nINFO: Default password hashing\n";
    print "INFO: $pwdhash\n";
    print "NOTE: Minimum recommended password hashing is SHA512\n";
    print "NOTE: For different Linux distributions, one of following methods are used:

run \"authconfig --passalgo=sha512 --update\"\n";
    print "Set \"CRYPT=SHA512\" in \"$SUSEDEFPASSWD\"\n";
    print "Modify \"password\" line in \"$UBUNTUDEFPASSWD\" 
Set \"ENCRYPT_METHOD SHA512\" in \"$LOGINDEFS\"\n";
}

print "\nINFO Status of configuration files in $PAMDIR\n";
my @pamls = `ls ${PAMDIR}/* 2>/dev/null`;
foreach my $pcfg (@pamls) {
    chomp($pcfg);
    if ( -s $pcfg ) {
        print "\nINFO Configuration file $pcfg\n\n";
        my @psfg = `grep -v ^# $pcfg | awk NF`;
        print @psfg;
    }
}

my @pamcfg = `pam-config --list-modules 2>/dev/null`;
if ( "@pamcfg" ) {
    print "\nINFO List of supported PAM modules\n\n";
    print @pamcfg;
}

if ( -s $AUDCONF ) {
    my @audc = `awk NF $AUDCONF 2>/dev/null | grep -v ^#`;
    if ( "@audc" ) {
        print "\nINFO Auditing configuration file $AUDCONF\n\n";
        print @audc;
    }
}

my @aurep = `aureport 2>/dev/null | awk NF`;
if ( "@aurep" ) {
    print "\nINFO Audit daemon logs\n\n";
    print @aurep;
}

my @pwckr = `pwck -r 2>/dev/null`;
if ( "@pwckr" ) {
    print "\nINFO Password file report in read-only mode (\"pwck -r\")\n\n";
    print @pwckr;
}

my %shadiff;

if ( -s "$SHADOW" ) {
    open my $afile, "$SHADOW" or die "Couldn't open $SHADOW: $!";
    while (my $link = <$afile>) {
        chomp $link;
        $shadiff{$link} = undef;
    }
    close $afile;
}

if ( -s "$SHADOWBCK" ) {
    open my $bfile, "$SHADOWBCK" or die "Couldn't open $SHADOWBCK: $!";
    while (my $link = <$bfile>) {
        chomp $link;
        next if exists $shadiff{$link}; 
        push(@SHADOWDIFF, "$link\n");
    }
    close $bfile;
}

if ( "@SHADOWDIFF" ) {
    print "\nINFO: $SHADOW differs from backup file $SHADOWBCK";
    print "\nINFO: Offending entries in $SHADOW\n\n";
    print @SHADOWDIFF;
}

my @PASA = ();

print "\nINFO: Hashing algorithm per username:\n";
while ( @entry = getpwent ) {
    my @pwx = `passwd -S $entry[0] 2>&1 | awk NF`;
    push(@PASA, "@pwx");
   
    my $pwhash = q{}; 
    if ( grep(/^\$/, $entry[1]) ) { 
        my @passwdarr = split(/\$/, $entry[1]);
        $pwhash = $passwdarr[$#passwdarr];
        if ( $#passwdarr eq 3 ) {
            print
"\n$entry[0]: $PWHASHARR{$passwdarr[1]}, salt=$passwdarr[2], hashed-password-and-salt=$passwdarr[3]\n";
        } elsif ( $#passwdarr eq 4 ) {
            if ( $passwdarr[2] =~ /rounds=/ ) {
                print
"\nINFO Username $entry[0]: $PWHASHARR{$passwdarr[1]}, $passwdarr[2], salt=$passwdarr[3], hashed-password-and-salt=$passwdarr[4]\n";
            }
            elsif ( "$passwdarr[3]" eq "" ) {
                print
"\nINFO Username $entry[0]: $PWHASHARR{$passwdarr[1]}, salt=$passwdarr[2], hashed-password-and-salt=$passwdarr[4]\n";
            }
            else {
                print
"\nINFO Username $entry[0]: $PWHASHARR{$passwdarr[1]}, salt=$passwdarr[2], hashed-password-and-salt=$passwdarr[4]\n";
            }
        } else {
            print "\n$entry[0]:\n";
            foreach my $passent ( @passwdarr) {
                print "$passent ";
            }
            print "\n";
        }

        if ( length($passwdarr[$#passwdarr]) ne $PWLEN{$passwdarr[1]} ) {
            print
"ERROR: Incorrect length of encrypted password string for user \"$entry[0]\" (length($passwdarr[$#passwdarr]) versus $PWLEN{$passwdarr[1]})\n";
        } else {
            print
"PASS: Correct length of encrypted password string for user \"$entry[0]\" ($PWLEN{$passwdarr[1]} for $PWHASHARR{$passwdarr[1]})\n";
        }

        if ( ! ( $pwhash =~ /^[a-zA-Z0-9\.\/]+$/ ) ) { 
            print "ERROR: Invalid characters in hashed password string \"$pwhash\"\n";
        }
    } else {
        if ( $entry[1] eq "x" ) {
            print "\n$entry[0]: hashing-algorithm=UNDEFINED\n";
            my @pw2 = `passwd -S $entry[0] 2>&1 | awk NF`;
            if ( "@pw2" ) {
                print "INFO Full password entry status for \"$entry[0]\" via \"passwd -S\" command \n";
                print @pw2;
            }
        }
        else {
            if ( ! grep(/!|\*/, $entry[1]) ) { 
                print "\n$entry[0]: hashing-algorithm=DES\n";

                if ( length($entry[1]) ne $DESLENGTH ) {
                   print "ERROR: Incorrect length of encrypted password string for user $entry[0] (length($entry[1]) versus $DESLENGTH)\n";
                } else {
                   print "PASS: Correct length of encrypted password string for user $entry[0] ($DESLENGTH)\n";
                }
            } 
            $pwhash = $entry[1];
        }

        if ( $pwhash =~ /^[a-zA-Z0-9\.\/]/ ) {
            if ( ! ( $pwhash =~ /^[a-zA-Z0-9\.\/]+$/ ) ) { 
                print "ERROR: Invalid characters in hashed password string \"$pwhash\"\n";
             } else {
                print "PASS: Valid characters in hashed password string\n";
             }
        }
    }
}

my @pwdsa = `passwd -Sa 2>/dev/null`;
if ( "@pwdsa" ) {
    print "\nINFO Password status (\"passwd -Sa\")\n\n";
    print @pwdsa;
} 
else {
    if ( "@PASA" ) {
        print "\nINFO Password status (\"passwd -S\")\n\n";
        print @PASA;
    }
}
exit(0);
