#!/bin/bash
###########################################################################
# File Name: mk_sudoer.sh
# Author: yushuibo
# Mail: hengchen2005@gmail.com
# Descraption: 通过一个hosts映射文件来批量把账号添加到sudoers里面，且sudo时免密码。
# Created Time: 2017-11-07 19:11:02
###########################################################################

[ $# -ne 1 ] && {
	echo "UASGE: `basename $0` maps_file"
	exit 10
}

file=$1
[ -f $file ] || {
	echo "$file not found."
	exit 11
}
hosts=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $1}'`)
projects=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $2}'`)
shells=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $3}'`)

[ $UID -ne 0 ] && {
    echo "Only the root user can be execute this scripts!"
    exit 100
}

[ `rpm -qa expect|wc -l` -eq 0 ] && yum install -y expect
 
send(){
	shell=$1
	host=$2
	project=$3
	if [ "$host"x == "testbased01"x ];then
		auth='_2018=JMgame%HexBv^75Qp'
	else
		auth='kgF^91@bhL_2018=JMgame%'
	fi

	echo "Copying $shell to project: $project on $host ..."
    /usr/bin/expect <<EOF
set timeout -1
spawn scp $shell $host:$project
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
    }
EOF
}

for ((i=0;i<${#projects[*]};i++));do
	h=${hosts[$i]}
	p=${projects[$i]}
	s=${shells[$i]}
    send $s $h $p
done
