#!/bin/bash  
###########################################################################
# File Name: xbp.sh
# Author: shy 
# Mail: hengchen2005@gmail.com
# Descraption: 
# Created Time: 2018-08-09 09:31:54
## 备份工具：
##  percona xtrabackup
##
## 备份策略：
##  (1)、每天凌晨04:20点进行全量备份一次；
##  (2)、每隔1小时增量备份一次；
##
###########################################################################

BAK_USER="xbp"
BAK_PASSWD="jm123"

# MySQL配置路径
MYSQL_CNF_PATH="/etc/my.cnf"

# 错误日志文件
LOG="/var/log/xtrabackup.log"


function show_help(){
	echo "Usage: $(basename $0) {full|inc} {nfs-host} [tables-file]"
	echo ""
	echo "Example: $(basename $0) full 10.0.1.46"
	echo "         $(basename $0) inc 10.0.1.46 /crond/dest_tables.txt"
	echo ""
	exit 1
}


# 检查MySQL的版本，当MySQL没安装时返回空；否则返回MySQL的版本
function mysql_version(){
	if [[ $(rpm -qa|grep 'mysql-server'|wc -l) -ne 0 ]];then
		local ver=$(rpm -qa|grep 'mysql-server'|awk -F '-' '{print $3}'|awk -F '.' '{print $1$2}')
		echo $ver
	elif [[ $(rpm -qa|grep 'mysql-community-server'|wc -l) -ne 0 ]];then
		local ver=$(rpm -qa|grep 'mysql-community-server'|awk -F '-' '{print $4}'|awk -F '.' '{print $1$2}')
		echo $ver
	else
		echo ''
	fi
}
 

# 如果MySQL没安装，不做任何操作
# xtrabackup基础套件不存在时，进行自动下载安装
# 当MySQL版本小于等于5.1时，需要安装percona-xtrabackup 2.0；否则安装percona-xtrabackup 2.4
# 安装nfs-utils和rpcbind
function check_env(){
	local nfs_host=$1
	# 安装percona xtrabackup
	if [[ "$(mysql_version)"x != ""x ]];then
		if [[ $(rpm -qa|grep 'percona-xtrabackup'|wc -l) -eq 0 ]];then
			yum install http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -y >/dev/null 2>>$LOG
			if [[ $(mysql_version) -gt 51 ]];then
				yum install percona-xtrabackup-24 -y >/dev/null 2>>$LOG
			elif [[ $(mysql_version) -le 51 ]];then
				yum install percona-xtrabackup-20 -y >/dev/null 2>>$LOG
			fi
		fi
		
		# 安装nfs-utils
		if [[ $(rpm -qa|grep 'nfs-utils'|wc -l) -eq 0 ]];then
			yum install -y nfs-utils 2>>$LOG
		fi
		# 安装rpcbind
		if [[ $(rpm -qa|grep 'rpcbind'|wc -l) -eq 0 ]];then
			yum install -y rpcbind 2>>$LOG
			chkconfig --level 235 rpcbind on
		fi
		
		if [[ $(ps -ef|grep 'rpcbind'|grep -v 'grep'|wc -l) -eq 0 ]];then
			/etc/init.d/rpcbind start
		fi

		# 挂在nfs盘
		if [[ $(df|grep "${nfs_host}"|wc -l) -eq 0 ]];then
			if [[ ! -d /backup ]];then
				mkdir /backup
			fi
			mount -t nfs ${nfs_host}:/backup /backup 2>>$LOG
		fi
	else
		echo "Not Found MySQL server on $(hostname), exit" >>$LOG
		exit 21
	fi
}


# 全备
function full_backup(){

	# 每次全备之前清理日志文件
	echo >$LOG
	# type：备份类型，当为0时表示全库备份；为1时表示备份特定的表
	local type=$1
	if [[ $type -eq 0 ]];then
		innobackupex --defaults-file=${MYSQL_CNF_PATH} --user=$BAK_USER --password=$BAK_PASSWD --slave-info --extra-lsndir=$LSNDIR --stream=tar /tmp 2>>${LOG}|gzip > $BACKUP_BASE_DIR/${CURRENT_DT}_full.tar.gz 2>> ${LOG}
	else
		local dests=$2
		innobackupex --defaults-file=${MYSQL_CNF_PATH} --tables-file=${dests} --user=$BAK_USER --password=$BAK_PASSWD --slave-info --extra-lsndir=$LSNDIR --stream=tar /tmp 2>>${LOG}|gzip > $BACKUP_BASE_DIR/${CURRENT_DT}_full.tar.gz 2>>${LOG}
	fi

	echo "NULL|${LSNDIR}|full" >> $INC_BASE_LIST
}


