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
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41de80500f9a7504552432048 RDM01.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41df10598224d504552432048 RDM02.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41dfa061846d8504552432048 RDM03.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e0406b60735504552432048 RDM04.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e0f0760e462504552432048 RDM05.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e1707cf4894504552432048 RDM06.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e1c0826e618504552432048 RDM07.vmdk -a lsilogic
#/usr/sbin/vmkfstools -z /vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e24089be08e504552432048 RDM08.vmdk -a lsilogic
#
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41de80500f9a7504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41df10598224d504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41dfa061846d8504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e0406b60735504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e0f0760e462504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e1707cf4894504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e1c0826e618504552432048
#/vmfs/devices/disks/vml.02000000006782bcb049611e0015c41e24089be08e504552432048
