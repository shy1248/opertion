#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : disk_monitor.py
@time: 2018/2/7 下午 01:39
@desc: --
'''

from utils.monitor import Monitor


class DiskMonitor(Monitor):

	def watch(self, server):
		for disk in server.disks:
			if disk.is_less():
				msg = 'A  problem of low hard drive space.\nDetails:\n\tServerName:\t{0}\n\tIP:\t{1}\n\tDisk:\n\t' \
				      'FileSystem\tSize\tUsed\tAvail\tUsed%\tMounted on\n\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}'.\
					format(server.name, server.ip, disk.fileSystem, disk.size, disk.used, disk.avail, disk.use_percent,
				           disk.mounted_on)
				self.send_mail('Warnning!', ''.join(msg))
