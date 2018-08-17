#!/bin/bash  
###########################################################################
# File Name: .sh
# Author: yushuibo  
# Mail: hengchen2005@gmail.com  
# Descraption: 
# 该脚本为Linux下启动java程序的通用脚本。即可以作为开机自启动service脚本被调用，
# 也可以作为启动java程序的独立脚本来使用。
# 警告!!!：该脚本stop部分使用系统kill命令来强制终止指定的java程序进程。
# 在杀死进程前，未作任何条件检查。在某些情况下，如程序正在进行文件或数据库写操作，
# 可能会造成数据丢失或数据不完整。如果必须要考虑到这类情况，则需要改写此脚本，
# 增加在执行kill命令前的一系列检查。
#
# Created Time: 2017-11-08 17:36:13
###########################################################################

[ -f /etc/init.d/functions ] && . /etc/init.d/functions
NOW=`date +%F-%T`
# JDK所在路径
JAVA_HOME="/usr/java/jdk1.6.0_38"
# java程序目录
APP_HOME=`pwd`
# java程序名
APP_NAME="`ls $APP_HOME|grep -E "jar$"`"
# 执行程序启动所使用的系统用户，考虑到安全，推荐不使用root帐号
USER=`ls -l $APP_HOME|grep $APP_NAME|awk '{print $3}'`
# log文件
LOG_FILE="$APP_HOME/out_$NOW.log"

get_pid(){
	if [ `ps -ef|grep $APP_HOME/$APP_NAME|grep -v 'grep'|wc -l` -ne 0 ];then
		echo `ps -ef|grep $APP_HOME/$APP_NAME|grep -v 'grep'|awk '{print $2}'`
	else
		echo ""
	fi
}

start() {
	PID=`get_pid`
	if [ x$PID != x ];then
		echo "$APP_HOME/$APP_NAME is running, and the pid=$PID."
		exit 80
	fi
	if [ -f $APP_HOME/$APP_NAME ];then
		JAVA_CMD="cd $APP_HOME;nohup $JAVA_HOME/bin/java -Dfile.encoding=UTF-8 -server -jar $APP_HOME/$APP_NAME >$LOG_FILE 2>&1 &"
		su - $USER -s /bin/sh -c "$JAVA_CMD"
      	if [ x$PID != x ];then
         	action "Starting $APP_HOME/$APP_NAME: " /bin/true
      	else
         	action "Starting $APP_HOME/$APP_NAME: " /bin/false
      	fi
	else
		echo "$APP_HOME/$APP_NAME not found."
		exit 10
   	fi
}
 
stop() {
	PID=`get_pid`
	if [ x$PID != x ];then
		kill -9 $PID	
		sleep 5
		if [ x$PID == x ];then
			action "Stoping $APP_HOME/$APP_NAME: " /bin/true
		else
			action "Stoping $APP_HOME/$APP_NAME: " /bin/false
		fi
	else
		echo "$APP_HOME/$APP_NAME is not running."
		exit 11
	fi
}
 
# (函数)检查程序运行状态
status() {
	PID=`get_pid`
	if [ x$PID != x ];then
		echo "$APP_HOME/$APP_NAME is running with pid: `get_pid`."
	else
		echo "$APP_HOME/$APP_NAME is not running."
	fi
	exit 0
}
 
# (函数)打印系统环境参数
info() {
	echo "System Information:"
	echo "****************************"
	echo `head -n 1 /etc/issue`
	echo `uname -a`
	echo
	echo "JAVA_HOME=$JAVA_HOME"
	echo `$JAVA_HOME/bin/java -version`
	echo
	echo "APP_HOME=$APP_HOME"
	echo "APP_NAME=$APP_NAME"
	echo
	exit 0
}
 
# 读取脚本的第一个参数($1)，进行判断
# 参数取值范围：{start|stop|restart|status|info}
# 如参数不在指定范围之内，则打印帮助信息
case "$1" in
	'start')
	start;;
	'stop')
	while read -p "Are you sure want to stop the $APP_HOME/$APP_NAME? (Y/N): " input;do
		case $input in
			'Y'|'y')
			stop && exit 0;;
			'N'|'n')
			echo "You give up to stop the $APP_HOME/$APP_NAME." && exit 0;;
			*)
			echo "Invalid input! Please try again." && continue;;
		esac
	done;;
	'restart')
	while read -p "Are you sure want to restart the $APP_HOME/$APP_NAME? (Y/N): " input;do
		case $input in
			'Y'|'y')
			stop && sleep 5 && start && exit 0;;
			'N'|'n')
			echo "You give up to restart the $APP_HOME/$APP_NAME." && exit 0;;
			*)
			echo "Invalid input! Please try again." && continue;;
		esac
	done;;
	'status')
		status;;
	'info')
		info;;
	*)
		echo "USAGE: `basename $0` {start|stop|restart|status|info}" && exit 1;;
esac
