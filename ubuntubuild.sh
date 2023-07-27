#!/bin/bash
clear

### User customization Variable section
## Change this if you don't want to use the defaults.  This should set it up correctly, but not throughly tested.

# Proxy settings for the Range.
ProxyIP="172.30.0.2"
ProxySub="21"
ProxyNetID="172.30.0.0"
ProxyPort="9999"

# Root password
MasterRootPass="toor"

# Certificate Authority Variables
CA="globalcert.com"
cac="US"                 	# Country for cert
cast="Oregon"			# State for cert
cal="Seattle"			# Locality (city)
cao="Global Certificates, Inc"	# Organization
caou="Root Cert"		# Organizational unit
capempass="password"

#### End of user customization section - mess with variables below at your own peril.

Proxy="http://$ProxyIP:$ProxyPort"
CAPass=$MasterRootPass
DNSPass=$MasterRootPass
SIPass=$MasterRootPass
# Network Interfaces for various builds.
# IA Proxy IP settings
iapnic1="$ProxyIP/$ProxySub"
iapnic2="dhcp"
# Root DNS IP Settings
rootdnsnic1="dhcp"
rootdnsnic2="8.8.8.8/24
             198.41.0.4/24  
             199.9.14.201/24 
             192.33.4.12/24 
             199.7.91.13/24 
             192.203.230.10/24 
             195.5.5.241/24 
             192.112.36.4/24
             198.97.190.53/24 
             192.36.148.17/24 
             192.58.128.30/24 
             193.0.14.129/24 
             199.7.83.42/24 
             202.12.27.33/24"
rootdnsgw="8.8.8.1"

# CA server
canic1="dhcp"
canic2="180.1.1.50/24"
caip="180.1.1.50"
cagw="180.1.1.1"

# RTS
rtsnic1="dhcp"
# Randomize an IP for the 5.29.0.1/20 IP range (this range is routable via the SI-router
oct3=`shuf -i 0-15 -n 1`
oct4=`shuf -i 2-254 -n 1`
rtsnic2="5.29.$oct3.$oct4/20"
rtsgw="5.29.0.1"
# Web Servers
webnic1="dhcp"
webnic2="180.1.1.100/24
        180.1.1.110/24
        180.1.1.120/24
        180.1.1.130/24
	    180.1.1.140/24
        180.1.1.150/24"
webgw="180.1.1.1"
owncloudIP="180.1.1.100"
pastebinIP="180.1.1.110"
redbookIP="180.1.1.120"
drawioIP="180.1.1.130"
ntpIP="180.1.1.140"
mssitesIP="180.1.1.150"

# Traffic Gen
trafnic1="dhcp"
trafnic2="92.107.127.12/24
          72.32.4.26/24
	  67.23.44.93/24
	  70.32.91.153/24
	  188.65.120.83/24"
trafgw="92.107.127.1"

# Web host
webhostnic1="dhcp"
webhostnic2="92.107.127.100/24"
webhostgw="92.107.127.1"

# Color codes for menu
white="\e[1;37m"
ltblue="\e[1;36m"
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;32m"
default="\e[0m"

BuildMenu()
{
  clear
  echo -e "\n$ltblue Ubuntu Grayspace build Script\n"
  echo -e "\tWhich Server will this be?"
  echo -e "\t$ltblue 1)$white IA_Proxy"
  echo -e "\t$ltblue 2)$white RootDNS"
  echo -e "\t$ltblue 3)$white CA_Server"
  echo -e "\t$ltblue 4)$white Web_Services"
  echo -e "\t$ltblue 5)$white Not Red Team Server (NRTS)"
  echo -e "\t$ltblue 6)$white Traffic_EmailGen"
  echo -e "\t$ltblue 7)$white Traffic_WebHost"
  echo -e "\t$ltblue q)$white Exit script"
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read answer
  case $answer in 
	  1) srv="IA_Proxy"; opt=1; needdocker=n;;
	  2) srv="RootDNS"; opt=2; needdocker=n;;
	  3) srv="CA_Server"; opt=3; needdocker=n;;
	  4) srv="Web_Services"; opt=4; needdocker=y;;
	  5) srv="Not Red Team Server"; opt=5; needdocker=y;;
	  6) srv="Traffic_EmailGen"; opt=6; needdocker=y;;
	  7) srv="Traffic_WebHost"; opt=7; needdocker=n;;
	  q|Q) exit;;
	  *) echo -e "\n\t\t$red Invalid Selection, Please try again$default"; sleep 2; BuildMenu;;
  esac
  echo -ne "$yellow You selected to build $srv? is this correct?(y or n): $default"
  read confirm
  case $confirm in 
	  y|Y|yes|YES|Yes) clear; echo -e "$green Beginning Configuration for $srv $default";;
	  *) BuildMenu;;
  esac
}
BuildMenu
# get interface name
anic=`ip link show | grep ^2: | awk {'print$2'} | cut -d: -f1`
if [ -z "$anic" ]; then
	echo -e "$red Error, the script couldn't determine your first nic $default"
	exit 0
