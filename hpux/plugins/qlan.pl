
# @(#) $Id: qlan.pl,v 5.1 2011-09-01 12:52:47 ralproth Exp $
# ---------------------------------------------------------------------------
# Will be made obsolete with the 6.xx stream. Will be replaced by nwmgr(1m)
# ---------------------------------------------------------------------------
# http://hpindkb.cup.hp.com/FAST-ETHERNETS/home/products/qlan.fe




#================================================
# get command line args
#================================================
for (@ARGV) {
   $args{$_} = 1;
}

#================================================
# display usuage
#================================================
if ($args{"-h"} == 1) {
    print "qlan version $Revision: 5.1 $ -- prototype lan tool\n";  ## 0.5p3
    print "Usage:   qlan [-h | -v] [interface | ppa | nmid]...\n";
    print "Default: prints terse info for all driver claimed interfaces\n\n";
    print "h\tDisplays this screen\n";
    print "v\tDisplays verbose mode\n";
    print "\nTo save output to a file type:\n";
    print "\tqlan -v >qlan.out\n";
    print "\nPlease send feedback to qlan-feedback\@hpindkb.cup.hp.com\n";
    exit;
}

#================================================
# set the ouput format - default label
#================================================
format STDOUT_label =
Hardware       Station
Path           Address        HW     Interface   @||| Driver    IP
                                                 $ppa
.

#================================================
# set the ouput format - default
#================================================
format STDOUT =
@<<<<<<<<<<<<< @<<<<<<<<<<<<< @<<< @>>>>>>> @<<< @||| @<<<<<<<< @<<<<<<<<<<<<<<
$hwpath,       $mac,     $hwstate, $iface,  $lanstate, $id, $driver, $inet
.

#================================================
# set the ouput format - verbose
#================================================
format STDOUT_verbose =
==================================@|||||||======================================
                                  $iface
Hardware Information:
    HW Path  : @<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<    : @<<<<<<<<<<<<<<<<<<<<<<<<<<
               $hwpath,                    $ppa,     $id
    MAC      : @<<<<<<<<<<<<<<<<<<<<<<<<<< HW State: @<<<<<<<<<<<<<<<<<<<<<<<<<<
               $mac,                                 $hwstate
    Desc     : @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
               $desc

IP Information:
    IP addr  : @<<<<<<<<<<<<<<<<<<<<<<<<<< SW State: @<<<<<<<<<<<<<<<<<<<<<<<<<<
               $inet,                                $lanstate
    Netmask  : @<<<<<<<<<<<<<<<<<<<<<<<<<< Ipkts   : @<<<<<<<<<<<<<<<<<<<<<<<<<<
               $netmask,                             $ipkts
    Broadcast: @<<<<<<<<<<<<<<<<<<<<<<<<<< Opkts   : @<<<<<<<<<<<<<<<<<<<<<<<<<<
               $broadcast,                           $opkts
    MTU      : @<<<<<<<<<<<<<<<<<<<<<<<<<<
               $mtu

Driver Information:
    Driver   : @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
               $driver
    Type     : @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
               $type
    Version  : @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
               $version

Technology Specific:
.

#================================================
# set the display format
#================================================
if ($args{"-v"} == 1) {
    $~ = "STDOUT_verbose";
    $#ARGV--;
}else {
    $^ = "STDOUT_label";
}

#================================================
# add /usr/sbin to the path -- temporary change
#================================================
$ENV{PATH} = "/usr/sbin:".$ENV{PATH};

#================================================
# get the OS version
# we need to know this because their are differences
# in the output of some commands depending on the OS
#================================================
if (!(open (UNAME, "uname -r |"))){
    die "Can't open uname -- maybe it's not in your path?\n";
}
getc UNAME;
getc UNAME;
$os = <UNAME>;

