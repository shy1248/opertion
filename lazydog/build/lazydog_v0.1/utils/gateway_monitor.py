#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : gateway_monitor.py
@time: 2018/2/7 下午 02:37
@desc: --
'''

from utils.monitor import Monitor


class GatewayMonitor(Monitor):

	def watch(self, server):
		for index, item in enumerate(server.projects):
			# check the local port from gate server to playback server.
			check_playback_shell = ["cd ", item,";http_port=`grep httpPort dist/Gateway/config/config|grep -v '^#'|"
				                    "awk -F '=' '{print $NF}'|sed 's/[[:space:]]//g'`;playback_port="
				                    "`grep localPort3 dist/Gateway/config/config|grep -v '^#'|"
				                    "awk -F '=' '{print $NF}'|sed 's/[[:space:]]//g'`;"
				                    "if [ `netstat -ntup|grep $playback_port|wc -l` -eq 0 ];then "
				                    "curl '127.0.0.1:$http_port/data?cmd=1&data=playbackServer';"
				                    "netstat -ntup|grep$playback_port|wc -l;else echo 1;fi"]
			result = server.run_shell(''.join(check_playback_shell))
			if result[0] == b'0\n':
				msg = ['Gateway disconnect to playback server.\nDetails:\n\tServerName:\t', server.name,
					    '\n\tIP:\t', server.ip]
				self.send_mail('Fire!', ''.join(msg))

			# check the local port from gate server to activity server.
			check_activity_shell = ["cd ", item,
				                    ";http_port=`grep httpPort dist/Gateway/config/config|grep -v '^#'|"
				                    "awk -F '=' '{print $NF}'|sed 's/[[:space:]]//g'`;activity_port="
				                    "`grep localPort4 dist/Gateway/config/config|grep -v '^#'|"
				                    "awk -F '=' '{print $NF}'|sed 's/[[:space:]]//g'`;"
				                    "if [ `netstat -ntup|grep $activity_port|wc -l` -eq 0 ];then "
				                    "curl '127.0.0.1:$http_port/data?cmd=1&data=activityServer';"
				                    "netstat -ntup|grep$activity_port|wc -l;else echo 1;fi"]
			result = server.run_shell(''.join(check_activity_shell))
			if result[0] == b'0\n':
				msg = ['Gateway disconnect to activity server.\nDetails:\n\tServerName:\t', server.name,
					    '\n\tIP:\t', server.ip]
				self.send_mail('Fire!', ''.join(msg))

			# check the local port from gate server to activity server.
			check_chat_shell = ["cd ", item, ";http_port=`grep httpPort dist/Gateway/config/config|grep -v '^#'|"
				                            "awk -F '=' '{print $NF}'|sed 's/[[:space:]]//g'`;chat_port="
				                            "`grep localPort2 dist/Gateway/config/config|grep -v '^#'|"
											"awk -F '=' '{print $NF}'|sed 's/[[:space:]]//g'`;"
				                            "if [ `netstat -ntup|grep $chat_port|wc -l` -eq 0 ];then "
				                            "curl '127.0.0.1:$http_port/data?cmd=1&data=chatServer';"
				                            "netstat -ntup|grep $chat_port|wc -l;else echo 1;fi"]
			result = server.run_shell(''.join(check_chat_shell))
			if result[0] == b'0\n':
				msg = ['Gateway disconnect to chat server.\nDetails:\n\tServerName:\t', server.name, '\n\tIP:\t', server.ip]
				self.send_mail('Fire!', ''.join(msg))
