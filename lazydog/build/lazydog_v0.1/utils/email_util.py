#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
@author: yushuibo
@licence: (c) Copyright 2017-2027, Node Supply China Manager Corporation Limited.
@contact: hengchen2005@gmail.com
@sftware: PyCharm
@site    : 
@file    : email_util.py.py
@time: 2018/2/7 上午 11:57
@desc: --
'''


import smtplib
import email.mime.multipart
import email.mime.text


class Email(object):
	server = None
	port = None
	username = None
	passwd = None
	mailto = None

	def __init__(self, subject, content):
		self.subject = subject
		self.content = content

	@classmethod
	def setup(cls, server, port, username, passwd, mailto):
		cls.server = server
		cls.port = port
		cls.username = username
		cls.passwd = passwd
		cls.mailto = mailto

	def send(self):
		msg = email.mime.multipart.MIMEMultipart()
		msg['from'] = Email.username
		msg['to'] = ','.join(Email.mailto)
		msg['subject'] = self.subject
		content = self.content
		txt = email.mime.text.MIMEText(content)
		msg.attach(txt)
		smtp = smtplib.SMTP_SSL(Email.server, Email.port)
		smtp.ehlo()
		smtp.login(Email.username, Email.passwd)
		smtp.sendmail(Email.username, self.mailto, str(msg))
		smtp.close()
