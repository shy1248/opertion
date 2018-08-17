#!/bin/bash1
TIME=`date +%F-%T`
DTH_HOME=`pwd`/dist
start()
{
        echo "set openfile num"
        ulimit -n 65535

        echo $DTH_HOME
        # DBServer
        echo "start DbServer..."
        cd $DTH_HOME/DbServer
        java -Dfile.encoding=UTF-8 -server -jar DbServer.jar &
        sleep 10

        # ChatServer
        echo "start ChatServer..."
        cd $DTH_HOME/ChatServer
        java -Dfile.encoding=UTF-8 -server -jar ChatServer.jar  &
        sleep 15

        # LogServer
        echo "start LogServer..."
        cd $DTH_HOME/LogServer
        java  -Dfile.encoding=UTF-8 -server -jar LogServer.jar  &
        sleep 20

        #initlogs
        cd $DTH_HOME
        if [ ! -d 'logs' ] ; then  mkdir logs ; fi
        # GameServer
        echo "start GameServer..."
        cd $DTH_HOME/GameServer
        java -Duser.language=zh -Duser.region=CN  -Dfile.encoding=utf-8 -Dserver.name=GameServer -server  -Xmx2000M -Xms2000M -Xmn1200M -Xss256K -XX:PermSize=600M -XX:MaxPermSize=600M -XX:MaxTenuringThreshold=20 -XX:SurvivorRatio=2 -XX:+UseConcMarkSweepGC -XX:-UseGCOverheadLimit -XX:+PrintGCTimeStamps -XX:+PrintGC -XX:+PrintGCDetails -Xloggc:$DTH_HOME/logs/gc.log -XX:+HeapDumpOnOutOfMemoryError -jar GameServer.jar  &
        echo "start GameServer over..."
        sleep 50
        
}
stop()
{
        kill -9 `lsof -t -i :8881`
        kill -9 `lsof -t -i :8882`
        kill -9 `lsof -t -i :5400`
        kill -9 `lsof -t -i :5403`
        kill -9 `lsof -t -i :5407`
        kill -9 `lsof -t -i :5409`
        kill -9 `lsof -t -i :8502`
        sleep 20
        echo "end server"
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  *)
       echo "err! start or stop"
esac
