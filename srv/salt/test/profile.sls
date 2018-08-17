create_user_op_log:
  cmd.run:
    - name: mkdir -p /var/log/.jm && echo usermonitor > /var/log/.jm/user_op.log && chown nobody.nobody /var/log/.jm/user_op.log && chmod 002 /var/log/.jm/user_op.log && chattr +a /var/log/.jm/user_op.log && echo 'source /etc/profile' >> /etc/bashrc
    - unless: test -d /var/log/.jm

copy_profile:
  file.managed:
    - name: /etc/profile
    - source: salt://files/profile.v20180425
    - user: root
    - group: root
    - mode: 644
