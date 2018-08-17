#!/bin/bash
###########################################################################
# File Name: create_user.sh
# Author: yushuibo
# Mail: hengchen2005@gmail.com
# Descraption: 通过一个hosts映射文件来批量添加用户名。
# Created Time: 2017-11-07 19:11:02
###########################################################################


[ $# -ne 1 ] && {
	echo "USAGE: `basename $0` host_file"
	exit 10
}

file=$1
[ -f $file ] || {
	echo "$file not found."
	exit 10
}

hosts=(`cat $file|grep -Ev "^#"|awk -F ':' '{print $2}'`)
# modify here with the username you want to add.
usernames=("chp")

# test the user is root or not
[ $UID -ne 0 ] && {
    echo "Only the root user can be execute this scripts!"
    exit 100
}
# test the expect application is installed or not. if not, install it
[ `rpm -qa expect|wc -l` -eq 0 ] && yum install -y expect
 
create_user(){
    local host=$1
	local user=$2
	local pass=$3
    # create user for each host, and make the value is "yes" of argvment "PasswordAuthentication" in sshd_config, and then restart sshd service 
    /usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$host
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
	"root@" { 
		send { useradd $user -g ggw && echo $pass|passwd --stdin $user }
		send "\r"
		send { sed -i 's/^\(PasswordAuthentication\).*/\1 yes/g' /etc/ssh/sshd_config }
		send "\r"
		send { /etc/init.d/sshd restart }
		send "\r"
		send "exit 1\r"
		expect eof
		exit
	 } 
}
EOF
echo "==== $host ====" >> users.txt
echo "$user: $pass" >> users.txt
}

for username in ${usernames[*]};do
	# get a random password string
	# pass=`echo $RANDOM | md5sum | cut -c 2-9`
	pass='_bjKo^4lsV#FcX%P'
    for host in ${hosts[*]};do
		# the root's password
		if [ $host == '10.0.0.15' ];then
			auth='_2018=JMgame%HexBv^75Qp'
		else
			auth='kgF^91@bhL_2018=JMgame%'
		fi
        create_user $host $username $pass
    done
done
