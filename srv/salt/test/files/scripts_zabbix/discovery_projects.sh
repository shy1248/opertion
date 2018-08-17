#!/bin/bash  
###########################################################################
# File Name: discovery_projects.sh
# Author: shy
# Mail: hengchen2005@gmail.com
# Descraption: 
#	Discovery projects on host.
#
# Created Time: 2018-07-23 09:16:55
###########################################################################

conf='/opt/zabbix_scripts/process.list'

if [ ! -f $conf ] || [ "$(cat $conf)"x = ""x ];then
    exit 1
fi

ip=$(ip addr|grep 'inet.*eth0'|grep -v '127.0.0.1'|awk '{print $2}'|cut -d '/' -f 1)

projects=($(grep -v '^#' $conf|grep "$ip"|awk -F ':' '{print $NF}'|tr ';' ' '))
length=${#projects[@]}

echo -e '{\n'
echo -e '\t"data":['

# if [ $length -ge 1 ];then
	for ((i=0;i<$length;i++));do
		if [ $i -eq $[$length-1] ];then
			echo -e "\t\t{\"{#PROJECT}\":\"${projects[$i]}\"}"
		else
			echo -e "\t\t{\"{#PROJECT}\":\"${projects[$i]}\"},"
		fi
	done
# else
	# echo -e "\n\t\t{\"{#PROJECT}\":\"NONE\"}"
# fi

echo -e '\n\t]'
echo -e '}'