fi
gnic=`ip link show | grep ^3: | awk {'print$2'} | cut -d: -f1`
if [ -z "$gnic" ]; then
	echo -e  "$red Error, the script didn't detect your second nic, did you add one for this VM? $default"
	exit 0
fi
servername=$srv
if [[ $opt != 1 ]]; then
  # Every else will use the internet proxy, so we'll set up all the proxy things here.
  if grep ^use_proxy /etc/wgetrc > /dev/null; then
    sed -i '/^use_proxy/d' /etc/wgetrc
  fi
  echo "use_proxy=yes" >> /etc/wgetrc	
  if grep ^http_proxy /etc/wgetrc > /dev/null; then
    sed -i '/^http_proxy/d' /etc/wgetrc
  fi
  echo "http_proxy=$Proxy" >> /etc/wgetrc
  if grep ^https_proxy /etc/wgetrc > /dev/null; then
    sed -i '/^https_proxy/d' /etc/wgetrc
  fi
  echo "https_proxy=$Proxy" >> /etc/wgetrc
  # Set up apt to use real internet proxy
  echo "Acquire::http::Proxy \"$Proxy\";" > /etc/apt/apt.conf.d/proxy.conf
  echo "Acquire::https::Proxy \"$Proxy\";" >> /etc/apt/apt.conf.d/proxy.conf
  export http_proxy=$Proxy
  export https_proxy=$Proxy
fi
echo -e "$green Changing some environment settings $default"
sleep 2
echo "colo industry" > /root/.vimrc
echo 'LS_COLORS=$LSCOLORS:"di=96:"; export LS_COLORS' >> /root/.bashrc
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
mkdir /etc/update-motd.d/originals
mv /etc/update-motd.d/* /etc/update-motd.d/originals 2</dev/null

echo "#!/bin/bash" > /etc/update-motd.d/00-header
echo "echo 'Welcome to the'" >> /etc/update-motd.d/00-header
echo "figlet $srv" >> /etc/update-motd.d/00-header
chmod 755 /etc/update-motd.d/00-header
clear
echo -e "$green Removing unncessary applications $default"
sleep 2
apt --purge remove -y cloud-* unattended-upgrades open-iscsi multipath-tools snapd nplan netplan.io
apt autoremove -y
rm -fr /root/snap
clear
echo -e "$green Disabling unnecssary services $default"
systemctl stop systemd-resolve.service
systemctl disable system-resolve.service
systemctl mask system-resolve.service
rm /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
clear
echo -e "$green set up some log management $default"
crontab -l > cronjbs
echo "0 1 * * * /usr/bin/find /var/log -name '*.gz' -exec rm -f {} \;" >> cronjbs
crontab cronjbs
rm cronjbs
sed -i 's/#SystemMaxUse=*/SystemMaxUse=100M/g' /etc/systemd/journald.conf
clear
echo -e "$green Installing needed applications $default"
sleep 2
apt install -y ifupdown net-tools curl make figlet ipcalc traceroute dos2unix sshpass
if [[ $needdocker == "y" ]]; then
  apt install -y ca-certificates gnupg
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --batch --yes -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
  mkdir -p /etc/systemd/system/docker.service.d
  echo "[Service]" > /etc/systemd/system/docker.service.d/http-proxy.conf
  echo "Environment=\"HTTP_PROXY=$Proxy\"" >> /etc/systemd/system/docker.service.d/http-proxy.conf
  echo "Environment=\"HTTPS_PROXY=$Proxy\"" >> /etc/systemd/system/docker.service.d/http-proxy.conf
  if grep -q "^export http_proxy" /etc/default/docker; then
    sed -i '/export http_proxy/d' /etc/default/docker
  fi
  if grep -q "^export https_proxy" /etc/default/docker; then
    sed -i '/export https_proxy/d' /etc/default/docker
  fi
  echo "export http_proxy=\"$Proxy\"" >> /etc/default/docker
  echo "export https_proxy=\"$Proxy\"" >> /etc/default/docker
  systemctl daemon-reload
  systemctl restart docker
