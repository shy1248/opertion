#!/bin/bash
#Config QQMAIL for Centos6.9 by yu
#Create at 2017-08-26

. /etc/init.d/functions 

if [ $# -ne 0 ];then
    echo "Usage: sh `basename $0`"
    exit 1 
fi

password="123456"
#QQMAIL authentication strings
mail_address='nengmeng5002@qq.com'
smtp_host='smtp.qq.com'
smtp_auth_user='nengmeng5002@qq.com'
#Your applications password for stmp.
smpt_auth_password='xclzcbbhixlmbgcg'
certs_dir=~/.certs
mail_conf=/etc/mail.rc

if [ -f $mail_conf ];then
   echo $password | sudo -S rm -f $mail_conf
fi

echo $password | sudo -S bash -c \
"cat >> $mail_conf <<EOF 
set from=$mail_address
set smtp=$smtp_host
set smtp-auth-user=$smtp_auth_user
set smtp-auth-password=$smpt_auth_password
set smtp-auth=login
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=$certs_dir
EOF"

if [ $? -eq 0 ];then
    echo "==================== Create Mail Done ===================="
    cat $mail_conf
fi
echo 
echo "Start to create a SSL certs ..."
[ ! -d $certs_dir ] && mkdir -p $certs_dir
echo -n | openssl s_client -connect $smtp_host:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $certs_dir/qq.mail.crt
certutil -A -n "GeoTrust SSL CA" -t "C,," -d $certs_dir -i $certs_dir/qq.mail.crt
certutil -A -n "GeoTrust Global CA" -t "C,," -d $certs_dir -i $certs_dir/qq.mail.crt
certutil -L -d $certs_dir
 
[ $? -eq 0  ] && echo "SSL created done."