if ($os == 10.20) {
    $nmid_ppa = 6;
    $ppa = "NMID";
    $opktsIndex = 6;
    $netstatSize = 9;
}else {
    if ($os == 11.00 || $os == 11.10 || $os == 11.11 || $os == 11.23 || $os == 11.31) {
        $nmid_ppa = 2;
        $ppa = "PPA";
        $opktsIndex = 5;
        $netstatSize = 6;
    }else { chomp $os; print "Unsupported OS Release ($os)!\n"; exit; } ## Unsupported OS Release (7.9(0.237/5/3))!
}

#================================================
# read output from lanscan
#================================================
if (!(open (LANSCAN, "lanscan |"))){
    die "Can't open lanscan -- maybe it's not in your path?\n";
}
<LANSCAN>;
<LANSCAN>;
for ($i=0; <LANSCAN>; $i += 10) {
    @buffer = split;
    for (@buffer) {
       $lanscan[++$#lanscan] = $_;
    }
    if (($#lanscan+1) % 10 != 0) {
        splice (@lanscan, $i+5, 0, ("NA"));
    }
    $lanscanIndex{$lanscan[$i+4]} = $i;
    $iface{$lanscan[$i+4]} = $lanscan[$i+$nmid_ppa];
}
close LANSCAN;

#================================================
# read the output of netstat -ni
#================================================
if (!(open (NETSTAT, "netstat -ni $_ 2>&1 |"))){
    die "Can't open netstat -- maybe it's not in your path?\n";
}
<NETSTAT>;
$i = 0;
while (<NETSTAT>) {
    @buffer = split;
    for (@buffer) {
       $netstat[++$#netstat] = $_;
    }
    $netstatIndex{$netstat[$i]} = $i;
    $i += $netstatSize;
}
close NETSTAT;

#================================================
# create SuperIfaceIndex
#================================================
for (keys %netstatIndex) {
    @temp = split (/:/, $_);
    $i = $lanscanIndex{$temp[0]};
    if ($i ne "") {
        # WARNING -- very important to chop off the trailing * if any!!
        if ($_ =~ m/\*/) { chop };
        $superIfaceIndex{$_} = $i;
    }
    for (keys %lanscanIndex) {
        $superIfaceIndex{$_} = $lanscanIndex{$_};
    }
}

#================================================
# read the output of ifconfig <interface>
#================================================
for (keys %superIfaceIndex) {
    if (!(open (IFCONFIG, "ifconfig $_ 2>&1 |"))) {
        die "Can't open ifconfig -- maybe it's not in your path?\n";
    }
    $buffer = <IFCONFIG>;
    if (grep(/UP/, $buffer)) {
        $state{$_} = "UP";
    }else {
        $state{$_} = "DOWN";
    }
    $ifconfig{$_} = <IFCONFIG>;
    close IFCONFIG;
    if (($#ARGV == -1)                                 ||
        ($args{$lanscan[$superIfaceIndex{$_}+2]} == 1) ||
        ($args{$_} == 1)             ||
        ($args{$lanscan[$superIfaceIndex{$_}+6]} == 1))
    {
        $display{$_} = 1;
        $validArg = 1;
    }
}

#================================================
# display usage
#================================================
if ($validArg != 1) {
    print "qlan -- prototype lan tool\n";
    print "-- invalid argument --\n";
    print "Usage:   qlan [-h | -v] [interface | ppa | nmid]...\n";
    print "Default: prints terse info for all driver claimed interfaces\n\n";
    print "h\tDisplays this screen\n";
    print "v\tDisplays verbose mode\n";
    print "\nTo save output to a file type:\n";
    print "\tqlan -v >qlan.out\n";
    print "\nPlease send feedback to qlan-feedback\@hpindkb.cup.hp.com\n";
    exit;
}

#================================================
# read the output of ioscan -kFH <hwpath>
#================================================
$j = 0;
for (keys %lanscanIndex) {
    $i = $lanscanIndex{$_};

    if (!(open (IOSCAN, "ioscan -kFH $lanscan[$i] 2>/dev/null |"))) {
	die "Can't open ioscan -- maybe it's not in your path?\n";
    }
    @buffer = split (/:/, <IOSCAN>);
    if ($buffer[0] ne "") {
        foreach $value (@buffer) {
           $ioscan[++$#ioscan] = $value;
        }
        $ioscanIndex{$ioscan[$j+10]} = $j;
        $j += 19;
    }
    close IOSCAN;
}

#================================================
# read output from what /stand/vmunix
#================================================
if ($args{"-v"} == 1) {
    if (!(open (WHAT, "what /stand/vmunix |"))){
	die "Can't open what -- maybe it's not in your path?\n";
    }
    while (<WHAT>){
        $what[++$#what] = $_;
    }
    close WHAT;
}


#================================================
# Display the info
#================================================
foreach $iface (sort {$superIfaceIndex{$a} <=> $superIfaceIndex{$b}}(keys %superIfaceIndex)) {
    if (($display{$iface} == 1)) {
        $lanstate = $state{$iface};
    	$i = $superIfaceIndex{$iface};
        if ($i ne "") {
            $hwpath = $lanscan[$i];
            $mac = $lanscan[$i+1];
            $hwstate = $lanscan[$i+3];
            $id = $lanscan[$i+$nmid_ppa];
        }else {
            $hwpath = "NA";
            $mac = "NA";
            $hwstate = "NA";
            $id = NA;
        }

        $i = $ioscanIndex{$lanscan[$i]};
        if ($i ne "") {
            $driver = $ioscan[$i+9];
            $swstate = $ioscan[$i+15];
            $desc = $ioscan[$i+17];
            @buffer = grep(/$driver.c/, @what);
            $version = $buffer[0];
	    $version =~ s/^\s+//;
            SWITCH: {
		if ($driver =~ /gelan/) { $type = "1000BT"; last SWITCH; }      # gelan/igelan
                if ($driver =~ /nioxb/) { $type = "X25";    last SWITCH; }
                if ($driver =~ /btlan/) { $type = "100BT";  last SWITCH; }
                if ($driver =~ /lan/)   { $type = "10BT";   last SWITCH; }
                if ($driver =~ /fddi/)  { $type = "FIDDI";  last SWITCH; }
                if ($driver =~ /token/) { $type = "T RING"; last SWITCH; }
                if ($driver =~ /pcitr/) { $type = "T RING"; last SWITCH; }
                $type = "?NA?".$driver;
            }
        }else {
            $driver = "NA";
            $swstate = "NA";
            $desc = "NA";
            $version = NA;
            $type = "NA";
        }

        @buffer = split (/\s+/, $ifconfig{$iface});
        # Perl4 and Perl5 handle leading white space differently
        if ($buffer[0] ne "inet") {
            shift @buffer;
        }
        # check if interface is not configured with an IP
        if ($buffer[0] ne "inet") {
            $inet = "NA";
            $netmask = "NA";
            $broadcast = "NA";
        } else {
            $inet = $buffer[1];
            $netmask = $buffer[3];
            $broadcast = $buffer[5];
        }

        $i = $netstatIndex{$iface};
        if ($i ne "") {
            $opkts = $netstat[$i+$opktsIndex];
            $ipkts = $netstat[$i+4];
            $mtu = $netstat[$i+1];
        }else {
	        $opkts = "NA";
                $ipkts = "NA";
	        $mtu = "NA";
        }

        write;
        #================================================
        # Technology Specific Section
        #================================================
	if ($args{"-v"} == 1) {
	    if ($type eq "100BT") {
                #================================================
                # read the output of lanadmin -x <nmid/ppa>
                #================================================
                $i = $superIfaceIndex{$iface};
                if (!(open (LANADMIN, "lanadmin -x $lanscan[$i+$nmid_ppa] 2>&1 |"))) {
                    die "Can't open lanadmin -- maybe it's not in your path?\n";
		}
                @buffer = split (/= /, <LANADMIN>);
                close LANADMIN;
	        print ("    Speed/Duplex = $buffer[1]\n");
            }else { print ("    Information Not Available\n");}
        }
    }
}


