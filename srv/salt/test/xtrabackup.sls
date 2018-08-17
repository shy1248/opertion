/crond/xbp.sh:
  file.managed:
    - source: salt://files/xbp.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - dir_mode: 755
    
/crond/xbp_dests.list:
  file.managed:
    - source: salt://files/xbp_dests.list
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - dir_mode: 755

xbp_remote_full:
  cron.present:
    - name: cd /crond && /bin/bash xbp.sh full 10.0.1.46 > /dev/null 2>&1
    - user: root
    - minute: 30
    - hour: 1
    - daymonth: '*/3'

xbp_remote_inc:
  cron.present:
    - name: cd /crond && /bin/bash xbp.sh inc 10.0.1.46 > /dev/null 2>&1
    - user: root
    - minute: 30
    - hour: 3

xbp_local_full:
  cron.present:
    - name: cd /crond && /bin/bash xbp.sh full 10.0.1.46 /crond/xbp_dests.list > /dev/null 2>&1
    - user: root
    - minute: 30
    - hour: 4
    - daymonth: '*/3'

xbp_local_inc:
  cron.present:
    - name: cd /crond && /bin/bash xbp.sh inc 10.0.1.46 /crond/xbp_dests.list > /dev/null 2>&1
    - user: root
    - minute: 30
    - hour: 5
