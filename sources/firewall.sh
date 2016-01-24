### configuration below ###

# addresses
ANY_ADDRESS="0.0.0.0/0"
HOST_ADDRESS="192.168.1.76"
LOCALHOST_ADDRESS="127.0.0.1"
SUBNET_ADDRESS="192.168.1.0/24"
BROADCAST_SRC_ADDRESS="0.0.0.0"
BROADCAST_DEST_ADDRESS="255.255.255.255"

# port ranges
USER_PORTS="1024:65535"

# custom chain targets (ACCEPT,DROP)
ICMP_TARGET="ACCEPT"
DHCP_TARGET="ACCEPT"
DNS_TARGET="ACCEPT"
SSH_SVR_TARGET="ACCEPT"
SSH_CLNT_TARGET="ACCEPT"
WWW_SVR_TARGET="ACCEPT"
WWW_CLNT_TARGET="ACCEPT"

# network interfaces (ifconfig)
INTERNET="wlan0"
LOOPBACK="lo"

# DNS configuration
# remote DNS server
REMOTE_DNS_SERVER_ADDRESS="192.168.1.254"
REMOTE_DNS_SERVER_PORT="53"
# local DNS server
LOCAL_DNS_SERVER_ADDRESS="127.0.1.1"
LOCAL_DNS_SERVER_PORT="53"

# DHCP configuration
# address of the DHCP server
DHCP_SERVER="192.168.1.254"

# WWW server configuration
# allowed local WWW server ports to enable remote access to
LOCAL_WWW_SERVERS="80"
# allowed inbound WWW client ports
INBOUND_WWW_CLIENTS=$USER_PORTS

# WWW client configuration
# allowed remote WWW server ports to enable access to
REMOTE_WWW_SERVERS="80,443"
# allowed outbound WWW client ports
OUTBOUND_WWW_CLIENTS=$USER_PORTS

# SSH server configuration
# allowed local SSH server ports to enable remote access to
LOCAL_SSH_SERVERS="22"
# allowed inbound SSH client ports
INBOUND_SSH_CLIENTS=$USER_PORTS

# SSH client configuration
# allowed remote SSH server ports to enable access to
REMOTE_SSH_SERVERS="22"
# allowed outbound SSH client ports
OUTBOUND_SSH_CLIENTS=$USER_PORTS

### code below - do not touch! ###

# reset firewall
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# set chain policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# create user chains
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

# enable ICMP
iptables -A INPUT -p icmp -j ICMP
iptables -A OUTPUT -p icmp -j ICMP

# enable DHCP
iptables -A OUTPUT -p udp \
    -s $BROADCAST_SRC_ADDRESS -m multiport --sport 67,68 \
    -d $BROADCAST_DEST_ADDRESS -m multiport --dport 67,68 \
    -j DHCP
iptables -A INPUT -p udp \
    -s $DHCP_SERVER -m multiport --sport 67 \
    -d $SUBNET_ADDRESS -m multiport --sport 68 \
    -j DHCP
iptables -A OUTPUT -p udp \
    -s $HOST_ADDRESS -m multiport --sport 68 \
    -d $DHCP_SERVER -m multiport --dport 67 \
    -j DHCP
iptables -A INPUT -p udp \
    -s $DHCP_SERVER -m multiport --sport 67 \
    -d $HOST_ADDRESS -m multiport --dport 68 \
    -j DHCP

# enable DNS client
iptables -A INPUT -i $INTERNET -p udp \
    -s $REMOTE_DNS_SERVER_ADDRESS -m multiport --sport $REMOTE_DNS_SERVER_PORT \
    -d $HOST_ADDRESS -m multiport --dport $USER_PORTS \
    -j DNS
iptables -A OUTPUT -o $INTERNET -p udp \
    -s $HOST_ADDRESS -m multiport --sport $USER_PORTS \
    -d $REMOTE_DNS_SERVER_ADDRESS -m multiport --dport $REMOTE_DNS_SERVER_PORT \
    -j DNS
