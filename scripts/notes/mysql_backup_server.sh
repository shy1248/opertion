#!/bin/bash
# Mysql backup script for backup server, check the backup file is right and send mail.
# Author: yushuibo
# Date: 2017-10-26

backup_root="/backup"
recevied="12345678@qq.com xxxxx@qq.com"

# Send email to adm.
send_mail(){
    local msg=$1
    echo $1|mail -s "MySQL backup report!" $recevied
}

# Check the backup files.
check(){
    local target_file="mysql_backup_$(date +%F).tar.gz"
    local md5_file="$target_file.md5"
    if [ !-f $target_file ];then
        local msg="The backup files $target_file is not found on the backup server!"
        send_mail $msg
        exit 1
    fi

    if [ ! -f $md5_file ];then
        local msg="The fingerprint information is not found of $target_file"
        send_mail $msg
        exit 2
    fi

    if [ `md5sum -c $md5_file|grep "OK"|wc -l` -eq 0 ];then
        local msg="The fingerprint information is not right of $target_file"
        send_mail $msg
        exit 3
    else
        local msg="The backup file $target_file is good!"
        send_mail $msg
    fi
}

# Delete the backup files of 180 days ago.
del_file(){
    find $backup_root -type f -mtime +180|xargs rm -rf
}

check
del_file
