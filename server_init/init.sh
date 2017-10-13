#!/bin/bash 
#--变量
source /etc/init.d/functions 
err_echo(){
    echo -e "\\033[31m[Error]: $1 \\033[0m"
    exit 1
}
  
info_echo(){
    echo -e "\\033[32m [Info]: $1 \\033[0m"
}
  
warn_echo(){
    echo -e "\\033[33m [Warning]: $1 \\033[0m"
}
  
check_exit(){
    if [ $? -ne 0 ]; then
        err_echo "$1"
        exit 1
    fi
}
 
SSH_PORT=9777
LOGIN_USER=pingtai
LOGIN_PASSWD="pingtai_ops@2017"
LOGIN_PASSWD_ROOT="root_ops@2017" 
#用户登录失败锁定阀值
LOGIN_FAILD=10
LOCK_TIME=30
CWD=`pwd`
check_version(){ 
cat << EOF
 +--------------------------------------------------------------+
 |         === Welcome to CentOS 6.x System init ==="           |
 +--------------------------------------------------------------+
EOF
 
info_echo "start check system vertion"
sv=`grep "CentOS" /etc/issue|awk '{print $1}'`
cv=`uname -r | awk -F. '{print $NF}'`
info_echo "System_Version: $sv\t$cv"
if [ $sv != CentOS ] && [ $cv != x86_64 ] ;then
        erro_echo "no CentOS or no x86_64 system !!! exit...."
        exit 7
fi
}
change_hostname(){
    info_echo "Change hostname."
    hn=""
    hostnamefile="$CWD/conf/hostname.txt"
    if [ -f $hostnamefile ];then
            hn=`cat $CWD/conf/hostname.txt|grep -v "^#"|grep -v "^$"`
    else
            echo "Input your new hostname"  
            read hn
    fi
    cp /etc/sysconfig/network /etc/sysconfig/network.org
    sed -i "s@^HOSTNAME.*@HOSTNAME=$hn@" /etc/sysconfig/network ;
    CMD="awk '/127.0.0.1/{print \$1\"\t\"\$2\"\t\"\"$hn\";next} {print \$0}' /etc/hosts     >/tmp/hosts"
    action $"$CMD" eval $CMD
    mv /tmp/hosts /etc/hosts
    hostname $hn
} 

add_default_dns(){
    info_echo "Add default dns to /etc/resolv.conf"
    test -f /etc/resolv.conf  && cp /etc/resolv.conf /etc/resolv.conf.bak
    cat $CWD/conf/resolv.conf > /etc/resolv.conf
}

dns_test(){
    url="www.baidu.com www.sina.com.cn www.163.com"
    info_echo "Resolv: $url"
    rpm -q dig
    if [ $? -ne 0 ];then
            yum_repo
            for i in $url;do
                CMD="dig $i"
                action $"$CMD" eval $CMD
        done
    fi
}

yum_repo(){
	#添加aliyun yum epel外部yum扩展源
	info_echo "add aliyun rpm sources..."
	grep -q mirrors.aliyun.com /etc/yum.repos.d/CentOS-Base.repo|| \
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
	info_echo "add epel rpm sources.."
	grep -q mirrors.aliyun.com  /etc/yum.repos.d/CentOS-Base.repo|| \
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
	#yum clean all 
	#yum makecache
	 
	#安装gcc基础库文件以及sysstat工具
	info_echo "install gcc gcc-c++ unzip unzip vim wget...."
	yum -y install gcc gcc-c++ vim-enhanced unzip unrar sysstat vim wget lrzsz dstat tcpdump wireshark  bind-utils lshw 
	yum -y groupinstall 'Development Tools' 'Development Libraries' 'Editors' 'Administration Tools' 'System Tools'
}
ntp_check(){ 
	info_echo "install ntpd..."
	#配置ntpdate自动对时
	yum -y install ntp
	grep -q ntpdate /etc/crontab || echo "*/10  * * * /usr/sbin/ntpdate 116.63.0.59    >> /dev/null 2>&1" >> /etc/crontab
	ntpdate ntp.api.bz
	service crond restart
	rm -f /etc/localtime
	cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}


#配置文件的ulimit值
ulimit_modify(){
	info_echo "config ulimit..."
	ulimit -SHn 65535
echo "ulimit -SHn 65535" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*                     soft     nofile             60000
*                     hard     nofile             65535
EOF
}

disabled_cad(){
	info_echo "disabled control-alt-delete..."
	#禁用control-alt-delete组合键以防止误操作
	sed -i 's@ca::ctrlaltdel:/sbin/shutdown -t3 -r now@#ca::ctrlaltdel:/sbin/shutdown -t3 -r now@' /etc/inittab
 }
