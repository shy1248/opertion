#!/bin/bash  
###########################################################################
# File Name: ssh_limit.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2018-01-08 14:48:38
###########################################################################
cat /var/log/secure|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1;}' > /root/limit_ssh.txt
DEFINE="3"
for i in `cat  /root/limit_ssh.txt`
do
    IP=`echo $i|awk -F '=' '{print $1}'`
    NUM=`echo $i|awk -F '=' '{print $2}'`
    if [ $NUM -gt $DEFINE ];then
        grep $IP /etc/hosts.deny > /dev/null
        if [ $? -gt 0 ];then
            echo "sshd:$IP:deny" >> /etc/hosts.deny
        fi
    fi
done
