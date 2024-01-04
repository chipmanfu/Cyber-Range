#!/bin/bash
# script abomination by Chip McElvain
# usability script for SourcePoint 

# Set variable names to add color codes to menu displays.
white="\e[1;37m"
ltblue="\e[1;36m"
ltgray="\e[0;37m"
dkgray="\e[1;30m"
red="\e[1;31m"
green="\e[1;32m"
whiteonblue="\e[5;37;44m"
yellow="\e[1;33m"
default="\e[0m"
declare -a peclone=("srv.dll" "ActivationManager.dll" "audioeng.dll" "AzureSettingSyncProvider.dll" "BingMaps.dll" "BootMenuUX.dll" "DIAGCPL.dll" "FIREWALLCONTROLPANEL.dll" "WMNetMgr.dll" "wwanapi.dll" "Windows.Storage.Search.dll" "Windows.System.Diagnostics.dll" "Windows.System.Launcher.dll" "Windows.System.SystemManagement.dll" "Windows.UI.BioFeedback.dll" "Windows.UI.BlockedShutdown.dll" "Windows.UI.Core.TextInput.dll" "FILEMGMT.dll" "polprocl.dll" "GPSVC.dll" "libcrypto.dll" "rdpcomapi.dll" "winsqlite3.dll" "wow64.dll" "wow64win.dll" "WWANSVC.dll")

declare -a postex=("WerFault.exe" "WWAHost.exe" "wlanext.exe" "auditpol.exe" "bootcfg.exe" "choice.exe" "bootcfg.exe" "dtdump.exe" "expand.exe" "fsutil.exe" "gpupdate.exe" "gpresult.exe" "logman.exe" "mcbuilder.exe" "mtstocom.exe" "pcaui.exe" "powercfg.exe" "svchost.exe")

declare -a useragent=("Win10Chrome" "Win10Edge" "Win10IE" "Win10" "Win6.3" "Linux" "Mac")

declare -a metadata=("base64" "base64url" "netbios" "netbiosu")

declare -a keylogger=("GetAsyncKeyState" "SetWindowsHookEx")
declare -a httpprofile=("Windowsupdate" "Slack" "Gotomeeting" "Outlook.Live")

MenuBanner()
{
  clear
  bannertitle="SourcePoint C2 Profile Builder"
  printf "\n\t$ltblue %-60s %8s\n"  "$bannertitle" "<b>-Back"
  printf "\t$ltblue %60s %8s\n"  "" "<q>-Quit"
  ShowCurrentSettings
  if [[ $mando = "y" ]]; then 
    echo -e "\n\t$yellow ALL Mandatory Flags are now set, you enter the following at anytime."
    echo -e "\t\t $white d or D $ltblue- to exit and built the C2 Profile with current settings"
    echo -e "\t\t $white s or S $ltblue- to skip a setting option and move on to the next option $default"
  fi
}

ShowCurrentSettings()
{
  if [[ ! -z $filenamesel ]]; then echo -e "\t\t$white Current settings"; fi
  if [[ ! -z $filenamesel ]]; then SettingFormat "Profile Name" "$filenamesel"; fi
  if [[ ! -z $hostsel ]]; then SettingFormat "C2 Profile FQDN" "$hostsel"; fi
  if [[ ! -z $injectsel ]]; then SettingFormat "Injector" "$injectsel"; fi
  if [[ ! -z $jittersel ]]; then SettingFormat "Jitter set to" "$jittersel"; fi
  if [[ ! -z $sleepsel ]]; then SettingFormat "Sleep set to" "$sleepsel"; fi
  if [[ ! -z $useragentsel ]]; then SettingFormat "User Agent" "$useragentsel"; fi
  if [[ ! -z $peclonesel ]]; then SettingFormat "PE_Clone" "$peclonesel"; fi
  if [[ ! -z $postexsel ]]; then SettingFormat "Post Ex" "$postexsel"; fi
  if [[ ! -z $metadatasel ]]; then SettingFormat "MetaData Transform" "$metadatasel"; fi
  if [[ ! -z $httpprofilesel ]]; then SettingFormat "HTTP Profile" "$httpprofilesel"; fi
  if [[ ! -z $keyloggersel ]]; then SettingFormat "KeyLogger" "$keyloggersel"; fi
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

#### MENU FUNCTIONS FOR GETTING USER INPUT

FileNameMenu()
{
  filenamesel=; mando=n
  MenuBanner
  echo -e "\n\t$ltblue First we need a outfile name.  The script will add the .profile extension for you"
  echo -e "\t and save the C2 profile in the$white /root/Profiles $ltblue directory"
  echo -ne "\t$ltblue Create a name for this profile here : $default"
  read filenamein
  case $filenamein in
    q|Q) UserQuit;;
    *) filenamesel=$filenamein".profile" 
       if ls /root/Profiles | grep -q $filenamesel; then
         echo -e "\n\t$red Warning:$white There is already a profile named $filenamesel $default"
         echo -ne "\t$ltblue Do you want to overwrite it? $default"
         read answer
         case $answer in
           y|Y|yes|YES|Yes) HostNameMenu; return;;
           n|N|no|NO|No) FileNameMenu; return;;
           *) echo "How much human error do I have to do!!, Exiting out of spite!"; sleep 4; exit 0;;
         esac
       else
         HostNameMenu
       fi;;
  esac    
}

