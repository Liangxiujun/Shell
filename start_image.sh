#!/bin/bash
HOSTNAME=hadoop01
IMAGE_NAME=docker.io/hasedon/centos6.5
CONTAINER_NAME=hadoop15


docker  run  -itd  --privileged=true  --net=none  -h $HOSTNAME  --name $CONTAINER_NAME -v /hadoop:/hadoop -v /data1/disk1:/data1/disk1 -v /data2/disk2:/data2/disk2  -v /data3/disk3:/data3/disk3 -v /home:/home  -v /data1/disk1/opt:/opt  $IMAGE_NAME  /bin/bash

