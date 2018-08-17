#!/bin/bash
###########################################################################
# File Name: mk_sudoer.sh
# Author: yushuibo
# Mail: hengchen2005@gmail.com
# Descraption: 通过一个hosts映射文件来批量把账号添加到sudoers里面，且sudo时免密码。
# Created Time: 2017-11-07 19:11:02
###########################################################################

[ $# -ne 3 ] && {
	echo "UASGE: `basename $0` username new_passwd host_file"
	exit 10
}

user=$1
new_pass=$2

file=$3
[ -f $file ] || {
	echo "$file not found."
	exit 11
}
hosts=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $2}'`)

[ $UID -ne 0 ] && {
    echo "Only the root user can be execute this scripts!"
    exit 100
}

[ `rpm -qa expect|wc -l` -eq 0 ] && yum install -y expect
 
chpass(){
    local host=$1
    /usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$host
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
	"root@" { 
		send { echo $new_pass|passwd --stdin $user }
		send "\r"
		send "exit 1\r"
		expect eof
		exit
	 } 
}
EOF
}

for host in ${hosts[*]};do
	auth='hgF^91@bhL^=JMgame2018%'
    chpass $host
done
