#!/bin/bash
logfile='/var/log/mysql_backup.log'
echo '' > $logfile

ips=("10.0.1.16" "10.0.0.11" "10.0.0.14")
auth='=^GbF^34@ljLJMgame2018%'
for ip in ${ips[*]};do
	/bin/bash ./mysql_backup_remote.sh $ip $auth
done
