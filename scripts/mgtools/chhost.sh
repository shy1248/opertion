#!/bin/bash
###########################################################################
# File Name: chhost.sh
# Author: yushuibo
# Mail: hengchen2005@gmail.com
# Descraption: 通过一个hosts映射文件来批量把账号添加到sudoers里面，且sudo时免密码。
# Created Time: 2017-11-07 19:11:02
###########################################################################

[ $# -ne 1 ] && {
	echo "UASGE: `basename $0` host_file"
	exit 10
}

file=$1
[ -f $file ] || {
	echo "$file not found."
	exit 11
}

ips=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $2}'`)
hosts=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $1}'`)
auth='_gHkj^5hF#ladi%w'

[ $UID -ne 0 ] && {
    echo "Only the root user can be execute this scripts!"
    exit 100
}

[ `rpm -qa expect|wc -l` -eq 0 ] && yum install -y expect
 
chhost(){
	local ip=$1
    local host=$2
    /usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$ip
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
	"root@" { 
		send { sed -i -e "s/HOSTNAME=.*/HOSTNAME=$host/g" /etc/sysconfig/network }
		send "\r"
		send { hostname $host }
		send "\r"
		send "exit 1\r"
		expect eof
		exit
	 } 
}
EOF
}

for ((i=0;i<${#ips[@]};i++));do
	ip=${ips[$i]}
	host=${hosts[$i]}
    chhost $ip $host
done
