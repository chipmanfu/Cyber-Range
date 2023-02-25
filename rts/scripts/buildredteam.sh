#!/bin/bash
# script abomination by Chip McElvain
# Not Red Team infastructure multi-use thing 

#### Secret Menu ## default is bridge, set this to zero, to start a teamserver on the host
#####  network.  If you do this, you'll need to always set teamserver listener "bind to" 
#####  ports to something non-standard.
tsbridge=1

##### ENVIRONMENT SPECIFIC VARIABLES ####
intname="ens192"                         # Interface name for the "in-game" interface
CAserver="180.1.1.51"                   # This is the IP for CA Server
capass="toor"
CAcrtpath="/root/ca/intermediate/certs"  # Need to get CA cert for Apache SSL server
CAcert="int.simcert.crt.pem"             # Name of Intermediate CA cert, needed for payload host
rootDNS="198.41.0.4"                     # This is the IP for the Root DNS server
rootpass="toor"
recursDNS="8.8.8.8"                      # This is the IP for the Recursive DNS Server
defaultdecoysite="insureme.com"

#set initial variables for paths, files, and/or values
IPlist="IPList.txt"
DNSlist="OPFOR-DNS.txt"
basesrvpath="/root/services"
manIPlist="/tmp/IPlist.txt"
tempintfile="/tmp/interface.txt"
TempDNSconf="/tmp/tmpDNS.txt"
rtrpath="/root/backbonerouters"
cspath="/root/cobaltstrike"
csc2path="/root/Profiles"
cp /dev/null $manIPlist
rtrtable="/etc/iproute2/rt_tables"
CurDNSInfo="/tmp/CurDNSinfo.txt"
intfile="/etc/network/interfaces"
postfixconf="/etc/postfix/main.cf"
disablepayload=0
gotdnsinfo=0

# Set variable names to add color codes to menu displays.
white="\e[1;37m"
ltblue="\e[1;36m"
ltgray="\e[0;37m"
red="\e[1;31m"
green="\e[1;32m"
whiteonblue="\e[5;37;44m"
yellow="\e[1;33m"
default="\e[0m"

######  Connectivity Check ########################
# Test connection to root DNS server
ping -c1 $rootDNS &>/dev/null
test $? = 0 && ctest=1 || ctest="failed"
if [ $ctest == "failed" ]; then
  echo -e "\n$red The script failed connectivity testing!$white DNS Server unreachable."
  echo -e "\t$ltblue The script variable$white 'rootDNS'$ltblue is set to$white $rootDNS$ltblue and can't be reached"
  echo -e "\t Edit the scripts 'rootDNS' value if this is wrong, otherwise troubleshoot"
  echo -e "\t Network connectivity issue. $default\n"
  exit 0
fi
# Test ssh key set up to the Root DNS server
ssh -o PasswordAuthentication=no -o BatchMode=yes $rootDNS exit &>/dev/null
test $? = 0 && stest=1 || stest="failed"
if [ $stest == "failed" ]; then
  echo -e "\n$red The script failed connectivity testing!$white SSH to DNS Server Failed."
  echo -e "\t$ltblue Script can't ssh to DNS server at $rootDNS, you need to set up an SSH key"
  echo -e "\t run$white ssh-copy-id $rootDNS"
  echo -e "\t$ltblue The password is$white $rootpass $default\n"
  exit 0
fi
# Test connection to CA server
ping -c1 $CAserver &>/dev/null
test $? = 0 && cctest=1 || cctest="failed"
if [ $cctest == "failed" ]; then
  echo -e "\n$red The script failed connectivity testing!$white CA Server unreachable"
  echo -e "\t$ltblue Script variable$white 'CAserver'$ltblue set to$white $CAserver$ltblue can't be reached"
  echo -e "\t Edit the scripts CAserver value if this is wrong, otherwise troubleshoot"
  echo -e "\t the Network connectivity issue. $default"
else 
  # Test ssh key set up to the CA server.
  ssh -o PasswordAuthentication=no -o BatchMode=yes $CAserver exit &>/dev/null
  test $? = 0 && stest=1 || stest="failed"
  if [ $stest == "failed" ]; then
    echo -e "\n$red The script failed connectivity testing!$white SSH to CA server Failed."
    echo -e "\t$ltblue Script can't ssh to CA server at $CAserver, run$white ssh-copy-id $CAserver"
    echo -e "\t$ltblue The password is$white $capass $default\n"
  fi
fi
if [[ $cctest == "failed" || $stest == "failed" ]]; then
  echo -e "\n\t$yellow The above error will prevent SSL redirectors and payload hosting."
  echo -e "\t$white Enter Q to quit or any key to accept this limitation$default"
  read answer
  case $answer in
    Q|q) exit 0;; 
  esac
  disablepayload=1
else
  ssh $CAserver "ls $CAcrtpath/$CAcert" &>/dev/null
  test $? = 0 && ccctest=1 || ccctest="failed"
  if [ $ccctest == "failed" ]; then
    echo -e "\n$yellow Warning:$ltblue The script can't find/reach the CA certificate."
    echo -e "\t  Script Variable CAcrtpath is$white $CAcrtpath $ltblue"
    echo -e "\t  Script Variable CAcert is$white $CAcert $ltblue"
    echo -e "\t  If this is the wrong path or the CA cert is listed wrong, edit the script to fix it"
    echo -e "\t  Otherwise, the script will not be able to stand up Payload servers on the system."
    echo -e "\t        $green Press any key to continue $default"
    read doesntmatter
    disablepayload=1
  fi
fi

####   GENERAL FUNCTIONS FOR FORMATTING, STANDARD MESSAGES
MenuBanner()
{
  clear
  case $opt in
    1) bannertitle="Build a NGINX redirector Container";;
    2) bannertitle="Build a HAProxy Redirector Container";;
    3) bannertitle="Set up a Cobalt Strike Container";;
    4) bannertitle="Set up a payload host Container";;
    5) bannertitle="Set up a phishing attack";;
    6) bannertitle="Container Management";;
    *) bannertitle="Not Red Team Server Docker Build Script";;
  esac
  printf "\n\t$ltblue %-60s %8s\n"  "$bannertitle" "<b>-Back"
  printf "\t$ltblue %60s %8s\n"  "" "<q>-Quit"
  ShowCurrentSettings
}

ShowCurrentSettings()
{
  if [[ ! -z $srvtag ]]; then echo -e "\t\t$white Current settings"; fi
  if [[ ! -z $srvtag ]]; then SettingFormat "Docker Service Tag" "$srvtag"; fi
  if [[ ! -z $countrysel ]]; then SettingFormat "Country Selected" "$countrysel"; fi
  if [[ ! -z $citysel ]]; then SettingFormat "City Selected" "$citysel"; fi
  if [[ ! -z $totalipssel ]]; then SettingFormat "Number of IP's" "$totalipssel"; fi
  if [[ ! -z $staticIPsel ]]; then SettingFormat "IP set to" "$staticIPsel"; fi
  if [[ ! -z $TSIP ]]; then SettingFormat "TeamServer IP" "$TSIP"; fi
  if [[ $randomipon == 1 ]]; then SettingFormat "IP set to" "Random"; fi
  if [[ ! -z $portsel ]]; then SettingFormat "Ports Selected" "$portsel"; fi
  if [[ ! -z $portsredir ]]; then SettingFormat "Ports redirected" "$portsredir"; fi
  if [[ ! -z $rediripsel ]]; then SettingFormat "Redir Dest IP" "$rediripsel"; fi
  if [[ $randomdns == 1 ]]; then SettingFormat "Set DNS" "Randomly"; fi
  if [[ ! -z $haprofile ]]; then SettingFormat "C2 Profile" "$haprofile"; fi
  if [[ ! -z $tsprofile ]]; then SettingFormat "C2 Profile" "$csc2profilesel"; fi
  if [[ ! -z $decoysite ]]; then SettingFormat "HA Proxy Decoy site" "$decoysite"; fi
  if [[ ! -z $passwordsel ]]; then SettingFormat "Password" "$passwordsel"; fi
  echo -ne "$default"
}

Format3Options()
{
  local count="$1"
  local title="$2"
  local dnsname="$3"
  printf "\t$ltblue%3b )$white %-15b $green%-40b\n" "$count" "$title" "$dnsname"
}

Format2Options()
{
  local count="$1"
  local title="$2"
  printf "\t$ltblue%3b )$white %-23b\n" "$count" "$title"
}

SettingFormat()
{
  local title="$1"
  local value="$2"
  printf "$ltgray%25s: $green%-20b\n" "$title" "$value"
}

InputError()
{
  echo -e "\n\t\t$red Invalid Selection, Please try again$default"; sleep 2
}

UserQuit()
{
  echo -e "$default";exit 0
}

CheckIP()
{
  local ip=$1        # Get passed IP address
  if `ipcalc -c $ip | grep -iq INVALID`; then
    return 1
  else
    return 0
  fi
}