fi
clear
echo -e "$green Setting up NTP service $default"
sed -i '/^NTP/d' /etc/systemd/timesyncd.conf
sed -i '/^#NTP/d' /ect/systemd/timesyncd.conf
sed -i '/^FallbackNTP/d' /etc/systemd/timesyncd.conf
sed -i '/^#FallbackNTP/d' /ect/systemd/timesyncd.conf
echo "NTP=pool.ntp.org" >> /etc/systemd/timesyncd.conf
echo "FallbackNTP=172.30.0.2" >> /etc/systemd/timesyncd.conf
timedatectl set-ntp true
clear
gw=
case $opt in
  1) echo -e "$green Setting interfaces for the IA Proxy $default"
     nic1=$iapnic1; nic2=$iapnic2;;
  2) echo -e "$green Setting interfaces for the RootDNS $default"
     nic1=$rootdnsnic1; nic2=$rootdnsnic2; gw=$rootdnsgw;;
  3) echo -e "$green Setting interfaces for the CA Server $default"
     nic1=$canic1; nic2=$canic2; gw=$cagw;;
  4) echo -e "$green Setting interfaces for the Web Services Server $default"
     nic1=$webnic1; nic2=$webnic2; gw=$webgw;;
  5) echo -e "$green Setting interfaces for the NRTS $default"
     nic1=$rtsnic1; nic2=$rtsnic2; gw=$rtsgw;;
  6) echo -e "$green Setting interfaces for the Traffic Gen Server $default"
     nic1=$trafnic1; nic2=$trafnic2; gw=$trafgw;;
  7) echo -e "$green Setting interfaces for the Web Traffic Host Server $default"
     nic1=$webhostnic1; nic2=$webhostnic2; gw=$webhostgw;;
esac

echo -e "auto lo\niface lo inet loopback" > /etc/network/interfaces
for IP in $nic1; do
  if [[ $IP == "dhcp" ]]; then
    echo -e "\nauto $anic\niface $anic inet dhcp" >> /etc/network/interfaces
  else
    echo -e "\nauto $anic\niface $anic inet static\n\taddress $IP" >> /etc/network/interfaces
  fi
done
count=0
for IP in $nic2; do
  if [[ $IP == "dhcp" ]]; then
    echo -e "\nauto $gnic\niface $gnic inet dhcp" >> /etc/network/interfaces
  else
    if [[ $count == 0 ]]; then 
      echo -e "\nauto $gnic\niface $gnic inet static\n\taddress $IP" >> /etc/network/interfaces
      if [[ ! -z $gw ]]; then
        echo -e "\tgateway $gw" >> /etc/network/interfaces
      fi
    else
      echo -e "\nauto $gnic:$count\niface $gnic:$count inet static\n\taddress $IP" >> /etc/network/interfaces
    fi
  fi
  let count++
done
if [ ! -f /etc/network/interfaces.org ]; then
  cp /etc/network/interfaces /etc/network/interfaces.org
