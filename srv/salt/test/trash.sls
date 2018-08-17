install_py34:
  pkg.installed:
    - name: python34

copy_required:
  file.recurse:
    - name: /root
    - source: salt://files/trash-cli
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755
    - mkdir: True
    - clean: False
  
install_trash-cli:
  cmd.run:
    - name: python3 ez_setup.py && cd trash-cli-master && python3 setup.py install && mkdir --parent /.Trash && chmod a+rw /.Trash && chmod +t /.Trash
    - require:
      - file: copy_required
