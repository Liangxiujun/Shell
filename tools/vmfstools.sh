#!/bin/bash

vmldir="/vmfs/devices/disks"
vmlfiles=`ls $vmldir | grep vml | grep -v ':'`

i=0
for vmlfile in $vmlfiles ; do
	let i=i+1
	cd /vmfs/volumes/*BaseSystem

	cmd=""
	if [ $i -lt 10 ];then
		cmd="/usr/sbin/vmkfstools -z ${vmldir}/${vmlfile} RDM0${i}.vmdk -a lsilogic"
		echo $cmd && eval $cmd
	else
		cmd="/usr/sbin/vmkfstools -z ${vmldir}/${vmlfile} RDM${i}.vmdk -a lsilogic"
		echo $cmd && eval $cmd
	fi
	
	if [ $? -eq 0 ];then
		echo "$cmd successful"
	else
		echo "$cmd faile"
	fi
done
