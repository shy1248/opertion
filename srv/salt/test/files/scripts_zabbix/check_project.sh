#!/bin/bash  
###########################################################################
# File Name: check_process.sh
# Author: shy 
# Mail: hengchen2005@gmail.com
# Descraption: 
#	Check the processes which defined at config file is running or not.
#
# Created Time: 2018-07-22 01:27:12
###########################################################################

# return：
# 1 - project work fine
# 2 - some process is out of service
# 3 - some listen port is down
# 4 - gateway disconnect to chart server
# 5 - gateway disconnect to playback server
# 6 - gateway disconnect to activity server

project_root=$1
process_names=('LoginServer' 'ChartServer' 'DbServer' 'LogServer' 'HallCenter' 'ActivityServer' 'mahjong' 'Gateway' 'PlaybackServer' 'ReLogServer')
targets_processes=()
tragets_ports=()
chart_port=0
playback_port=0
activity_port=0
gateway_http_port=0

function is_process_alive(){
	local process=$1
	if [ $(ps -ef|grep $process|grep -v 'grep'|wc -l) -eq 0 ];then
		echo 0
	else
		echo 1
	fi
}

function is_port_on(){
	local port=$1
	# type: 0 listen port
	# type: 1 up port
	local type=$2
	if [ $type -eq 0 ];then
		if [ $port -ne 0 ] && [ $(sudo netstat -lntup|grep $port|grep -v 'grep'|wc -l) -eq 0 ];then
			echo 0
		else
			echo 1
		fi
	else
		if [ $port -ne 0 ] && [ $(sudo netstat -ntup|grep $port|grep -v 'grep'|wc -l) -eq 0 ];then
			echo 0
		else
			echo 1
		fi
	fi
}

function is_login(){
	local process_name=$1
	if [ "$process_name"x = "LoginServer.jar"x ];then
		echo 1
	else
		echo 0
	fi
}

function is_gateway(){
	local process_name=$1
	if [ "$process_name"x = "Gateway.jar"x ];then
		echo 1
	else
		echo 0
	fi
}

function is_a_process(){
	local process=$1
	local mark=0
	for p in ${process_names[@]};do
		if [ "${p}.jar" = "$process" ];then
			mark=1
			break
		fi
	done
	echo $mark
}

function get_tcp_port(){
	local conf_file=$1
	local tcp=$(sed -n '/^\s*tcpPort\s*=\s*\d*/p' $conf_file | awk -F= '{print $2}' | sed 's/\s*//g')
	if [ "$tcp"x = ""x ];then
		echo 0
	else
		echo $tcp
	fi
}

function get_http_port(){
	local conf_file=$1
	local http=$(sed -n '/^\s*httpPort\s*=\s*\d*/p' $conf_file | awk -F= '{print $2}' | sed 's/\s*//g')
	if [ "$http"x = ""x ];then
		echo 0
	else
		echo $http
	fi
}

function get_gpt_chart(){
	local conf_file=$1
	local pchart=$(sed -n '/^\s*localPort2\s*=\s*\d*/p' $conf_file | awk -F= '{print $2}' | sed 's/\s*//g')
	if [ "$pchart"x = ""x ];then
		echo 0
	else
		echo $pchart
	fi
}

function get_gpt_playback(){
	local conf_file=$1
	local pback=$(sed -n '/^\s*localPort3\s*=\s*\d*/p' $conf_file | awk -F= '{print $2}' | sed 's/\s*//g')
	if [ "$pback"x = ""x ];then
		echo 0
	else
		echo $pback
	fi
}

function get_gpt_activity(){
	local conf_file=$1
	local pactivity=$(sed -n '/^\s*localPort4\s*=\s*\d*/p'  $conf_file | awk -F= '{print $2}' | sed 's/\s*//g')
	if [ "$pactivity"x = ""x ];then
	    echo 0
    else
		echo $pactivity
	fi
}

function get_target_processes(){
	local proot=$1
	local i=0
	for f in $(find $proot -type f -name "*.jar");do
		local c=$(dirname $f)/config/config
		local pn=$(basename $f)
		if [ -f $c ] && [ $(is_a_process $pn) -eq 1 ];then
			targets_processes[$i]=$f
			if [ $(is_login $pn) -eq 1 ];then
				targets_ports[$i]=$(get_http_port $c)
			else
				targets_ports[$i]=$(get_tcp_port $c)
			fi
			if [ $(is_gateway $pn) -eq 1 ];then
				chart_port=$(get_gpt_chart $c)
				playback_port=$(get_gpt_playback $c)
				activity_port=$(get_gpt_activity $c)
				gateway_http_port=$(get_http_port $c)
			fi
			i=$(expr $i + 1)
		fi
	done
}

function main(){
	if [ $(find $project_root -type l -name 'dist'|wc -l) -eq 0 ];then
		get_target_processes $project_root
	else
		get_target_processes ${project_root}/dist/
	fi

	for ((j=0;j<${#targets_processes[@]};j++));do
		local process=${targets_processes[$j]}
		local port=${targets_ports[$j]}

		if [ $(is_process_alive $process) -ne 1 ];then
			echo 2
			exit 2
		elif [ $(is_process_alive $process) -eq 1 ] && [ $(is_port_on $port 0) -ne 1 ];then
			echo 3
			exit 3
		elif [ $(is_process_alive $process) -eq 1 ] && [ $(is_port_on $port 0) -eq 1 ] ;then 
			if [ $chart_port -ne 0 ] && [ $(is_port_on $chart_port 1) -ne 1 ];then
				curl "127.0.0.1:$gateway_http_port/data?cmd=1&data=stopChatServer" >/dev/null 2>&1
				curl "127.0.0.1:$gateway_http_port/data?cmd=1&data=chatServer" >/dev/null 2>&1
				if [ $(is_port_on $chart_port 1) -ne 1 ];then
					echo 4
					exit 4
				else
					echo 1
					exit 1
				fi
			elif [ $playback_port -ne 0 ] && [ $(is_port_on $playback_port 1) -ne 1 ];then
				curl "127.0.0.1:$gateway_http_port/data?cmd=1&data=stopPlaybackServer" >/dev/null 2>&1
				curl "127.0.0.1:$gateway_http_port/data?cmd=1&data=playbackServer" >/dev/null 2>&1
				if [ $(is_port_on $playback_port 1) -ne 1 ];then
					echo 5
					exit 5
				else
					echo 1
					exit 1
				fi
			elif [ $activity_port -ne 0 ] && [ $(is_port_on $activity_port 1) -ne 1 ];then
				curl "127.0.0.1:$gateway_http_port/data?cmd=1&data=stopActivityServer" >/dev/null 2>&1
				curl "127.0.0.1:$gateway_http_port/data?cmd=1&data=activityServer" >/dev/null 2>&1
				if [ $(is_port_on $activity_port 1) -ne 1 ];then
					echo 6
					exit 6
				else
					echo 1
					exit 1
				fi
			else
				echo 1
				exit 1
			fi
		fi
	done
}

main $*
