#!/bin/bash  
###########################################################################
# File Name: add_monion.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-12-01 09:55:49
###########################################################################

ip=$1
hostname=$2
auth=$3

[ $# -ne 3 ] && {
	echo "USAGE: `basename $0` ip hostname passwd_for_root"
	exit 1
}

[ $UID -ne 0 ] && {
	echo "Run `basename $0`: Permission denied!"
	exit 2
}

source_dir='/srv/salt/test/files'
last_hosts="`ll -t $source_dir|grep hosts|head -1|awk '{print $NF}'`"
new_hosts="hosts.v`date +%F|sed 's/-//g'`"
cp $source_dir/$last_hosts $source_dir/$new_hosts
if [ $? -ne 0 ];then
	secv=`echo $last_hosts|awk -F '_' '{print $2}'`
	if [ x'$secv' == x ];then
		new_hosts="hosts.v`date +%F|sed 's/-//g'`_1"
	else
		new_hosts="hosts.v`date +%F|sed 's/-//g'`_(($secv + 1))"
	fi
	cp $source_dir/$last_hosts $source_dir/$new_hosts
	[ $? -ne 0 ] && {
		echo "An error occourd when backup the hosts file."
		exit 3
	}
fi

echo $hostname >> $source_dir/$new_hosts

sed -i "s/$last_hosts/$new_hosts/g" ./hosts.sls
	
/usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$ip
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
    "root@" {
        send { sed -i "s/\(HOSTNAME=\).*/\1$hostname/g" /etc/sysconfig/network }
        send "\r"
        send { hostname $hostname }
        send "\r"
        send { echo '10.0.1.17	manager01' >> /etc/hosts }
        send "\r"
        send { yum install -y salt-minion }
        send "\r"
        send { sed -i "s/#master: salt/master: manager01/g;s/#id:/id: $hostname/g"  /etc/salt/minion }
        send "\r"
        send { /etc/init.d/salt-minion start }
        send "\r"
        send "exit 1\r"
        expect eof
        exit
    }
}
EOF


