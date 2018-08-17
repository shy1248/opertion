#!/bin/bash  
###########################################################################
# File Name: zero_log.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-11-28 17:22:49
###########################################################################

hosts=('10.0.1.35' '10.0.1.48' '10.0.1.33' '10.0.1.46' '10.0.1.18' '10.0.0.12' '10.0.0.4' '10.0.0.9' '10.0.0.7' '10.0.1.16' '10.0.0.2' '10.0.0.15' '10.0.1.14')

for host in ${hosts[*]};do
    # if [ $host == '10.0.0.15' ];then
        # auth='_2018=JMgame%HexBv^75Qp'
    # else
        # auth='kgF^91@bhL_2018=JMgame%'
    # fi
	auth='=^GbF^34@ljLJMgame2018%'
	/usr/bin/expect <<EOF
set timeout -1
spawn ssh root@$host
expect {
	"yes/no" { send "yes\r";exp_continue; }
	"*password" { send "$auth\r";exp_continue; }
	"root@" {
	send { project_roots=('/jmserver/test-svn2' '/jmserver/test-svn3' '/jmserver/test-svn3-1' '/jmserver/ios_verify_ly' '/jmserver/ios_verify_cc' '/jmserver/ios_verify_zg' '/ly_gate_ios_shenhe' '/gy_gate_ios_shenhe' '/fj_gate_ios_shenhe' '/zg_gate_ios_shenhe' '/cc_gate_ios_shenhe' '/jmserver/cxcc_hall_001' '/jmserver/jpcc_hall_001' '/jmserver/df_hall_001' '/jmserver/tdk_hall_002' '/jmserver/cxcc_gs_001' '/jmserver/cxcc_gs_002' '/jmserver/jpcc_gs_001' '/jmserver/jpcc_gs_002' '/jmserver/df_gs_001' '/jmserver/df_gs_002' '/jmserver/tdk_gs_001' '/jmserver/tdk_gs_002' '/jmserver/cxcc_gw_001' '/jmserver/jpcc_gw_001' '/jmserver/df_gw_001' '/jmserver/tdk_gw_001' '/jmserver/cxcc_login_001' '/jmserver/jpcc_login_001' '/jmserver/df_login_001' '/jmserver/tdk_login_001' '/home/lw/cxcc_agent_root_tomcat' '/home/lw/cxcc_agent_tomcat' '/home/lw/jpcc_agent_root_tomcat' '/home/lw/jpcc_agent_tomcat' '/home/lw/dongfeng_agent_root_tomcat' '/home/lw/dongfeng_agent_tomcat' '/home/lw/tdk_agent_root_tomcat' '/home/lw/tdk_agent_tomcat' '/jmserver/ly_gw_001' '/data/LoginServer_liaoyuan_gaofang' '/data/loginserver_ly' '/LoginServer_liaoyuan' '/LoginServer_liaoyuan_test' '/LoginServer_LYIOS' '/LoginServer_ZGIOS' '/LoginServer_CCIOS' '/data/workspace0002' '/data/workspace0003' '/liaoyuan_workspace0001_hall' '/liaoyuan_workspace0002_hall' '/ly_majong_workspace0001' '/ly_majong_workspace0002' '/data/ly_majong_workspace0001' '/data/ly_majong_workspace0002' '/data/ly_majong_workspace0003' '/workspace0002_liaoyuan_playback' '/workspace0003_liaoyuan_playback' '/replay_workspace0001' '/ios_shenhe_replay' '/ios_shenhe_replay_zg' '/ios_shenhe_replay_cc' '/ios_shenhe_workspace' '/ios_shenhe_workspace_zg' '/ios_shenhe_workspace_cc' '/jmserver/cxcc_relog_001' '/jmserver/jpcc_relog_001' '/jmserver/df_relog_001' '/jmserver/tdk_relog_001') }
        send "\r"
	    send { for root in \${project_roots[*]};do if [ -d \$root ];then cd \$root;for dir in \`find . -type d -name 'logs'|sed "s#\.#\$root#g"|xargs\`;do cd \$dir;for file in \`ls \$dir|grep out\`;do  echo "" > \$file;done;done;else continue;fi;done }
    	send "\r"
    	send "exit 1\r"
    	expect eof
    	exit
	}
}
EOF
done
