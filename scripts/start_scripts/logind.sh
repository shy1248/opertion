#!/bin/bash  
###########################################################################
# File Name: halld.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-11-27 15:41:05
###########################################################################

# 该项目所有启动的jar文件，名字不能错，并且需要按照启动顺序来修改
TAGE_JARS=('LoginServer.jar')
# a time string at now.
NOW_STR=`date +%F-%T|sed 's/-//g'|sed 's/://g'`
# the parent path of this script.
APP_HOME="`pwd -P`"
# the full name of the log file.
LOG_FILE="$APP_HOME/logs/out_$NOW_STR.log"
# 程序运行的用户，根据需要修改
RUN_USER="jm"
# java home
JAVA_HOME="/usr/java/default"
# add this options when the jar file is mahjong.jar.
JVM_EXT_OPS="-Duser.language=zh -Duser.region=CN -Xmx5000M -Xms5000M -Xmn1600M -Xss256K -XX:PermSize=600M -XX:MaxPermSize=600M -XX:MaxTenuringThreshold=20 -XX:SurvivorRatio=6 -XX:+UseConcMarkSweepGC -XX:-UseGCOverheadLimit -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -XX:+PrintGC -XX:+PrintGCDetails -Xloggc:log/gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCApplicationStoppedTime"

start(){
	# rmove the last log file.
	/bin/rm -rf logs/*
	for ((i=0;i<${#TAGE_JARS[*]};i++));do
		JAR_PATH=`get_jar_path ${TAGE_JARS[$i]}`
		if [ "$JAR_PATH"X != ""X ];then
			run_jar $JAR_PATH
			sleep 1
		else
			echo "Cound not found ${TAGE_JARS[$i]}!"
			exit 14
		fi
	done
}

stop(){
	while read -p "Are you sure to execute the stop server operation?(Y/n): " input;do
        case $input in
            'Y'|'y')
			for ((i=${#TAGE_JARS[*]}-1;i>=0;i--));do
				JAR_PATH=`get_jar_path ${TAGE_JARS[$i]}`
				if [ "$JAR_PATH"X != ""X ];then
					kill_jar $JAR_PATH
					sleep 1
				else
					echo "Cound not found ${TAGE_JARS[$i]}!"
					exit 15
				fi
			done
 			break;;
            'N'|'n')
            echo "You give up the operation." && break;;
            *)
            echo "Invalid input! Please try again." && continue;;
        esac
    done
}

status(){
    for ((i=0;i<${#TAGE_JARS[*]};i++));do
        JAR_PATH=`get_jar_path ${TAGE_JARS[$i]}`
		if [ "$JAR_PATH"X != ""X ];then
			check_status $JAR_PATH
		else
			echo "Cound not found ${TAGE_JARS[$i]}!"
			exit 16
		fi
    done
}

# if the directory of log file is not exist, create it.
check_log_dir(){
	LOG_DIR=`echo $LOG_FILE|xargs dirname`
	if [ ! -d $LOG_DIR ];then
		mkdir -p $LOG_DIR
	fi
}

# check the running user is exist or not.
check_user(){
	# only the root user can be run this script.
	[ $UID -ne 0 ] && {
		echo "Cound not run `basename $0`: Permission Denied!"
		exit 8
	}
	# if the $RUN_USER is not exist. add it.
	if [ `grep -w $RUN_USER /etc/passwd|wc -l` -eq 0 ];then
		useradd $RUN_USER -s /sbin/nologin -M -d /
	fi
	# change the file's owner to $RUN_USER
	chown -R $RUN_USER:$RUN_USER $APP_HOME
}

get_jar_path(){
	JAR_NAME=$1
	if [ `find ./dist/ -type f -name $JAR_NAME 2>/dev/null|wc -l` -eq 1 ];then
		find ./dist/ -type f -name $JAR_NAME|sed "s#.#$APP_HOME#"
	elif [ `find ./build/ -type f -name $JAR_NAME 2>/dev/null|wc -l` -eq 1 ];then
		find ./build/ -type f -name $JAR_NAME|sed "s#.#$APP_HOME#"
	elif [ `find ./ -type f -name $JAR_NAME 2>/dev/null|wc -l` -eq 1 ];then
		find ./ -type f -name $JAR_NAME|sed "s#.#$APP_HOME#"
	else
		echo ""
	fi
}

# get the tage jar's process id.
get_pid(){
	JAR_PATH=$1
    if [ `ps -ef|grep $JAR_PATH|grep -v 'grep'|wc -l` -ne 0 ];then
        echo "`ps -ef|grep $JAR_PATH|grep -v 'grep'|awk '{print $2}'`"
    else
        echo ""
    fi
}

# run jar.
run_jar() {
	JAR_PATH=$1
    PID=`get_pid $JAR_PATH`
    if [ "x$PID" != "x" ];then
        echo -e "$JAR_PATH is already running with pid: #\033[;33m$PID\033[0m."
        exit 80
    fi
    if [ -f $JAR_PATH ];then
        if [ "`echo $JAR_PATH|xargs basename`" == "mahjong.jar"  ];then
            JAVA_CMD="cd `echo $JAR_PATH|xargs dirname`;$JAVA_HOME/bin/java $JVM_EXT_OPS -Dfile.encoding=UTF-8 -server -jar $JAR_PATH &"
        else
            JAVA_CMD="cd `echo $JAR_PATH|xargs dirname`;$JAVA_HOME/bin/java -Dfile.encoding=UTF-8 -server -jar $JAR_PATH &"
        fi
        su - $RUN_USER -s /bin/sh -c "$JAVA_CMD" >> $LOG_FILE 2>&1
        sleep 5
        PID=`get_pid $JAR_PATH`
            if [ "x$PID" != "x" ];then
            	echo -e "Starting $JAR_PATH(#\033[;33m$PID\033[0m):  \033[;32mSUCCESS\033[0m!"
            else
            	echo -e "Starting $JAR_PATH:  \033[;31mFAILED\033[0m!"
				exit 12
            fi
    else
        echo "$JAR_PATH not found."
		exit 13
    fi
}

# kill jar.
kill_jar() {
	JAR_PATH=$1
	JAR_NAME=`echo $1|xargs basename`
	JAR_DIR=`echo $1|xargs dirname`
    PID=`get_pid $JAR_PATH`
	WAIT_TIME=0
    if [ "x$PID" != "x" ];then
        # su - $RUN_USER -s /bin/sh -c "kill -15 $PID"
		if [[ $JAR_NAME == "HallCenter.jar" || $JAR_NAME == "mahjong.jar" || $JAR_NAME == "GameServer.jar" ||$JAR_NAME == "ActivityServer.jar" ]];then
			TAG_FILE="$JAR_DIR/`ls -l $JAR_DIR|grep 'signal_term'|grep -v 'grep'|awk '{print $NF}'`"
			[ -f $TAG_FILE ] && /bin/rm $TAG_FILE
			su - $RUN_USER -s /bin/sh -c "kill -15 $PID"
			while [ ! -f "$JAR_DIR/`ls -l $JAR_DIR|grep 'signal_term'|grep -v 'grep'|awk '{print $NF}'`" ];do
				if [ $WAIT_TIME -le 600 ];then
					# echo -e -n "\rWaitting for $((600 - $WAIT_TIME))sec to cache ..."
					sleep 1
					WAIT_TIME=$((WAIT_TIME+1))
				else
					echo -e "Stoping $JAR_PATH(#\033[;33m$PID\033[0m):  \033[;31mFAILED\033[0m!"
					exit 10
				fi				
			done
		elif [[ $JAR_NAME == "ReLogServer.jar" ]];then
			STOP_FILE=`grep 'stopFile' ${JAR_DIR}/config/config|sed 's/[[:space:]]//g'|awk -F'=' '{print $NF}'`
			touch $STOP_FILE
			sleep 2
			su - $RUN_USER -s /bin/sh -c "kill -15 $PID"
		else
			su - $RUN_USER -s /bin/sh -c "kill -15 $PID"
		fi
        sleep 5
        PID=`get_pid $JAR_PATH`
        if [ "x$PID" == "x" ];then
            echo -e "Stoping $JAR_PATH:  \033[;32mSUCCESS\033[0m!"
			if [[ $JAR_NAME == "ReLogServer.jar" ]];then
				/bin/rm $STOP_FILE
			fi
        else
            echo -e "Stoping $JAR_PATH(#\033[;33m$PID\033[0m):  \033[;31mFAILED\033[0m!"
			exit 11
        fi
    else
        echo "$JAR_PATH is not running now."
    fi
}

# check is the tage jar is running or not.
check_status() {
	JAR_PATH=$1
    PID=`get_pid $JAR_PATH`
    if [ "x$PID" != "x" ];then
        echo -e "$JAR_PATH is running with pid: #\033[;33m$PID\033[0m."
    else
        echo "$JAR_PATH is not running now."
    fi
}

main(){
	check_log_dir
	check_user
	case "$1" in
		'start')
		start;;
		'stop')
		stop;;
		'status')
		status;;
		*)
		echo "USAGE: `basename $0` {start|stop|status}" && exit 1;;
	esac
}

main $*
