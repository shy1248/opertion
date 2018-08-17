#!/bin/bash  
###########################################################################
# File Name: get_kpi.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-12-02 15:03:38
###########################################################################

start='2017-12-01 00:00:00'
end='2017-12-02 00:00:00'
date='2017_12_01'
username='dumper'
passwd='db_jm123'

# 新用户数
new_player=`mysql -h'10.0.1.8' -u$username -p$passwd -e "use zg_mj;SELECT COUNT(DISTINCT acc_name) FROM tb_acc WHERE reg_time>='$start' AND reg_time<'$end';"|grep -v "COUNT"`
# echo $new_player

# 老用户数
old_player=`mysql -h'10.0.1.8' -u$username -p$passwd -e "use zg_mj;SELECT COUNT(DISTINCT acc_name) FROM tb_acc WHERE reg_time<='$start';"|grep -v "COUNT"`
# echo $old_player

# DAU
dau=`mysql -h'10.0.1.11' -u$username -p$passwd -e "use zg_mj_log;SELECT COUNT(DISTINCT playerId) FROM chess_login_$date WHERE time>=UNIX_TIMESTAMP('$start')*1000 AND time<UNIX_TIMESTAMP('$end')*1000;"|grep -v "COUNT"`
# echo $dau

# 建房数
room_created=`mysql -h'10.0.1.11' -u$username -p$passwd -e "use zg_mj_log;SELECT COUNT(room_id) FROM create_room_start_$date WHERE createRoomTime>=UNIX_TIMESTAMP('$start')*1000 AND createRoomTime<UNIX_TIMESTAMP('$end')*1000;"|grep -v "COUNT"`
# echo $room_created

# 消耗房卡数
card=`mysql -h'10.0.1.11' -u$username -p$passwd -e "use zg_mj_log;SELECT SUM(card_num) FROM use_card_$date WHERE use_time>=UNIX_TIMESTAMP('$start')*1000 AND use_time<UNIX_TIMESTAMP('$end')*1000;"|grep -v "SUM"`
# echo $card

# 开启局数
# table_num=`mysql -h'10.0.1.11' -u$username -p$passwd -e "use zg_mj_log;SELECT SUM(t1.table_num) FROM create_room_start_$date t1 JOIN create_room_end_$date t2 ON t1.room_id=t2.room_id WHERE t1.createRoomTime>=UNIX_TIMESTAMP('$start')*1000 AND t1.createRoomTime<UNIX_TIMESTAMP('$end')*1000 AND t2.dissolut=0;"|grep -v "SUM"`

room_ids=(`mysql -h'10.0.1.11' -u$username -p$passwd -e "use zg_mj_log;SELECT t1.room_id FROM create_room_start_$date t1 JOIN create_room_end_$date t2 ON t1.room_id=t2.room_id WHERE t1.createRoomTime>=UNIX_TIMESTAMP('$start')*1000 AND t1.createRoomTime<UNIX_TIMESTAMP('$end')*1000;"|grep -v "room_id"|xargs`)

for id in ${room_ids[*]};do
	temp=`mysql -udumper -pdb_jm123 -h10.0.1.36 -e "use zg_mj_file_log;SELECT DISTINCT currentNum FROM chess_$date WHERE roomId='$id'  ORDER BY id desc;"|grep -v "currentNum"|head -1`
	((table_num=$table_num+$temp))
done
# echo $table_num

# 新增代理数
new_agent=`mysql -h'10.0.1.11' -u$username -p$passwd -e "use zg_chess_agent;SELECT COUNT(DISTINCT login_id) FROM agent WHERE time>='$start' AND time<'$end' AND level in(1,2);"|grep -v "COUNT"`
# echo $new_agent
echo -e "NEW\tOLD\tDAU\tROOM\tCARD\tTABLE\tAGENT"
echo -e "${new_player}\t${old_player}\t${dau}\t${room_created}\t${card}\t${table_num}\t${new_agent}"
