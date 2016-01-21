
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

# todo: test to see which rules get packets, and try to consolidate the rules

echo "# INPUT chain"
iptables -A INPUT -i any -p icmp -j ACCEPT
iptables -A INPUT -i lo  -p tcp -m multiport --dport 80  -j WWW
iptables -A INPUT -i lo  -p udp -m multiport --dport 80  -j WWW
iptables -A INPUT -i lo  -p tcp -m multiport --dport 443 -j WWW
iptables -A INPUT -i lo  -p udp -m multiport --dport 443 -j WWW
iptables -A INPUT -i lo  -p tcp -m multiport --dport 53  -j WWW
iptables -A INPUT -i lo  -p udp -m multiport --dport 53  -j WWW
iptables -A INPUT -i lo  -j ACCEPT
iptables -A INPUT -i any -p tcp -m multiport --sport 80  -j WWW
iptables -A INPUT -i any -p udp -m multiport --sport 80  -j WWW
iptables -A INPUT -i any -p tcp -m multiport --sport 443 -j WWW
iptables -A INPUT -i any -p udp -m multiport --sport 443 -j WWW
iptables -A INPUT -i any -p udp -m multiport --sport 53  -j WWW
iptables -A INPUT -j ACCEPT
iptables -P INPUT DROP

# todo: test to see which rules get packets, and try to consolidate the rules

echo "# OUTPUT chain"
iptables -A OUTPUT -o any -p icmp -j ACCEPT
iptables -A OUTPUT -o lo  -p tcp -m multiport --sport 80  -j WWW
iptables -A OUTPUT -o lo  -p udp -m multiport --sport 80  -j WWW
iptables -A OUTPUT -o lo  -p tcp -m multiport --sport 443 -j WWW
iptables -A OUTPUT -o lo  -p udp -m multiport --sport 443 -j WWW
iptables -A OUTPUT -o lo  -p tcp -m multiport --sport 53  -j WWW
iptables -A OUTPUT -o lo  -p udp -m multiport --sport 53  -j WWW
iptables -A OUTPUT -o lo  -j ACCEPT
iptables -A OUTPUT -o any -p tcp -m multiport --dport 80  -j WWW
iptables -A OUTPUT -o any -p udp -m multiport --dport 80  -j WWW
iptables -A OUTPUT -o any -p tcp -m multiport --dport 443 -j WWW
iptables -A OUTPUT -o any -p udp -m multiport --dport 443 -j WWW
iptables -A OUTPUT -o any -p udp -m multiport --dport 53  -j WWW
iptables -A INPUT -j ACCEPT
iptables -P OUTPUT DROP

echo "# FORWARD chain"
iptables -P FORWARD DROP
