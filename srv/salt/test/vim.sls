vim_home:
  file.recurse:
    - name: /usr/share/vim/vimfiles
    - source: salt://files/vimfiles
    - user: root
    - file_mode: 644
    - dir_mode: 755
    - mkdir: True
    - clean: False