# 增量备份
function inc_backup(){
	# type：备份类型，当为0时表示全库备份；为1时表示备份特定的表
	local last_lsndir=$1
	local type=$2
	if [[ $type -eq 0 ]];then
		innobackupex --defaults-file=${MYSQL_CNF_PATH} --user=$BAK_USER --password=$BAK_PASSWD --slave-info --extra-lsndir=$LSNDIR --incremental --incremental-basedir=$last_lsndir --stream=xbstream --compress /tmp > $BACKUP_BASE_DIR/${CURRENT_DT}_inc.comp.xbstream 2>>${LOG}
	else
		local dests=$3
		innobackupex --defaults-file=${MYSQL_CNF_PATH} --tables-file=${dests} --user=$BAK_USER --password=$BAK_PASSWD --slave-info --extra-lsndir=$LSNDIR --incremental --incremental-basedir=$last_lsndir --stream=xbstream --compress /tmp > $BACKUP_BASE_DIR/${CURRENT_DT}_inc.comp.xbstream 2>>${LOG}
	fi
	
	echo "${last_lsndir}|${LSNDIR}|full" >> $INC_BASE_LIST
}


# 删除1周前的数据备份
function clean(){
	cd ${BACKUP_BASE_DIR} && find ./ -type f -mtime +7|xargs /bin/rm -rf
	if [[ $? -eq 0 ]];then
		sed -i "/`date -d '7 days ago' +'%F'`/d" ${INC_BASE_LIST}
	else
		echo "Delete the backup files failed!" >>${LOG}
	fi
}

 
function main(){
	local nfs_host=$2

	check_env $nfs_host
	if [[ $# -eq 2 ]];then
		BACKUP_BASE_DIR=/backup/remote/$(hostname)
	elif [[ $# -eq 3 ]];then
		BACKUP_BASE_DIR=/backup/local/$(hostname)
	fi
	if [[ ! -d ${BACKUP_BASE_DIR} ]];then
	   	mkdir -p ${BACKUP_BASE_DIR}
	fi
	# 当前日期时间，格式：XXXX-XX-XX-XXXXXX
	CURRENT_DT=$(date +%F-%H%M%S)
	LSNDIR=$BACKUP_BASE_DIR/$CURRENT_DT
	# 增量备份时，用到的基准目录列表文件
	# 内容格式：基准目录|本次备份目录|备份类型【full|inc】
	INC_BASE_LIST=${BACKUP_BASE_DIR}/incremental_basedir_list.txt

	# 全量备份
	if [[ $# -eq 2 ]];then
		if [[ "$1"x == "full"x ]]; then
			full_backup 0
		# 增量备份
		elif [[ "$1"x == "inc"x ]]; then
			# 基准目录列表文件不存在或者为空的情况，需要做一次全量备份
			if [[ ! -f ${INC_BASE_LIST} || $(sed '/^$/d' ${INC_BASE_LIST} | wc -l) -eq 0 ]]; then
				full_backup 0
			# 不存在任何目录的情况，需要做一次全量备份，以避免增量备份失败
			elif [[ $(find ${BACKUP_BASE_DIR} -maxdepth 1 -type d | wc -l) -eq 1 ]]; then
				full_backup 0
			# 在上一次备份的基础上，进行增量备份
			else
				local last_lsndir=$(sed '/^$/d' ${INC_BASE_LIST} | tail -1 | awk -F '|' '{print $2}')
				# 上次的备份目录不存在或者目录为空的情况，以避免人为删除的可能性【针对部分恶意删除的情况，目前还没有较好的检查方法】
				if [[ ! -d $last_lsndir || -z $(ls $last_lsndir) ]]; then
					full_backup 0
				else
					inc_backup $last_lsndir 0
				fi
			fi
		else
			show_help
		fi
	elif [[ $# -eq 3 ]];then
		local tbs_file=$3
		if [[ "$1"x == "full"x ]]; then
			full_backup 1 $tbs_file
		# 增量备份
		elif [[ "$1"x == "inc"x ]]; then
			# 基准目录列表文件不存在或者为空的情况，需要做一次全量备份
			if [[ ! -f ${INC_BASE_LIST} || $(sed '/^$/d' ${INC_BASE_LIST} | wc -l) -eq 0 ]]; then
				full_backup 1 $tbs_file
			# 不存在任何目录的情况，需要做一次全量备份，以避免增量备份失败
			elif [[ $(find ${BACKUP_BASE_DIR} -maxdepth 1 -type d | wc -l) -eq 1 ]]; then
				full_backup 1 $tbs_file
			# 在上一次备份的基础上，进行增量备份
			else
				local last_lsndir=$(sed '/^$/d' ${INC_BASE_LIST} | tail -1 | awk -F '|' '{print $2}')
				# 上次的备份目录不存在或者目录为空的情况，以避免人为删除的可能性【针对部分恶意删除的情况，目前还没有较好的检查方法】
				if [[ ! -d $last_lsndir || -z $(ls $last_lsndir) ]]; then
					full_backup 1 $tbs_file
				else
					inc_backup $last_lsndir 1 $tbs_file
				fi
			fi
		else
			show_help
		fi
	else
		show_help
	fi

	clean
}
 

# 只允许一个副本运行，以避免全量备份与增量备份出现交叉，发生数据错乱的可能性
# [[ -n `ps uax | grep innobackupex | grep -v grep` ]] && exit 1
[[ $UID -ne 0 ]] && echo "$(basename $0): Permission denied!" && exit 0
main $*
