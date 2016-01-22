
echo "### configuration below ###"

# allowed local WWW server ports to enable remote access to
LOCAL_WWW_SERVERS="80,443"
# allowed inbound WWW client ports
INBOUND_WWW_CLIENTS="1024:65535"

# allowed remote WWW server ports to enable access to
REMOTE_WWW_SERVERS="80,443"
# allowed outbound WWW client ports
OUTBOUND_WWW_CLIENTS="1024:65535"

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

echo "# ICMP chain"
iptables -N ICMP
iptables -A ICMP -j ACCEPT

echo "# DHCP chain"
iptables -N DHCP
iptables -A DHCP -j ACCEPT

echo "# DNS chain"
iptables -N DNS
iptables -A DNS -j ACCEPT

echo "# SSH chain"
iptables -N SSH
iptables -A SSH -j ACCEPT

echo "# WWW_SVR chain"
iptables -N WWW_SVR
iptables -A WWW_SVR -j ACCEPT

echo "# WWW_CLNT chain"
iptables -N WWW_CLNT
iptables -A WWW_CLNT -j ACCEPT

echo "# enable ICMP"
iptables -A INPUT -p icmp -j ICMP
iptables -A OUTPUT -p icmp -j ICMP

echo "# enable DHCP"
iptables -A INPUT -p udp -m multiport --dport 67,68 -j DHCP # test
iptables -A OUTPUT -p udp -m multiport --sport 67,68 -j DHCP # test

echo "# enable remote DNS"
iptables -A INPUT -p udp -m multiport --sport 53 -j DNS
iptables -A OUTPUT -p udp -m multiport --dport 53 -j DNS

echo "# enable localhost DNS"
iptables -A INPUT -i lo -p udp -m multiport --dport 53 -j DNS
iptables -A OUTPUT -o lo -p udp -m multiport --sport 53 -j DNS

echo "# enable connections to local SSH server"
iptables -A INPUT  -p tcp -m multiport --dport $LOCAL_SSH_SERVERS -m multiport --sport $INBOUND_SSH_CLIENTS --tcp-flags NONE NONE -j SSH
iptables -A OUTPUT -p tcp -m multiport --sport $LOCAL_SSH_SERVERS -m multiport --dport $INBOUND_SSH_CLIENTS --tcp-flags ACK  ACK  -j SSH

echo "# enable connections to remote SSH servers"
iptables -A INPUT  -p tcp -m multiport --sport $REMOTE_SSH_SERVERS -m multiport --dport $OUTBOUND_SSH_CLIENTS --tcp-flags ACK  ACK  -j SSH
iptables -A OUTPUT -p tcp -m multiport --dport $REMOTE_SSH_SERVERS -m multiport --sport $OUTBOUND_SSH_CLIENTS --tcp-flags NONE NONE -j SSH

echo "# enable web hosting"
iptables -A INPUT  -p tcp -m multiport --dport $LOCAL_WWW_SERVERS -m multiport --sport $INBOUND_WWW_CLIENTS -j WWW_SVR
iptables -A OUTPUT -p tcp -m multiport --sport $LOCAL_WWW_SERVERS -m multiport --dport $INBOUND_WWW_CLIENTS -j WWW_SVR

echo "# enable web browsing"
iptables -A INPUT  -p tcp -m multiport --sport $REMOTE_WWW_SERVERS -m multiport --dport $OUTBOUND_WWW_CLIENTS -j WWW_CLNT
iptables -A OUTPUT -p tcp -m multiport --dport $REMOTE_WWW_SERVERS -m multiport --sport $OUTBOUND_WWW_CLIENTS -j WWW_CLNT
