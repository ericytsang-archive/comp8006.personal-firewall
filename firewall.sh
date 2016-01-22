
echo "### configuration below ###"

# allowed local SSH server ports to enable remote access to
LOCAL_SSH_SERVERS="22"
# allowed inbound SSH client ports
INBOUND_SSH_CLIENTS="513:65535"

# allowed remote SSH server ports to enable access to
REMOTE_SSH_SERVERS="22"
# allowed outbound SSH client ports
OUTBOUND_SSH_CLIENTS="513:65535"

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

echo "# WWW_CLNT chain"
iptables -N WWW_CLNT
iptables -A WWW_CLNT -j ACCEPT

echo "# WWW_SVR chain"
iptables -N WWW_SVR
iptables -A WWW_SVR -j ACCEPT

echo "# SSH chain"
iptables -N SSH
iptables -A SSH -j ACCEPT

echo "# DHCP chain"
iptables -N DHCP
iptables -A DHCP -j ACCEPT

echo "# enable DNS"

iptables -A INPUT -i lo -p udp -m multiport --dport 53 -j WWW_CLNT
iptables -A INPUT -p udp -m multiport --sport 53 -j WWW_CLNT

iptables -A OUTPUT -o lo -p udp -m multiport --sport 53 -j WWW_CLNT
iptables -A OUTPUT -p udp -m multiport --dport 53 -j WWW_CLNT

echo "# enable DHCP"
iptables -A INPUT -p udp -m multiport --dport 67,68 -j DHCP # test
iptables -A OUTPUT -p udp -m multiport --sport 67,68 -j DHCP # test

echo "# enable web hosting"
iptables -A INPUT -p tcp -m multiport --dport 80,443 -m multiport --sport 1024:65535 -j WWW_SVR
iptables -A OUTPUT -p tcp -m multiport --sport 80,443 -m multiport --dport 1024:65535 -j WWW_SVR

echo "# enable web browsing"

iptables -A INPUT -p tcp -m multiport --sport 80,443 -j WWW_CLNT
iptables -A INPUT -p icmp -j WWW_CLNT

iptables -A OUTPUT -p tcp -m multiport --dport 80,443 -j WWW_CLNT
iptables -A OUTPUT -p icmp -j WWW_CLNT

echo "# enable connections to local SSH server"
iptables -A INPUT  -p tcp -m multiport --dport $LOCAL_SSH_SERVERS -m multiport --sport $INBOUND_SSH_CLIENTS --tcp-flags NONE NONE -j SSH # test
iptables -A OUTPUT -p tcp -m multiport --sport $LOCAL_SSH_SERVERS -m multiport --dport $INBOUND_SSH_CLIENTS --tcp-flags ALL  ACK  -j SSH # test

echo "# enable connections to remote SSH servers"
iptables -A INPUT  -p tcp -m multiport --sport $REMOTE_SSH_SERVERS -m multiport --dport $OUTBOUND_SSH_CLIENTS --tcp-flags ALL  ACK  -j SSH # test
iptables -A OUTPUT -p tcp -m multiport --dport $REMOTE_SSH_SERVERS -m multiport --sport $OUTBOUND_SSH_CLIENTS --tcp-flags NONE NONE -j SSH # test