#### MENU FUNCTIONS FOR GETTING USER INPUT
MainMenu()
{
  # Set initial variables, Resets values if user navigates back to the beginning
  opt=0; setnginx=0; sethaproxy=0; setcsts=0; setpayload=0; setphish=0; totalipssel=;
  tmpsrvpath=
  # Calls menu Banner
  MenuBanner
  # List options, get user input, process the input.
  Format2Options 1 "Set up a NGINX redirector (http,https,DNS)"
  Format2Options 2 "Set up a HAProxy redirector (${yellow}http and/or https only)"
  Format2Options 3 "Set up a Cobalt Strike teamserver"
  Format2Options 4 "Set up a payload host server"
  Format2Options 5 "Set up phishing attack"
  Format2Options 6 "Container Management"
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read optin
  case $optin in
    1) opt=1; service="Nginx Redirector"; setnginx=1; ServiceTagMenu;;
    2) opt=2; service="HAProxy Redirector"; sethaproxy=1; ServiceTagMenu;;
    3) opt=3; service="CS Teamserver"; setcsts=1; ServiceTagMenu;;
    4) opt=4
       if [ $disablepayload == 1 ]; then
         echo -e "$red Option is disabled!"
         echo -e "$ltblue CA cert can't be reached"
         sleep 2
         MainMenu
       else
         service="Payload Host"; setpayload=1; ServiceTagMenu
       fi;;
    5) opt=5; setphish=1; srvtag="phish"; tmpsrvpath="/tmp/$srvtag"; totalipssel=1; 
       if [ -d $tmpsrvpath ]; then rm -r $tmpsrvpath; fi
       mkdir -p $tmpsrvpath
       CountryMenu;;
    6) opt=6; ContainerMenu;;
    b|B) MainMenu;;
    q|Q) UserQuit;;
    *) InputError
       MainMenu;;
  esac
}

ServiceTagMenu()
{
  srvtag=; tmpsrvpath=
  # Create a service type tag based on option selected.
  case $opt in
    1|2)  typetag="RD";;
    3)  typetag="TS";;
    4)  typetag="P";;
  esac
  # Check if service tag exists, if it does increment and test again until you find a free tag.
  for x in {1..1000}; do
    if [ -d $basesrvpath/$typetag$x ]; then
      continue
    else 
      dtag="$typetag$x"
      break
    fi 
  done
  MenuBanner
  echo -e "\n\t$ltblue Enter a unique tag or just press enter to accept the (default)"
  echo -en "\t$ltblue Tag for service ($white$dtag$ltblue): $default"
  read tagin
  case $tagin in
    "") srvtag=$dtag;;
    b|B) MainMenu; return;;
    q|Q) UserQuit;;
    *) srvtag=$tagin;;
  esac
  if [[ ! -d $basesrvpath/$srvtag ]]; then  # Check if a saved/running service has that tag
    # tag is unqiue, start building service in a temporary location.
    tmpsrvpath="/tmp/$srvtag"
    # check if there is already a temp folder and if so delete it.
    if [ -d $tmpsrvpath ]; then rm -r $tmpsrvpath; fi 
    # make temp folder to hold data until service is commited by the user.
    mkdir -p $tmpsrvpath
    echo "$service" > $tmpsrvpath/ServiceInfo.txt
    if (( $setcsts == 1 )); then      # Cobalt Strike Team Server.
      totalipssel=1; CountryMenu
    else
      NumIPsMenu
    fi
  else
    echo -e "\n\t$red Service Tag already Exists! Try again. $default"
    sleep 2
    ServiceTagMenu
  fi
}

NumIPsMenu()
{
  totalipssel=
  MenuBanner
  # List options, get user input, process the input
  echo -e "\n\t$ltblue Select number of IPs you want to set. (Max: 20)"
  echo -ne "\t$ltblue Enter the number of IPs: $default"
  read totalips
  case $totalips in
    q|Q) UserQuit;;
    b|B) ServiceTagMenu;;
    *) if (( $totalips >= 1 && $totalips <= 20 )) 2>/dev/null; then
          totalipssel=$totalips
          CountryMenu
        else
          InputError
          NumIPsMenu
        fi;;
  esac
}

CountryMenu()
{
  # Sets initial variables, resets values if user navigates back.
  count=1; countrysel=
  MenuBanner
  # List options, get user input, process the input
  echo -e "\n\t$ltblue SETUP IPs - Start with Selecting a Geolocation"
  echo -e "\t$ltblue Select a Country of Origin$ltblue"
  for folder in `ls $rtrpath`; do
    Format2Options "$count" "$folder"
    let "count++";
  done
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read country
  case $country in
    q|Q) UserQuit;;
    b|B)  if [[ $setcsts == 1 ]]; then 
            ServiceTagMenu
          elif [[ $setphish == 1 ]]; then
            MainMenu
          else 			
            NumIPsMenu
          fi;;
    *) if (( $country >= 1 && $country < $count )) 2>/dev/null; then
          countrysel=`ls $rtrpath  | sed -n ${country}p`
          CityMenu
        else
          InputError
          CountryMenu
        fi;;
  esac
}

CityMenu()
{
  # sets initial variables, resets values if user navigates back
  count=1; citysel=
  MenuBanner
  # List options, get user input, process the input
  echo -e "\n\t$ltblue Select a City$ltblue"
  for file in `ls $rtrpath/$countrysel | sed -e 's/\.txt//'`; do
    Format2Options "$count" "$file"
    let "count++";
  done
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read City
  case $City in
    q|Q) UserQuit;;
    b|B) countrysel=; CountryMenu;;
    *) if (( $City >= 1 && $City < $count )) 2>/dev/null; then
         routerfile=`ls $rtrpath/$countrysel | sed -n ${City}p`
         citysel=`echo $routerfile | sed -e 's/\.txt//'`
         SetIPOption
       else
         InputError
         CityMenu
       fi;;
   esac
}

SetIPOption()
{
  MenuBanner
  echo -e "\n\t$ltblue Do you want to get random IPs or set them manually?"
  Format2Options 1 "Set random IPs"
  Format2Options 2 "Set IPs manually"
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read optin
  case $optin in
    1) GenRanIPlist
       if (( $setnginx == 1 || $sethaproxy == 1 )); then  # All redirectors
         PortMenu
       elif (( $setcsts == 1 )); then  # Cobalt Strike Teamserver
         sed -i "/^Teamserver/d'" $tmpsrvpath/ServiceInfo.txt
         # Get Teamserver IP
         TSIP=`grep -v "^#" $tmpsrvpath/$IPlist | cut -d/ -f1`
         echo "Teamserver IP: $TSIP" >> $tmpsrvpath/ServiceInfo.txt
         csc2profileMenu
       elif (( $setpayload == 1 || $setphish == 1 )); then  # Payload Host.
         AddDNSMenu
       else
         echo "How did you get here??"; exit 0;
       fi;;
    2) ManualIPMenu;;
    b|B) CityMenu;;
    q|Q) UserQuit;;
    *) InputError
       SetIPOption;;
  esac
}

ManualIPMenu()
{
  sIPin=
  MenuBanner
  echo -e "\n\t$ltblue Please enter an IP that's within the County/city orgin subnet below"
  echo -e "\t$ltblue Enter [s] to see ip ranges for the country/city selected."
  if [[ $totalipssel == 1 ]]; then
    echo -ne "\n\t$ltblue Enter an IP: $default"
    read sIPin
    case $sIPin in
      q|Q) UserQuit;;
      b|B) SetIPOption;;
      s|S) showSubnets;;
      *)  CheckIP $sIPin
        if [[ $? -eq 0 ]]; then
          for x in `cat $rtrpath/$countrysel/$citysel.txt`; do
            if [[ $x == \#* ]]; then continue; fi
            gateway=`echo $x | cut -d/ -f1`
            subnet=`echo $x | cut -d/ -f2`
            ipmin=`ipcalc $sIPin/$subnet | grep HostMin | tr -s ' ' | cut -d ' ' -f2`
            if [[ $gateway == $ipmin ]]; then
              staticgatewayin=$gateway
              staticIPin=$sIPin/$subnet
              staticIPsel=$sIPin
              echo "1,$staticIPin,$staticgatewayin" > $manIPlist
              found="yes"
              break
            fi
          done
          if [[ $found == "yes" ]]; then
            GenManIPList
            if (( $setnginx == 1 || $sethaproxy == 1 )); then  # All redirectors
              PortMenu
            elif (( $setcsts == 1 )); then  # Cobalt Strike Teamserver
              csc2profileMenu
            elif (( $setpayload == 1 || $setphish == 1 )); then  # Payload Host.
              AddDNSMenu
            else
              echo "How did you get here??"; exit 0;
            fi
          else
            echo -e "\n\t\t$red Invalid Selection, $sIPin is not within a range"
            echo -e "\t\t$red for the country city you selected.  Enter [s] to see"
            echo -e "\t\t$red useable IP ranges for your selected location. Please try again $default"
            sleep 3
            ManualIPMenu
          fi
        else
          echo -e "\n\t\t$red $sIPin is not a valid IP! Please try again $default"; sleep 2
          ManualIPMenu
        fi;;
      esac
  else
    echo -e "\n\t$ltblue Select an option number from the list and set an IP, once set, it"
    echo -e "\t$ltblue will bring you back to this menu, select D when you're finished adding IPs\n"
    for x in $(seq $totalipssel)
    do
      ipadded=`grep ^$x, $manIPlist 2>/dev/null | cut -d, -f2`
      if [[ ! -z $ipadded ]]; then
        Format2Options "$x" "$ipadded"
      else
         Format2Options "$x" ""
      fi
    done
    Format2Options "c" "Clear all"
    Format2Options "d" "Done"
    Format2Options "s" "Show available Subnets"
    echo -ne "\n\t$ltblue Enter a Selection Here: $default"
    read answer
    case $answer in
      b|B) SetIPOption;;
      q|Q) UserQuit;;
      c|C) cp /dev/null $manIPlist; ManualIPMenu;;
      s|S) showSubnets;;
      d|D) GenManIPList
           if (( $setnginx == 1 || $sethaproxy == 1 )); then
             PortMenu
           elif (( $setcsts == 1 )); then
             CSProfileMenu
           else
             AddDNSMenu
           fi;;
      *) if [[ $answer -ge 1 ]] && [[ $answer -le $totalipssel ]]; then
           IPspot=$answer
           IPentry
         else
           InputError
           ManualIPMenu
         fi;;
    esac
  fi
}

