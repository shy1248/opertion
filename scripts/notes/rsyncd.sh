#!/bin/bash
#chkconfig: 2345 98 08
#get a daemon process for inotify and rsync.
#create by yu at 2017-08-28.

#defaults vars
shell_name=/server/scripts/inotify_rsync.sh
pid_file=/var/run/rsyncd.pid

#check if requirement are met
[ -x ${shell_name} ] || {
    echo "${shell_name} has no executed permission!" 
    exit 1 
}

#source library functions
if [ ! -f /etc/init.d/functions ];then
    echo "Library functions file not found!"
else
    . /etc/init.d/functions
fi

if [ $# -ne 1 ]:then
    usage: $0 [start|stop|restart]
    exit 1
fi

start(){
    echo Sarting inotify service of rsync ...
    /bin/bash $shell_name &
    echo $$ > $pid_file
    if [ $(ps -ef|grep inotify|wc -l) -gt 2 ];then
        action "Inotify service of rsync is started!" /bin/true
    else
        action "Inotify service of rsync is started!" /bin/false
    fi 
}

stop(){
    echo Stopping inotify service of rsync ....
    kill -9 $(cat ${pid_file}) >/dev/null 2>&1
    pkill inotifywait
    sleep 1
    if [ $(ps -ef|grep inotify|grep -v grep|wc -l) -eq 0 ];then
        action "Inotify service of rsync is stopped!" /bin/true
    else
        action "Inotify service of rsync is stopped!" /bin/false
    fi   
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    stop
    start
    ;;
*)
    usage: $0 [start|stop|restart]
    exit 1
esac
