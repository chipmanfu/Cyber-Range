#!/bin/bash
composefile="docker-compose.yml"
emaillistpath="/root/TG/SendTo/"
emailerfile="/root/emailerlist.txt"
iface="ens35"           ##  Make sure this matches.
ltblue="\e[1;36m"
white="\e[1;37m"
yellow="\e[1;33m"
green="\e[1;32m"
red="\e[1;31m"
default="\e[0m"

echo -e "$ltblue\n Running a Traffic-Gen set up check"

IPList=`ip a | grep $iface | grep inet | awk {'print$2'} | cut -d/ -f1`
if [ -z "$IPList" ]; then
  echo -e "\t$red ERROR!! $yellow No IPs found, could be none are set or this script is looking at the"
  echo -e "\t wrong interface.  Script is using $white'$iface'$yellow if this is wrong, edit the script"
  echo -e "\t exiting.. $default"
  exit 0
fi
if [ ! -s $emailerfile ]; then
  echo -e "\t$red Error!! $white $emailerfile $yellow either doesn't exist or is empty.  This file needs to exist"
  echo -e "\t and match the file name above.  Format is FQDN, IP #no space, one per line"
  echo -e "\t exiting.. $default"
  exit 0
fi
errorcount=0
for combo in `cat $emailerfile | grep -v '^#' | grep -v '^$'`
do
  domainin=`echo $combo | cut -d, -f1`
  ipin=`echo $combo | cut -d, -f2`
  resolve=`nslookup $domainin`
  if echo $resolve | grep -q $ipin
  then 
    continue
  else
    if [ "$errorcount" -eq "0" ]; then  
      echo -e "$red Error!"$default
      errorcount=1
    fi
    echo -e "$yellow $domainin with $ipin doesn't resolve.  Check $white'nslookup $domainin'$default"
  fi
done
if [ "$errorcount" -eq "1" ]; then
  echo -e "$white exiting...$default"
  exit 0
fi

# Script is still running then it passed the checks, lets move on.
echo -e "$green All Checks are good!  Starting build compose file menu. $default"
sleep 3

FormatOption()
{
  local count="$1"
  local title="$2"
  printf "\t$ltblue%3d )$white %-23b\n" "$count" "$title"
}

InputError()
{
  echo -e "\n\t\t$red Invalid Selection, Please try again"; sleep 2
}
MainMenu()
{
  clear
  echo -e "\n$ltblue    This will build a new docker-compose.yml file.  It will start up the following domains$white"
  cat $emailerfile | grep -v "^#" | grep -v "^$" | cut -d, -f1 | sed 's/^/\t/g'
  echo -e "$ltblue     Select the target domains to send emails to below"
  count=1
  for folder in `ls $emaillistpath`; do
    FormatOption "$count" "$folder"
    let "count++";
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read optin
  case $optin in
    q|Q) echo -e "$default"; exit 0;;
      *)  if (( $optin >= 1 && $optin < $count )) 2>/dev/null; then
            emaillist=`ls $emaillistpath | sed -n ${optin}p`
            BuildYML
          else
            InputError
            MainMenu
          fi;;
   esac
}
BuildYML()
{
  clear
  echo -e "$green\n Building docker-compose file that will send emails to$white $emaillist"
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
    echo "    restart: unless-stopped" >> $composefile
    echo "    image: emailgen" >> $composefile
    echo "    stdin_open: true" >> $composefile
    echo "    tty: true" >> $composefile
    echo "    volumes:" >> $composefile
    echo "      - /root/TG/SendTo/$emaillist:/sendto" >> $composefile
    echo "      - /root/TG:/content" >> $composefile
    echo "    ports:" >> $composefile
    echo "      - $IP:25:25" >> $composefile
    echo "    entrypoint: /content/Script/StartEmailGen.sh -d $fqdn" >> $composefile
  done < /root/emailerlist.txt
  echo -e "$green Complete! Run 'starttrafficgen.sh' to start sending emails $default"
  exit 0
}
MainMenu
