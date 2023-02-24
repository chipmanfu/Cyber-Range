#!/bin/bash

rootDNS="198.41.0.4"
#add some color, cuz why not.
default="\e[0m"
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
ltblue="\e[1;36m"
white="\e[1;37m"

UsageMessage()
{
  echo -e "\n$green Usage: RegisterDNS.sh <DNSFile>\n"
  echo -e "$yellow<DNSFile>$ltblue - should be a file with your list of Domains and IPs"
  echo -e "\tThe file format should be domain,IP  - one per line and no spaces"
  echo -e "\tThen the last line should be a Tag and it has to be exactly \"# Tag:\""
  echo -e "\tBelow is example of the file format required.$white"
  echo -e "\n\t\texample.com,4.5.4.3"
  echo -e "\t\tWidgetfarmer.com,123.32.1.3"
  echo -e "\t\tthejuiceisloose.com,144.21.3.44"
  echo -e "\t\t# Tag:mytaggoeshere"
  echo -e "\n\t$yellow NOTE: don't put www in front of your domain, that will be added"
  echo -e "\tautomatically to your DNS zone file.$default"
  echo -e "\n\tTo View or Delete DNS use$white ManageDNS.sh$default, remember your tag\n"
}

if [[ -z $1 ]]; then
  UsageMessage
  exit
fi
if [[ ! -f $1 ]] || [[ ! -s $1 ]]; then
  echo -e "$red DNS Registration Aborted"
  echo -e "$yellow The file $white$1$yellow provide either doesn't exist, is empty or if its in a"
  echo -e "different directory and you need to provide the full path."
  echo -e "Run .\RegisterDNS.sh - to see file format requirements.$default"
  exit
else
  # Do some quit file validation
  # Check for tag
  tagin=`grep "# Tag:" $1 | cut -d: -f2`
  if [ -z $tagin ]; then 
    echo -e "$red DNS Registration Aborted"
    echo -e "$yellow Your file $white$1$yellow doesn't have a tag. Please add a tag to the last line."
    echo -e "should look like $white# Tag:yourtaghere$yellow  - but replace yourtaghere with something"
    echo -e "Run .\RegisterDNS.sh - to see file format requirements.$default"
    exit
  fi
  # if the script is still going we'll look at each IP and Domain.
  errorsfound=0
  while read i;
  do
    if [[ $errorsfound -ge 10 ]]; then
      echo -e "$RED Multiple errors found, aborting DNS registration, please review your"
      echo -e "DNS file."
      echo -e "Run .\RegisterDNS.sh - to see file format requirements.$default"
      exit
    fi
    if [[ $i == \#* ]] || [[ $i == "" ]]; then  #skipping comments or blank lines.
      continue
    fi
    #Seperate domain and IPs
    domain=`echo $i | cut -d, -f 1`
    IP=`echo $i | cut -d, -f 2`
    # Test that IP is valid.
    octets=`awk -F. '{print NF-1}' <<< $IP`
    if [[ $octets == 3 ]]; then
      if `ipcalc -c $IP | grep -iq INVALID`; then
        let errorsfound++
        echo -e "$red The IP listed for $yellow$domain$red of $yellow$IP$red is not a valid IP$default"
      fi
    else
      let errorsfound++
      echo -e "$red The IP listed for $yellow$domain$red of $yellow$IP$red is not a valid IP$default"
    fi
    # Check the domain name.
    regexFQDN="(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)"
    if [[ ! `echo $domain | grep -P $regexFQDN` ]]; then
      let errorsfound++
      echo -e "$red The domain $yellow$domain$red isn't a FQDN$default"
    fi
  done<$1
  if [[ $errorsfound -eq 0 ]]; then
    echo -e "$green DNS file check was successful, Registering DNS now!$default"
    echo -e "$yellow If prompted, the password is $green toor $yellow"
    echo -e " To avoid password prompts you can use ssh-copy-id 198.41.0.4 to set up keys$default"
    cp $1 /tmp/dnsfile.txt
    scp /tmp/dnsfile.txt $rootDNS:/root/scripts/OPFOR-DNS.txt
    ssh $rootDNS '/root/scripts/add-REDTEAM-DNS.sh /root/scripts/OPFOR-DNS.txt'
    rm /tmp/dnsfile.txt
  else
    echo -e "$red DNS Registation aborted due to errors.  Please fix your DNS file$default"
    echo -e "$yellow Run .\RegisterDNS.sh - to see file format requirements.$default"
  fi
fi
