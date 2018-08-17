#!/bin/bash  
###########################################################################
# File Name: check_top.sh
# Author: shy
# Mail: hengchen2005@gmail.com
# Descraption: 
#	Check the highest percent of cpu and memory usage for process.
#
# Created Time: 2018-07-21 19:55:30
###########################################################################

mode=$1
threshold=$2

cpu_tmp_file='/tmp/.cpu_info.txt'
mem_tmp_file='/tmp/.mem_info.txt'
touch $cpu_tmp_file $mem_tmp_file
chown zabbix:zabbix $cpu_tmp_file
chown zabbix:zabbix $mem_tmp_file

last_cpu_info=`cat $cpu_tmp_file 2>/dev/null`
last_mem_info=`cat $mem_tmp_file 2>/dev/null`
cur_cpu_info=`top -b -n 1|tail -n +8|head -1|awk '{print $1"\t"$9}'`
cur_mem_info=`top -a -b -n 1|tail -n +8|head -1|awk '{print $1"\t"$10}'`
echo $cur_cpu_info > $cpu_tmp_file
echo $cur_mem_info > $mem_tmp_file

if [ "$mode"x = "cpu"x ] && [ "$last_cpu_info" != ""x ];then
	last_pid=`echo $last_cpu_info|awk '{print $1}'`
	last_per=`echo $last_cpu_info|awk '{print $2}'`
	cur_pid=`echo $cur_cpu_info|awk '{print $1}'`
	cur_per=`echo $cur_cpu_info|awk '{print $2}'`
elif [ "$mode"x = "mem"x ] && [ "$last_mem_info" != ""x ];then
	last_pid=`echo $last_mem_info|awk '{print $1}'`
	last_per=`echo $last_mem_info|awk '{print $2}'`
	cur_pid=`echo $cur_mem_info|awk '{print $1}'`
	cur_per=`echo $cur_mem_info|awk '{print $2}'`
else
	exit 2
fi

# is_cur_per_gt_threshold=`awk -v n1=$cur_per -v  n2=$threshold 'BEGIN{print (n1 > n2) ? "1":"0"}'`
# is_last_per_gt_threshold=`awk -v n1=$last_per -v n2=$threshold 'BEGIN{print (n1 > n2) ? "1":"0"}'`

if [ $(echo "${cur_per} > ${threshold}"|bc) -eq 1 ] && [ $(echo "${last_per} > ${threshold}"|bc) -eq 1 ] &&  [ "$cur_pid" =  "$last_pid" ];then
	echo 1
else
	echo 0
fi

exit 0
