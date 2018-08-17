#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : server.py.py
@time: 2018/2/7 下午 12:14
@desc: --
'''

import paramiko

class Server:
	def __init__(self, name, ip, projects, tcpPorts):
		self.name = name
		self.ip = ip
		self.projects = projects
		self.tcpPorts = tcpPorts
		self.user = 'root'
		if self.name == 'gate01-ly':
			self.passwd = 'cdjm123qwe'
		else:
			self.passwd = 'gHkj^5hF#ladi%w'
		self.disks = self._get_disks()

	def out(self):
		print('ServerName:{0}\tIP:{1}\tProjects:{2}\tTcpPorts:{3}'.format(self.name, self.ip, self.projects, self.tcpPorts))

	def _connect(self):
		ssh = paramiko.SSHClient()
		ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		ssh.connect(self.ip, 22, self.user, self.passwd)
		return ssh

	def _disconnect(self, ssh):
		ssh.close()

	def run_shell(self, shell_str):
		ssh = self._connect()
		stdin, stdout, stderr = ssh.exec_command(shell_str)
		result = stdout.read(), stderr.read()
		self._disconnect(ssh)
		return result

	def _get_disks(self):
		disks = []
		result = self.run_shell('df -h|tail -n +2')
		result = str(result[0])
		result = result[2:len(result)-3]
		disk_infos = result.split('\\n')
		for info in disk_infos:
			info_list = info.split()
			disk = self.Disk(info_list[0], info_list[1], info_list[2], info_list[3], info_list[4], info_list[5])
			disks.append(disk)
		return disks

	class Disk():
		def __init__(self, fileSystem, size, used, avail, use_percent, mounted_on):
			self.fileSystem = fileSystem
			self.size = size
			self.used = used
			self.avail = avail
			self.use_percent = use_percent
			self.mounted_on = mounted_on

		def is_less(self):
			if int(self.use_percent.strip('%')) < 75:
				return False
			else:
				return True
