#!/bin/bash
dtime=60
djitter=50
dmaxto=4
dmaxattach=2
composefile="docker-compose.yml"
emaillistpath="/root/TG/SendTo/"
emailerfile="/root/emailerlist.txt"
iface="ens35"           ##  Make sure this matches.
ltblue="\e[1;36m"
ltgray="\e[0;37m"
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

ShowCurrentSettings()
{
   if [[ ! -z $emaillist ]]; then SettingFormat "Send to Target Domain" "$emaillist"; fi
   if [[ ! -z $timesel ]]; then SettingFormat "Time Interval" "$timesel"; fi
   if [[ ! -z $jittersel ]]; then SettingFormat "Percent Jitter" "$jittersel"; fi
   if [[ ! -z $maxtosel ]]; then SettingFormat "Max To" "$maxtosel"; fi
   if [[ ! -z $maxattachsel ]]; then SettingFormat "Max Attachments" "$maxattachsel"; fi
}
SettingFormat()
{
  local title="$1"
  local value="$2"
  printf "$ltgray%25s: $green%-20b\n" "$title" "$value"
}
FormatOption()
{
  local count="$1"
  local title="$2"
  printf "\t$ltblue%3d )$white %-23b\n" "$count" "$title"
}

MenuBanner()
{
  clear
  echo -e "\n\t$ltblue Email Traffic Gen Configuration Script"
  ShowCurrentSettings
}

InputError()
{
  echo -e "\n\t\t$red Invalid Selection, Please try again $default"; sleep 2
}
IsNumber()
{
  local x=$1
  if [[ "$x" =~ ^[0-9]+$ ]]; then
    return 1 
  else 
    return 0
  fi
}
MainMenu()
{
  MenuBanner
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
            TimeintMenu
          else
            InputError
            MainMenu
          fi;;
   esac
}
TimeintMenu()
{
  MenuBanner
  echo -e "\n$ltblue How frequently would you like to the traffic-emailgen to send emails from each traffic gen domain?"
  echo -ne "\n\t$ltblue Enter a time interval in seconds Here (default is $dtime): $default"
  read timeint
  case $timeint in
    q|Q) echo -e "$default"; exit 0;;
     "") timesel=$dtime; JitterMenu;;
      *) if IsNumber $timeint; then
           InputError
           TimeintMenu
         else 
           timesel=$timeint
           JitterMenu
         fi
  esac
}

JitterMenu()
{
  MenuBanner
  echo -e "\n$ltblue How much Jitter do you want to use, enter a value between 0 and 100.  Ex, 50 = 50%"
  echo -en "\n\t$ltblue Enter a Jitter Value here (default is $djitter): $default"
  read jitter
  case $jitter in 
    q|Q) echo -e "$default"; exit 0;;
     "") jittersel=$djitter; MaxToMenu;;
      *) if IsNumber $jitter; then
           InputError
           JitterMenu
         else
           if (( $jitter < 0 || $jitter > 101 )); then
             InputError
             JitterMenu
           else
             jittersel=$jitter
             MaxToMenu
           fi
         fi
  esac
}
MaxToMenu()
{
  MenuBanner
  echo -e "\n$ltblue What is the max number of reciepts you want per email? Max is 10."
  echo -en "\n\t$ltblue Enter Max to here (default $dmaxto): $default"
  read maxto
  case $maxto in
    q|Q) echo -e "$default"; exit 0;;
     "") maxtosel=$dmaxto; MaxAttachMenu;;
      *) if IsNumber $maxto; then
           InputError
           MaxToMenu
         else
           if (( $Maxto < 0 || $Maxto > 11 )); then
             InputError
             MaxToMenu
           else
             maxtosel=$maxto
             MaxAttachMenu
           fi
         fi
  esac
}
MaxAttachMenu()
{
  MenuBanner
  echo -e "\n$ltblue What is the max number of attachments you want per email? Max is 5."
  echo -en "\n\t$ltblue Enter Max Attachments here (default $dmaxattach): $default"
  read maxattach
  case $maxattach in
    q|Q) echo -e "$default"; exit 0;;
     "") maxattachsel=$dmaxattach; BuildConfirm;;
      *) if IsNumber $maxattach; then
           InputError
           MaxAttachMenu
         else
           if (( $Maxattach < 0 || $Maxattach > 6 )); then
             InputError
             MaxAttachMenu
           else
             maxattachsel=$maxattach
             BuildConfirm
           fi
         fi
  esac
}

BuildConfirm()
{
  MenuBanner
  echo -e "\n$ltblue This will configure the Email Traffic gen with the above settings"
  echo -en "\n\t$ltblue Press <enter> to continue"
  read nothing
  BuildYML
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
    echo "    entrypoint: /content/Script/StartEmailGen.sh -d $fqdn -t $timesel -j $jittersel -m $maxtosel -a $maxattachsel" >> $composefile
  done < /root/emailerlist.txt
  echo -e "$green Complete! Run 'starttrafficgen.sh' to start sending emails $default"
  exit 0
}
MainMenu
