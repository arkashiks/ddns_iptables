# ddns_iptables
Script which allows use of iptables in combination with Dynamic DNS services. Uses Perl to perform verifications and reload iptables service if changes detected.

Original script was written by Thomas Gutzmann and can be found here https://wiki.gutzmann.com/confluence/display/HowTo/IPTables+Firewall+Setup+for+Dynamic+DNS.

This script is adaptation for my systems (fail2ban removed, added control which will prevent iptables reload if one or more FQDNs cannot be resolved - otherwise will crash iptables service).

Installation is pretty simple:

1. Copy file into your directory with scripts;
2. Set chmod to 700: chmod 700 update_firewall.pl;
3. Create rules you want with dynamic DNS names in /etc/sysconfig/iptables;
4. Add script execution in cron at required time/period and send output in log file you want;

Example of iptables rules below (only ones with FQDNs in source are in scope of script):

```
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 127.0.0.0/8 -j ACCEPT

# pool.ntp.org membership, permit NTP requests from any
-A INPUT -p udp -m udp --dport 123 -j ACCEPT

# web and management
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -s myjumphost.mydomian.com -j ACCEPT
COMMIT
```

In case of this example, there is only one dynamic host which is myjumphost.mydomian.com. Each time script will run, it will try to resolve this FQDN and then check if resolved IP is in iptables policy, if not - then it will trigger reload of iptables service and as result new IP will be in the policy.