iptables -A INPUT -i $INTERNET -p tcp \
    -s $REMOTE_DNS_SERVER_ADDRESS -m multiport --sport $REMOTE_DNS_SERVER_PORT \
    -d $HOST_ADDRESS -m multiport --dport $USER_PORTS \
    -m state --state ESTABLISHED -j DNS
iptables -A OUTPUT -o $INTERNET -p tcp \
    -s $HOST_ADDRESS -m multiport --sport $USER_PORTS \
    -d $REMOTE_DNS_SERVER_ADDRESS -m multiport --dport $REMOTE_DNS_SERVER_PORT \
    -m state --state NEW,ESTABLISHED -j DNS

# enable loop-back DNS client
iptables -A INPUT -i $LOOPBACK -p udp \
    -s $LOCAL_DNS_SERVER_ADDRESS -m multiport --sport $LOCAL_DNS_SERVER_PORT \
    -d $LOCALHOST_ADDRESS -m multiport --dport $USER_PORTS \
    -j DNS
iptables -A OUTPUT -o $LOOPBACK -p udp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $USER_PORTS \
    -d $LOCAL_DNS_SERVER_ADDRESS -m multiport --dport $LOCAL_DNS_SERVER_PORT \
    -j DNS
iptables -A INPUT -i $LOOPBACK -p tcp \
    -s $LOCAL_DNS_SERVER_ADDRESS -m multiport --sport $LOCAL_DNS_SERVER_PORT \
    -d $LOCALHOST_ADDRESS -m multiport --dport $USER_PORTS \
    -m state --state ESTABLISHED -j DNS
iptables -A OUTPUT -o $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $USER_PORTS \
    -d $LOCAL_DNS_SERVER_ADDRESS -m multiport --dport $LOCAL_DNS_SERVER_PORT \
    -m state --state NEW,ESTABLISHED -j DNS

# enable loop-back DNS server
iptables -A INPUT -i $LOOPBACK -p udp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $USER_PORTS \
    -d $LOCAL_DNS_SERVER_ADDRESS -m multiport --dport $LOCAL_DNS_SERVER_PORT \
    -j DNS
iptables -A OUTPUT -o $LOOPBACK -p udp \
    -s $LOCAL_DNS_SERVER_ADDRESS -m multiport --sport $LOCAL_DNS_SERVER_PORT \
    -d $LOCALHOST_ADDRESS -m multiport --dport $USER_PORTS \
    -j DNS
iptables -A INPUT -i $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $USER_PORTS \
    -d $LOCAL_DNS_SERVER_ADDRESS -m multiport --dport $LOCAL_DNS_SERVER_PORT \
    -m state --state ESTABLISHED -j DNS
iptables -A OUTPUT -o $LOOPBACK -p tcp \
    -s $LOCAL_DNS_SERVER_ADDRESS -m multiport --sport $LOCAL_DNS_SERVER_PORT \
    -d $LOCALHOST_ADDRESS -m multiport --dport $USER_PORTS \
    -m state --state NEW,ESTABLISHED -j DNS

# enable SSH server
iptables -A INPUT -i $INTERNET -p tcp \
    -s $ANY_ADDRESS -m multiport --sport $INBOUND_SSH_CLIENTS \
    -d $HOST_ADDRESS -m multiport --dport $LOCAL_SSH_SERVERS \
    -m state --state NEW,ESTABLISHED --tcp-flags NONE NONE -j SSH_SVR
iptables -A OUTPUT -o $INTERNET -p tcp \
    -s $HOST_ADDRESS -m multiport --sport $LOCAL_SSH_SERVERS \
    -d $ANY_ADDRESS -m multiport --dport $INBOUND_SSH_CLIENTS \
    -m state --state ESTABLISHED --tcp-flags ACK  ACK -j SSH_SVR
