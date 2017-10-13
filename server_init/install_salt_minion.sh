#!/bin/bash

. /etc/init.d/functions

if [ $# -lt 1 ];then
    echo "Usage: $0 isp-city salt-master"
    echo "Ex: $0 cm-shanxi 122.72.0.5"
    echo "default salt-master is 122.72.0.5"
    exit 1
fi
check_rpm(){
    rpm -q salt-minion 
    if [ "$?" -eq "0" ];then
    return 0
    else 
    return 1
    fi
}

install_os_5(){
    if check_rpm;then
    echo "salt-minion client already installed"
    else
    echo "salt-minion client is not installed."
    rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
    wget -c -O /etc/yum.repos.d/saltstack-salt-el5-epel-5.repo  http://copr.fedoraproject.org/coprs/saltstack/salt-el5/repo/epel-5/saltstack-salt-el5-epel-5.repo
    yum -y install salt-minion
    fi
}

install_os_6(){
    if check_rpm;then
        echo "salt-minion client already installed"
    else
        echo "salt-minion client is not installed."
        #rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
        yum -y install salt-minion
    fi
}

check_os_version(){
    osversion=$(cat /etc/issue|awk 'NR==1{print $3}'|cut -d. -f1) 
    if [ "$osversion" == "5" ];then
        
        install_os_5
    elif [ "$osversion" == "6" ]; then
        
        install_os_6
    else
        echo "[ERROR] system version is wrong, please check again."
        exit 0
    fi

}
install_salt(){
    check_os_version
    if [ -z "$2" ];then
        master="122.72.0.5"
    else
        master="$2"
    fi
    localip=$(ip route|awk 'NR==1{print $NF}')
    sed -i "/-$localip/d" /etc/salt/minion
    sed -i "/master: /d" /etc/salt/minion
    echo "id: "$1"-$localip" >> /etc/salt/minion
    echo "master: $master" >> /etc/salt/minion
    /etc/init.d/salt-minion restart
}

install_salt $1 $2