IPentry()
{
  MenuBanner
  IPcheck=`grep ^$IPspot, $manIPlist 2>/dev/null | cut -d, -f2`
  if [[ $IPcheck != "" ]]; then
    echo -e "\n\t$ltblue IP already assigned as $green $IPcheck"
    echo -e "\t$ltblue This will replace it, if this isn't what you want hit B to go back"
  fi
  echo -e "\n\t$ltblue Please set the IP you would like to use"
  echo -ne "\n\t$ltblue Here: $default "
  read IPin
  if [[ $IPin == b ]] || [[ $IPin == B ]]; then ManualIPMenu; fi
  if [[ $IPin == q ]] || [[ $IPin == Q ]]; then UserQuit; fi
  CheckIP $IPin
  if [[ $? -eq 0 ]]; then
    found="no"
    for y in `cat $rtrpath/$countrysel/$citysel.txt`; do
      if [[ $y == \#* ]]; then continue; fi
      gateway=`echo $y | cut -d/ -f1`
      subnet=`echo $y | cut -d/ -f2`
      ipmin=`ipcalc $IPin/$subnet | grep HostMin | tr -s ' ' | cut -d ' ' -f2`
      if [[ $gateway == $ipmin ]]; then
        staticgatewayin=$gateway
        staticIPin=$IPin/$subnet
        found="yes"
        break;
      fi
    done
    if [[ $found == "yes" ]]; then
      sed -i "/^$IPspot\,/d" $manIPlist
      #Add new IP
      echo "$IPspot,$staticIPin,$staticgatewayin" >> $manIPlist
      ManualIPMenu
    else
      echo -e "\n\t\t$red Invalid Selection, $IPin is not within a range"
      echo -e "\t\t$red for the country city you selected.  Enter [s] to see"
      echo -e "\t\t$red useable IP ranges for your selected location. Please try again $default"
      sleep 3
      ManualIPMenu
    fi
  else
    echo -e "\n\t\t$red $IPin is not a valid IP! Please try again $default"; sleep 2
    ManualIPMenu
  fi
}

PortMenu()
{
  # Set initial variables, resets if user navigates back
  http=0; https=0; dns=0; portsel=""
  MenuBanner
  sed -i "/^Ports Redirected/d" $tmpsrvpath/ServiceInfo.txt
  # List Options, get user input, process the input.
  echo -e "\n\t$ltblue Set Ports to be redirected"
  Format2Options 1 "HTTP, HTTPS"
  Format2Options 2 "HTTP only"
  Format2Options 3 "HTTPS only"
  if [[ $setnginx == 1 ]]; then 
    Format2Options 4 "DNS, HTTP, HTTPS"
    Format2Options 5 "DNS, HTTP"
    Format2Options 6 "DNS, HTTPS"
    Format2Options 7 "DNS only"
  fi
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read optin
  case $optin in
    q|Q) UserQuit;;
    b|B)  SetIPOption; return;;
    1) https=1; http=1;;
    2) http=1;;
    3) https=1;;
    4|5|6|7) if [[ $sethaproxy == 1 ]]; then 
               InputError 
               PortMenu
               return 
             else
               if [[ $optin == 4 ]]; then https=1; http=1; dns=1; 
               elif [[ $optin == 5 ]]; then http=1; dns=1;
               elif [[ $optin == 6 ]]; then https=1; dns=1;
               elif [[ $optin == 7 ]]; then dns=1
               fi
             fi;;
    *) InputError
       PortMenu
       return;;
  esac
  # Get and display user selected information
  if [[ $dns == 1 ]]; then portsel="dns"; fi
  if [[ $http == 1 ]]; then portsel="http "$portsel; fi
  if [[ $https == 1 ]]; then portsel="https "$portsel; fi
  echo "Ports Redirected: $portsel" >> $tmpsrvpath/ServiceInfo.txt
  BindPortMenu
}

BindPortMenu()
{
  portsredir=
  sed -i "/^Bind\,/d" $tmpsrvpath/ServiceInfo.txt
  MenuBanner
  echo -e "\n\t$ltblue Next set the port you want to redirect to. This would be the"
  echo -e "\t the 'bind to' setting on the teamserver listener"
  for port in $portsel; do
    found=0  
    while [[ $found == 0 ]]; do
      case $port in
        dns) defport="53";;
        http) defport="80";;
        https) defport="443";;
      esac
      echo -e "\n\t$ltblue Select a port to redirect$white $port$ltblue to."
      echo -e "\t The defualt is set to$white $defport,$ltblue to keep this just press enter."
      echo -ne "\t Otherwise, enter a different port here: $default"
      read answer
      case $answer in
        b|B) PortMenu; return;;
        q|Q) UserQuit;;
        "") found=1; bindport=$defport;;
        *) if [[ $answer -ge 1 ]] && [[ $answer -le  65536 ]]; then
             bindport=$answer
             found=1
           else
             echo -e "$red Invalid port!, please select a port between 1 and 65536"
             sleep 2			   
             continue
           fi;;
      esac
      case $port in 
        dns) binddns=$bindport; portsredir="dns($binddns) "$portsredir;;
        http) bindhttp=$bindport; portsredir="http($bindhttp) "$portsredir;;
        https) bindhttps=$bindport; portsredir="https($bindhttps) "$portsredir;;
      esac 
    done
  done
  echo "Bind Ports: $portsredir" >> $tmpsrvpath/ServiceInfo.txt  
  RedirDestMenu
}
	
RedirDestMenu()
{
  rediripsel=
  MenuBanner
  sed -i "/^Redirected to/d" $tmpsrvpath/ServiceInfo.txt
  echo -ne "\n\t$ltblue Enter the IP you want to redirect to Here: $white"
  read redirip
  case $redirip in
    q|Q) UserQuit;;
    b|B) BindPortMenu;;
    *) rediripsel=$redirip;;
  esac
  CheckIP $rediripsel
  if [[ $? -eq 0 ]]; then
    echo "Redirected to IP: $rediripsel" >> $tmpsrvpath/ServiceInfo.txt
    if [[ $sethaproxy == 1 ]]; then 
      csc2profileMenu
    else 
      AddDNSMenu
    fi
  else
    InputError
    RedirDestMenu
  fi
}

GetDNSInfo()
{
  if [[ $gotdnsinfo != 1 ]]; then
    # Get DNS information for the primary DNS server
    ssh $rootDNS 'cd /etc/bind/OPFOR; grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" * | uniq | sed "s/db.//" | sed "s/\:/ /"' > /tmp/IPinfo
    ssh $rootDNS 'cd /etc/bind/OPFOR; grep -Eo "OPFOR[-0-9A-Za-z]{0,40}" * | sed "s/db.//" | sed "s/\:/ /"' > /tmp/taginfo
    awk 'FNR==NR{a[$1]=$2 FS $3;next} $1 in a {print $0, a[$1]}' /tmp/taginfo /tmp/IPinfo | sort -k 3 > $CurDNSInfo
    usertags=`cat $CurDNSInfo | cut -d " " -f 3 | sort -u`
  fi
}

AddDNSMenu()
{
  GetDNSInfo
  gotdnsinfo=1  # Flip this to 1 so we don't pull DNS information repeatly if user navigates back.
  randomdns=
  MenuBanner
  if [[ $https == 1 ]]; then
    echo -e "\n\t$ltblue You are building a$white $service$ltblue and redirecting HTTPS"
    echo -e "\n\t$ltblue We need to register DNS in order to generate SSL certificates"
    echo -e "\n\t$ltblue How would you like to assign domain names?"
  else
    echo -e "\n\t$ltblue Would you like to assign DNS now?"
  fi
  Format2Options 1 "Use randomly generated one/s."
  Format2Options 2 "Manually create domain name/s."
  if [[ $https == 0 ]]; then
    Format2Options 3 "I'll Assign DNS Later"
  fi
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read answer
  case $answer in
    1) randomdns=1; DNSTagMenu;;
    2) ManualDNS;;
    3) ExecAndValidate;;
    b|B) if [[ $setpayload == 1 || $setphish == 1 ]]; then
           SetIPOption
         elif [[ $sethaproxy == 1 ]]; then
           DecoyMenu       
         else 		   
           RedirDestMenu
         fi;;
    q|Q) UserQuit;;
    *) InputError
       AddDNSMenu;;
  esac
}

