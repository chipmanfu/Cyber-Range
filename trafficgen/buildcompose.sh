#!/bin/bash
composefile="docker-compose.yml"

echo "version: '3'" > $composefile
echo "services:" >> $composefile
while read line
do
  [[ "$line" =~ ^#.* ]] && continue
  fqdn=`echo $line | cut -d, -f1`
  IP=`echo $line | cut -d, -f2`
  name=`echo $fqdn | awk -F. '{print $(NF-1)}'`
  echo "  $name:" >> $composefile
  echo "    container_name: $name" >> $composefile
  echo "    hostname: $fqdn" >> $composefile
  echo "    image: emailgen" >> $composefile
  echo "    stdin_open: true" >> $composefile
  echo "    tty: true" >> $composefile
  echo "    volumes:" >> $composefile
  echo "      - /root/TG/SendTo/OEV/ALL:/sendto" >> $composefile
  echo "      - /root/TG:/content" >> $composefile
  echo "    ports:" >> $composefile
  echo "      - $IP:25:25" >> $composefile
  echo "    entrypoint: /content/Script/StartEmailGen.sh -d $fqdn" >> $composefile
done < /root/emailerlist.txt