disabled_selinux(){
	#关闭SElinux
	info_echo "disable Selinux..."
	sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config
}

modify_kernel_conf(){
#内核网络基础优化
	info_echo "system kernel network optimize... "
    modprobe ip_conntrack
    echo "modprobe ip_conntrack">> /etc/rc.local
	grep -q "net.ipv4.tcp_keepalive_time = 30" /etc/sysctl.conf || \
cat >> /etc/sysctl.conf << EOF
# ------------- Kernel Optimization -------------
net.ipv4.tcp_max_tw_buckets = 60000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
net.nf_conntrack_max = 655360
net.netfilter.nf_conntrack_max =655360
net.netfilter.nf_conntrack_tcp_timeout_established = 180
EOF
/sbin/sysctl -p
}
change_sshd_port(){
#ssh服务配置优化
	info_echo "backup sshd config..."
	info_echo "set ssh port $SSH_PORT"

	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
    grep -v "^Port " /etc/ssh/sshd_config > /tmp/sshd_config
    echo "Port 9777" >> /tmp/sshd_config
    mv -f /tmp/sshd_config /etc/ssh/sshd_config
	info_echo "enable port $SSH_PORT"
    service sshd restart
	info_echo "deny root login..."
	sed -i '/#PermitRootLogin/a\PermitRootLogin no' /etc/ssh/sshd_config
	sed -i 's@#UseDNS yes@UseDNS no@' /etc/ssh/sshd_config
	cat $CWD/conf/iptables.conf > /etc/sysconfig/iptables 
    service iptables restart
}

add_user_login(){
	#增加登录用户
	info_echo "add login user..."
	useradd $LOGIN_USER
	echo -e  $LOGIN_PASSWD | passwd  $LOGIN_USER --stdin
	echo -e  $LOGIN_PASSWD_ROOT | passwd  root --stdin
}
disable_ipv6(){
#禁用ipv6地址
	info_echo "disabled ipv6..."
	echo "alias net-pf-10 off" >> /etc/modprobe.conf
	echo "alias ipv6 off" >> /etc/modprobe.conf
	echo "install ipv6 /bin/true" >> /etc/modprobe.conf
	echo "IPV6INIT=no" >> /etc/sysconfig/network
	sed -i 's@NETWORKING_IPV6=yes@NETWORKING_IPV6=no@'    /etc/sysconfig/network
	chkconfig ip6tables off
}
vim_conf(){
	#vim基础语法优化
	info_echo "vim optimized..."
grep -q "colorscheme evening" /root/.vimrc || \
cat  >> /root/.vimrc << eof
colorscheme evening 
syntax on
set ts=4
set expandtab
set shiftwidth=4

eof
}

turn_off_unnecessar_services(){
        echo "Turn off unnecessar services."
        cd /etc/init.d
        services=`for  i in * ;do echo $i ;done`
        for service in $services ; do
        case $service in
                snmpd)                          ;;
                crond)                          ;;
                cpuspeed)                       ;;
                dnsmasq)                        ;;
                iptables)                       ;;
                irqbalance)                     ;;
                kudzu)                          ;;
                messagebus)                     ;;
                mysqld)                         ;;
                network)                        ;;
                ntpd)                           ;;
                rawdevices)                     ;;
                sshd)                           ;;
                rsyslog)                        ;;
                salt-minion)                    ;;
                zabbix-agent)                   ;;
                zebra)                          ;;
                *)
		service $service stop && chkconfig --level 2345 $service off
                ;;
        esac
        done
}
del_usergroup(){
    echo "Delete system unnecessar usergroup."
    user="adm lp sync shutdown halt news uucp operator games gopher ftp"
    group="ftp adm lp news uucp dip"
    for u in $user;do userdel $u;done
    for g in $group;do groupdel $g;done
    echo "Delete usergroup ok..."
}

limit_login_num(){
	#设置用户登录失败锁定阀值，锁定时间
	info_echo "set login faild lock time..."
	cp -p /etc/pam.d/sshd /etc/pam.d/sshd.back
	#sed -i "/#%PAM-1.0/a\ auth    required    pam_tally2.so    deny=$LOGIN_FAILD    unlock_time=$LOCK_TIME even_deny_root root_unlock_time=$LOCK_TIME" /etc/pam.d/sshd
	#查看错误登录次数
	#pam_tally2 –u USER 
	#解锁命令
	#pam_tally2 -u USER --reset
}

