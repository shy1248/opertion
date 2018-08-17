#!/bin/bash

targert_dir=/date/$(/bin/date +%Y%m%d -d -1day)
mkdir -p ${targert_dir}
/bin/find /var/log -type f -size +1k -mtime +7 | xargs mv -t ${targert_dir} 
