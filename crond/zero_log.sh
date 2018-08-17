#!/bin/bash  
###########################################################################
# File Name: zero_log.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-11-28 17:22:49
###########################################################################

hosts=('10.0.1.36' '10.0.1.22' '10.0.1.34' '10.0.0.6' '10.0.1.3' '10.0.1.25' '10.0.0.32' '10.0.0.23' '10.0.1.44' '10.0.0.27' '10.0.1.40')
auth='_gHkj^5hF#ladi%w'
project_root='/jmserver'


for host in ${hosts[*]};do
	/usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$host
expect {
	"yes/no" { send "yes\r";exp_continue; }
	"*password" { send "$auth\r";exp_continue; }
	"root@" {
    	send { cd $project_root }
    	send "\r"
		send { for dir in \`find . -type d -name 'logs'|sed 's#\.#/jmserver#g'|xargs\`;do echo "" > \$dir/*.log;done }
    	send "\r"
    	send "exit 1\r"
    	expect eof
    	exit
	}
}
EOF
done
