#!/bin/bash
cd /tmp
mkdir tbackup
cd tbackup

docker exec -i bookstack_db mysqldump -uroot -pbookstack bookstackapp > bookstack.sql
docker cp bookstack:/config/www/uploads .
docker cp bookstack:/config/www/files .
tstamp=$(date '+%d-%b-%y')
tar -czvf redbookbackup.tar.gz bookstack.sql uploads/ files/
cp redbookbackup.tar.gz /root/backups/redbook/redbookbackup-$tstamp.tar.gz
rm -r /tmp/tbackup
