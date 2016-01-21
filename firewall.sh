
echo "### configuration below ###"

echo "### code below - do not touch! ###"

echo "# reset firewall"
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

echo "# set chain policies"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "# WWW chain"
iptables -N WWW
iptables -A WWW -j ACCEPT

echo "# SSH chain"
iptables -N SSH
iptables -A SSH -j ACCEPT

echo "# configure chains to enable DHCP"

echo "# INPUT chain"
iptables -A INPUT -p udp -m multiport --dport 67,68 -j ACCEPT # test

echo "# OUTPUT chain"
iptables -A OUTPUT -p udp -m multiport --sport 67,68 -j ACCEPT # test

echo "# configure chains to enable web hosting"

echo "# INPUT chain"
iptables -A INPUT -p tcp -m multiport --dport 80,443 -m multiport --sport 1024:65535 -j WWW # test

echo "# OUTPUT chain"
iptables -A OUTPUT -p tcp -m multiport --sport 80,443 -m multiport --dport 1024:65535 -j WWW # test

echo "# configure chains to enable web browsing"

echo "# INPUT chain"
iptables -A INPUT -i lo -p udp -m multiport --dport 53 -j WWW
iptables -A INPUT -p tcp -m multiport --sport 80,443 -j WWW
iptables -A INPUT -p udp -m multiport --sport 53 -j WWW
iptables -A INPUT -p icmp -j WWW

echo "# OUTPUT chain"
iptables -A OUTPUT -o lo -p udp -m multiport --sport 53 -j WWW
iptables -A OUTPUT -p tcp -m multiport --dport 80,443 -j WWW
iptables -A OUTPUT -p udp -m multiport --dport 53 -j WWW
iptables -A OUTPUT -p icmp -j WWW

echo "# configure chains to accept SSH traffic"

echo "# INPUT chain"
iptables -A INPUT -p tcp -m multiport --sport 22 -j SSH # test

echo "# OUTPUT chain"
iptables -A OUTPUT -p tcp -m multiport --dport 22 -j SSH # test
