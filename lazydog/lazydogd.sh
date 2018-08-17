#!/bin/bash  
###########################################################################
# File Name: start.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2018-02-08 10:54:46
###########################################################################

# load system function
. /etc/init.d/functions
# the pid file
PID_FILE='/lazydog/lazydog.pid'

# check the user is root or not
if [ $UID -ne 0 ];then
	echo "`basename $0`: Permission Denied!"
	exit 10
fi

# check the params
if [ $# -ne 1 ];then
	 echo "USAGE: `basename $0` {start|stop|check}"
	 exit 11
 fi

start(){
	cd lazydog
	./venv/bin/python lazydog.py &>/dev/null &
	sleep 1
	if (kill -0 $! 2>/dev/null)  ;then
		action "Starting lazyDog: " /bin/true
		echo $! > $PID_FILE
	else
		action "Starting lazyDog: " /bin/false
	fi
}

stop(){
	if [ -f $PID_FILE ];then
		PID=`cat $PID_FILE`
		kill $PID &>/dev/null
		sleep 1
		if (kill -0 $PID 2>/dev/null)  ;then
			action "Stoping lazyDog: " /bin/false
		else
			action  "Stoping lazyDog: " /bin/true
			/bin/rm $PID_FILE
		fi
	else
		PID=`ps -ef|grep "lazydog.py"|grep -v grep|awk '{print $2}'`
		if [ -n "$PID" ];then
			echo "Missing the pid file with pid: $PID, kill it!"
		else
			echo "The LazyDog is not running right now!"
		fi
	fi
}

check(){
	if [ -f $PID_FILE ];then
		PID=`cat $PID_FILE`
		if [ `ps mp $PID|grep -w 'Sl'|wc -l` -ne 5 ];then
			stop && sleep 1 && start
		fi
	else
		PC=`ps -ef|grep "lazydog.py"|grep -v grep|awk '{print $2}'|wc -l`
		if [ $PC -eq 1 ];then
			kill `ps -ef|grep "lazydog.py"|grep -v grep|awk '{print $2}'`
		fi
		start
	fi
}

case $1 in
	start)
	start
	;;
	stop)
	stop
	;;
	check)
	check
	;;
	*)
	echo "USAGE: `basename $0` {start|stop|check}"
	exit 11
	;;
esac
