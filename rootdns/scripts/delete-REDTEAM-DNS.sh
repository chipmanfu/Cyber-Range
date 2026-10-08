#!/bin/bash
# written by Chip McElvain
# Removes RedTeam DNS entries created by add-REDTEAM-DNS.sh
# Arguments: redteam server tagname.
# If no argument, deletes all redteam DNS records.

rDNS="8.8.8.8"
bdir="/etc/bind/OPFOR"
rdir="/etc/bind/REVERSE"
confile="/etc/bind/named.conf.OPFOR"
rconfile="/etc/bind/named.conf.REVERSE"
sdir="/root/scripts"

clear

if [ -z "$1" ]; then
  zonetag="OPFOR"
  namedstart="OPFORSTART"
  namedend="OPFOREND"
  ptrtag="PTR-OPFOR"
else
  zonetag="$1"
  tag=$(echo "$1" | sed 's/OPFOR-//g')
  namedstart="OPFORSTART-$tag"
  namedend="OPFOREND-$tag"
  ptrtag="PTR-OPFOR-$tag"
fi

for file in $(ls $bdir/db.* 2>/dev/null); do
  if grep -Fq "$zonetag" "$file"; then
    echo "Deleting $file"
    rm "$file"
  fi
done

for file in $(ls $rdir/db.* 2>/dev/null); do
  if grep -Fq "$ptrtag" "$file"; then
    echo "Removing PTR records from $file"
    sed "/;$ptrtag/,/;PTR-END/d" "$file" > "$sdir/reverse_tmp.tmp"
    mv "$sdir/reverse_tmp.tmp" "$file"
    
    if ! grep -q "IN.*PTR" "$file"; then
      echo "Zone file $file has no more PTR records, deleting"
      rm "$file"
    fi
  fi
done

sed "/\/\/$namedstart/,/\/\/$namedend/d" "$confile" > "$sdir/named.tmp"

if /usr/bin/named-checkconf "$sdir/named.tmp" > /dev/null 2>&1; then
  echo "Forward named.conf cleaned up and passed checkconf"
  mv "$sdir/named.tmp" "$confile"
else
  echo "Errors in forward named.conf changes"
  /usr/bin/named-checkconf "$sdir/named.tmp"
  rm "$sdir/named.tmp"
  exit 1
fi

if [ -f "$rconfile" ]; then
  echo "Regenerating named.conf.REVERSE..."
  echo "//REVERSE DNS START" > "$sdir/named_reverse.tmp"
  
  for file in $(ls $rdir/db.* 2>/dev/null); do
    if [ -s "$file" ] && grep -q "IN.*PTR" "$file"; then
      zone_name=$(basename "$file" | sed 's/db\.//')
      echo "zone \"$zone_name.\" IN {" >> "$sdir/named_reverse.tmp"
      echo "    type master;" >> "$sdir/named_reverse.tmp"
      echo "    file \"REVERSE/db.$zone_name\";" >> "$sdir/named_reverse.tmp"
      echo "    allow-query { any; };" >> "$sdir/named_reverse.tmp"
      echo "    allow-update { none; };" >> "$sdir/named_reverse.tmp"
      echo "};" >> "$sdir/named_reverse.tmp"
    fi
  done
  
  echo "//REVERSE DNS END" >> "$sdir/named_reverse.tmp"

  if /usr/bin/named-checkconf "$sdir/named_reverse.tmp" > /dev/null 2>&1; then
    echo "Reverse named.conf cleaned up and passed checkconf"
    mv "$sdir/named_reverse.tmp" "$rconfile"
  else
    echo "Errors in reverse named.conf changes"
    /usr/bin/named-checkconf "$sdir/named_reverse.tmp"
    rm "$sdir/named_reverse.tmp"
    exit 1
  fi
fi

echo "Restarting bind9 service!"
service bind9 restart

echo "bind9 service status is below"
service bind9 status | grep Active
