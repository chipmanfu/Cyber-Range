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
clear
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
sleep 5 

ShowCurrentSettings()
{
   if [[ ! -z $numsenders ]]; then SettingFormat "# of sending domains" "$numsenders"; fi
   if [[ ! -z $emaillist ]]; then SettingFormat "Send to Target Domain" "$emaillist ($numaddrs email addresses)"; fi
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
  bannertitle="Email Traffic Gen Configuration Script"
  printf "\n\t$ltblue %-60s %8s\n" "$bannertitle" "<b>-back"
  printf "\t$ltblue %60s %8s\n" "" "<q>-Quit"
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
  echo -e "\n$ltblue This will build a new docker-compose.yml file."
  echo -e "\n$ltblue  It will start up the following domains$white"
  cat $emailerfile | grep -v "^#" | grep -v "^$" | cut -d, -f1 | sed 's/^/\t/g'
  numsenders=`cat $emailerfile | grep -v '^#' | grep -v '^$' | wc -l`
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
            numaddrs=`cat $emaillistpath$emaillist/sendto.txt | wc -l`
            TimeintMenu
          else
            InputError
            MainMenu
          fi;;
   esac
}
TimeintMenu()
{
  timesel=
  MenuBanner
  echo -e "\n\t$ltblue Set email send frequency."
  echo -ne "\t$ltblue Enter a time interval in seconds Here (default is $dtime): $default"
  read timeint
  case $timeint in
    q|Q) echo -e "$default"; exit 0;;
    b|B) MainMenu; return;;
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
  jittersel=
  MenuBanner
  echo -e "\n\t$ltblue Set a time jitter value between 0 and 100, ex, 50 = 50%"
  echo -en "\t$ltblue Enter a Jitter Value here (default is $djitter): $default"
  read jitter
  case $jitter in 
    q|Q) echo -e "$default"; exit 0;;
    b|B) TimeintMenu; return;;
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
  maxtosel=
  MenuBanner
  echo -e "\n\t$ltblue Set the max. number of recipients per email."
  echo -en "\t$ltblue Enter Max to here (default $dmaxto): $default"
  read maxto
  case $maxto in
    q|Q) echo -e "$default"; exit 0;;
    b|B) JitterMenu; return;;
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
  maxattachsel=
  MenuBanner
  echo -e "\n\t$ltblue Set the max number of attachments you want per email? Max is 5."
  echo -en "\t$ltblue Enter Max Attachments here (default $dmaxattach): $default"
  read maxattach
  case $maxattach in
    q|Q) echo -e "$default"; exit 0;;
    b|B) MaxToMenu; return;;
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
  # Math for estimating # emails per hour explained.
  #  Number of Senders times the mean average of recipients (1 + max number of recipients)/2 this is divided by the mean average emai interval in seconds (time interval * jitter/100)/2
  #  Then this results on the emails per second.  To convert this to emails per hour I multiple it by 60 sec/m then multiple it by 60 m/hr.
  emailsperhr=`awk -v s=$numsenders -v m=$maxtosel -v t=$timesel -v j=$jittersel 'BEGIN { print s*((1+m)/2)/((t*j/100+t)/2)*60*60 }'`
  # Math for estimate # of emails per user per hour explained.
  # I take the estimated # of emails per hour from the above calculation, then divide that by the number of email address that the script is sending to.
  userperhr=`awk -v n=$numaddrs -v r=$emailsperhr 'BEGIN { print (r/n) }'`
  echo -e "\n$ltblue This will configure the Email Traffic gen with the above settings"
  echo -e "\n\t$white  Estimated rate of emails sent per hour: $green $emailsperhr"
  echo -e "\t$white  Estimated # of emails per user per hour: $green $userperhr" 
  echo -en "\n\t$ltblue Press <enter> to continue $default"
  read confirmbuild
  case $confirmbuild in
    q|Q) echo -e "$default"; exit 0;;
    b|B) MaxAttachMenu; return;;
      *) BuildYML;;
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
    echo "    entrypoint: /content/Script/StartEmailGen.sh -d $fqdn -t $timesel -j $jittersel -m $maxtosel -a $maxattachsel" >> $composefile
  done < /root/emailerlist.txt
  echo -e "$green Complete! Run 'starttrafficgen.sh' to start sending emails $default"
  exit 0
}
MainMenu
