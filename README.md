# Shell
#运维脚本

vpn_centos6.sh
运行一键安装包

#bash vpn_centos6.sh

会有三个选择:

安装VPN服务
修复VPN
添加VPN用户
首先输入1，回车,VPS开始安装VPN服务（VPN服务安装完毕后会默认生成一个用户名为vpn，密码为随机数的用户来。）

此外需要添加新的VPN用户时，作如下操作，

#bash vpn_centos6.sh

然后选择3，然后输入用户名和密码,OK

修复VPN服务 
如果VPN拨号发生错误,可以试着修复VPN,然后重启VPS
#bash vpn_centos6.sh

选择2，然后reboot
