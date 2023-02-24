#!/bin/bash
# Written by Chip McElvain 
# Script to add DNS records.
# needs file to read in
# Format for the file should be domain,IP with a tag line at the end that
# looks like  "# Tag:mytag" where mytag is whatever you want to tag it with. 

# Prevent a PID to lock the script to prevent simulaneous exectution.
PIDFILE="/root/scripts/addDNS.pid"

# Check if the script is already running before doing things.
if [[ -s $PIDFILE ]]; then
  echo "Script is currently running, try again later"
  exit 0
else
  echo $BASHPID > $PIDFILE
fi 

# Check for argument.
if [ -z "$1" ]
then
  echo "This script requires a file to be passed as an argument"
  echo "The file formate is domain,IP and the last line should be a tag line"
  echo "The tag line format is # Tag:mytag   - where mytag is whatever you want to use"
  rm $PIDFILE
  exit 1
else
  dnsconf=$1
fi

#clear Terminal for output
clear

# Check to see if dnsconf file exists and isn't empty
if [ ! -f $dnsconf ] || [ ! -s $dnsconf ]
then
  echo "The file $dnsconf is empty or doesn't exist."
  echo "Script is exiting"
   rm $PIDFILE
   exit 1
fi

# Set variables
bdir="/etc/bind"
odir="/etc/bind/OPFOR"
sdir="/root/scripts"

# a DNS file exists and isn't empty, so we are going to process it.
echo "DNS file processing."

# Get user tag
userin=`grep "# Tag:" $dnsconf | cut -d: -f2`

# create comment tags for DNS entries based what was passed in the tag line
# otherwise use a generic OPFOR tag.  This is used to remove DNS entries later.
# NOTE: for a zone file comments are denoted by a ";"
# NOTE: for zone references made in named.conf.OPFOR, comments are denoted by "//".

if [ -z $userin ]
then  #use generic Tags
  zonetag=";OPFOR-NoTag"
  namedstart="//OPFORSTART-NoTag"
  namedend="//OPFOREND-NoTag"
else
  zonetag=";OPFOR-$userin"
  namedstart="//OPFORSTART-$userin"
  namedend="//OPFOREND-$userin"
fi

# Create a zones.tmp file for storing zone references that we will add
# to the named.conf at the end.
echo $namedstart > $sdir/zones.tmp

# Loop through the DNS files records in $dnsfile.
while read i; 
do
  # Ignore comments and empty lines
  if [[ $i == \#* ]] || [[ $i == "" ]]
  then continue
  fi

  # Seperate domain and IPs
  domain=`echo $i | cut -d, -f 1`
  IP=`echo $i | cut -d, -f 2`

  # Create zone file or overwrite any existing zone files with the same domain
  # First check to see if a zone file for the domain exists.
  # using a wild card for directory so it will check OPFOR,SimSpace,and Range directorys.
  if [ -f /etc/bind/*/db.$domain ]
  then
    # If we get a hit, well see if it's already an OPFOR doamin, and if so we'll update it.
	if grep -q OPFOR $odir/db.$domain; then
	  echo "Updating db.$domain"
	else 
	  echo "Domain $domain is already registered. Skipping"
	  continue
	fi
  else
    echo "Adding db.$domain"
  fi

  # Create the zone file
  echo "$zonetag" > $odir/db.$domain
  echo -e "\$TTL\t86400" >> $odir/db.$domain
  echo -e "@\tIN\tSOA\t@\tns1.$domain. 42 3H 15M 1W 1D" >> $odir/db.$domain
  echo -e "@\tIN\tNS\t\tns1.$domain." >> $odir/db.$domain
  echo -e "@\tIN\tMX\t10\t$domain." >> $odir/db.$domain
  echo -e "@\tIN\tA\t\t$IP" >> $odir/db.$domain
  echo -e "mail\tIN\tA\t\t$IP" >> $odir/db.$domain
  echo -e "www\tIN\tA\t\t$IP" >> $odir/db.$domain
  echo -e "ns1\tIN\tA\t\t198.41.0.4" >> $odir/db.$domain

  # checks if domain is already in named.conf
  if grep -Fq "zone \"$domain.\"" $bdir/named.conf.OPFOR
  then
    continue # We don't need to add the reference to the zone file since it already exists.
  else
    # create zone file reference in named.conf.OPFOR
    echo "zone \"$domain.\" IN {"  >> $sdir/zones.tmp
    echo "    type master;" >> $sdir/zones.tmp
    echo "    file \"OPFOR/db.$domain\";" >> $sdir/zones.tmp
    echo "    allow-query { any; };" >> $sdir/zones.tmp
    echo "    allow-update { none; };" >> $sdir/zones.tmp
    echo "};" >> $sdir/zones.tmp
  fi
done<$dnsconf

# Checks to see if there were any zone files references that need to be added
# to named.conf
if [[ $(wc -l <$sdir/zones.tmp) -eq 1 ]]
then
  echo "No new zone files to add to named.conf"
  rm $sdir/zones.tmp
else
  # Close the zone reference file with a tag so the section can be identified.
  # This is done on the temp file which is then tested for config errors 
  # before putting in production and restarting bind.
  echo $namedend >> $sdir/zones.tmp
  cat $sdir/zones.tmp $bdir/named.conf.OPFOR > $sdir/named.tmp

  # Checks the modified named.conf configuration
  if /usr/sbin/named-checkconf $sdir/named.tmp > /dev/null 2>&1
  then
    echo "DNS Zone changes to named.conf checked out good"
    rm $sdir/zones.tmp
    mv $sdir/named.tmp $bdir/named.conf.OPFOR
  else
    echo "DNZ Zone Changes created errors, see below"
    /usr/sbin/named-checkconf $sdir/named.tmp
    rm $sdir/named.tmp
    rm $sdir/zones.tmp
    rm $PIDFILE
    exit 1
  fi
fi

# If the script is still running, config changes are good so lets restart
# bind9 on the root Server
echo "Restarting bind9 service"
service bind9 restart
echo "Bind9 Status is below"
bindstatus=`service bind9 status | grep Active`
if `service bind9 status | grep -q "running"`
then
  echo "bind9 is good, have a good day!"
else
  echo "Bind9 has a problem, WHAT DID YOU DO!!"
  /usr/sbin/named-checkconf $bdir/named.conf.OPFOR
  rm $PIDFILE
  exit 1
fi
rm $PIDFILE