HostNameMenu()
{
  # Set initial variables, Resets values if user navigates back to the beginning
  hostsel=
  # Calls menu Banner
  MenuBanner
  echo -e "\n\t$ltblue Next enter the FQDN you want to use for your C2 Profile"
  echo -en "\t$ltblue Enter a FQDN here: $default"
  read hostin
  case $hostin in
    b|B) FileNameMenu;;
    q|Q) UserQuit;;
    *) hostsel=$hostin; InjectorMenu;;
  esac
}

InjectorMenu()
{
  injectsel=; mando=n
  MenuBanner
  echo -e "\n\t$ltblue Next Select memory injection method"
  Format3Options "1" "VirtualAllocEx (good for cross arch i.e. x86->x64 x64->x86)"
  Format3Options "2" "NtMapViewOfSection (stealthier, but fails over to VirtualAllocEx which can be louder)"
  echo -ne "\n\t$ltblue Enter Selection Here: $default"
  read injectin
  case $injectin in
    b|B) HostNameMenu;;
    q|Q) UserQuit;;
      1) injectsel="VirtualAllocEx"; JitterMenu;;
      2) injectsel="NtMapViewOfSection"; JitterMenu;;
      *) InputError; InjectorMenu;;
  esac
}

JitterMenu()
{
  jittersel=; mando=y
  MenuBanner
  echo -e "\n\t$ltblue Set Jitter Amount number between 0-100"
  echo -ne "\t Set Jitter Amount Here: $default"
  read jitterin
  case $jitterin in
    b|B) InjectorMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    s|S) $jittersel=; SleepMenu;;
    [0-9]|[1-9][0-9]|100) jittersel=$jitterin; SleepMenu;;
      *) InputError; JitterMenu;;
  esac
}

SleepMenu()
{
  sleepsel=
  MenuBanner
  echo -e "\n\t$ltblue Set Sleep interval (in seconds)"
  echo -ne "\t Enter Here: $default"
  read sleepin
  case $sleepin in
    b|B) JitterMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    s|S) $sleepsel=; UserAgentMenu;;
    [0-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]) sleepsel=$sleepin; UserAgentMenu;;
    *) InputError; SleepMenu;;
  esac
}

UserAgentMenu()
{
  useragentsel=
  MenuBanner
  echo -e "\n\t$ltblue Select a option for User agent"
  count=1
  for x in "${useragent[@]}"; do
    Format3Options "$count" "$x"
    let "count++"
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read useragentin
  case $useragentin in
    b|B) SleepMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    s|S) $useragentsel=; PECloneMenu;;
    [0-6]) useragentsel=${useragent[$useragentin-1]}; PECloneMenu;;
      *) InputError; UserAgentMenu;;
   esac
}

PECloneMenu()
{
  peclonesel=
  MenuBanner
  echo -e "\n\t$ltblue Select a option for PE_Clone PE file beacon will mimic this"
  count=1
  for x in "${peclone[@]}"; do
    Format3Options "$count" "$x"
    let "count++"
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read peclonein
  case $peclonein in
    b|B) JitterMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    s|S) peclonesel=; PostExMenu;;
    [1-9]|1[0-9]|2[0-6]) pecloneopt=$peclonein; peclonesel=${peclone[$peclonein-1]}; PostExMenu;;
    *) InputError; PECloneMenu;;
  esac
}

