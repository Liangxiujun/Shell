#!/bin/bash
#audit conf

mkdir -p /var/log/.usermonitor
touch /var/log/.usermonitor/usermonitor.log
chown nobody:nobody /var/log/.usermonitor/usermonitor.log
chmod 002 /var/log/.usermonitor/usermonitor.log
chattr +a /var/log/.usermonitor/usermonitor.log


if [ -f /etc/rsyslog.conf ]
then
    cat syslog_conf >> /etc/rsyslog.conf
    service rsyslog restart
else
    cat syslog_conf >> /etc/syslog.conf
    service syslog restart
fi

echo '111.13.137.185 logserver' >>/etc/hosts
echo "> ~/.bash_history" >> /etc/bashrc
echo "export HISTTIMEFORMAT=''" >> /etc/bashrc
echo "export HISTORY_FILE=/var/log/.usermonitor/usermonitor.log" >> /etc/bashrc

cat hist_format >> /etc/bashrc
. /etc/bashrc
sed -i '/NOPASSWD: ALL/s/#//g' /etc/sudoers
for user in `cat user_list`
do
    useradd -g wheel monitor
    useradd -g wheel $user
    echo 'clickwise123456' | passwd --stdin $user
    chage -d0 $user
done
