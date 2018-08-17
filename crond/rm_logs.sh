#!/bin/bash  
###########################################################################
# File Name: rm_logs.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-11-28 17:22:49
###########################################################################

hosts=('10.0.1.36' '10.0.1.22' '10.0.1.34' '10.0.0.6' '10.0.1.3' '10.0.1.25' '10.0.0.32' '10.0.0.23' '10.0.1.44' '10.0.0.27' '10.0.1.40')
auth='_gHkj^5hF#ladi%w'

for host in ${hosts[*]};do
	/usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$host
expect {
	"yes/no" { send "yes\r";exp_continue; }
	"*password" { send "$auth\r";exp_continue; }
	"root@" {
    	send { cd /jmserver }
    	send "\r"
		send { dirs=(\`find . -type d -name 'log'|sed 's#^\.#/jmserver#g'|xargs\`) }
    	send "\r"
		send { split_time=\$(date -d "-1 month" +%F);for dir in \${dirs[*]};do cd \$dir;files=(\`ll|awk '{print \$NF}'|grep -E ".*.log.*-*-*.log"\`);for file in \${files[*]};do t=\$(date -d "\`echo \$file|awk -F '.' '{print \$3}'\`" +%F);if [ \$t \< \${split_time} ];then /bin/rm -rf \$file;fi;done;done }
    	send "\r"
    	send "exit 1\r"
    	expect eof
    	exit
	}
}
EOF
done
