#!/bin/bash
# Written by Chip McElvain
# This script will randomly assign domains to redteam server IP addresses.
# It gets the ipfile list passed as a variable, then uses
# a masterdoaminlist file that consists of around 10500 domains that
# was obtained from an expired domain website.

# Check for argument.
if [ -z "$1" ]
then
  echo "You need to pass a IP file to use as a script argument"
  echo "script is exiting"
  exit 1
else
  ipfile=$1
fi

# Set variables for files 
dfile="/root/scripts/autoredirector/masterdomainlist.txt"
tempdns="/root/scripts/autoredirector/tempdns"
tempips="/root/scripts/autoredirector/tempips"
dnsfile="/root/scripts/autoredirector/dnsfile.txt"

# Get a count of IP's in the redirector IP list.
numips=`grep -c -v "^#" $ipfile`

# Get redirector hostname from the redirector ip file.  This is added to the 
# dnsfile for zone tagging in the DNS bind zone and named records.
# this tagging of zone files is done by the add-REDTEAM-DNS.sh
tagin=`grep "# Tag:" $ipfile | cut -d: -f2`


#Initialize files
echo -n "" >$tempdns
echo -n "" >$tempips

# Loop through master domain list and randomly grab domains for total number of IPs.
# Ignore any commented out domains, these were previously used.
for x in `cat $dfile | grep -v "^#" | shuf -n $numips`
do
 echo $x >> $tempdns
 # Comment out domain in the master domain file so it can't be reused.
 sed -i "s/$x/#$x/" $dfile
done

# Loop through the redirector IP file and strip out the IP address
for ips in `cat $ipfile | grep -v "^#"`
do
  echo $ips | cut -d/ -f1 >> $tempips
done

# Merge the domains with IPs, this will also overwrite and existing dnsfile.
paste $tempdns $tempips > $dnsfile

# modify the dns file so the domain and IP are seperated by a comma.
sed -i 's/\t/,/' $dnsfile

# Append the dnsfile with the hostname of the redirector for
# DNS record tagging.
echo "# Tag:$tagin" >> $dnsfile

# Clean up transfered redirector file and temp files used
rm $tempdns
rm $tempips
rm $ipfile
