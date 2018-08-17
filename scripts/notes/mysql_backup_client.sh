#!/bin/bash
# MySQL backup
# Author: yushuibo
# Date: 2017-10-26

db_user="root"
db_passwd=""
db_port=3306
db_run="mysql -u$db_user -p$db_passwd"
db_dump="mysqldump -u$db_user -p$db_passwd"
db_data_dir="/data/mysql"
db_backup_root="/backup"
db_backup_dir="$db_backup_root/$(date +%F)"
log_file="/var/log/mysql_bak.log"

# Write logs.
log(){
    local log_type=$1
    local msg=$2
    local file=$3
    echo "`date '+%Y-%m-%d %H:%M:%S'` - $log_type:$msg" >> $file
}

# Judge mysql service is running or not
is_mysql_running(){
    if [ `ps -ef|grep mysqld|wc -l` -eq 1 ];then
        log "ERROR" "Mysql is not running!" $log_file
        exit 1
    fi
}

# The full backup of mysql
full_backup(){
    is_mysql_running
    local dir=$db_backup_dir
    if [ ! -d $dir ];then
        mkdir -P $dir
    fi
    $db_dump -A --flush-privileges --single-transaction --flush-logs --triggers --routines --events --hex-blob|gzip >> $dir/full_bak.tar.gz 
    if [ $? -eq 0 ];then
        log "MESSAGE" "The full backup of mysql has done." $log_file
    else
        log "ERROR" "An error occourd when dumpping the full backup of mysql." $log_file
        exit 2
    fi
}

# The backup of mysql for each database
db_backup(){
    is_mysql_running
    target_dbs=(`$db_run -e "show databases;"|grep -Ev "Database|performance_schema"`)
    for db in ${target_dbs[*]};do
        local dir=${db_backup_dir}/$db
        if [ ! -d $dir ];then
            mkdir -P $dir
        fi
        $db_dump -B $db --flush-privileges --single-transaction --flush-logs --triggers --routines --events --hex-blob|gzip >> $dir/$db.tar.gz
        if [ $? -eq 0 ];then
            log "MESSAGE" "Database $db backup has done." $log_file
        else
            log "ERROR" "An error occourd when dumpping the database $db." $log_file
            exit 3
        if
    done
}

# The backup of mysql for tables
tables_backup(){
    is_mysql_running
    target_dbs=(`$db_run -e "show databases;"|grep -v "Database"`)
    for db in ${target_dbs[*]};do
        target_tables=(`$db_run -e "show tables from $db;"|sed '1d'`)
        local dir="${db_backup_dir}/$db"
        if [ ! -d $dir ];then
            mkdir -P $dir
        fi
        for table in ${target_tables[*]};do
            $db_dump $db $table|gzip >> $dir/$table.tar.gz 
            if [ $? -eq 0 ];then
                log "MESSAGE" "Table $table in database $db backup has done." $log_file
            else
                log "ERROR" "An error occourd when dumpping the table $table in databases $db." $log_file
                exit 4
            fi
        done
    done
}

# Copy the binlog files to backup directoty.
copy_binlog(){
    local dir="${db_backup_dir}/binlog"
    if [ ! -d $dir ];then
        mkdir -P $dir
    fi
    find $db_data_dir -type f -name "mysql-bin.*"|xargs cp -t $dir
    if [ $? -eq 0 ];then
        log "MESSAGE" "The binlog files has been copyed to backup directory." $log_file
    else
        log "ERROR" "An error occourd when copying the binlog files." $log_file
        exit 5
    fi
}

# Compact the backup files use gzip, and use md5sum create a fingerprint information for the target file.
compact(){
    local gzip_file="mysql_backup_$(date +%F).tar.gz"
    cd $db_backup_root
    tar cf $gzip_file $db_backup_dir
    if [ $? -eq 0 ];then
        md5sum $gzip_file >> $gzip_file.md5
    else
        log "ERROR" "An error occourd when compressing the backup files." $log_file
        exit 6
    fi
    cd /backup
    rm -rf ./$(date +%F)
}

# Sync the backup files to backup server.
sync_file(){
    local passwd_file="/etc/rsyncd.secret"
    local rsync_user="rsync_user"
    local rsync_host="10.0.0.0"
    local remote_dir="backup"
    rsync -avz --password-file=$passwd_file $db_backup_root/ $rsync_user@$rsync_host::$remote_dir
    if [ $? -eq 0 ];then
        log "MESSAGE" "Backup files has been synced to remote server." $log_file
    else
        log "ERROR" "An error occourd when syncing the backup files." $log_file
        exit 7
    fi
}

# Delete expires backup files.
del_backup(){
    find $db_backup_root -type f -mtime +7|xargs rm -rf
    if [ $? -eq 0 ];then
        log "MESSAGE" "The backup files which copyed at 7 days ago has been deleted." $log_file
    else
        log "ERROR" "An error occourd when deleteing the backup files." $log_file
        exit 8
    fi
}

# Function main.
main(){

    # Judge the user is root or not.
    [ $UID -ne 0 ] && {
        log "ERROR" "Only the root user can be executed this scripts!" $log_file 
        exit 100
    }
    full_backup
    db_backup
    tables_backup
    copy_binlog
    compact
    sync_file
    del_backup
}

main $*
