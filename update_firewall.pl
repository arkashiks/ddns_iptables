#!/usr/bin/perl -w
 
use strict;
use warnings;
 
use POSIX;
use Socket;

print "\n", strftime("%F %T", localtime) , " Firewall update script started.";

my $vReload = "no"; # restart only once
 
# create a name/address hash from all ip names in /etc/sysconfig/iptables
open (IPTABLES, '/etc/sysconfig/iptables')
    or die "Could not open /etc/sysconfig/iptables: $!";
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
					print "\n", strftime("%F %T", localtime) , " gethostbyname: Can't resolve $vIPName: $!";
					print "\n", strftime("%F %T", localtime) , " Aborting script execution.\n";
					close IPTABLES;
					exit;
				} else {
					$vIPAddress = inet_ntoa(inet_aton($vIPName))
						or die "\n", strftime("%F %T", localtime) , " ninet_ntoa: Can't resolve $vIPName: $!";
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
         print "\n", strftime("%F %T", localtime) , " $vIPName has the new address $vIPAddress";
         $vReload = "yes";
    }
}
 
# reload iptables
if ($vReload eq "yes") {
    print "\n", strftime("%F %T", localtime) , " Changes detected, reloading iptables.";
    system "/sbin/service iptables reload" ;
	print "\n", strftime("%F %T", localtime) , " Script completed.\n";
} else {
	print "\n", strftime("%F %T", localtime) , " No changes detected. Script completed.\n";
}