DNSTagMenu()
{
  MenuBanner
  echo -e "\n\t$ltblue Enter a tag to be able to identify your DNS records"
  echo -e "\t The tag will automatically be prepended with OPFOR-"
  echo -e "\t Best Practice: Use your FirstName and use.  For example,"
  echo -e "\t\t  $white Chad-DecScrim  or  Joe-Testing $ltblue"
  echo -e "\t If you decide to add additional DNS Records for the same purpose"
  echo -e "\t then re-use the same tag"
  echo -ne "\n\t  Enter a Tag here: $default"
  read answer
  case $answer in
    b|B) AddDNSMenu; return;;
    q|Q) UserQuit;;
      *) Tagin=$answer; ExecAndValidate;;
  esac
}

ManualDNS()
{
  MenuBanner
  if [ ! -f $TempDNSconf ]; then touch $TempDNSconf; fi
  iplist=`grep -v "#" $tmpsrvpath/$IPlist | cut -d/ -f1`
  numip=`echo "$iplist" | wc -l`
  if [[ $numip == 1 ]]; then
    echo -e "\n\t$ltblue Your Current IP is $green $iplist"
    echo -e "\n\t$ltblue Please set the Fully Qualified Domain Name you would like to use"
    echo -ne "\n\t$ltblue Here: $default"
    read DNSin
 #   regexfqn="(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)"
    regexfqn="(?=^.{5,254}$)(^(?:(?\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)"
    if [[ `echo $DNSin | grep -P $regexfqn` ]]; then
    ## Check if dns is already registered
      if grep -q "$DNSin" $CurDNSInfo; then
        echo "$DNSin is already registred, please try again."; sleep 2
        ManualDNS
      fi
      #Remove any previously set FQDN for the IP selected.
      sed -i "/$iplist/d" $TempDNSconf
      #Add new FQDN
      lowercaseDNS=`echo $DNSin | tr '[:upper:]' '[:lower:]'`
      echo "$lowercaseDNS,$iplist" >> $TempDNSconf
      DNSTagMenu
    else
      echo "$DNSin is not a valid FQDN, please try again."; sleep 2
      ManualDNS
    fi
  else
    echo -e "\n\t$ltblue You currently have multiple IP's, you can set manual FQDNs"
    echo -e "\t$ltblue for each one, select an IP from the list to set a FQDN for that"
    echo -e "\t$ltblue IP, once set it will bring you back to this menu, select D for"
    echo -e "\t$ltblue done when you're finished adding FQDN's to IPs $default\n"
    count=1
    for ip in $iplist
    do
      dnsadded=`grep $ip $TempDNSconf | cut -d, -f1`
      if [[ ! -z $dnsadded ]]; then
        Format3Options "$count" "$ip" "$dnsadded"
      else
        Format3Options "$count" "$ip"
      fi
      let count++
    done
    Format2Options "c" "Clear all"
    Format2Options "d" "Done"
    echo -ne "\n\t$ltblue Enter a Selection Here: $default"
    read answer
    case $answer in
      b|B) AddDNSMenu;;
      q|Q) UserQuit;;
      c|C) cp /dev/null $TempDNSconf; ManualDNS;;
      d|D) cp $TempDNSconf $tmpsrvpath/$DNSlist; DNSTagMenu;;
      *) if [[ $answer -ge 1 ]] && [[ $answer -le $numip ]]; then
           IPselected=`echo "$iplist" | sed -n ${answer}p`
           DNSentry
         else
           InputError
           ManualDNS
         fi;;
    esac
  fi
}

DNSentry()
{
  MenuBanner
  domainin=`grep $IPselected $TempDNSconf 2>/dev/null | cut -d, -f1`
  if [[ $domainin != "" ]]; then
    echo -e "\n\t$ltblue DNS already assigned as $green $domainin"
    echo -e "\t$ltblue This will replace it, if this isn't what you want hit B to go back"
  fi
  echo -e "\n\t$ltblue Your Current IP is $green $IPselected"
  echo -e "\n\t$ltblue Please set the Fully Qualified Domain Name you would like to use"
  echo -ne "\n\t$ltblue Here: $default "
  read DNSin
  if [[ $DNSin == b ]] || [[ $DNSin == B ]]; then ManualDNS; fi
  if [[ $DNSin == q ]] || [[ $DNSin == Q ]]; then UserQuit; fi
  regexfqn="(?=^.{4,253}$)(^(?:[a-zA-Z](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z])?\.)+[a-zA-Z]{2,}$)"
  if [[ `echo $DNSin | grep -P $regexfqn` ]]; then
    if grep -q -i "$DNSin" $CurDNSInfo; then
      echo "$DNSin is already registered, please try again."; sleep 2
      ManualDNS
    else
      #Remove any previously set FQDN for the IP selected.
      sed -i "/$IPselected/d" $TempDNSconf
      #Add new FQDN
      lowercaseDNS=`echo $DNSin | tr '[:upper:]' '[:lower:]'`
      echo "$lowercaseDNS,$IPselected" >> $TempDNSconf
      ManualDNS
    fi
  else
    echo -e "\t\t$red $DNSin is not a valid FQDN, please try again.$default"; sleep 2
    DNSentry
  fi
}

RegisterDNS()
{
  if [[ $randomdns == 1 ]]; then
    #Make sure the IPList.txt file doesn't already have a tag
    sed -i '/# Tag:/d' $srvpath/$IPlist
    #add Tag
    echo "# Tag:$Tagin" >> $srvpath/$IPlist 
    scp $srvpath/$IPlist $rootDNS:/root/scripts/autoredirector/iplist.txt &>/dev/null
    ssh -n $rootDNS '/root/scripts/autoredirector/makednsfile.sh /root/scripts/autoredirector/iplist.txt' &>/dev/null
    if [[ $dns == 1 ]]; then 
      ssh -n $rootDNS '/root/scripts/add-REDTEAM-DNS.sh /root/scripts/autoredirector/dnsfile.txt dns' &>/dev/null
    else 
      ssh -n $rootDNS '/root/scripts/add-REDTEAM-DNS.sh /root/scripts/autoredirector/dnsfile.txt' &>/dev/null
    fi
    scp $rootDNS:/root/scripts/autoredirector/dnsfile.txt $srvpath/OPFOR-DNS.txt &>/dev/null
    ssh -n $rootDNS 'rm /root/scripts/autoredirector/dnsfile.txt' &>/dev/null
  else
    if [ ! -s $TempDNSconf ]
    then
      echo -e "\n\t$yellow No manually created DNS records found, script is exiting $default\n"
      exit 0;
    fi
    # Tag the DNS file with the servers hostname
    echo "# Tag:$Tagin" >> $TempDNSconf
    mv $TempDNSconf $srvpath/OPFOR-DNS.txt
    scp $srvpath/OPFOR-DNS.txt $rootDNS:/root/scripts/OPFOR-DNS.txt &>/dev/null
# Future mod to signal the root DNS script that the domain will be used for DNS beacons.
#    if [[ $dns == 1 ]] ; then
#      ssh -n $rootDNS '/root/scripts/add-REDTEAM-DNS.sh /root/scripts/OPFOR-DNS.txt dns' &>/dev/null
#    else
      ssh -n $rootDNS '/root/scripts/add-REDTEAM-DNS.sh /root/scripts/OPFOR-DNS.txt' &>/dev/null
#    fi
  fi
}

RandomSSLGen()
{
  mkdir -p $srvpath/SSL
  while read dom; do
    if [[ $dom == \#* ]]; then continue; fi
    cdomain=`echo $dom | cut -d, -f1`
    ssh -n $CAserver "/root/scripts/certmaker.sh -d $cdomain -DNS1 www.$cdomain -r -q" &>/dev/null 
    scp $CAserver:/var/www/html/$cdomain.key $srvpath/SSL &>/dev/null
    scp $CAserver:/var/www/html/$cdomain.crt $srvpath/SSL &>/dev/null
    scp $CAserver:/var/www/html/$cdomain.p12 $srvpath/SSL &>/dev/null
    scp $CAserver:/var/www/html/$cdomain.pem $srvpath/SSL &>/dev/null
  done<$srvpath/OPFOR-DNS.txt
}

ContainerMenu()
{
  copt=; caction=
  MenuBanner
  echo -e "\n\t$ltblue Container management Menu"
  Format2Options "1" "View Containers"
  Format2Options "2" "Delete Containers"
  Format2Options "3" "Start Saved Containers"
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read answer
  case $answer in
    q|Q) UserQuit;;
    b|B) MainMenu;;
    1) copt=1; caction="$ltblue View Container Menu $default"; SelectServicesMenu;;
    2) copt=2; caction="$red Delete Container Menu $default"; SelectServicesMenu;;
    3) copt=3; caction="$green Start a Container Menu $default"; SelectServicesMenu;;
    *) InputError; ContainerMenu;;
   esac
 }
 