modify_history(){
	#设置bash保留的历史命令数目
	info_echo "set bash history command amount..."
	cp -p /etc/profile /etc/profile.back 
	sed -i "s/HISTSIZE=1000/HISTSIZE=5000/" /etc/profile
	grep -q "export HISTTIMEFORMAT=" /etc/profile || \
	echo "export HISTTIMEFORMAT=\"%F %T `whoami` \"" >>/etc/profile
	grep -q "alias grep=" /etc/profile ||  \
	echo "alias grep='grep --color=auto'" >>/etc/profile
}
print_system_errors(){
    info_echo "Print system errors."
    grep --color -niE error /var/log/messages
}
bringup_active_network_devices_onboot(){
    cd /etc/sysconfig/network-scripts
    interfaces=$(ls ifcfg* | \
                LANG=C sed -e "$sed_discard_ignored_files" \
                           -e '/\(ifcfg-lo\|:\|ifcfg-.*-range\)/d' \
                           -e '/ifcfg-[A-Za-z0-9\._-]\+$/ { s/^ifcfg-//g;s/[0-9]/ &/}' | \
                LANG=C sort -k 1,1 -k 2n | \
                LANG=C sed 's/ //')
    # bringup all interfaces first
    for i in $interfaces ; do ifconfig $i up ; done
    # active linked network card
    for i in $interfaces ; do
            `ethtool $i | grep -Eq 'Link detected: yes'` \
                                    && ifconfig $i up \
                                    || ifconfig $i down
    done
    active_device=`echo $(/sbin/ip -o link show up | awk -F ": " '{ print $2 }')`
    for i in $active_device ; do
            # make sure device: ethN onboot
            CMD="sed -i '/ONBOOT/s/no/yes/' /etc/sysconfig/network-scripts/ifcfg-$i"
            action $"bringup $i onboot..." eval $CMD
            `ethtool $i | grep -Eq "(10|100)Mb/s"` \
        && ethtool $i | grep --color -iE -A 9 -B 10 "(10|100)Mb/s" \
    
    done
    cd - &
}
update_os(){
    info_echo "update os system to the latest version."
    nohup yum -y update &>/tmp/update_os.log &
}


get_devices_info(){
    info_echo "get devices info.."
    sh $PWD/device_info.sh
}
menu(){
word="
check_version
change_hostname
add_default_dns
dns_test
bringup_active_network_devices_onboot
yum_repo
ntp_check
ulimit_modify
disabled_cad
disabled_selinux
modify_kernel_conf
change_sshd_port
add_user_login
disable_ipv6
vim_conf
turn_off_unnecessar_services
del_usergroup
limit_login_num
modify_history
print_system_errors
update_os
get_devices_info
exit
"
PS3="Select which you want to do: "

select i in $word ;do
    echo "================== start ====================="
    case $i in
	check_version				) check_verison			;;
	change_hostname				) change_hostname			;;
	add_default_dns				) add_default_dns			;;
	dns_test				) dns_test			;;
	bringup_active_network_devices_onboot	) bringup_active_network_devices_onboot	;;
	yum_repo				) yum_repo			;;
	ntp_check				) ntp_check			;;
	ulimit_modify				) ulimit_modify			;;
	disabled_cad				) disabled_cad			;;
	disabled_selinux			) disabled_selinux			;;
	modify_kernel_conf			) modify_kernel_conf		;;
	change_sshd_port			) change_sshd_port			;;
	add_user_login				) add_user_login			;;
	disable_ipv6				) disable_ipv6			;;
	vim_conf				) vim_conf			;;
	turn_off_unnecessar_services		) turn_off_unnecessar_services	;;
	del_usergroup				) del_usergroup			;;
	limit_login_num				) limit_login_num			;;
	modify_history				) modify_history			;;
	print_system_errors			) print_system_errors		;;
	update_os			        ) update_os		;;
    get_devices_info                       ) get_devices_info                         ;;             # 
    exit                                    ) break                                    ;;     # exit
    *                                       ) echo "input error"                       ;;
    esac

    echo "==================== end ====================="

done
}

case $1 in 
	--auto|auto)
	check_version
	change_hostname
	add_default_dns
	dns_test
	bringup_active_network_devices_onboot
	yum_repo
	ntp_check
	ulimit_modify
	disabled_cad
	disabled_selinux
	modify_kernel_conf
	change_sshd_port
	add_user_login
	disable_ipv6
	vim_conf
	turn_off_unnecessar_services
	del_usergroup
	limit_login_num
	modify_history
    update_os
    get_devices_info
	print_system_errors
	info_echo "init OK @@!!"
	;;
	--debug|debug)
	check_version
	add_default_dns
	dns_test
	info_echo "debug OK@@!!"
	;;
	--menu|menu)
	menu
	;;	
	*)
        echo $"Usage: $0 {debug|auto|menu}"
        break
        ;;
esac
#重启服务器
#rebooit
