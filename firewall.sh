
echo "### configuration below ###"

# custom chain targets
ICMP_TARGET="ACCEPT"
DHCP_TARGET="ACCEPT"
DNS_TARGET="ACCEPT"
SSH_SVR_TARGET="ACCEPT"
SSH_CLNT_TARGET="ACCEPT"
WWW_SVR_TARGET="ACCEPT"
WWW_CLNT_TARGET="ACCEPT"

# DHCP configuration
# address of the DHCP server
DHCP_SERVER="192.168.1.254"

# WWW server configuration
# allowed local WWW server ports to enable remote access to
LOCAL_WWW_SERVERS="80"
# allowed inbound WWW client ports
INBOUND_WWW_CLIENTS="1024:65535"

# WWW client configuration
# allowed remote WWW server ports to enable access to
REMOTE_WWW_SERVERS="80,443"
# allowed outbound WWW client ports
OUTBOUND_WWW_CLIENTS="1024:65535"

# SSH server configuration
# allowed local SSH server ports to enable remote access to
LOCAL_SSH_SERVERS="22"
# allowed inbound SSH client ports
INBOUND_SSH_CLIENTS="513:65535"

# SSH client configuration
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

echo "# create user chains"
iptables -N ICMP
iptables -A ICMP -j $ICMP_TARGET
iptables -N DHCP
iptables -A DHCP -j $DHCP_TARGET
iptables -N DNS
iptables -A DNS -j $DNS_TARGET
iptables -N SSH_SVR
iptables -A SSH_SVR -j $SSH_SVR_TARGET
iptables -N SSH_CLNT
iptables -A SSH_CLNT -j $SSH_CLNT_TARGET
iptables -N WWW_SVR
iptables -A WWW_SVR -j $WWW_SVR_TARGET
iptables -N WWW_CLNT
iptables -A WWW_CLNT -j $WWW_CLNT_TARGET

echo "# enable ICMP"
iptables -A INPUT -p icmp -j ICMP
iptables -A OUTPUT -p icmp -j ICMP

echo "# enable DHCP"
iptables -A INPUT -p udp -m multiport --dport 67,68 -j DHCP # test
iptables -A OUTPUT -p udp -m multiport --sport 67,68 -j DHCP # test

echo "# enable remote DNS"
iptables -A INPUT -p udp -m multiport --sport 53 -j DNS # fixme!
iptables -A OUTPUT -p udp -m multiport --dport 53 -j DNS # fixme!

echo "# enable localhost DNS"
iptables -A INPUT -i lo -p udp -m multiport --dport 53 -j DNS # fixme!
iptables -A OUTPUT -o lo -p udp -m multiport --sport 53 -j DNS # fixme!

echo "# enable SSH server"
iptables -A INPUT  -p tcp -m multiport --dport $LOCAL_SSH_SERVERS -m multiport --sport $INBOUND_SSH_CLIENTS --tcp-flags NONE NONE -j SSH_SVR
iptables -A OUTPUT -p tcp -m multiport --sport $LOCAL_SSH_SERVERS -m multiport --dport $INBOUND_SSH_CLIENTS --tcp-flags ACK  ACK  -j SSH_SVR

echo "# enable SSH client"
iptables -A INPUT  -p tcp -m multiport --sport $REMOTE_SSH_SERVERS -m multiport --dport $OUTBOUND_SSH_CLIENTS --tcp-flags ACK  ACK  -j SSH_CLNT
iptables -A OUTPUT -p tcp -m multiport --dport $REMOTE_SSH_SERVERS -m multiport --sport $OUTBOUND_SSH_CLIENTS --tcp-flags NONE NONE -j SSH_CLNT

echo "# enable WWW server"
iptables -A INPUT  -p tcp -m multiport --dport $LOCAL_WWW_SERVERS -m multiport --sport $INBOUND_WWW_CLIENTS -j WWW_SVR
iptables -A OUTPUT -p tcp -m multiport --sport $LOCAL_WWW_SERVERS -m multiport --dport $INBOUND_WWW_CLIENTS -j WWW_SVR

echo "# enable WWW client"
iptables -A INPUT  -p tcp -m multiport --sport $REMOTE_WWW_SERVERS -m multiport --dport $OUTBOUND_WWW_CLIENTS -j WWW_CLNT
iptables -A OUTPUT -p tcp -m multiport --dport $REMOTE_WWW_SERVERS -m multiport --sport $OUTBOUND_WWW_CLIENTS -j WWW_CLNT
