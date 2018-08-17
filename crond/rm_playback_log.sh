#!/bin/bash  
###########################################################################
# File Name: rm_playback_log.sh
# Author: 
# Mail:
# Descraption: delete the playback log at 3 days ago.  
# Created Time: 2018-07-30 09:41:01
###########################################################################

HOST=$1
DEST_DB=$2
TIME=$3

DB_USER='cdb_outerroot'
DB_PASSWD='9WCkn%J^ydIp'

DEST_TABLE="chess_$(date -d $TIME +%Y_%m_%d)"
# echo $DEST_TABLE

mysql -u$DB_USER -p$DB_PASSWD -h$HOST -e "use $DEST_DB;drop table if exists $DEST_TABLE;"
