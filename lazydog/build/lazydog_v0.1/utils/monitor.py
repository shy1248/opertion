#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : monitor.py
@time: 2018/2/7 下午 01:17
@desc: --
'''

from abc import ABCMeta
from abc import abstractmethod
import threading
import time

from utils.email_util import Email


class Monitor(threading.Thread):
	__metaclass__ = ABCMeta

	def __init__(self, name, interval, logger):
		threading.Thread.__init__(self)
		self.servers = []
		self.name = name
		self.interval = interval
		self.logger = logger

	@abstractmethod
	def watch(self, server):
		pass

	def add_server(self, server):
		self.servers.append(server)

	def send_mail(self, resume, msg):
		email = Email(resume, msg)
		email.send()

	def run(self):
		while True:
			for server in self.servers:
				self.logger.info('{0} checked server {1}.'.format(self.name, server.name))
				self.watch(server)
			time.sleep(self.interval)