iptables -A INPUT -i $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $INBOUND_SSH_CLIENTS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $LOCAL_SSH_SERVERS \
    -m state --state NEW,ESTABLISHED --tcp-flags NONE NONE -j SSH_SVR
iptables -A OUTPUT -o $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $LOCAL_SSH_SERVERS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $INBOUND_SSH_CLIENTS \
    -m state --state ESTABLISHED --tcp-flags ACK  ACK -j SSH_SVR

# enable SSH client
iptables -A INPUT -i $INTERNET -p tcp \
    -s $ANY_ADDRESS -m multiport --sport $REMOTE_SSH_SERVERS \
    -d $HOST_ADDRESS -m multiport --dport $OUTBOUND_SSH_CLIENTS \
    -m state --state ESTABLISHED --tcp-flags ACK  ACK -j SSH_CLNT
iptables -A OUTPUT -o $INTERNET -p tcp \
    -s $HOST_ADDRESS -m multiport --sport $OUTBOUND_SSH_CLIENTS \
    -d $ANY_ADDRESS -m multiport --dport $REMOTE_SSH_SERVERS \
    -m state --state NEW,ESTABLISHED --tcp-flags NONE NONE -j SSH_CLNT
iptables -A INPUT -i $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $REMOTE_SSH_SERVERS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $OUTBOUND_SSH_CLIENTS \
    -m state --state ESTABLISHED --tcp-flags ACK  ACK -j SSH_CLNT
iptables -A OUTPUT -o $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $OUTBOUND_SSH_CLIENTS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $REMOTE_SSH_SERVERS \
    -m state --state NEW,ESTABLISHED --tcp-flags NONE NONE -j SSH_CLNT

# enable WWW server
iptables -A INPUT -i $INTERNET -p tcp \
    -s $ANY_ADDRESS -m multiport --sport $INBOUND_WWW_CLIENTS \
    -d $HOST_ADDRESS -m multiport --dport $LOCAL_WWW_SERVERS \
    -m state --state NEW,ESTABLISHED -j WWW_SVR
iptables -A OUTPUT -o $INTERNET -p tcp \
    -s $HOST_ADDRESS -m multiport --sport $LOCAL_WWW_SERVERS \
    -d $ANY_ADDRESS -m multiport --dport $INBOUND_WWW_CLIENTS \
    -m state --state ESTABLISHED -j WWW_SVR
iptables -A INPUT -i $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $INBOUND_WWW_CLIENTS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $LOCAL_WWW_SERVERS \
    -m state --state NEW,ESTABLISHED -j WWW_SVR
iptables -A OUTPUT -o $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $LOCAL_WWW_SERVERS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $INBOUND_WWW_CLIENTS \
    -m state --state ESTABLISHED -j WWW_SVR

# enable WWW client
iptables -A INPUT -i $INTERNET -p tcp \
    -s $ANY_ADDRESS -m multiport --sport $REMOTE_WWW_SERVERS \
    -d $HOST_ADDRESS -m multiport --dport $OUTBOUND_WWW_CLIENTS \
    -m state --state ESTABLISHED -j WWW_CLNT
iptables -A OUTPUT -o $INTERNET -p tcp \
    -s $HOST_ADDRESS -m multiport --sport $OUTBOUND_WWW_CLIENTS \
    -d $ANY_ADDRESS -m multiport --dport $REMOTE_WWW_SERVERS \
    -m state --state NEW,ESTABLISHED -j WWW_CLNT
iptables -A INPUT -i $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $REMOTE_WWW_SERVERS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $OUTBOUND_WWW_CLIENTS \
    -m state --state ESTABLISHED -j WWW_CLNT
iptables -A OUTPUT -o $LOOPBACK -p tcp \
    -s $LOCALHOST_ADDRESS -m multiport --sport $OUTBOUND_WWW_CLIENTS \
    -d $LOCALHOST_ADDRESS -m multiport --dport $REMOTE_WWW_SERVERS \
    -m state --state NEW,ESTABLISHED -j WWW_CLNT
