### parameters ###
NETWORK_ADDRESS="192.168.1.76"
LOCALHOST_ADDRESS="127.0.0.1"

### code - do not touch! ###

PASS=0
FAIL=1

assert() {
    if [ $? = $1 ]
    then echo "pass"
    else echo "fail"
    fi
}

echo "test ssh"
hping3 $NETWORK_ADDRESS   -c 1 --syn -s 80 -p 22 > /dev/null 2>&1; assert $FAIL # disallow connections from privileged ports from Internet
hping3 $NETWORK_ADDRESS   -c 1 --syn       -p 22 > /dev/null 2>&1; assert $PASS # allow connections from non-privileged ports from Internet
hping3 $LOCALHOST_ADDRESS -c 1 --syn -s 81 -p 22 > /dev/null 2>&1; assert $FAIL # disallow connections from privileged ports from localhost
hping3 $LOCALHOST_ADDRESS -c 1 --syn       -p 22 > /dev/null 2>&1; assert $PASS # allow connections from non-privileged ports from localhost

echo "test http"
hping3 $NETWORK_ADDRESS   -c 1 --syn -s 82 -p 80 > /dev/null 2>&1; assert $FAIL
hping3 $NETWORK_ADDRESS   -c 1 --syn       -p 80 > /dev/null 2>&1; assert $PASS
hping3 $LOCALHOST_ADDRESS -c 1 --syn -s 83 -p 80 > /dev/null 2>&1; assert $FAIL
hping3 $LOCALHOST_ADDRESS -c 1 --syn       -p 80 > /dev/null 2>&1; assert $PASS
