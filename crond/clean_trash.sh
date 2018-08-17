#!/bin/bash  
###########################################################################
# File Name: clean_trash.sh
# Author: 
# Mail:
# Descraption: --  
# Created Time: 2017-11-28 17:22:49
###########################################################################

trash_root='/.Trash'
salt \* cmd.run "[ -d $trash_root ] && cd $trash_root && find . -mtime +30|xargs /bin/rm -rf"
