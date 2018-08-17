zabbix-agent-install:
  cmd.run:
    - name: rpm -ivh http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm

  pkg.installed:
    - names:
      - zabbix-agent

  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://files/zabbix_agentd.conf
    - user: zabbix
    - group: zabbix
    - mode: 644
    - template: jinja
    - defaults:
      SERVER_IP: {{}}
      HOSTNAME: {{}}

  service.running:
    - name: zabbix-zgent
    - enable: True
    - reload: True
    - watch:
      - file: zabbix-agent-install 


