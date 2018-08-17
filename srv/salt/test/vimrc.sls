/etc/vimrc:
  file.managed:
    - source: salt://files/vimrc.v20171124
    - user: root
    - group: root
    - mode: 644