PostExMenu()
{
  postexsel=; postexopt=
  MenuBanner
  echo -e "\n\t$ltblue Select a Post-Ex process for spawn injection"
  count=1
  for x in "${postex[@]}"; do
    Format3Options "$count" "$x"
    let "count++"
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read postexin
  case $postexin in
    b|B) PECloneMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    s|S) postexopt=; MetaDataMenu;;
    [1-9]|1[0-8])  postexopt=$postexin; postexsel=${postex[$postexin-1]}; MetaDataMenu;;
    *) InputError; PostExMenu;;
  esac    
}

MetaDataMenu()
{
  metadatasel=
  MenuBanner
  echo -e "\n\t$ltblue Select how to transform and embed MetatData into HTTP requests"
  count=1
  for x in "${metadata[@]}"; do
    Format3Options "$count" "$x"
    let "count++"
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read metadatain
  case $metadatain in
    b|B) PostExMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    s|S) metadatasel=; HTTPProfileMenu;;
    [1-4])  metadatasel=${metadata[$metadatain-1]}; HTTPProfileMenu;;
    *) InputError; MetaDataMenu;;
  esac    
} 

HTTPProfileMenu()
{
  httpprofileopt=;httpprofilesel=
  MenuBanner
  echo -e "\n\t$ltblue Select an HTTP Get/Post profile"
  count=1
  for x in "${httpprofile[@]}"; do
    Format3Options "$count" "$x"
    let "count++"
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read httpprofilein
  case $httpprofilein in
    b|B) MetaDataMenu;;
    d|D) ConfirmMenu;;
    q|Q) UserQuit;;
    s|S) httpprofilesel=; KeyLoggerMenu;;
    [1-6])  httpprofileopt=$httpprofilein; httpprofilesel=${httpprofile[$httpprofilein-1]}; KeyLoggerMenu;;
    *) InputError; HTTPProfileMenu;;
  esac    
} 

KeyLoggerMenu()
{
  keyloggersel=
  MenuBanner
  echo -e "\n\t$ltblue Select keylogging method"
  count=1
  for x in "${keylogger[@]}"; do
    Format3Options "$count" "$x"
    let "count++"
  done
  echo -en "\n\t$ltblue Enter a Selection: $default"
  read keyloggerin
  case $keyloggerin in
    b|B) HTTPProfileMenu;;
    q|Q) UserQuit;;
    d|D) ConfirmMenu;;
    q|Q) UserQuit;;
    [1-2])  keyloggersel=${keylogger[$keyloggerin-1]}; ConfirmMenu;;
    *) InputError; KeyLoggerMenu;;
  esac    
}

ConfirmMenu()
{
  MenuBanner
  echo -ne "\n\t$ltblue Do you want to generate a C2 profile with the above settings (y or n)? $default"
  read confirm
  case $confirm in
    y|Y|yes|YES|Yes) BuildProfile;;
    n|N|no|NO|No) exit 0;;
    b|B) KeyLoggerMenu;;
    q|Q) UserQuit;;
    *) InputError; ConfirmMenu;;
  esac
}

BuildProfile()
{
flagstring="-Host $hostsel -Injector $injectsel -Outfile /root/Profiles/$filenamesel "
if [ ! -z $jittersel ]; then
  addflagstring="-Jitter $jittersel "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
if [ ! -z $sleepsel ]; then
  addflagstring="-Sleep $sleepsel "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
if [ ! -z $useragentsel ]; then
  addflagstring="-Useragent $useragentsel "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
if [ ! -z $peclonesel ]; then
  addflagstring="-PE_Clone $pecloneopt "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
if [ ! -z $postexsel ]; then
  addflagstring="-PostEX_Name $postexopt "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
if [ ! -z $metadatasel ]; then
  addflagstring="-Metadata $metadatasel "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
if [ ! -z $httpprofileopt ]; then
  addflagstring="-Profile $httpprofileopt "
  c=$flagstring
  flagstring="$c$addflagstring"
fi 
if [ ! -z $keyloggersel ]; then
  addflagstring="-Keylogger $keyloggersel "
  c=$flagstring
  flagstring="$c$addflagstring"
fi
/root/go/bin/SourcePoint $flagstring

echo -e "\n\t$green Hopefully it completed successfully, if not below is the command to re-run it\n"
echo -e "$default /root/go/bin/SourcePoint $flagstring"
echo -e "\n$yellow Check this profile against C2lint before using, new Sourcepoint is a bit buggy\n"
echo -e "$default"
}
# Script execution actually starts here with a call to the MainMenu.
FileNameMenu
