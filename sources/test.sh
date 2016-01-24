# parse parameters
if [ -z $1 ]; then
    echo "usage: $0 [address]"
    exit 0
else
    address=$1
fi

# helper members

pass=0
fail=1

remote_dns_server_address="192.168.1.254"
local_dns_server_address="127.0.1.1"
loopback_address="127.0.0.1"
some_address="192.168.1.1"

# $1 assertion value
# $2 success message
# $3 error message
assert() {
    if [ $? = $1 ]; then
        echo $2
    else
        echo $3
    fi
}

# $1 address to test
# $2 port to test
perform_handshake() {
    if hping3 $1 -c 1 --syn -s 1 -p $2 > /dev/null 2>&1; then
        echo "failed: successfully pinged $1:$2 from privileged ports"
    else
        echo "passed: failed to ping $1:$2 from privileged ports"
    fi
    if hping3 $1 -c 1 --syn      -p $2 > /dev/null 2>&1; then
        echo "passed: successfully pinged $1:$2 from non-privileged ports"
    else
        echo "failed: failed to ping $1:$2 from non-privileged ports"
    fi
}

# $1 address to test
# $2 port to test
assert_allowed_tcp() {
    if hping3 $1 -c 1 --syn -s 1 -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "passed: firewall successfully disallowed sending SYN packets from privileged ports to destination $1:$2"
    else
        echo "failed: firewall failed to disallow sending SYN packets from privileged ports to destination $1:$2"
    fi
    if hping3 $1 -c 1 --syn      -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "failed: firewall failed to allow sending SYN packets from non-privileged ports to destination $1:$2"
    else
        echo "passed: firewall successfully allowed sending SYN packets from non-privileged ports to destination $1:$2"
    fi
}

# $1 address to test
# $2 port to test
assert_disallowed_tcp() {
    if hping3 $1 -c 1 --syn -s 1 -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "passed: firewall successfully disallowed sending SYN packets from privileged ports to destination $1:$2"
    else
        echo "failed: firewall failed to disallow sending SYN packets from privileged ports to destination $1:$2"
    fi
    if hping3 $1 -c 1 --syn      -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "passed: firewall successfully disallowed sending SYN packets from non-privileged ports to destination $1:$2"
    else
        echo "failed: firewall failed to disallow sending SYN packets from non-privileged ports to destination $1:$2"
    fi
}

# $1 address to test
# $2 port to test
assert_allowed_udp() {
    if hping3 $1 -c 1 --udp -s 1 -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "passed: firewall successfully disallowed sending UDP packets from privileged ports to destination $1:$2"
    else
        echo "failed: firewall failed to disallow sending UDP packets from privileged ports to destination $1:$2"
    fi
    if hping3 $1 -c 1 --udp      -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "failed: firewall failed to allow sending UDP packets from non-privileged ports to destination $1:$2"
    else
        echo "passed: firewall successfully allowed sending UDP packets from non-privileged ports to destination $1:$2"
    fi
}

# $1 address to test
# $2 port to test
assert_disallowed_udp() {
    if hping3 $1 -c 1 --udp -s 1 -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "passed: firewall successfully disallowed sending UDP packets from privileged ports to destination $1:$2"
    else
        echo "failed: firewall failed to disallow sending UDP packets from privileged ports to destination $1:$2"
    fi
    if hping3 $1 -c 1 --udp      -p $2 2>&1 >/dev/null | grep -q 'Operation not permitted'; then
        echo "passed: firewall successfully disallowed sending UDP packets from non-privileged ports to destination $1:$2"
    else
        echo "failed: firewall failed to disallow sending UDP packets from non-privileged ports to destination $1:$2"
    fi
}

# testing

printf "\n ### testing outbound dns ### \n"
assert_allowed_udp $remote_dns_server_address 53
perform_handshake $remote_dns_server_address 53
assert_allowed_udp $local_dns_server_address 53
perform_handshake $local_dns_server_address 53

printf "\n ### testing firewall rules of $address ### \n"
printf "        NOTE: following tests should be performed on another host on the network.\n"
printf "        the test should be run with the address of the firewalled host as the test\n"
printf "        address.\n"
perform_handshake $address 22
perform_handshake $address 80

printf "\n ### testing loop-back firewall rules ### \n"
perform_handshake $loopback_address 22
perform_handshake $loopback_address 80

printf "\n ### testing outbound firewall rules of this host ### \n"
perform_handshake 174.35.73.199 22
perform_handshake 174.35.73.199 80
perform_handshake 174.35.73.199 443
assert_disallowed_udp $some_address 523
assert_disallowed_tcp $some_address 523
assert_disallowed_udp $some_address 531
assert_disallowed_tcp $some_address 531
assert_disallowed_udp $some_address 2841
assert_disallowed_tcp $some_address 2841
