/opt/zabbix_scripts/process.list:
  file.managed:
    - source: salt://files/monitor_process.list
    - user: zabbix
    - group: zabbix
    - mode: 644
    - makedirs: True
