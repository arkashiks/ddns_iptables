#!/usr/bin/perl -w

use strict;
use warnings;

use POSIX;
use Socket;

my $vReload = "no"; # restart only once

# create a name/address hash from all ip names in /etc/sysconfig/iptables
open (IPTABLES, '/etc/sysconfig/iptables')
    or die "", strftime("%F %T", localtime) , "Could not open /etc/sysconfig/iptables: $!";
my %vIPNames;

while (my $vLine = <IPTABLES>)  {
    # only lines containing ip names (at least aaa.bbb)
    if ($vLine !~ /^\s*#/) {
        if ($vLine =~ m/([a-zA-Z][^\s]+\.[^\s]+)/) {
            my $vIPName = $1;
            # ns lookup once only
            if (! exists $vIPNames{$vIPName}) {
                my $vIPAddress = "127.0.0.1";
                my @vHostInfo = gethostbyname($vIPName);
                if (scalar(@vHostInfo) == 0) {
                    print strftime("%F %T", localtime) , " gethostbyname: Can't resolve $vIPName: $!\n";
                    print strftime("%F %T", localtime) , " Aborting script execution.\n";
                    close IPTABLES;
                    exit;
                } else {
                    $vIPAddress = inet_ntoa(inet_aton($vIPName))
                        or die "", strftime("%F %T", localtime) , " ninet_ntoa: Can't resolve $vIPName: $!\n";
                    chomp $vIPAddress;
                    $vIPNames{$vIPName} = $vIPAddress;
                }
            }
        }
    }
}
close IPTABLES;

# check against actual numeric values in /sbin/iptables -nL
for my $vIPName (sort (keys %vIPNames)) {
    my $vIPAddress = $vIPNames{$vIPName};
    # print "$vIPName = $vIPAddress\n";
    if (system("/sbin/iptables -nL -v | grep -i $vIPAddress > /dev/null ") != 0) {
         print strftime("%F %T", localtime) , " $vIPName has the new address $vIPAddress\n";
         $vReload = "yes";
    }
}

# reload iptables
if ($vReload eq "yes") {
    print strftime("%F %T", localtime) , " Changes detected, reloading iptables.\n";
    system "/sbin/service iptables reload" ;
        print strftime("%F %T", localtime) , " Firewall policy update completed.\n";
} else {
        print strftime("%F %T", localtime) , " No changes detected.\n";
}
