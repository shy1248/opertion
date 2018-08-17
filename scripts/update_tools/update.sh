#!/bin/bash  
###########################################################################
# File Name: update.sh
# Author: yushuibo  
# Mail: hengchen2005@gmail.com  
# Descraption: --  
# Created Time: 2017-11-10 15:33:37
###########################################################################

# temp directory
temp="./temp"
zip_file="dist.zip"
remote_host=$1
remote_dir=$2

[ $# -ne 2 ] && {
	echo "USAGE: `basename $0` remote_host remote_dir"
	exit 10
}

# upload files
cd $temp
echo "Uploading original files ..."
rz

# unzip files
echo "Unzip original files ..."
unzip $zip_file

cd dist
target_files=(`find . -type f`)
for file in ${target_files[*]};do
	echo "NOTICE: $file will be updated."
done

user=`ssh -t $remote_host "stat dist|grep 'Uid:'|awk '{print $6}'|sed 's/)//g"`
# backup remote files
echo "Backup remote files ..."
ssh -t $remote_host "cd $remote_dir;cp -r dist dist-`date +%F|sed 's/-//g'`"

# copy local files to remote
echo "Copying files to remote ..."
for file in ${target_files[*]};do
	scp $file $remote_host:$remote_dir/dist`echo $file|sed 's/^.//g'`
done

# restart service
echo "Restarting service ..."

echo "Update package done."
