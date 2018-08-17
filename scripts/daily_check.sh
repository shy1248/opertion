#!/bin/bash  
###########################################################################
# File Name: daily_check.sh
# Author: yushuibo  
# Mail: shyu@jiemai-tech.com
# Descraption: servers daily checked. 
# Created Time: 2017-10-31 16:45:10
###########################################################################

# will be checked hosts.
hosts=("10.0.1.17" "10.0.1.36" "10.0.1.8" "10.0.1.11" "10.0.1.22" "10.0.1.34" "10.0.0.6" "10.0.1.3" "10.0.1.25" "10.0.0.32" "10.0.0.23" "10.0.1.44" "10.0.0.27" "10.0.1.40" "1        0.0.1.42" "10.0.1.35" "10.0.1.18" "10.0.1.48" "10.0.0.12" "10.0.0.4" "10.0.0.9" "10.0.1.9" "10.0.0.7" "10.0.1.16" "10.0.0.11" "10.0.0.14" "10.0.1.7" "10.0.0.16")
report_home="/reoprts/daily_check"

export LC_ALL="en_US.UTF-8"
server_info(){
    echo ====================== Basic Info ==============================
    echo 1-Hostname
    /bin/hostname
	echo
    echo 2-IP MASK
    /sbin/ifconfig eth0|grep "inet addr:"|awk '{print $2,"/ "$4}'
	echo
    echo 3-Gateway
    cat /etc/sysconfig/network|grep GATEWAY|awk -F "=" '{print $2}'
	echo
    echo 4-Product Name
    dmidecode | grep -A10 "System Information$" |grep "Product Name:"|awk '{print $3,$4,$5}'
	echo
    echo 5-CPU
    cat /proc/cpuinfo|grep "name"|cut -d: -f2 |awk '{print "*"$1,$2,$3,$4}'|uniq -c
	echo
    echo 6-Physical memory number
    dmidecode | grep -A 16 "Memory Device$" |grep Size:|grep -v "No Module Installed"|awk '{print "*" $2,$3}'|uniq -c
	echo
    echo 7-System version
    cat /etc/issue | head -1
	echo
}
 
OS_info(){
    echo ======================= OS Info ================================
    echo 1-Kernel Version
    uname -a
	echo
    echo 2-Running Days
    /usr/bin/uptime
	echo
}
 
performance_info(){
    echo ======================= Performance =============================
    echo 1-CPU Info
    top -b -n 1|head -25
	echo
    echo 2-Mem Info
	free -m
	echo
	echo 4-Disk Info
	echo
}
 
sec_info(){
    echo ======================= Security =============================
    echo 1-Users Load
    w
	echo
    echo 2-File Used
    df -ah
	echo
    echo 3-Demsg Errors
    dmesg |grep fail
    dmesg |grep error
    lastlog
	echo
}

check(){
	# test the user is root or not
	[ $UID -ne 0 ] && echo Permission denied! && exit 1
	# test dmidecode is installed or not. if not, install it.
	[ `rpm -qa dmidecode|wc -l` -eq 0 ] && yum install -y dmidecode
	# if the report home directory not exist, create it.
	[ ! -d $report_home ] && mkdir -p $report_home
	server_info >> $report_home/$(/bin/hostname)-`date +%F`.txt
	OS_info >> $report_home/$(/bin/hostname)-`date +%F`.txt
	performance_info >> $report_home/$(/bin/hostname)-`date +%F`.txt
	sec_info >> $report_home/$(/bin/hostname)-`date +%F`.txt
	echo "$(/bin/hostname) daily check has done!"
}

for host in ${hosts[*]};do
	
done