fi
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher.service systemd-networkd-wait-online
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher.service systemd-networkd-wait-online
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher.service systemd-networkd-wait-online
systemctl unmask networking
systemctl enable networking
service networking stop
ip addr flush $anic
ip addr flush $gnic
service networking start
service ssh restart
case $opt in 
  1) clear; echo -e "$green Installing $svr Specific Applications $default";
     apt install -y ntp
     apt install -y squid
     mv /etc/squid/squid.conf /etc/squid/squidmanual.txt 
     grep -v "^#" /etc/squid/squidmanual.txt | grep -v "^$" > /etc/squid/squid.conf
     sed -i '/^acl localnet/d' /etc/squid/squid.conf
     echo -e "acl localnet src $ProxyNetID/$ProxySub\n$(cat /etc/squid/squid.conf)" > /etc/squid/squid.conf
     sed -i 's/http_access allow localhost/http_access allow localnet/g' /etc/squid/squid.conf
     sed -i "s/^http_port 3128/http_port $ProxyPort/g" /etc/squid/squid.conf
     service squid restart
     clear
     echo -e "$green Installation Complete! $default";;
  2) clear; echo -e "$green Installing $svr Specific Applications $default";
     apt update
     apt install -y bind9 bind9utils bind9-doc
     chmod 775 /etc/bind
     cp -r rootdns/bind/* /etc/bind
     cp -r rootdns/scripts /root/
     sed -i '/^OPTIONS/d' /etc/default/named
     echo "OPTIONS=\"-u bind -4\"" >> /etc/default/named
     echo "include \"/etc/bind/named.conf.OPFOR\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/named.conf.RANGE\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/named.conf.TRAFFIC\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/blackhole/rangism.zones\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/rndc.key\";" >> /etc/bind/named.conf
     service bind9 restart
     clear
     echo -e "$green Installation Complete! $default";;
  3) clear; echo -e "$green Installing $svr Specific Applications $default";
     cp -r ca /root
     cd /root/ca
     mv /root/ca/scripts /root/
     mkdir newcerts certs crl private requests
     touch index.txt
     touch index.txt.attr
     echo '1000' > serial
     sed -i "s/DOMAINNAME/$CA/g" openssl_root.cnf
     openssl genrsa -aes256 -out private/ca.$CA.key.pem -passout pass:$capempass 4096
     openssl req -config openssl_root.cnf -new -x509 -sha512 -extensions v3_ca -key /root/ca/private/ca.$CA.key.pem -out /root/ca/certs/ca.$CA.crt.pem -days 3650 -set_serial 0 -passin pass:$capempass -subj "/C=$cac/ST=$cast/L=$cal/O=$cao/OU=$caou/CN=ca.$CA"
     mkdir -p /root/ca/intermediate
     cd /root/ca/intermediate
     mkdir certs newcerts crl csr private
     touch index.txt
     touch index.txt.attr
     echo 1000 > /root/ca/intermediate/crlnumber
     echo '1234' > serial
     sed -i "s/DOMAINNAME/$CA/g" openssl_intermediate.cnf
     cd /root/ca
     openssl req -config /root/ca/intermediate/openssl_intermediate.cnf -new -newkey rsa:4096 -keyout /root/ca/intermediate/private/int.$CA.key.pem -out /root/ca/intermediate/csr/int.$CA.csr -passout pass:$capempass -subj "/C=$cac/ST=$cast/L=$cal/O=$cao/OU=$caou/CN=int.$CA"
     openssl ca -batch -config /root/ca/openssl_root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha512 -in /root/ca/intermediate/csr/int.$CA.csr -out /root/ca/intermediate/certs/int.$CA.crt.pem -passin pass:$capempass
     cat intermediate/certs/int.$CA.crt.pem certs/ca.$CA.crt.pem > intermediate/certs/chain.$CA.crt.pem
     mkdir -p /var/www
     mkdir -p /var/www/html
     chmod 755 /root/scripts/*.sh
     sed -i "s/CAPASSWORD/$capempass/g" /root/scripts/*.sh
     sed -i "s/CADOMAINNAME/$CA/g" /root/scripts/*.sh
     clear
     echo -e "$green Installation Complete! $default";;
  4) clear
     echo -e "$green Setting up Webservices VM $default"
     cp -r webservices/owncloud /root
     mkdir -p /root/owncloud/SSL
     cp -r webservices/pastebin /root
     mkdir -p /root/pastebin/SSL
     cp -r webservices/redbook /root
     mkdir -p /root/redbook/SSL
     cp -r webservices/drawio /root
     mkdir -p /root/drawio/SSL
     cp -r webservices/ms_sites /root
     mkdir -p /root/ms_sites/SSL
     cp -r webservices/ntp /root
     cp -r webservices/scripts /root
     mkdir -p /root/backups
     mkdir -p /root/backups/redbook
     mkdir -p /root/backups/dropbox
     echo -e "$green Pulling SSL certs for dropbox.com, pastebin.com, diagams.net, redbook.com, and msftconnecttest.com $default"
     sleep 2
     existingcerts=`sshpass -p $CAPass ssh -o StrictHostKeyChecking=no 180.1.1.50 'ls /var/www/html'`
     if echo $existingcerts | grep dropbox.com.crt > /dev/null; then
       echo "dropbox.com certs exists, skipping creation"
     else
       sshpass -p $CAPass ssh 180.1.1.50 "/root/scripts/certmaker.sh -q -d dropbox.com -C US -ST 'New York' -L 'New York City' -O 'Dropbox,inc' -CN dropbox.com -A dropbox -DNS1 www.dropbox.com -DNS2 dropbox.com"
     fi
     if echo $existingcerts | grep pastebin.com.crt > /dev/null; then
       echo "pastebin.com certs exists, skipping creation"
     else
       sshpass -p $CAPass ssh 180.1.1.50 "/root/scripts/certmaker.sh -q -d pastebin.com -C US -ST Utah -L Provo -O PasteBin -CN pastebin.com -A pastebin -DNS1 www.pastebin.com -DNS2 pastebin.com"
     fi
     if echo $existingcerts | grep redbook.com.crt > /dev/null; then
       echo "redbook.com certs exists, skipping creation"
     else
       sshpass -p $CAPass ssh 180.1.1.50 "/root/scripts/certmaker.sh -q -d redbook.com -C US -ST Hawaii -L 'big Island' -O 'things corp' -CN redbook.com -A redbook -DNS1 www.redbook.com -DNS2 redbook.com"
     fi
     if echo $existingcerts | grep diagrams.net.crt > /dev/null; then
       echo "diagrams.net certs exists, skipping creation"
     else
       sshpass -p $CAPass ssh 180.1.1.50 "/root/scripts/certmaker.sh -q -d diagrams.net -C US -ST Idaho -L Boise -O 'draw corp' -CN diagrams.net -A diagrams -DNS1 diagrams.net -DNS2 embed.diagrams.net -DNS3 log.diagrams.net"
     fi
     if echo $existingcerts | grep msftconnecttest.com.crt > /dev/null; then
       echo "msftconnecttest.com certs exists, skipping creation"
     else
       sshpass -p $CAPass ssh 180.1.1.50 "/root/scripts/certmaker.sh -q -d msftconnecttest.com -C US -ST Washington -L Redmond -O 'Microsoft corp' -CN msftconnecttest.com -A msftconnecttest -DNS1 www.msftconnecttest.com -DNS2 msftncsi.com -DNS3 www.msftncsi.com"
     fi
     sshpass -p $CAPass scp -r 180.1.1.50:/var/www/html/dropbox* /root/owncloud/SSL/
     sshpass -p $CAPass scp -r 180.1.1.50:/var/www/html/pastebin* /root/pastebin/SSL/
     sshpass -p $CAPass scp -r 180.1.1.50:/var/www/html/redbook* /root/redbook/SSL/
     sshpass -p $CAPass scp -r 180.1.1.50:/var/www/html/diagrams* /root/drawio/SSL/
     sshpass -p $CAPass scp -r 180.1.1.50:/var/www/html/msftconnecttest* /root/ms_sites/SSL/
     clear 
     echo -e "$green Setting up NTP server $default"
     sleep 2
     cd /root/ntp
     docker-compose up -d
     clear
     echo -e "$green Setting up Microsoft online connection test sites $default"
     cd /root/ms_sites
     docker-compose up -d
     clear
     echo -e "$green Setting up owncloud server $default"
     sleep 2
     cd /root/owncloud
     docker-compose up -d
     clear
     echo -e "$green Setting up pastebin server $default"
     sleep 2
     cd /root/pastebin
     docker-compose up --build -d
     clear
     echo -e "$green Setting up Redbook server $default"
     sleep 2
     cd /root/redbook
     docker-compose up -d
     clear
     echo -e "$green Setting up diagrams.net server $default"
     sleep 2
     cd /root/drawio
     docker-compose up -d
     clear
     echo -e "$green Setting up backup automation for Bookstack and Owncloud $default"
     crontab -l > cronjbs
     echo "0 1 * * 1 /root/scripts/redbook/redbook_backup.sh" >> cronjbs
     echo "0 2 * * 1 ls /root/backups/redbook/ -t | tail -n +4 | xargs rm -- 2>/dev/null" >> cronjbs
     echo "0 3 * * 1 /root/scripts/dropbox/dropbox_backup.sh" >> cronjbs
     echo "0 4 * * 1 ls /root/backups/dropbox/ -t | tail -n +4 | xargs rm -- 2>/dev/null" >> cronjbs
     crontab cronjbs
     rm cronjbs
     clear
     echo -e "$green Setting up Bookstack and populating it with the Cyber Range documentation $default"
     mv /root/redbook/CRoriginal.tar.gz /root/backups/redbook
     /root/scripts/redbook/restore_redbook.sh CRoriginal.tar.gz
     clear
     echo -e "$green Installation Complete! $default";;


  5) clear; echo -e "$green Installing $srv Specific Applications $default"
     cp -r rts/scripts /root
     cp -r rts/backbonerouters /root
     cp -r rts/Profiles /root
     sed -i "s/= 'i'/= 'a'/g" /etc/needrestart/needrestart.conf
     sed -i "s/#\$nrconf{re/\$nrconf{re/g" /etc/needrestart/needrestart.conf
     sed -i "s/^intname=.*/intname=\"$gnic\"/g" /root/scripts/buildredteam.sh
     sed -i "s/^CAserver=.*/CAserver=\"$caip\"/g" /root/scripts/buildredteam.sh
     sed -i "s/^CAcert=.*/CAcert=\"int.$CA.crt.pem\"/g" /root/scripts/buildredteam.sh
     apt install -y openjdk-11-jdk
     update-java-alternatives -s java-1.11.0-openjdk-amd64
     echo -e "$green Grabbing Cobalt Strike $default"
     InstallCS="n"
     while :
     do
       echo -ne "$ltblue\t Please enter your Cobalt Strike License (c to cancel): $default"
       read csl
       if [[ $csl = @(c|C) ]]; then break; fi
       export TOKEN=$(curl -s https://download.cobaltstrike.com/download -d "dlkey=${csl}" | grep 'href="/downloads/' | cut -d '/' -f3) 
       if [ ! -z $TOKEN ]; then
         InstallCS="y"
	 break
       else 
         echo -e "$red ERROR! $white Key entered is invalid, Please try again. $default"
         sleep 2
         clear
       fi
    done
     if [ $InstallCS = "y" ]; then 
       echo -e "$green Cobalt Strike License accepted! $default"
       cd /root
       wget https://download.cobaltstrike.com/downloads/${TOKEN}/latest46/cobaltstrike-dist.tgz
       tar -zxf cobaltstrike-dist.tgz
       rm cobaltstrike-dist.tgz
       mv cobaltstrike cobaltstrike-local
       sed -i "s/^java/java -Dhttp.proxyHost=$ProxyIP -Dhttp.proxyPort=$ProxyPort -Dhttps.proxyHost=$ProxyIP -Dhttps.proxyPort=$ProxyPort/g" /root/cobaltstrike-local/update
       cd /root/cobaltstrike-local
       echo -e "$green Updating Cobalt Strike. NOTE: It will ask for your license again, but you won't need to enter it. $default"
       sleep 2
       echo ${csl} | ./update
       sleep 2
     else
       echo -e "$yellow Cobalt Strike install cancelled! $default"
       sleep 2
     fi 
     cd /root
     echo -e "$green Grabbing C2concealer $default"
     export http_proxy=$Proxy
     export https_proxy=$Proxy
     apt install -y mutt python3-pip golang
     cd /root
     git clone https://github.com/FortyNorthSecurity/C2concealer
     cd C2concealer
     ./install.sh
     cd /root
     echo -e "$green Grabbing SourcePoint $default"
     git clone https://github.com/Tylous/SourcePoint
     cd /root/SourcePoint
     go build SourcePoint.go
     echo -e "$green Pulling docker images $default"
     docker pull nginx
     docker pull haproxy
     docker pull httpd
     if [ $InstallCS = "y" ]; then 
       echo "FROM ubuntu" > /root/Dockerfile
       echo "ENV http_proxy $Proxy" >> /root/Dockerfile
       echo "ENV https_proxy $Proxy" >> /root/Dockerfile
       echo "USER root" >> /root/Dockerfile
       echo "RUN apt update && apt install --no-install-recommends -y openjdk-11-jdk && \ " >> /root/Dockerfile
       echo "    apt clean && rm -rf /var/local/apt/lists/* /tmp/* /var/tmp/*" >> /root/Dockerfile
       echo "RUN update-java-alternatives -s java-1.11.0-openjdk-amd64" >> /root/Dockerfile
       docker build -t cobaltstrike /root
     fi
     debconf-set-selections <<< "postfix postfix/mailname string rts"
     debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
     apt install --assume-yes postfix
     ssh-keygen -b 1024 -t rsa -f /root/.ssh/id_rsa -q -N ""
     sshpass -p $CAPass ssh-copy-id -o StrictHostKeyChecking=no 180.1.1.50
     sshpass -p $DNSPass ssh-copy-id -o StrictHostKeyChecking=no 198.41.0.4
     clear
     echo -e "$green Installation Complete! $default";;
  6) clear
     echo -e "$green Setting up External SMTP Traffic Gen $default"
     sleep 2
     cp -r trafficgen/* /root/
     cd /root
     docker build -t emailgen .
     clear
     echo -e "$green Installation Complete! $default";;
  7) clear 
     echo -e "$green Setting up Traffic Web Host server $default"
     sleep 2
     apt update
     apt install -y apache2
     a2enmod ssl
     echo -e "$green Downloading websites now, this will take a bit, approx 1,1GB download. $default"
     wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1__Z5LllzuOA_HnVA6YsC47toHsmEo99d' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1__Z5LllzuOA_HnVA6YsC47toHsmEo99d" -O trafficsites.tar.gz && rm -rf /tmp/cookies.txt
     echo -e "$green Download complete, extracting sites. $default"
     sleep 2
     tar -zxvf trafficsites.tar.gz -C /var/www/html
     rm /var/www/html/index.html
     mv /var/www/html/websites.txt /tmp/

     sshpass -p $CAPass ssh -o StrictHostKeyChecking=no root@180.1.1.50 'echo prepping CA connection'
     echo -e "auto lo\niface lo inet loopback\n\nauto $anic\niface $anic inet dhcp" > /etc/network/interfaces
     # Seperate website list into the following;
     #   domains (for registing with rootDNS and configuring virtual host on apache)
     #   ips (for assigning IPS to traffic-WebHost VM)
     #   routes (to add to the SI_router via script)
     routes=`cut -d, -f2 /tmp/websites.txt | cut -d. -f1-3 | sort -t . -k 1,1n -k 2,2n -k 3,3n | uniq`
     ips=`cut -d, -f2 /tmp/websites.txt | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | uniq`
     domains=`cut -d, -f1 /tmp/websites.txt | sort | uniq`
     echo -e "$green Configuring IPs. $default"
     # Configure /etc/network/interfaces
     count=0
     # set all IPs as /24 networks.
     cidr=24
     for ip in $ips
     do
       if [[ $count == 0 ]]; then
         echo -e "\nauto $gnic\niface $gnic inet static\n\taddress $ip/$cidr" >> /etc/network/interfaces
         first3octets=`echo $ip | cut -d. -f1,2,3`
         gw="$first3octets.1"
         echo -e "\tgateway $gw" >> /etc/network/interfaces
         count=1
       else
         echo -e "\nauto $gnic:$count\niface $gnic:$count inet static\n\taddress $ip/$cidr" >> /etc/network/interfaces
         let count++
       fi
     done
     # Build script for SI_router for all webhost IPs.
     echo -e "$green Configuring routes for the SI_router. $default"
     echo "#!/bin/vbash" > /tmp/Eth1TrafficWebHosts.sh
     echo "source /opt/vyatta/etc/functions/script-template" >> /tmp/Eth1TrafficWebHosts.sh
     echo "configure" >> /tmp/Eth1TrafficWebHosts.sh
     chmod 755 /tmp/Eth1TrafficWebHosts.sh
     for subnet in $routes
     do
       echo "set interfaces ethernet eth1 address $subnet.1/24" >> /tmp/Eth1TrafficWebHosts.sh
     done
     echo "commit" >> /tmp/Eth1TrafficWebHosts.sh
     echo "save" >> /tmp/Eth1TrafficWebHosts.sh
     echo "exit" >> /tmp/Eth1TrafficWebHosts.sh
     # Copy script to SI_Router and run it
     sshpass -p $SIPass scp -o StrictHostKeyChecking=no /tmp/Eth1TrafficWebHosts.sh vyos@172.30.7.254:/home/vyos/Scripts/
     sshpass -p $SIPass ssh -o StrictHostKeyChecking=no vyos@172.30.7.254 '/home/vyos/Scripts/Eth1TrafficWebHosts.sh'
     echo -e "$green Configure Apache Web server and Generate SSL Certs via the CA-Server. $default"     
     # Configure Apache webserver
     httpconf="TG_HTTP.conf"
     httpsconf="TG_HTTPS.conf"
     echo "" > $httpconf
     echo "" > $httpsconf
     for domain in $domains
     do 
       tld=`echo $domain | sed 's/www.//g'`
       # configure HTTP
       echo "<VirtualHost *:80>" >> $httpconf
       echo "    ServerAdmin webmaster@$tld" >> $httpconf
       echo "    ServerName $tld" >> $httpconf
       echo "    ServerAlias www.$tld" >> $httpconf
#       echo "    ServerAlias $ip" >> $httpconf
       echo "    DocumentRoot /var/www/html/$tld" >> $httpconf
       echo "    ErrorLog \${APACHE_LOG_DIR}/error.log" >> $httpconf
       echo "    CustomLog \${APACHE_LOG_DIR}/access.log combined" >> $httpconf
       echo "</VirtualHost>" >> $httpconf
       # configure HTTPS
       echo "<VirtualHost *:443>" >> $httpsconf
       echo "    ServerName \"$tld\"" >> $httpsconf
       echo "    ServerAlias \"www.$tld\"" >> $httpsconf
#       echo "    ServerAlias $ip" >> $httpsconf
       echo "    ServerAdmin webmaster@$tld" >> $httpsconf
       echo "    DocumentRoot /var/www/html/$tld" >> $httpsconf
       echo "    ErrorLog \${APACHE_LOG_DIR}/error.log" >> $httpsconf
       echo "    CustomLog \${APACHE_LOG_DIR}/access.log combined" >> $httpsconf
       echo "    SSLEngine on" >> $httpsconf
       echo "    SSLCertificateFile /etc/ssl/certs/$tld.crt" >> $httpsconf
       echo "    SSLCertificateKeyFile /etc/ssl/private/$tld.key" >> $httpsconf
       echo "</VirtualHost>" >> $httpsconf
       # Get SSL Cert
       sshpass -p $CAPass ssh root@180.1.1.50 "/root/scripts/certmaker.sh -d $tld -q -r"
       sshpass -p $CAPass scp root@180.1.1.50:/var/www/html/$tld.crt /etc/ssl/certs/
       sshpass -p $CAPass scp root@180.1.1.50:/var/www/html/$tld.key /etc/ssl/private/
     done
     mv $httpconf /etc/apache2/sites-available/
     mv $httpsconf /etc/apache2/sites-available/
     a2ensite $httpconf
     a2ensite $httpsconf
     ip addr flush $anic
     ip addr flush $gnic
     service networking restart
     systemctl reload apache2
     clear
     echo -e "$green Register Domains on RootDNS server. $default"
     sshpass -p $DNSPass scp -o StrictHostKeyChecking=no /tmp/websites.txt 198.41.0.4:/root/scripts/
     sshpass -p $DNSPass ssh -o StrictHostKeyChecking=no 198.41.0.4 '/root/scripts/add-TRAFFIC-DNS.sh /root/scripts/websites.txt'
     echo -e "$green Installation Complete! $default";;
esac
