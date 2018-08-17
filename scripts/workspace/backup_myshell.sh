#!/bin/bash
TIME=`date +%F-%T`
DTH_HOME=`pwd`/dist

sh start.sh start 1>$DTH_HOME/logs/out_$TIME.log 2>$DTH_HOME/logs/err_$TIME.log &