SelectServicesMenu()
{
  MenuBanner
  count=1; srvsel=
  srvcount=`ls $basesrvpath | wc -l`
  if [[ $srvcount == 0 ]]; then
    echo -e "\n\t$ltblue No services built or running $default"
    sleep 4
    ContainerMenu
  else
    echo -e "\n\t\t$caction"  
    echo -e "\n\t$ltblue Select a Service Tag"
    for srv in `ls $basesrvpath`; do
      if [[ $srv == "phish" ]]; then
        Format2Options "$count" "$srv"
      else 
        runcheck=`docker ps | awk '{print $NF}' | grep $srv`
        if [[ ! -z $runcheck ]]; then
          Format3Options "$count" "$srv" "(running)"
        else
          Format3Options "$count" "$srv" "(${red}Stopped)"
        fi
      fi
      let "count++";
    done
    echo -ne "\n\t$ltblue Enter a Selection: $default"
    read srvnum 
    case $srvnum in
      q|Q) UserQuit;;
      b|B) MainMenu;;
        *) if (( $srvnum >= 1 && $srvnum < $count )) 2>/dev/null; then
             srvsel=`ls $basesrvpath | sed -n ${srvnum}p`
             case $copt in
               1) ServiceDetailsMenu;;
               2) DeleteServicesMenu;;
               3) StartServiceMenu;;
             esac
           else
             InputError
             ViewServicesMenu
           fi;;
    esac
  fi
 }

ServiceDetailsMenu()
{
  MenuBanner
  echo -e "\n\t$ltblue Here is the information on $srvsel $default"
  echo -e "\t$white SERVICE INFO $default"
  cat $basesrvpath/$srvsel/ServiceInfo.txt
  if [[ -f $basesrvpath/$srvsel/$DNSlist ]]; then 
    echo -e "\n\t$white DNS Info $default"
    cat $basesrvpath/$srvsel/$DNSlist 
  else
    echo -e "\n\t$white No DNS registered for this containers services"
  fi
  echo -e "\n\t$ltblue Hit Return to go back to the services list menu $default"
  read doesntmatter
  SelectServicesMenu
 }
 
DeleteServicesMenu()
{
  echo -e "\n\t$red This will remove$yellow $srvsel$red, are you sure you want to do this?"
  echo -ne "\n\t$ltblue Enter y to continue or n to abort: $default"
  read answer
  case $answer in
    y|Y) MenuBanner
         echo -e "\n\t$ltblue Deleting Container $default"
         docker kill $srvsel
         docker rm $srvsel
         docker network prune --force
         echo -e "\n\t$ltblue Removing IPs $default"
         DeleteIPs $srvsel
         echo -e "\n\t$ltblue Removing config folder $default"
         rm -r $basesrvpath/$srvsel
         echo -e "\n\t$ltblue Service $srvsel has been delete. $default"
         sleep 2
         ContainerMenu;;
    n|N) echo -e "\n\t$ltblue Container deletion aborted!"
         sleep 2
         ContainerMenu;;
      *) InputError
         ContainerMenu;;
    q|Q) UserQuit;;
    b|B) ContainerMenu;;
  esac
}

StartServiceMenu()
{
   docker-compose -f $basesrvpath/$srvsel/docker-compose.yml up -d
   echo -e "\n\t$ltblue Starting $srvel"
   iptables -F OUTPUT -t nat
   iptables -F PREROUTING -t nat 
   ContainerMenu
}

BuildDockerContainer()
{
  if [[ $setnginx == 1 ]]; then
    image="nginx"
    confpath="config/nginx.conf:/etc/nginx/nginx.conf"
  elif [[ $sethaproxy == 1 ]]; then
    image="haproxy"
    confpath="config/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
  elif [[ $setpayload == 1 ]]; then
    image="httpd"
    confpath="config/httpd.conf:/usr/local/apache2/conf/httpd.conf" 
    confpath2="config/httpd-ssl.conf:/usr/local/apache2/conf/extra/httpd-ssl.conf"
    confpath3="WWW:/usr/local/apache2/htdocs"
  elif [[ $setcsts == 1 ]]; then
    image="cobaltstrike"
    tsip=`grep -v "^#" $srvpath/$IPlist | cut -d '/' -f1`
    echo "#!/bin/bash" > $srvpath/startteamserver.sh
    echo "cd /cobaltstrike" >> $srvpath/startteamserver.sh
    echo "./teamserver $tsip $passwordsel /$tsprofile" >> $srvpath/startteamserver.sh
    chmod 755 $srvpath/startteamserver.sh
    confpath="cobaltstrike:/cobaltstrike"
    confpath2="startteamserver.sh:/startteamserver.sh"
    confpath3="$tsprofile:/$tsprofile"
  fi
     
  composefile=$srvpath/docker-compose.yml
  echo "version: '3.4'" > $composefile
  echo "services:" >> $composefile
  echo "  $srvtag:" >> $composefile
  if [[ $tsbridge == 1 && $setcsts == 1 ]]; then
    echo "    network_mode: bridge" >> $composefile
  else
    echo "    network_mode: host" >> $composefile
  fi
  echo "    user: root" >> $composefile
  echo "    container_name: $srvtag" >> $composefile
  echo "    image: $image" >> $composefile
 # echo "    stdin_open: true" >> $composefile
 # echo "    tty: true" >> $composefile
  echo "    volumes:" >> $composefile
  echo "      - $srvpath/SSL:/SSL" >> $composefile
  echo "      - $srvpath/$confpath" >> $composefile
  if [[ $setpayload == 1 ]]; then
    echo "      - $srvpath/$confpath2" >> $composefile
    echo "      - $srvpath/$confpath3" >> $composefile
  fi
  if [[ $setcsts == 1 ]]; then
    echo "      - $srvpath/$confpath2" >> $composefile
    echo "      - $srvpath/$confpath3" >> $composefile
    if [[ $tsbridge == 1 ]]; then
      echo "    ports:" >> $composefile
      echo "      - $tsip:50050:50050/tcp" >> $composefile
      echo "      - $tsip:443:443/tcp" >> $composefile
      echo "      - $tsip:80:80/tcp" >> $composefile
      echo "      - $tsip:53:53/tcp" >> $composefile
      echo "      - $tsip:53:53/udp" >> $composefile 
    fi
    echo "    entrypoint: /startteamserver.sh" >> $composefile
  fi
}

StartDockerContainer()
{
  cd $srvpath
  docker-compose up -d &>/dev/null
}

csc2profileMenu()
{
  tsprofile=; haprofile=
  sed -i "/^Profile/d" $tmpsrvpath/ServiceInfo.txt
  MenuBanner
  # sets initial variables, resets values if user navigates back
  count=1
  # List options, get user input, process the input
  if [[ $sethaproxy == 1 ]]; then 
    echo -e "\n\t$yellow NOTE: In order for this script to set up HAProxy redirector, it will "
    echo -e "\t need the cobalt strike Malleable C2 profile to set ACL's"
  fi
  echo -e "\n\t$ltblue Select a Cobalt Strike Malleable C2 Profile$ltblue"
  pcount=`ls $csc2path | wc -l`
  if [[ $pcount -le 0 ]]; then
    echo -e "\t$red Sorry there are no profiles at $csc2path"
  else
    for file in `ls $csc2path`; do
      Format2Options "$count" "$file"
      let "count++";
    done
    echo -ne "\n\t$ltblue Enter Profile Here: $default"
  fi
  read profile
  case $profile in
    q|Q) UserQuit;;
    b|B) if [[ $sethaproxy == 1 ]]; then 
           RedirDestMenu
         else
           SetIPOption
         fi;;
      *) if (( $profile >= 1 && $profile< $count )) 2>/dev/null; then
           csc2profilesel=`ls $csc2path | sed -n ${profile}p`
           if [[ $sethaproxy == 1 ]]; then
             haprofile=$csc2profilesel
             echo "Profile: $haprofile" >> $tmpsrvpath/ServiceInfo.txt
             DecoyMenu
           else
             tsprofile=$csc2profilesel
             cp $csc2path/$tsprofile $tmpsrvpath/$tsprofile 
             echo "Profile: $tsprofile" >> $tmpsrvpath/ServiceInfo.txt
             csc2passwdMenu
           fi
         else
           InputError
           csc2profileMenu
         fi;;
   esac
}

DecoyMenu()
{
  MenuBanner
   echo -e "\n\t$ltblue Set the decoy website that HAProxy will use.$ltblue"
   echo -e "\t\t$ltblue The default is$yellow $defaultdecoysite $ltblue"
   echo -e "\n\t$ltblue To keep the default press <enter>.  Otherwise set it below.$ltblue"
   echo -e "\t$ltblue NOTE: It has to be a site in the environment otherwise HAProxy will crash $ltblue"
   echo -ne "\n\t$ltblue Enter a Decoy website here: $default"
   read decoysite
   case $decoysite in
     q|Q) UserQuit;;
     b|B) csc2profilesel=; decoysite=; csc2profileMenu;;
      "") decoysite=$defaultdecoysite; AddDNSMenu;;
       *) if nslookup $decoysite | grep -q "can't find"; then
            echo -e "\n\t$red Error! $default the decoy site must be reachable"
            echo -e "\t$white $decoysite $default is unreachable, try again"
            sleep 2
            DecoyMenu
          else
            AddDNSMenu
          fi;;
   esac
}

