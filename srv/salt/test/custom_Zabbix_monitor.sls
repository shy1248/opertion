zabbix_agent_scripts:
  file.recurse:
    - name: /opt/zabbix_scripts
    - source: salt://files/scripts_zabbix
    - user: zabbix
    - group: zabbix
    - file_mode: 744
    - dir_mode: 755
    - mkdir: True
    - clean: False

/etc/zabbix/zabbix_agentd.d/userparameters.conf:
  file.managed:
    - source: salt://files/custom_zabbix/userparameters.conf
    - user: zabbix
    - group: zabbix
    - mode: 644
    - makedirs: True

restart_zabbix_agentd:
  cmd.run:
    - name: /etc/init.d/zabbix-agent restart
