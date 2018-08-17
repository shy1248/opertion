#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : lazydog.py
@time: 2018/2/7 下午 12:17
@desc: --
'''

import json
import logging

from utils.disk_monitor import DiskMonitor
from utils.email_util import Email
from utils.gateway_monitor import GatewayMonitor
from utils.server import Server
from utils.progress_monitor import ProgressMonitor


def get_logger(logfile):
	logger = logging.getLogger()
	logger.setLevel(logging.DEBUG)
	# print to screen
	ch = logging.StreamHandler()
	ch.setLevel(logging.INFO)
	# write to log file
	fh = logging.FileHandler(logfile)
	fh.setLevel(logging.WARNING)
	# set the format for record
	formatter = logging.Formatter('%(asctime)s -%(name)s-%(levelname)s-%(module)s:%(message)s')
	ch.setFormatter(formatter)
	fh.setFormatter(formatter)
	logger.addHandler(ch)
	logger.addHandler(fh)
	return logger

def get_monitors(logger):
	disk_monitor = DiskMonitor('DiskMonitor',3600,logger)
	progress_monitor = ProgressMonitor('ProgressMonitor',60,logger)
	gateway_monitor = GatewayMonitor('GatewayMonitor',60, logger)
	f = open('hosts.json', "r+")
	content = f.read()
	server_infos = json.loads(content)['servers']
	for server_info in server_infos:
		server = Server(server_info['name'], server_info['ip'], server_info['projects'], server_info['tcpPorts'])
		disk_monitor.add_server(server)
		if server.tcpPorts:
			progress_monitor.add_server(server)
			if 'gate' in server.name:
				gateway_monitor.add_server(server)
	return disk_monitor, progress_monitor, gateway_monitor


if __name__ == '__main__':
	logger = get_logger('./lazydog.log')
	smtp_server = 'smtp.exmail.qq.com'
	smtp_port = '465'
	smtp_username = 'shyu@jiemai-tech.com'
	smtp_passwd = '1980@CHenbo422'
	mailto = ['shyu@jiemai-tech.com', 'chpeng@jiemai-tech.com', 'xluo@jiemai-tech.com', 'htang@jiemai-tech.com']
	Email.setup(smtp_server, smtp_port, smtp_username, smtp_passwd, mailto)
	disk_monitor,progress_monitor,gateway_monitor = get_monitors(logger)
	disk_monitor.start()
	progress_monitor.start()
	gateway_monitor.start()
