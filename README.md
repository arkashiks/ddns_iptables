# ddns_iptables
Script which allows use of iptables in conjunction with Dynamic DNS services. Uses Perl to perform verifications and reload iptables service if changes detected.

Original script was written by Thomas Gutzmann and can be found here https://wiki.gutzmann.com/confluence/display/HowTo/IPTables+Firewall+Setup+for+Dynamic+DNS.

This script is adaptation for my systems (fail2ban removed, added control which will prevent iptables reload if one or more FQDNs cannot be resolved - otherwise will crash iptables service).
