#!/bin/bash
# Written by Chip McElvain
# Script to add DNS records with reverse DNS support
# Format: domain,IP with optional tag line "# Tag:mytag"

PIDFILE="/root/scripts/addDNS.pid"

if [[ -s $PIDFILE ]]; then
  echo "Script is currently running, try again later"
  exit 0
else
  echo $BASHPID > $PIDFILE
fi

if [ -z "$1" ]; then
  echo "This script requires a file to be passed as an argument"
  echo "The file format is domain,IP and the last line should be a tag line"
  echo "The tag line format is # Tag:mytag"
  rm $PIDFILE
  exit 1
else
  dnsconf=$1
fi

clear

if [ ! -f $dnsconf ] || [ ! -s $dnsconf ]; then
  echo "The file $dnsconf is empty or doesn't exist."
  echo "Script is exiting"
  rm $PIDFILE
  exit 1
fi

bdir="/etc/bind"
odir="/etc/bind/OPFOR"
rdir="/etc/bind/REVERSE"
sdir="/root/scripts"
rconf="$bdir/named.conf.REVERSE"

echo "DNS file processing."

userin=$(grep "# Tag:" $dnsconf | cut -d: -f2)

if [ -z $userin ]; then
  zonetag=";OPFOR-NoTag"
  namedstart="//OPFORSTART-NoTag"
  namedend="//OPFOREND-NoTag"
  ptrstart=";PTR-OPFOR-NoTag"
  ptrend=";PTR-END"
else
  zonetag=";OPFOR-$userin"
  namedstart="//OPFORSTART-$userin"
  namedend="//OPFOREND-$userin"
  ptrstart=";PTR-OPFOR-$userin"
  ptrend=";PTR-END"
fi

echo $namedstart > $sdir/zones.tmp

while read i; do
  if [[ $i == \#* ]] || [[ $i == "" ]]; then
    continue
  fi

  domain=$(echo $i | cut -d, -f 1)
  IP=$(echo $i | cut -d, -f 2)

  if [ -f /etc/bind/*/db.$domain ]; then
    if grep -q OPFOR $odir/db.$domain; then
      echo "Updating db.$domain"
    else
      echo "Domain $domain is already registered. Skipping"
      continue
    fi
  else
    echo "Adding db.$domain"
  fi

  echo "$zonetag" > $odir/db.$domain
  echo -e '$TTL\t86400' >> $odir/db.$domain
  echo -e '@\tIN\tSOA\t@\tns1.'"$domain"'. 42 3H 15M 1W 1D' >> $odir/db.$domain
  echo -e '@\tIN\tNS\t\tns1.'"$domain"'.' >> $odir/db.$domain
  echo -e '@\tIN\tMX\t10\t'"$domain"'.' >> $odir/db.$domain
  echo -e '@\tIN\tA\t\t'"$IP" >> $odir/db.$domain
  echo -e 'mail\tIN\tA\t\t'"$IP" >> $odir/db.$domain
  echo -e 'www\tIN\tA\t\t'"$IP" >> $odir/db.$domain
  echo -e 'ns1\tIN\tA\t\t198.41.0.4' >> $odir/db.$domain

  if grep -Fq "zone \"$domain.\"" $bdir/named.conf.OPFOR; then
    :
  else
    echo "zone \"$domain.\" IN {" >> $sdir/zones.tmp
    echo "    type master;" >> $sdir/zones.tmp
    echo "    file \"OPFOR/db.$domain\";" >> $sdir/zones.tmp
    echo "    allow-query { any; };" >> $sdir/zones.tmp
    echo "    allow-update { none; };" >> $sdir/zones.tmp
    echo "};" >> $sdir/zones.tmp
  fi

  octets=(${IP//./ })
  third_octet=${octets[2]}
  second_octet=${octets[1]}
  first_octet=${octets[0]}
  last_octet=${octets[3]}
  network="${third_octet}.${second_octet}.${first_octet}"
  zone_name="${network}.in-addr.arpa"
  rev_zone_file="$rdir/db.$zone_name"

  mkdir -p "$rdir"

  if [ -f "$rev_zone_file" ]; then
    if grep -q "PTR.*$domain" "$rev_zone_file"; then
      echo "PTR record for $domain already exists in $zone_name. Skipping reverse."
    else
      echo "Adding PTR record to existing zone $zone_name"
      echo "$ptrstart-$domain" >> "$rev_zone_file"
      echo -e "${last_octet}\tIN\tPTR\t${domain}." >> "$rev_zone_file"
      echo "$ptrend" >> "$rev_zone_file"
    fi
  else
    echo "Creating new reverse zone $zone_name"
    echo ";REVERSE-Zone" > "$rev_zone_file"
    echo -e '$TTL\t86400' >> "$rev_zone_file"
    echo -e "@\tIN\tSOA\t@\tns1.${zone_name}.\t42 3H 15M 1W 1D" >> "$rev_zone_file"
    echo -e "@\tIN\tNS\t\tns1.${zone_name}." >> "$rev_zone_file"
    echo -e 'ns1\tIN\tA\t\t198.41.0.4' >> "$rev_zone_file"
    echo "$ptrstart-$domain" >> "$rev_zone_file"
    echo -e "${last_octet}\tIN\tPTR\t${domain}." >> "$rev_zone_file"
    echo "$ptrend" >> "$rev_zone_file"

    if ! grep -Fq "zone \"$zone_name.\"" "$rconf" 2>/dev/null; then
      echo "zone \"$zone_name.\" IN {" >> "$sdir/zones.tmp"
      echo "    type master;" >> "$sdir/zones.tmp"
      echo "    file \"REVERSE/db.$zone_name\";" >> "$sdir/zones.tmp"
      echo "    allow-query { any; };" >> "$sdir/zones.tmp"
      echo "    allow-update { none; };" >> "$sdir/zones.tmp"
      echo "};" >> "$sdir/zones.tmp"
    fi
  fi
done < $dnsconf

if [[ $(wc -l < $sdir/zones.tmp) -gt 1 ]]; then
  echo $namedend >> $sdir/zones.tmp
  cat $sdir/zones.tmp $bdir/named.conf.OPFOR > $sdir/named.tmp

  if /usr/bin/named-checkconf $sdir/named.tmp > /dev/null 2>&1; then
    echo "DNS Zone changes to named.conf checked out good"
    rm $sdir/zones.tmp
    mv $sdir/named.tmp $bdir/named.conf.OPFOR
  else
    echo "DNS Zone Changes created errors, see below"
    /usr/bin/named-checkconf $sdir/named.tmp
    rm $sdir/named.tmp
    rm $sdir/zones.tmp
    rm $PIDFILE
    exit 1
  fi
else
  echo "No new forward zone files to add to named.conf"
  rm $sdir/zones.tmp
fi

echo "Restarting bind9 service"
service bind9 restart

if service bind9 status | grep -q "running"; then
  echo "bind9 is running successfully"
else
  echo "bind9 has a problem"
  /usr/bin/named-checkconf $bdir/named.conf.OPFOR
  rm $PIDFILE
  exit 1
fi

rm $PIDFILE
echo "DNS setup complete"
