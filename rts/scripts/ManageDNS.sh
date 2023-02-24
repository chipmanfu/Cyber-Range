#!/bin/bash
# Written by Chip McElvain 
# Manages Domain name registration
# NOTE: Set up ssh keys between the primary range DNS server and this redirector 
# before this will work.
rootDNS="198.41.0.4"
# Set variable names to add color codes to menu displays.
white="\e[1;37m"
ltblue="\e[1;36m"
ltgray="\e[0;37m"
red="\e[1;31m"
green="\e[1;32m"
whiteonblue="\e[5;37;44m"
yellow="\e[1;33m"
default="\e[0m"

# Check for network connectivity to the primary DNS server.
ping -c 1 $rootDNS 1>/dev/null

if [[ $? -ne 0 ]]
then
  clear
  echo -e "\n\t\t\t$red ####  ERRROR  ####"
  echo -e "\t$ltgray Can't reach the primary DNS server at $rootDNS"
  echo -e "\t Check your IPs\n$default"
  exit 0;
fi

# set conf file location
TempDNSconf="/tmp/tmpDNS.txt"
DNSconf="/root/OPFOR-DNS.txt"
CurDNSInfo="/tmp/CurDNSinfo.txt"
# Set variables
random=0
bannertitle="DNS Management Menu"
# Header for all menu items, clears the terminal, adds a banner.
MenuBanner()
{
  clear
  printf "\n\t$ltblue %-60s %8s\n"  "$bannertitle" "<b>-Back"
  printf "\t$ltblue %60s %8s\n"  "" "<q>-Quit"
}

FormatOptions()
{
  local count="$1"
  local title="$2"
  local dnsname="$3"
  printf "\t$ltblue%3b )$white %-15b $green%-40b\n" "$count" "$title" "$dnsname"
}

InputError()
{
  echo -e "\n\t\t$red Invalid Selection, Please try again"; sleep 2
}

UserQuit()
{
  echo -e "$default";if [[ -f "$TempDNSconf" ]]; then rm $TempDNSconf; fi; exit 0
}

DNSMenu()
{
  MenuBanner
  echo -e "\n\t$ltblue What would you like to do?"
  FormatOptions 1 "View DNS records"
  FormatOptions 2 "Delete DNS records"
  echo -ne "\n\t$ltblue Enter a Selection: $white"
  read answer 
  case $answer in 
    1)  ViewDNSMenu;;
    2)  DeleteDNSMenu;;
    b|B) DNSMenu;;
    q|Q) UserQuit;;
    *) InputError
       DNSMenu;;
  esac
}

GetDNSInfo()
{
  # Get DNS information for the primary DNS server
  ssh $rootDNS 'cd /etc/bind/OPFOR; grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" * | uniq | sed "s/db.//" | sed "s/\:/ /"' > /tmp/IPinfo
  ssh $rootDNS 'cd /etc/bind/OPFOR; grep -Eo "OPFOR[-0-9A-Za-z]{0,40}" * | sed "s/db.//" | sed "s/\:/ /"' > /tmp/taginfo
  awk 'FNR==NR{a[$1]=$2 FS $3;next} $1 in a {print $0, a[$1]}' /tmp/taginfo /tmp/IPinfo | sort -k 3 > $CurDNSInfo
  usertags=`cat $CurDNSInfo | cut -d " " -f 3 | sort -u`
}

ViewDNSMenu()
{
  GetDNSInfo
  MenuBanner
  echo -e "\n\tTo view registered OPFOR DNS records, select from the options below"
  FormatOptions 1 "View all OPFOR DNS records"
  count=2
  for usertag in $usertags
  do 
    FormatOptions "$count" "tagged with ${yellow}$usertag$white"
    let count++
    if [[ $count == 21 ]]; then break; fi
  done
  echo -en "\n\t$ltblue Enter a Selection: $white"
  read answer
  case $answer in 
    b|B) DNSMenu;;
    q|Q) UserQuit;;
      *) if (( $answer >= 1 && $answer < $count)) 2>/dev/null; then
           clear
           if (( $answer == 1 )); then
             cat $CurDNSInfo
	     echo "Hit return to continue"
             read doesntmatter
	     ViewDNSMenu 
           else
             offset=`expr $answer - 1`
             user=`echo $usertags | cut -d" " -f$offset`
             grep $user $CurDNSInfo > /tmp/userdns.txt
             cat /tmp/userdns.txt
	     echo "Hit return to continue"
             read doesntmatter
             rm /tmp/userdns.txt
             ViewDNSMenu
           fi
         else
           InputError
           ViewDNSMenu
         fi;;
  esac
}
DeleteDNSMenu()
{
  GetDNSInfo
  MenuBanner
  echo -e "\n\t$yellow Note: DNS records are tagged with the username you created when you made them."  
  echo -e "\tSelecting option 2 will delete ones you previously created using that username"
  echo -e "\tWarning, if someone else created records using this same username,"
  echo -e "\tthey will get delete too\n"
  echo -e "\t$ltblue Which DNS records would you like to delete?"
  FormatOptions 1 "${red}All$white OPFOR DNS Records"
  count=2
  for usertag in $usertags
  do 
    FormatOptions "$count" "tagged by ${yellow}$usertag$white"
    let count++
    if [[ $count == 24 ]]; then break;fi
  done
  echo -en "\n\t$ltblue Enter a Selection: $white"
  read answer
  case $answer in
    b|B) DNSMenu;;
    q|Q) UserQuit;;
    *) if (( $answer >= 1 && $answer <= $count)) 2>/dev/null; then
         if (( $answer == 1 )); then
           delopt="all" 
         else
           offset=`expr $answer - 1`
           user=`echo $usertags | cut -d" " -f$offset`
           delopt=$user
         fi
         DeleteDNS
       else
         InputError
	 DeleteDNSMenu
       fi;;
  esac
}

DeleteDNS()
{
  MenuBanner
  if [[ $delopt == "all" ]]; then
    echo -e "\n\t$yellow Warning!!! This will delete$red ALL$yellow Red Team DNS records.\n"
    echo -e "\t$ltblue Are you absolutely sure this is what you want to do?"
  else 
    echo -e "\n\t$yellow Warning! This will delete all DNS records for $delopt"
    echo -e "\n\t$ltblue Are you sure you want to delete all$yellow $delopt$ltblue Red Team DNS records?"  
  fi
  echo -en "\t$ltblue Enter y to continue $default "
  read answer 
  case $answer in
     y|Y|yes|YES|Yes) 
       clear
       if [[ $delopt == "all" ]]; then
         echo -e "\n\t$red YOUR ARE DELETING ALL OPFOR DNS RECORDS!! Are you sure about this?"
         echo -e "\n\t$yellow Deleting in 30 seconds, hit ctrl+C to abort$default"
         sleep 30
         ssh $rootDNS '/root/scripts/delete-REDTEAM-DNS.sh'
         echo -e "\n\t$green All Red Team DNS has been deleted, I hope you really wanted to do this.$default"
       else
	 echo -e "\n\t$ltblue Deleting DNS records for$yellow $delopt$ltblue in 10 seconds, hit ctrl+c to abort$default"
	 sleep 10
         ssh $rootDNS "/root/scripts/delete-REDTEAM-DNS.sh $delopt"
         echo -e "\n\t$green All Red Team DNS tagged with $delopt have been deleted," 
         echo -e "\t I hope you really wanted to do this.$default"
       fi;;
     b|B) DeleteDNSMenu;;
     q|Q) UserQuit;;
     *) InputError
        DeleteDNS;;
   esac
   
}
  
DNSMenu
