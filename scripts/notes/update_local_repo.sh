#!/bin/bash  
###########################################################################
# File Name: update_local_repo.sh
# Author: yushuibo  
# Mail: hengchen2005@gmail.com  
# Descraption: Sync the online repo's rpms to loacl and disable to use 
#              the online repo. 
# Created Time: 2017-09-05 23:33:13
###########################################################################

# Define variables.
LANG=en
rpms_dir=/var/html/www/rhel6
online_dest=(`yum repolist|sed -n '/^repo id/{:a;n;/^repolist:/q;p;ba}'|awk '{print $1}'|grep -v 'Local$'|xargs`)
id_file=/etc/yum.repos.d/repo.id
log_dir=/var/log/repo.logs.d
local_repo=/etc/yum.repos.d/local.repo

# Update local repo file
updata_repo(){
cat >>$local_repo<<EOF
[$1-Local]
name=CentOS-6.9-$1-Local
baseurl=http://mirrors.node-managed.com/rhel6/$1
gpgcheck=0
enabled=1
EOF
}

# Disable all online repos.
disable_repo(){
	flag=`sed -n "/\[$1\]/,/^\[/p" $2|grep "enabled="|wc -l`
	if [ $flag -ne 0 ];then
		sed -i '/^enabled/c enabled=0' $2
	else
		sed -i "/^\[$1\]/a enabled=0" $2
	fi
}

# Updata repo ids to id file and disable it. 
updata_ids(){
	if [ ! -f $id_file ];then
		touch $id_file
	fi
	for dest in ${online_dest[*]};do
		if [ `grep "^$dest$" $id_file|wc -l` -eq 0 ];then
			echo $dest >> $id_file
			updata_repo $dest
			repo_file=`find /etc/yum.repos.d/ -type f ! -name "*local.repo"|xargs grep "\[$dest\]"|cut -d: -f1`
			disable_repo $dest $repo_file
			# Sync the local repo file to cluster node.
			cp -f $local_repo /srv/salt/prod/repo/files
			salt '*' state.sls repo.change_to_local prod &>/dev/null &
		fi
	done
}

# Check the online repo's rpm and download it to local.
sync(){
	while read line;do
		# -m Download group info file
		# -n Only download the last version package
		# -r The repo id
		# -p The packages saved directory  
	    reposync -m -n -r $line -p $rpms_dir
	done < $id_file
}

# Updata the packages index for local repo's db.
updata_repo_db(){
	while read line;do
		# If comps.xml existed, then update the local packags index by group
		if [ -f $rpms_dir/$line/comps.xml ];then
			createrepo -g comps.xml --update $rpms_dir/$line
		else
			createrepo --update $rpms_dir/$line
		fi
	done < $id_file
}

# Delete the log file which was created at 30 days ago. 
del_old_logs(){
	find $log_dir -type f -name "*.log" -mtime +30|xargs rm -f
}

# Main function.
main(){
	updata_ids
	temp=/tmp/reposync.temp
	# If no package to download, don't revoke the function which updata local repo's db.
    sync > $temp
	download_num=`grep "Downloading" $temp|wc -l`
	if [ $download_num -eq 0 ];then
		echo "No package download!"
	else
		grep "Downloading" $temp
		updata_repo_db
	fi
	rm -f $temp
	del_old_logs
}

[ $UID -ne 0 ] && echo "This script only can be executed by the root user." && exit 0

# Create log directory.
[ ! -d $log_dir ] && mkdir -p $log_dir
# Revoke the main function and write the log to file.
main $* &> $log_dir"/`date +%F`.log"
# main $*
