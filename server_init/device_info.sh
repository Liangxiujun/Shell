echo "" >/root/device_info.txt

#HOSTNAME
echo "********************HOSTNAME*******************" >>/root/device_info.txt
hostname >>/root/device_info.txt


#CPU
echo "********************CPU************************" >>/root/device_info.txt
cat /proc/cpuinfo | grep 'model name' >>/root/device_info.txt


#MEMORY
echo "********************MEMORY*********************" >>/root/device_info.txt
free -g >>/root/device_info.txt


#DISK
echo "********************DISK***********************" >>/root/device_info.txt
fdisk -l|grep Disk|grep GB >>/root/device_info.txt


#NETWORK
echo "********************NETWORK********************" >>/root/device_info.txt
ip addr |grep eth >>/root/device_info.txt

fdisk -l|sed 's/://g' |awk '/GB/ {print$2}'>disk.txt
lshw > device_all.txt

while read DISK
do
	cat device_all.txt |grep -A 3 $DISK |sed 's/^[[:space:]]\+//' |awk 'BEGIN{ FS = "\n"; RS = ""} {print $1,$3}'  >> /root/device_info.txt
done < disk.txt

rm -f disk.txt
rm -f device_all.txt
#cat /root/device_info.txt
