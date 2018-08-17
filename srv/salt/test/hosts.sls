 /etc/hosts:
   file.managed:
     - source: salt://files/hosts.v20180712
     - user: root
     - group: root
     - mode: 644
