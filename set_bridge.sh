#!/bin/sh
#$1 本机IP
#$2	网管
#$3 网卡
if [ ! -n "$1" ] || [ ! -n "$2" ] || [ ! -n "$3" ];then
	echo "Usage `basename $0` <LocalIP> <gateway> <nic>"
	exit 1
else
	brctl addbr bridge0
	ip link set dev bridge0 up
	brctl addif bridge0 $3
	ip addr del $1 dev $3
	ip addr add $1 dev bridge0
	ip route add 0/0 via $2
fi
