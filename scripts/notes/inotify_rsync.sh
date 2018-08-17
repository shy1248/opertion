#!/bin/bash
# nfs sync by inotify+inotify.
# create by yu at 2017-080-28

password="123456"
bak_dir=/data
host=backup

/usr/bin/inotifywait -mrq --format "%w%F" -e close_write,delete ${bak_dir} \
| while read file
do
    if [ -e $file ];then
        echo $password | sudo -S rsync -az --delete $file ${bak_dir} rsync_user@$host::nfsbackup --password-file=/etc/rsyncd.secrets
    else
	echo $password | sudo -S rsync -az --delete $(dirname $file) ${bak_dir} rsync_user@$host::nfsbackup --password-file=/rsyncd.secrets
    fi
done
