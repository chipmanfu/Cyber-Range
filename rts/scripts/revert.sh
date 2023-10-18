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
       oct3=`shuf -i 0-15 -n 1`
       oct4=`shuf -i 2-254 -n 1 `
       newip="5.29.$oct3.$oct4/20"
       anic=`ip link show | grep ^2: | awk {'print$2'} | cut -d: -f1`
       bnic=`ip link show | grep ^3: | awk {'print$2'} | cut -d: -f1`
       echo -e "auto lo\niface lo inet loopback" > /etc/network/interfaces
       echo -e "\nauto $anic\niface $anic inet dhcp" >> /etc/network/interfaces
       echo -e "\nauto $bnic\niface $bnic inet static\n\taddress $newip" >> /etc/network/interfaces
       echo -e "\tgateway 5.29.0.1" >> /etc/network/interfaces
       ip addr flush $nic
       sed -i '/^inet_interfaces/d' /etc/postfix/main.cf
       echo "inet_interfaces = 127.0.0.1" >> /etc/postfix/main.cf
       service networking restart
       [ "$(ls -A /root/services)" ] && rm -r /root/services/* || echo "";;
  *) exit 0;;
esac
