#!/bin/bash
# MySQL backup
# Author: yushuibo
# Date: 2017-10-26

host='10.0.1.16'
auth='kgF^91@bhL_2018=JMgame%'
db_user="dumper"
db_passwd="db_jm123"
db_port=3306
db_run="mysql -u$db_user -p$db_passwd -h$host"
db_dump="mysqldump -h$host -u$db_user -p$db_passwd"
db_data_dir="/data/mysql"
db_backup_root="/backup/$host"
db_backup_dir="$db_backup_root/$(date +%F)"
log_file="/var/log/mysql_backup.log"
target_dbs=(`$db_run -e "show databases;"|grep -Ev "Database|performance_schema|information_schema"`)


# Write logs.
log(){
    local log_type=$1
    local msg=$2
    local file=$3
    # echo "`date '+%Y-%m-%d %H:%M:%S'` - [$log_type]: $msg" >> $file
    echo "`date '+%Y-%m-%d %H:%M:%S'` - [$log_type]: $msg"
}

# Judge mysql service is running or not
is_mysql_running(){
    if [ `ps -ef|grep mysqld|wc -l` -eq 1 ];then
        log "ERROR" "Mysql is not running!" $log_file
        exit 1
    fi
}

# do backup
backup(){
	local db=$1
	local table=$2
	# if not give the database, default to action a full backup
	if [ x"$db" == x ];then
		local dir=$db_backup_dir
		[ ! -d $dir ] && mkdir -p $dir
		$db_dump -C -B ${target_dbs[*]} --flush-privileges --single-transaction --routines --events|gzip > $dir/full_bak.sql.gz 
		if [ $? -eq 0 ];then
			log "MESSAGE" "The full backup of mysql has done." $log_file
		else
			log "ERROR" "An error occourd when dumpping the full backup of mysql." $log_file
			exit 2
		fi
	# if not give a table, then backup the gived database.
	elif [ x"$table" == x ];then
		local dir="${db_backup_dir}/$db"
		[ ! -d $dir ] && mkdir -p $dir
		$db_dump -C -B $db --master-data=1 --flush-privileges --single-transaction --routines --events|gzip > $dir/$db.sql.gz
        if [ $? -eq 0 ];then
            log "MESSAGE" "Database $db backup has done." $log_file
        else
            log "ERROR" "An error occourd when dumpping the database $db." $log_file
            exit 3
		fi
	# otherwise, backup the dest table in gived database.
	else
		local dir="${db_backup_dir}/$db"
		[ ! -d $dir ] && mkdir -p $dir
		$db_dump $db $table -C --master-data=1 --flush-privileges --single-transaction --routines --events|gzip > $dir/${db}_$table.sql.gz
        if [ $? -eq 0 ];then
            log "MESSAGE" "Table $table in database $db backup has done." $log_file
        else
            log "ERROR" "An error occourd when dumpping the table $table in databases $db." $log_file
            exit 4
        fi
	fi
}

# The backup of mysql for each database
all_dbs_backup(){
    for db in ${target_dbs[*]};do
		backup $db
	done
}

# The backup of mysql for tables
all_tables_backup(){
    for db in ${target_dbs[*]};do
        target_tables=(`$db_run -e "show tables from $db;"|sed '1d'`)
        for table in ${target_tables[*]};do
			backup $db $table
        done
    done
}

# Copy the binlog files to backup directoty.
copy_binlog(){
    local dir="${db_backup_dir}/binlog"
    if [ ! -d $dir ];then
        mkdir -p $dir
    fi
	    /usr/bin/expect <<EOF
set timeout -1
spawn scp root@$host:$db_data_dir/mysql-bin.* $dir
expect {
    "yes/no" { send "yes\r";exp_continue; }
    "*password" { send "$auth\r";exp_continue; }
    expect eof
    exit
}
EOF
    if [ $? -eq 0 ];then
        log "MESSAGE" "The binlog files has been copyed to backup directory." $log_file
    else
        log "ERROR" "An error occourd when copying the binlog files." $log_file
        exit 5
    fi
}

# Compact the backup files use gzip, and use md5sum create a fingerprint information for the target file.
compact(){
    local gzip_file="${host}_mysql_backup_$(date +%F).tar.gz"
    cd $db_backup_root
    tar cfP $gzip_file $db_backup_dir
    if [ $? -eq 0 ];then
        md5sum $gzip_file >> $gzip_file.md5
    else
        log "ERROR" "An error occourd when compressing the backup files." $log_file
        exit 6
    fi
    /bin/rm -rf ./$(date +%F)
}

# Sync the backup files to backup server.
sync_files(){
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
del_files(){
	cd $db_backup_root && find ./ -type f -mtime +1|xargs /bin/rm -rf
    if [ $? -eq 0 ];then
        log "MESSAGE" "The backup files which copyed at 1 days ago has been deleted." $log_file
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
	log "MESSAGE" "MySQL backup for $host start ..." $log_file
    backup
    # all_dbs_backup
    # all_tables_backup
	# split bin-log
	$db_run -e "flush logs;"
	copy_binlog
	compact
    # sync_files
    del_files
	log "MESSAGE" "MySQL backup for $host end." $log_file
}

main $*
