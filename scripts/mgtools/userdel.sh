#!/bin/bash

[ $# -ne 1 ] && {
	echo "USAGE: `basename $0` host_file"
	exit 10
}

file=$1
[ -f $file ] || {
	echo "$file not found."
	exit 11
}
hosts=`cat $file|grep -Ev "^#"|awk -F ':' '{print $2}'`
usernames=("hta")
auth='kgF^91@bhL_2018=JMgame%'

[ $UID -ne 0 ] && {
    echo "Only the root user can be execute this scripts!"
    exit 100
}

[ `rpm -qa expect|wc -l` -eq 0 ] && yum install -y expect

del_user(){
    local host=$1
	local name=$2
    /usr/bin/expect <<EOF
#set timeout -1
spawn ssh root@$host
expect { 
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
    "root@" { 
        send "userdel $name -r\r";
		send "exit 1\r"
        expect eof
        exit
    }
}
EOF
}

for username in ${usernames[*]};do
    for host in ${hosts[*]};do
        del_user $host $username
    done
done
