#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : progress_monitor.py
@time: 2018/2/7 下午 02:31
@desc: --
'''

from utils.monitor import Monitor


class ProgressMonitor(Monitor):

	def watch(self, server):
		for index, item in enumerate(server.tcpPorts):
			cmd = ['netstat -lntup|grep ', item, '|wc -l']
			result = server.run_shell(''.join(cmd))
			if result[0] == b'0\n':
				msg = 'A project is not working now!\nDetails:\n\tServerName:\t{0}\n\tIP:\t{1}\n\tProject:\t{2}\n\t' \
					    'TcpPort:\t{3}'.format(server.name, server.ip, server.projects[index], item)
				self.send_mail('Fire!', ''.join(msg))
