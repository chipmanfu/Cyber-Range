#!/bin/bash
cd /tmp
mkdir tbackup
cd tbackup

docker exec -i owncloud_db mysqldump -uowncloud -powncloud owncloud > owncloud.sql
tstamp=$(date '+%d-%b-%y')
tar -czvf owncloudbackup.tar.gz owncloud.sql 
cp owncloudbackup.tar.gz /root/backups/owncloud/owncloudbackup-$tstamp.tar.gz
rm -r /tmp/tbackup
