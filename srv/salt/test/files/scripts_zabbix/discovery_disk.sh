#!/bin/bash  
###########################################################################
# File Name: discovery_disk.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2018-07-19 16:16:49
###########################################################################

function get_disk_name () {
    # diskarray=($(cat /proc/diskstats|egrep "\b$1\b"|awk '{print $3}'|sort|uniq   2>/dev/null))
	diskarray=($(df -h|tail -n +2|awk '{print $1}'))
	length=${#diskarray[@]}

    function printf_disk_name () {
		for ((i=0;i<${length};i++));do
        	if [ $i -lt $[${length}-1] ];then
            	printf "{ \"{#DISK}\":\"${diskarray[$i]}\" },\n"
            else
                printf "{ \"{#DISK}\":\"${diskarray[$i]}\" }\n"
            fi
        done
    }
	
    printf "{ \"data\":[\n"
        printf_disk_name
    printf "]}"
}

get_disk_name $1

exit 0

