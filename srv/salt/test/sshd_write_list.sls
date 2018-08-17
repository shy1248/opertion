/etc/hosts.allow:
  file.managed:
    - source: salt://files/hosts.allow.v20180322
    - user: root
    - group: root
    - mode: 644