csc2passwdMenu()
{
  passwordsel=
  sed -i "/^Password/d" $tmpsrvpath/ServiceInfo.txt
  MenuBanner
  # List options, get user input, process the input
  echo -e "\n\t$ltblue Next Set a Teamserver Password, this will be used to connect later"
  echo -ne "\n\t$ltblue Enter Password Here: $default"
  read passwordin
  case $passwordin in
    q|Q)  UserQuit;;
    b|B)  csc2profilesel=; csc2profileMenu;;
    *\ *) echo -e "\n\t\t$red Password can't have spaces, Please try again$default"; sleep 2
          csc2passwdMenu;;
     "")  echo -e "\n\t\t$red Password can't be blank, Please try again$default"; sleep 2
          csc2passwdMenu;;
      *)  passwordsel=$passwordin; 
          echo "Password: $passwordsel" >> $tmpsrvpath/ServiceInfo.txt 
          ExecAndValidate;;
   esac
}


###################################### BUILD FUNCTIONS ############################################
showSubnets()
{
  clear
  echo -e "$green Search through the IP ranges below, use up and down arrows to search the list"
  echo -e "Then enter 'q' when you're done $default"
  sed '1d; s/\/[0-9][0-9],/ \- /' $rtrpath/$countrysel/$citysel.txt > /tmp/subnets.txt
  less /tmp/subnets.txt
  rm /tmp/subnets.txt
  ManualIPMenu
}

