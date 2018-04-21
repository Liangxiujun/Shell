#!/bin/bash
yum install -y parted
sleep 1s
yum install -y vim
sleep 1s
#####################################################################
myFile=/root/test1
 
if [ ! -x "$myFile" ];then
    touch "$myFile"
fi
i=1
b=1
for  disk in `fdisk -l | grep "/dev/sd*" | awk '{if($2~/sd/ && $2!="/dev/sda:" ) print substr($2,0,8)}'`

do
        # parted $disk  << EXIT
        # mklabel gpt
        # mkpart primary 0 -1
        # ignore
        # quit
fdisk $disk <<EXIT
p
d
p
d
d
1
d
2
d
3
d
4
d

p
n
p
1


p
w
EXIT
       mkfs.ext4 $disk$b
echo "/n/n****************$disk_was Fdisked!Waithing For 10 second****/n/n"
sleep 1s
        uuid=`blkid $disk$b | awk '{print $2}'|awk -F"\"" '{print $2}'`
        if [ ! -d "myPath" ];then
           mkdir /data$i
       fi
        cat << EXIT > /root/test1
UUID=$uuid      /data${i}       ext4    defaults                1 2 
EXIT
        cat /root/test1 >> /etc/fstab
i=$(($i + 1))
done
  
######################################################################
mount -a
