#!/bin/bash
# written by Chip McElvain 
# Removes RedTeam DNS entries created by the add-REDTEAM-DNS.sh
# Arguments: redteam server tagname. 
# argument is used to delete specific redteam server domains,
# if no argument is passed it will delete all redteam DNS records.

# Create variables
rDNS="8.8.8.8"
bdir="/etc/bind/OPFOR"
confile="/etc/bind/named.conf.OPFOR"
sdir="/root/scripts"

# Clears terminal for output messages.
clear

# Check for argument.  This is used to detemine if we will be 
# deleting all Red team DNS or just a specific red team tagged records.
# Note: format for "tagging" red team DNS Zones is specified
# in the add-REDTEAM-DNS.sh located on the a.root server 
# at /root/scripts.  Basically the redteam template VM
if [ -z "$1" ]
then
  zonetag="OPFOR"
  namedstart="OPFORSTART"
  namedend="OPFOREND"
else
  zonetag="$1"
  tag=`echo $1 | sed 's/OPFOR-//g'`
  namedstart="OPFORSTART-$tag"
  namedend="OPFOREND-$tag"
fi
#process through the /etc/bind directory and remove any redteam entries.
for file in `ls $bdir/db.*`
do
  if grep -Fq "$zonetag" $file
  then
    echo "Deleting $file" 
    rm $file
  fi
done
# Remove reference in named.conf
sed "/\/\/$namedstart/,/\/\/$namedend/d" $confile > $sdir/named.tmp
if /usr/bin/named-checkconf $sdir/named.tmp > /dev/null 2>&1
then
  echo "Named.conf cleaned up and passed checkconf"
  mv $sdir/named.tmp $confile
  echo "Restarting bind9 service!"
  service bind9 restart
  echo "bind9 service status is below"
  service bind9 status | grep Active
else
  echo "There were errors in the named.conf changes"
  echo "Check the named.tmp file to see what the issue is"
  /usr/bin/named-checkconf $sdir/named.tmp 
fi
