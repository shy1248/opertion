#!/bin/bash
###########################################################################
# File Name: mk_sudoer.sh
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
hosts=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $2}'`)
usernames=("chp")


[ $UID -ne 0 ] && {
    echo "Only the root user can be execute this scripts!"
    exit 100
}

[ `rpm -qa expect|wc -l` -eq 0 ] && yum install -y expect
 
mk_sudoer(){
    local host=$1
	local user=$2
    # if [[ "$host" == "10.0.1.7" || "$host" == "10.0.0.16" ]];then
         # local auth="kn%J^ydFcZ#jj0"
     # else
         # local auth="9WCkn%J^ydIp"
     # fi
    /usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$host
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
	"root@" { 
		send { echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers}
		send "\r"
		send "exit 1\r"
		expect eof
		exit
	 } 
}
EOF
}

for username in ${usernames[*]};do
    for host in ${hosts[*]};do
		# the passwd of root
		if [ $host == '10.0.0.15' ];then
			auth='_2018=JMgame%HexBv^75Qp'
		else
			auth='kgF^91@bhL_2018=JMgame%'
		fi
        mk_sudoer $host $username
    done
done
