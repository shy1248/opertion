#!/bin/bash
TIME=`date +%F-%T`
DTH_HOME=`pwd`/dist

sh start.sh start >> $DTH_HOME/logs/out_$TIME.log>&1 &
