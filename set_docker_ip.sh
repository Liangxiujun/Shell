#!/bin/bash
#$1 ip 容器内ip
#$2 gateway 容器网关
#$3 containerid 容器id
#docker images 查看容器id
if [ $# -lt 3 ];then
	echo "Usage:"
cat  <<EOF
#$1 ip
#$2 gateway 容器网关
#$3 containerid 容器id
#docker images 查看容器id
EOF
	echo "sh $0 < ip > < geteway >  < containerid > "
	exit 1
else
	CONTAINERID=$3
	A=etha
	B=ethb

	pid=`docker inspect -f '{{.State.Pid}}' $CONTAINERID`
	echo $pid
	mkdir -p /var/run/netns

	ln -s /proc/$pid/ns/net /var/run/netns/$pid

	ip link add $A type veth peer name $B
	brctl addif bridge0 $B
	ip link set $B up
	ip link set $A netns $pid

	ip netns exec $pid ip link set dev $A name eth0
	ip netns exec $pid ip link set eth0 up
	ip netns exec $pid ip addr add $1 dev eth0
	ip netns exec $pid ip route add default via $2
fi