BuildHAProxyConfig()
{
  # set path to temporary haproxy config file
  mkdir -p $srvpath/config
  haproxyconf="$srvpath/config/haproxy.cfg"
  # Build initial file
  echo -e "# HAProxy configured by buildredteam.sh script" > $haproxyconf
  if [[ ! -z $haprofile ]]; then
    echo -e "# Configured for Malleable C2 Profile:$haprofile" >> $haproxyconf
  fi
  echo -e "global" >> $haproxyconf
  echo -e "  log 127.0.0.1 local2 debug" >> $haproxyconf
  echo -e "  maxconn 2000" >> $haproxyconf
  echo -e "  user haproxy" >> $haproxyconf
  echo -e "  group haproxy" >> $haproxyconf
  echo -e "defaults" >> $haproxyconf
  echo -e "  log     global" >> $haproxyconf
  echo -e "  mode    http" >> $haproxyconf
  echo -e "  option  httplog" >> $haproxyconf
  echo -e "  option  dontlognull" >> $haproxyconf
  echo -e "  retries 3" >> $haproxyconf
  echo -e "  option  redispatch" >> $haproxyconf
  echo -e "  timeout connect  5000" >> $haproxyconf
  echo -e "  timeout client  10000" >> $haproxyconf
  echo -e "  timeout server  10000" >> $haproxyconf
  if [[ $https == 1 ]]; then
    echo -e "\nfrontend www-https" >> $haproxyconf
    echo -e "  option http-buffer-request" >> $haproxyconf
    echo -e "  declare capture request len 40000" >> $haproxyconf
    echo -e "  capture request header User-Agent len 512" >> $haproxyconf
    echo -e "  capture request header Host len 512" >> $haproxyconf
    echo -e "  capture request header X-Forwarded-For len 512" >> $haproxyconf
    echo -e "  capture request header X-Forwarded-Proto len 512" >> $haproxyconf
    echo -e "  capture request header X-Host len 512" >> $haproxyconf
    echo -e "  capture request header Forwarded len 512" >> $haproxyconf
    echo -e "  capture request header Via len 512" >> $haproxyconf
    echo -e "  log /dev/log local2 debug" >> $haproxyconf
    while read line; do
      if [[ $line == \#* ]]; then continue; fi
      sip=`echo $line | cut -d, -f2`
      sdom=`echo $line | cut -d, -f1`
      echo -e "  bind $sip:443 ssl crt /SSL/$sdom.pem" >> $haproxyconf
    done<$srvpath/$DNSlist
    echo -e "  http-request add-header X-Forwarded-Proto https" >> $haproxyconf
    # add code to insert acl based on teamserver profile
    if [[ ! -z $haprofile ]]; then
      for i in `grep "set uri" $csc2path/$haprofile  | awk -F '"' '{print$2}'`; do
        echo -e "  acl path_cs path -m beg $i" >> $haproxyconf
      done
      echo -e "  acl path_cs path_reg ^/[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]$" >> $haproxyconf
      echo -e "  use_backend c2-https if path_cs" >> $haproxyconf
      echo -e "  default_backend decoy-www" >> $haproxyconf
    else
      echo -e " default_backend c2-https" >> $haproxyconf
    fi
    echo -e "  timeout client 1m" >> $haproxyconf
    echo -e "\nbackend c2-https" >> $haproxyconf
    echo -e "  option forwardfor" >> $haproxyconf
    echo -e "  server teamserver $rediripsel:$bindhttps ssl verify none" >> $haproxyconf
  fi
  if [[ $http == 1 ]]; then
    echo -e "\nfrontend www-http" >> $haproxyconf
    echo -e "  mode http" >> $haproxyconf
    echo -e "  option http-buffer-request" >> $haproxyconf
    echo -e "  declare capture request len 40000" >> $haproxyconf
    echo -e "  capture request header User-Agent len 512" >> $haproxyconf
    echo -e "  capture request header Host len 512" >> $haproxyconf
    echo -e "  capture request header X-Forwarded-For len 512" >> $haproxyconf
    echo -e "  capture request header X-Forwarded-Proto len 512" >> $haproxyconf
    echo -e "  capture request header X-Host len 512" >> $haproxyconf
    echo -e "  capture request header Forwarded len 512" >> $haproxyconf
    echo -e "  capture request header Via len 512" >> $haproxyconf
    echo -e "  log /dev/log local2 debug" >> $haproxyconf
    while read p; do
      if [[ $p == \#* ]]; then continue; fi
      sip=`echo $p | cut -d/ -f1`
      echo -e "  bind $sip:80" >> $haproxyconf
    done<$srvpath/$IPlist
    echo -e "  http-request add-header X-Forwarded-Proto http" >> $haproxyconf
    # add code to insert acl based on teamserver profile
    if [[ ! -z $haprofile ]]; then
      for i in `grep "set uri" $csc2path/$haprofile  | awk -F '"' '{print$2}'`; do
        echo -e "  acl path_cs path -m beg $i" >> $haproxyconf
      done
      echo -e "  acl path_cs path_reg ^/[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]$" >> $haproxyconf
      echo -e "  use_backend c2-http if path_cs" >> $haproxyconf
      echo -e "  default_backend decoy-www" >> $haproxyconf
    else
      echo -e " default_backend c2-http" >> $haproxyconf
    fi
    echo -e "  timeout client 1m" >> $haproxyconf
    echo -e "\nbackend c2-http" >> $haproxyconf
    echo -e "  option forwardfor" >> $haproxyconf
    echo -e "  server teamserver $rediripsel:$bindhttp" >> $haproxyconf
  fi
  echo -e "\nbackend decoy-www" >> $haproxyconf
  echo -e "  mode http" >> $haproxyconf
  echo -e "  server decoy $decoysite:80" >> $haproxyconf
}

BuildNGINXConfig()
{
  mkdir -p $srvpath/config
  # Set path to temporary nginx config file
  nginxconf="$srvpath/config/nginx.conf"
  # build initial file
  echo -e "# NGINX configured by buildredteam.sh script" > $nginxconf
  echo -e "# Server: $rediripsel" >> $nginxconf
  echo -e "worker_processes 5;" >> $nginxconf
  echo -e "pid /var/run/nginx.pid;" >> $nginxconf
  echo -e "error_log /var/log/nginx.error_log info;" >> $nginxconf
  echo -e "\nload_module /usr/lib/nginx/modules/ngx_stream_geoip_module.so;" >> $nginxconf
  echo -e "\nevents {\n\tworker_connections 1024;\n}" >> $nginxconf
  if [[ $https == 1 ]] || [[ $http == 1 ]]; then
    echo -e "\nhttp {" >> $nginxconf
    echo -e "\n\tmap \$redir_hostname \$redir_hostname {" >> $nginxconf
    echo -e "\t\tdefault \"${hostnamesel}\";" >> $nginxconf
    echo -e "\t}" >> $nginxconf
    echo -e "\n\tmap \$backend_name \$backend_name {" >> $nginxconf
    echo -e "\t\tdefault \"c2-www\";" >> $nginxconf
    echo -e "\t}" >> $nginxconf
    echo -e "\n\tmap \$frontend_name \$frontend_name {" >> $nginxconf
    echo -e "\t\tdefault \"www-http\";" >> $nginxconf
    echo -e "\t}" >> $nginxconf
    if [[ $https == 1 ]]; then
      while read p; do
        if [[ $p == \#* ]]; then continue; fi
        sip=`echo $p | cut -d, -f2`
        sdom=`echo $p | cut -d, -f1`
        echo -e "\n\tserver {" >> $nginxconf
        echo -e "\t\tlisten $sip:443 ssl;" >> $nginxconf
        echo -e "\t\tlocation / {" >> $nginxconf
        echo -e "\t\t\tproxy_pass https://$rediripsel:$bindhttps;" >> $nginxconf
        echo -e "\t\t\tproxy_ssl_verify off;" >> $nginxconf
        echo -e "\t\t\tproxy_set_header Host \$host;" >> $nginxconf
        echo -e "\t\t}" >> $nginxconf
        echo -e "\t\tssl_certificate /SSL/$sdom.crt;" >> $nginxconf
        echo -e "\t\tssl_certificate_key /SSL/$sdom.key;" >> $nginxconf
        echo -e "\t}" >> $nginxconf
      done<$srvpath/$DNSlist
    fi
    if [[ $http == 1 ]]; then
      while read p; do
        if [[ $p == \#* ]]; then continue; fi
        sip=`echo $p | cut -d/ -f1`
        echo -e "\n\tserver {" >> $nginxconf
        echo -e "\t\tlisten $sip:80;" >> $nginxconf
        echo -e "\t\tlocation / {" >> $nginxconf
        echo -e "\t\t\tproxy_pass http://$rediripsel:$bindhttp;" >> $nginxconf
        echo -e "\t\t\tproxy_ssl_verify off;" >> $nginxconf
        echo -e "\t\t\tproxy_set_header Host \$host;" >> $nginxconf
 #       echo -e "\t\t\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> $nginxconf
        echo -e "\t\t}" >> $nginxconf
        echo -e "\t}" >> $nginxconf
      done<$srvpath/IPList.txt
    fi
    echo -e "}" >> $nginxconf
  fi
  if [[ $dns == 1 ]]; then
    echo -e "\nstream {" >> $nginxconf
    echo -e "\n\tupstream dns {\n\t\tserver $rediripsel:$binddns;\n\t}" >> $nginxconf
    echo -e "\n\tserver {" >> $nginxconf
    while read p; do
      if [[ $p == \#* ]]; then continue; fi
      sip=`echo $p | cut -d/ -f1`
      echo -e "\t\tlisten $sip:53;" >> $nginxconf
    done<$srvpath/IPList.txt
    echo -e "\t\tproxy_pass dns;\n\t}" >> $nginxconf
    echo -e "\n\tserver {" >> $nginxconf
    while read p; do
      if [[ $p == \#* ]]; then continue; fi
      sip=`echo $p | cut -d/ -f1`
      echo -e "\t\tlisten $sip:53 udp;" >> $nginxconf
    done<$srvpath/IPList.txt
    echo -e "\t\tproxy_pass dns;\n\t}" >> $nginxconf
    echo -e "\n}" >> $nginxconf
  fi
}

BuildApacheConfig()
{
  mkdir -p $srvpath/config
  mkdir -p $srvpath/WWW
  echo "<html><body>Welcome</body></html>" > $srvpath/WWW/index.html
  # Set path to temporary apache config file
  apacheconf="$srvpath/config/httpd.conf"
  # build initial file
  echo -e "# Apache2 configured by buildredteam.sh script" > $apacheconf
  while read p; do
    if [[ $p == \#* ]]; then continue; fi
    sip=`echo $p | cut -d/ -f1`
    echo -e "listen $sip:80" >> $apacheconf
  done<$srvpath/IPList.txt
  echo "LoadModule mpm_event_module modules/mod_mpm_event.so" >> $apacheconf
  echo "LoadModule authz_host_module modules/mod_authz_host.so" >> $apacheconf
  echo "LoadModule authz_core_module modules/mod_authz_core.so" >> $apacheconf
  echo "LoadModule socache_shmcb_module modules/mod_socache_shmcb.so" >> $apacheconf
  echo "LoadModule reqtimeout_module modules/mod_reqtimeout.so" >> $apacheconf
  echo "LoadModule mime_module modules/mod_mime.so" >> $apacheconf
  echo "LoadModule ssl_module modules/mod_ssl.so" >> $apacheconf
  echo "LoadModule unixd_module modules/mod_unixd.so" >> $apacheconf
  echo "LoadModule dir_module modules/mod_dir.so" >> $apacheconf
  echo "DocumentRoot "/usr/local/apache2/htdocs"" >> $apacheconf
  echo "<Directory "/usr/local/apache2/htdocs">" >> $apacheconf
  echo "   Options Indexes FollowSymLinks" >> $apacheconf
  echo "   AllowOverride None" >> $apacheconf
  echo "    Require all granted" >> $apacheconf
  echo "</Directory>" >> $apacheconf
  echo "Include conf/extra/httpd-ssl.conf" >> $apacheconf
  apachesslconf="$srvpath/config/httpd-ssl.conf"
  # build initial file
  echo -e "# Apache2 configured by buildredteam.sh script" > $apachesslconf
  scp $CAserver:$CAcrtpath/$CAcert $srvpath/SSL/$CAcert &>/dev/null 
  while read -r p; do 
    if [[ $p == \#* ]]; then continue; fi
    sip=`echo $p | cut -d, -f2`
    sdom=`echo $p | cut -d, -f1`
    echo "Listen $sip:443" >> $apachesslconf
    echo "<VirtualHost $sip:443>" >> $apachesslconf
    echo "ServerName $sdom" >> $apachesslconf
    echo 'DocumentRoot  "/usr/local/apache2/htdocs"' >> $apachesslconf
    echo "SSLEngine on" >> $apachesslconf
    echo "SSLCertificateFile /SSL/$sdom.crt" >> $apachesslconf
    echo "SSLCertificateKeyFile /SSL/$sdom.key" >> $apachesslconf
    echo "SSLCertificateChainFile /SSL/$CAcert" >> $apachesslconf
    echo "</VirtualHost>" >> $apachesslconf
  done<$srvpath/OPFOR-DNS.txt
}
  
GenManIPList()
{
  echo "# Manual IP List for $srvtag" > $tmpsrvpath/$IPlist
  echo "# $countrysel/$citysel" >> $tmpsrvpath/$IPlist
  while read -r line; do
    manaddr=`echo $line | cut -d, -f2`
    mangwy=`echo $line | cut -d, -f3`
    echo "$manaddr,$mangwy" >> $tmpsrvpath/$IPlist
  done<$manIPlist
}

GenRanIPlist()
{
  # Configuration file is built, now we process through it to create
  # a new interface config file.  This file will get moved to /etc/network/interfaces
  # Set the name for the configuration file that will get built.
  # get the selected backbone router file.
  brtrfile="$rtrpath/$countrysel/$routerfile"
  # initialize the List of IPs file.
  echo "# Random IP List for $srvtag" > $tmpsrvpath/$IPlist
  echo "# $countrysel/$citysel" >> $tmpsrvpath/$IPlist

  #process through to create random IPs
  # get # of IP ranges within the backbone router file, ignore comment lines.
  rangecount=`grep -vc ^\# $brtrfile`
  # see how many IP's per range will be needed to reach the select number of IPs
  factor=` expr $totalipssel / $rangecount`
  # Add 1 to the factor so we run over and not under.
  numips=` expr $factor + 1`
  count=0
  while read y; do
    # Ignore comment lines or blank lines in the file.
    if [[ $y == \#* ]] || [[ $y == "" ]]; then continue; fi
    # Exits loop when totalipssel is reached.
    if [[ $count == $totalipssel ]]; then break; fi
    # Breaks up the routing table IP into chucks.
    gwyIP=`echo $y | cut -d/ -f1`
    cidr=`echo $y | cut -d/ -f2`
    oct1=`echo $gwyIP | cut -d. -f1`
    oct2=`echo $gwyIP | cut -d. -f2`
    oct3=`echo $gwyIP | cut -d. -f3`
    oct4=`echo $gwyIP | cut -d. -f4`
    # Add one to the last oct as the starting IP range
    oct4plus1=` expr $oct4 + 1`
    # the mod is the remainder of the cidr divided by 8
    mod=` expr $cidr % 8`
    # the div is the whole number of times the cidr divides into 8
    div=` expr $cidr / 8`
    # process the mod and set the value to add to the target oct. Subnet math...
    case $mod in
      7) addval=1;;
      6) addval=3;;
      5) addval=7;;
      4) addval=15;;
      3) addval=31;;
      2) addval=63;;
      1) addval=127;;
      0) addval=255;;
    esac
    # Modify IP oct based on the div.
    # each one uses the shuf command, this generates random numbers set
    # by -n between two numbers. then puts the IP back together
    # attachs the CIDR back and saves it to the config file.
    case $div in
      3) octmod=` expr $oct4 + $addval - 2`;
           for x in `shuf -i $oct4plus1-$octmod -n $numips`; do
       if [[ $count == $totalipssel ]]; then break; fi
             echo $oct1.$oct2.$oct3.$x/$cidr,$gwyIP >> $tmpsrvpath/$IPlist
             let "count++"
           done;;
      2) octmod=` expr $oct3 + $addval`;
           for x in `shuf -i 1-254 -n $numips`; do
             if [[ $count == $totalipssel ]]; then break; fi
             randoct3=`shuf -i $oct3-$octmod -n 1`
          echo $oct1.$oct2.$randoct3.$x/$cidr,$gwyIP >> $tmpsrvpath/$IPlist
             let "count++"
           done;;
      1) octmod=` expr $oct2 + $addval`;
           for x in `shuf -i 1-254 -n $numips`; do
             if [[ $count == $totalipssel ]]; then break; fi
             randoct2=`shuf -i $oct2-$octmod -n 1`
             randoct3=`shuf -i 0-255 -n 1`
          echo $oct1.$randoct2.$randoct3.$x/$cidr,$gwyIP >> $tmpsrvpath/$IPlist
             let "count++"
           done;;
      0) octmod=` expr $oct1 + $addval`;
           for x in `shuf -i 1-254 -n $numips`; do
             if [[ $count == $totalipssel ]]; then break; fi
             randoct1=`shuf -1 $oct1-$octmod -n 1`
             randoct2=`shuf -i 0-255 -n 1`
             randoct3=`shuf -i 0-255 -n 1`
          echo $randoct1.$randoct2.$randoct3.$x/$cidr,$gwyIP >> $tmpsrvpath/$IPlist
             let "count++"
           done;;
    esac
  done<$brtrfile
}

BuildIPs()
{
  if [ ! -f $rtrtable.org ]; then cp $rtrtable $rtrtable.org; fi
  for x in {1..100}
  do
    if grep -q ^$x $rtrtable; then
      continue
    else
      echo "$x  $srvtag" >> $rtrtable
      break
    fi
  done
  #We'll be using letters of the aphabet to tag subinterfaces.  Need to find an available one.
  for x in {a..z}
  do
    if ip a | grep -q $intname:$x; then
      continue
    else
      subvar=$x
      break;
    fi
  done
  pass=1
  # Loops through the config file to create interfaces file
  # Initializes the interfaces file
  echo -e "\n#$srvtag START Interface adds Docker service" > $tempintfile
  while read p; do
    if [[ $p == \#* ]] || [[ $p == "" ]]; then continue; fi
    intnamein=$intname:$subvar$pass
    addrandcidr=`echo $p | cut -d, -f1`
    addrin=`echo $addrandcidr | cut -d/ -f1`
    gwyip=`echo $p | cut -d, -f2`
    netid=`ipcalc $addrandcidr | grep ^Network | awk '{print$2}'`
    ifconfig $intnamein $addrandcidr   # adds IP to running system
    ip route add $netid dev $intnamein src $addrin table $srvtag # adds route using new rt_table
    echo "auto $intnamein" >> $tempintfile                    # adds IP to interface config
    echo "iface $intnamein inet static" >> $tempintfile
    echo "  address $addrandcidr" >> $tempintfile
    echo "  post-up ip route add $netid dev $intnamein src $addrin table $srvtag" >> $tempintfile
    if [[ $pass -eq 1 ]]; then
      ip route add default via $gwyip dev $intnamein table $srvtag
      echo "  post-up ip route add default via $gwyip dev $intname table $srvtag" >> $tempintfile
    fi
    ip rule add from $addrin/32 table $srvtag
    ip rule add to $addrin/32 table $srvtag
    echo "  post-up ip rule add from $addrin/32 table $srvtag" >> $tempintfile
    echo "  post-up ip rule add to $addrin/32 table $srvtag" >> $tempintfile
    let "pass++"
  done<$srvpath/IPList.txt
  echo -e "#$srvtag STOP Interface adds Docker Server\n" >> $tempintfile
  cat $tempintfile >> $intfile
}

DeleteIPs()
{
  dsrv=$1
  for ip in `grep -v "^#" $basesrvpath/$dsrv/$IPlist | cut -d, -f1`; do
    int=`ip a | grep $ip | awk '{ print $NF }'`
    dip=`echo $ip | cut -d/ -f1`
    ifconfig $int del $dip
  done
  iconfstart="#$dsrv START"
  iconfstop="#$dsrv STOP"
  sed -i "/$iconfstart/,/$iconfstop/d" /etc/network/interfaces
  sed -i "/$dsrv$/d" /etc/iproute2/rt_tables
} 
#######################  FINAL SCRIPT EXECTUION FUNCTION ########################

ExecAndValidate()
{
  MenuBanner
  # Get user selections and display them for confirmation
  case $opt in
    1) echo -e "\n\t$ltblue Setting up a NGINX redirector using the above settings";;
    2) echo -e "\n\t$ltblue Setting up a HAProxy redirector using the above settings";;
    3) echo -e "\n\t$ltblue Setting up a Cobalt Strike TeamServer using above settings";;
    4) echo -e "\n\t$ltblue Setting up a Payload Host using the above settings";;
    5) echo -e "\n\t$ltblue Setting up for Phish attacks using the above settings";;
    *) echo -e "\n\t$red Not sure how you broke the script, but you did! opt=$opt";;
  esac
  # based on main menu selection, execute set scripts.
  echo -ne "\t$ltblue Do you want to continue? Press enter to continue or q to quit $default"
  read answer
  case $answer in
    q|Q) echo -e "$default"; exit 0;;
    b|B) case $opt in
           1) DNSTagMenu; return;; 
           2) DNSTagMenu; return;;
           3) DNSTagMenu; return;;
           4) DNSTagMenu; return;;
           5) DNSTagMenu; return;;
         esac
         exit;;
    *) MenuBanner;;
  esac
  # add a return to seperate script execution output.
  echo ""
  
  # Create service path folder and move tmpsrvpath data to it.
  srvpath="$basesrvpath/$srvtag"
  if [[ $setphish == 1 ]]; then
    if [[ -d $srvpath ]]; then 
      # Remove previous IP's build for phish
      DeleteIPs phish
      rm -r $srvpath; fi
  fi
  mkdir -p $srvpath
  mv $tmpsrvpath $basesrvpath 
   
    # Build required configurations and start services
  if [[ -s $srvpath/$IPlist ]]; then 
    echo -ne "\t$yellow Building IP's Now.... $default"
    BuildIPs
    echo -e "$green Finished! $default"
  fi
  if [[ -s $srvpath/$DNSlist || $randomdns == 1 ]]; then
    echo -ne "\t$yellow Registering DNS Now ... $default"
    RegisterDNS
    echo -e "\t$green Finished! $default"
  fi
  if [[ $https == 1 || $setpayload == 1 ]]; then
    echo -ne "\t$yellow Generating SSL certs Now.... $default"
    RandomSSLGen
    echo -e "\t$green Finished! $default"
  fi  
  if [[ $setnginx == 1 ]]; then
    echo -ne "\t$yellow Building NGINX.conf for redirection Now.... $default"
    BuildNGINXConfig
    echo -e "$green Finished! $default"
  elif [[ $sethaproxy == 1 ]]; then
    echo -ne "\t$yellow Building haproxy.cfg for redirection Now.... $default"
    BuildHAProxyConfig
    echo -e "$green Finished! $default"
  elif [[ $setpayload == 1 ]]; then
    echo -ne "\t$yellow Building Apache2 Now...."
    BuildApacheConfig
    echo -e "$green Finished!"
  elif [[ $setcsts == 1 ]]; then
    cp -r /root/cobaltstrike-local $srvpath/cobaltstrike
    if [[ $tsbridge != 1 ]]; then
      tsip=`grep -v "^#" $srvpath/$IPlist | cut -d '/' -f1`
      sed -i "s/0.0.0.0/$tsip/g" $srvpath/cobaltstrike/teamserver
    fi
  elif [[ $setphish == 1 ]]; then
    phishDNS=`grep -v "^#" $srvpath/$DNSlist | cut -d, -f1`
	phishIP=`grep -v "^#" $srvpath/$IPlist | cut -d '/' -f1`
    if (nslookup -type=mx $phishDNS | grep -q "No answer"); then
      echo -e "\n$red ERROR: the domain entered can't resolve the MX record.  See below"
      nslookup -type=mx $phishDNS
    else
      echo -ne "\n\t$yellow Setting up postfix using $phishDNS...$default"
      service postfix stop
      sed -i '/^myorigin/d' $postfixconf
      sed -i '/^myhostname/d' $postfixconf
      sed -i '/^smtpd_banner/d' $postfixconf
      sed -i '/^mydestination/d' $postfixconf
      sed -i '/^virtual_alias_maps/d' $postfixconf
	  sed -i '/^inet_interfaces/d' $postfixconf 
      echo "myhostname=$phishDNS" >> $postfixconf
      echo "myorigin=/etc/mailname" >> $postfixconf
      echo "smtpd_banner= \$myhostname Microsoft ESMTP Mail" >> $postfixconf
      echo "mydestination= \$myhostname,localhost" >> $postfixconf
      echo "virtual_alias_maps=hash:/etc/postfix/virtual_alias" >> $postfixconf
	  echo "inet_interfaces = $phishIP" >> $postfixconf 
      echo $phishDNS > /etc/mailname
      echo "mailer-daemon: postmaster" > /etc/aliases
      echo "admin@$phishDNS admin" > /etc/postfix/virtual_alias
      postmap /etc/postfix/virtual_alias
      newaliases
      service postfix start
      echo -e "$green Finished, happy phishing!$default"
    fi
  fi
  if [[ $setphish != 1 ]]; then 
    echo -ne "\t$yellow Building Docker compose file Now.... $default"
    BuildDockerContainer
    echo -e "$green Finished! $default"
    echo -ne "\t$yellow Starting Docker Container Now... $default"
    StartDockerContainer
    echo -e "$green Finished! $default"
    echo -e "\n\t$ltblue Service information is located at $srvpath"
    echo -e "\t This folder contains Service info, IP file, and OPFOR-DNS file $default"
  fi 
  # Remove iptable rules that create container isolation
  iptables -F OUTPUT -t nat
  iptables -F PREROUTING -t nat
}

# Script execution actually starts here with a call to the MainMenu.
MainMenu
