#!/bin/bash
# Written by Chip McElvain
# Script to add reverse DNS records from existing forward zones
# Creates reverse zones in /etc/bind/REVERSE with single named.conf.REVERSE

PIDFILE="/root/scripts/addREVERSEDNS.pid"

if [[ -s $PIDFILE ]]; then
  echo "Script is currently running, try again later"
  exit 0
else
  echo $BASHPID > $PIDFILE
fi

clear
echo "Reverse DNS Zone Generation"
echo "============================"

bdir="/etc/bind"
sdir="/root/scripts"
rdir="$bdir/REVERSE"
rconf="$bdir/named.conf.REVERSE"
tmpfile="$sdir/reverse_ips.tmp"

> $tmpfile

for category in OPFOR RANGE TRAFFIC; do
  if [ -d "$bdir/$category" ]; then
    echo "Scanning $category directory..."
    for zonefile in $bdir/$category/db.*; do
      [ -f "$zonefile" ] || continue
      
      domain=$(basename "$zonefile" | sed 's/db\.//')
      
      while read line; do
        [[ $line =~ ^[[:space:]]*# ]] && continue
        [[ $line =~ ^[[:space:]]*// ]] && continue
        [[ -z $line ]] && continue
        
        if [[ $line =~ ^@[[:space:]]+IN[[:space:]]+A[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
          ip="${BASH_REMATCH[1]}"
          echo "$ip|$category|$domain" >> $tmpfile
        fi
      done < "$zonefile"
    done
  fi
done

echo "Processing reverse zones..."

declare -A reverse_zones
declare -A ptr_records

while IFS='|' read -r ip category domain; do
  octets=(${ip//./ })
  third_octet=${octets[2]}
  second_octet=${octets[1]}
  first_octet=${octets[0]}
  last_octet=${octets[3]}
  
  network="${third_octet}.${second_octet}.${first_octet}"
  key="${network}"
  
  if [ -z "${reverse_zones[$key]}" ]; then
    reverse_zones[$key]=1
  fi
  
  ptr_records["${network}|${last_octet}"]="$domain|$category"
done < $tmpfile

mkdir -p "$rdir"

echo "//REVERSE DNS START" > "$sdir/reverse_zones.tmp"

for key in "${!reverse_zones[@]}"; do
  zone_name="${key}.in-addr.arpa"
  zone_file="$rdir/db.$zone_name"
  
  if [ -f "$zone_file" ]; then
    echo "Updating existing zone $zone_name"
    
    for ptr_key in "${!ptr_records[@]}"; do
      IFS='|' read -r ptr_net ptr_octet <<< "$ptr_key"
      [ "$ptr_net" != "$key" ] && continue
      
      ptr_data="${ptr_records[$ptr_key]}"
      IFS='|' read -r domain category <<< "$ptr_data"
      
      if ! grep -q "PTR.*$domain" "$zone_file"; then
        echo "  Adding PTR for $domain ($ptr_octet)"
        echo ";PTR-$category-$domain" >> "$zone_file"
        echo -e "${ptr_octet}\tIN\tPTR\t${domain}." >> "$zone_file"
        echo ";PTR-END" >> "$zone_file"
      fi
    done
    
    if ! grep -Fq "zone \"$zone_name.\"" "$rconf" 2>/dev/null; then
      echo "zone \"$zone_name.\" IN {" >> "$sdir/reverse_zones.tmp"
      echo "    type master;" >> "$sdir/reverse_zones.tmp"
      echo "    file \"REVERSE/db.$zone_name\";" >> "$sdir/reverse_zones.tmp"
      echo "    allow-query { any; };" >> "$sdir/reverse_zones.tmp"
      echo "    allow-update { none; };" >> "$sdir/reverse_zones.tmp"
      echo "};" >> "$sdir/reverse_zones.tmp"
    fi
  else
    echo "Creating new zone $zone_name"
    
    echo ";REVERSE-Zone" > "$zone_file"
    echo -e '$TTL\t86400' >> "$zone_file"
    echo -e "@\tIN\tSOA\t@\tns1.${zone_name}.\t42 3H 15M 1W 1D" >> "$zone_file"
    echo -e "@\tIN\tNS\t\tns1.${zone_name}." >> "$zone_file"
    echo -e 'ns1\tIN\tA\t\t198.41.0.4' >> "$zone_file"
    
    for ptr_key in "${!ptr_records[@]}"; do
      IFS='|' read -r ptr_net ptr_octet <<< "$ptr_key"
      [ "$ptr_net" != "$key" ] && continue
      
      ptr_data="${ptr_records[$ptr_key]}"
      IFS='|' read -r domain category <<< "$ptr_data"
      
      echo ";PTR-$category-$domain" >> "$zone_file"
      echo -e "${ptr_octet}\tIN\tPTR\t${domain}." >> "$zone_file"
      echo ";PTR-END" >> "$zone_file"
    done
    
    echo "zone \"$zone_name.\" IN {" >> "$sdir/reverse_zones.tmp"
    echo "    type master;" >> "$sdir/reverse_zones.tmp"
    echo "    file \"REVERSE/db.$zone_name\";" >> "$sdir/reverse_zones.tmp"
    echo "    allow-query { any; };" >> "$sdir/reverse_zones.tmp"
    echo "    allow-update { none; };" >> "$sdir/reverse_zones.tmp"
    echo "};" >> "$sdir/reverse_zones.tmp"
  fi
done

echo "//REVERSE DNS END" >> "$sdir/reverse_zones.tmp"

if [ $(wc -l < "$sdir/reverse_zones.tmp") -gt 2 ]; then
  if [ -f "$rconf" ]; then
    cat "$sdir/reverse_zones.tmp" "$rconf" > "$sdir/named_reverse.tmp"
  else
    cat "$sdir/reverse_zones.tmp" > "$sdir/named_reverse.tmp"
  fi
  
  if /usr/bin/named-checkconf "$sdir/named_reverse.tmp" > /dev/null 2>&1; then
    echo "Configuration OK"
    mv "$sdir/named_reverse.tmp" "$rconf"
  else
    echo "Configuration error:"
    /usr/bin/named-checkconf "$sdir/named_reverse.tmp"
    rm "$sdir/named_reverse.tmp"
    rm "$sdir/reverse_zones.tmp"
    rm $PIDFILE
    exit 1
  fi
  rm "$sdir/reverse_zones.tmp"
else
  echo "No new zones to add"
  rm "$sdir/reverse_zones.tmp"
fi

rm $tmpfile

echo "Restarting bind9 service"
service bind9 restart

if service bind9 status | grep -q "running"; then
  echo "bind9 is running successfully"
else
  echo "bind9 has a problem"
  exit 1
fi

rm $PIDFILE
echo "Reverse DNS setup complete"
