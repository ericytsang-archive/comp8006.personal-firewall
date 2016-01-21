
echo "### configuration below ###"

echo "### code below - do not touch! ###"

echo "# reset firewall"
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

echo "# WWW chain"
iptables -N WWW
iptables -A WWW -j ACCEPT

echo "# SSH chain"
iptables -N SSH
iptables -A SSH -j ACCEPT

echo "# INPUT chain"
# WWW traffic
iptables -A INPUT -i any -p icmp -j ACCEPT
iptables -A INPUT -i any -p tcp -m multiport --sport 80,443 -j WWW
iptables -A INPUT -i any -p udp -m multiport --sport 80,443,53 -j WWW
# iptables -A INPUT -i lo -j WWW
iptables -A INPUT -i lo  -p udp -m multiport --dport 53 -j WWW
# SSH traffic
# iptables -A INPUT -i any -p tcp -m multiport --sport 22 -j SSH # test
# iptables -A INPUT -i any -p udp -m multiport --sport 22 -j SSH # test
iptables -P INPUT DROP

echo "# OUTPUT chain"
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dport 80,443 -j WWW
iptables -A OUTPUT -p udp -m multiport --dport 80,443,53 -j WWW
# iptables -A OUTPUT -p tcp -m multiport --dport 22 -j SSH # test
# iptables -A OUTPUT -p udp -m multiport --dport 22 -j SSH # test
iptables -P OUTPUT DROP

echo "# FORWARD chain"
iptables -P FORWARD DROP
