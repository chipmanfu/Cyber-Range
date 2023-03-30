#!/bin/bash
clear
echo -e "\n\tThis will remove all service configurations, do you want to continue?"
echo -ne "\tEnter Y for yes, otherwise enter q to abort: "
read answer
case $answer in 
  y|Y) nic=`ip link show | grep ^3: | awk {'print$2'} | cut -d: -f1` 
       rcon=`docker ps | wc -l`
       if [[ $rcon > 1 ]]; then
         docker kill $(docker ps -q)
       fi
       scon=`docker ps -a | wc -l`
       if [[ $scon > 1 ]]; then
         docker rm $(docker ps -a -q)
       fi
       docker network prune --force
       cp /etc/iproute2/rt_tables.org /etc/iproute2/rt_tables
       cp /etc/network/interfaces.org /etc/network/interfaces
       ip addr flush $nic
       sed -i '/^inet_interfaces/d' /etc/postfix/main.cf
       echo "inet_interfaces = 127.0.0.1" >> /etc/postfix/main.cf
       service networking restart
       rm -r /root/services/*;;
  *) exit 0;;
esac
