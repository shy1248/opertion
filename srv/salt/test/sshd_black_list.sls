/crond/ssh_limit.sh:
  file.managed:
    - source: salt://files/ssh_limit.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - dir_mode: 755
  cron.present:
    - name: cd /crond && /bin/bash ssh_limit.sh > /dev/null 2>&1
    - user: root
    - minute: '*/1'
    
