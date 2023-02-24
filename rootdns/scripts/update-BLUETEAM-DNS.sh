#!/bin/bash
# Written by Chip McElvain 168COS
# Script to add DNS records.
# add user created zone records to all root servers
# clear the terminal for script output
clear

# Set variables
bdir="/etc/bind"
sdir="/root/scripts"

echo "Restarting bind9 service"
service bind9 restart
echo "Bind9 Status is below"
bindstatus=`service bind9 status | grep Active`
if `service bind9 status | grep -q "running"`
then
  echo "bind9 is good, going to update all roots"
else
  echo "Bind9 has a problem, aborting updating all roots!"
  /usr/sbin/named-checkconf $bdir/named.conf
  exit 1
fi

## UPDATE ALL OTHER ROOT SERVERS - script hasn't exited so bind is good.
sleep 1   # pause for 10 sec before updating all roots.
for i in `cat $sdir/rootips.txt`
do
  echo "Updating $i ...."
  for p in `grep -l ";BLUETEAMZONE" $bdir/db.*`
  do 
    scp $p root@$i:$p
  done
  scp $bdir/named.conf root@$i:$bdir/named.conf
  echo "Restarting $i Bind9 service"
  ssh root@$i service bind9 restart;
  ssh root@$i 'service bind9 status | grep Active' >output
  echo "Bind9 service status for $i"
  cat output
  rm output
done
## Last step, restart bind on the recursive DNS server to clear the cache
ssh root@17.72.153.88 service bind9 restart;
ssh root@17.72.153.88 'service bind9 status | grep Active' >output
echo "Bind9 service status for the Recursive DNS server"
cat output
rm output
