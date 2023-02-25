#!/bin/bash
clear

# Proxy settings for the Range if you change these, make sure the Proxy, ProxyIP, and ProxyPort all line up.
Proxy="http://172.30.0.2:9999"
ProxyIP="172.30.0.2"
ProxyPort="9999"
# Certificate Authority Variables
CA="globalcert.com"
cac="US"                 	# Country for cert
cast="Oregon"			# State for cert
cal="Seattle"			# Locality (city)
cao="Global Certificates, Inc"	# Organization
caou="Root Cert"		# Organizational unit
capempass="password"

# Cobalt Strike License
csl="008c-c31c-e321-0001"

# Network Interfaces for various builds.
# IA Proxy IP settings
iapnic1="172.30.0.2/21"
iapnic2="dhcp"
# Root DNS IP Settings
rootdnsnic1="dhcp"
rootdnsnic2="8.8.8.8/24
             198.41.0.4/24  
             192.228.79.59/24 
             192.33.4.12/24 
             128.8.10.90/24 
             192.203.230.10/24 
             195.5.5.241/24 
             192.112.36.4/24
             128.63.2.53/24 
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
# Traffic Gen
trafnic1="dhcp"
# Web host
webhostnic1="dhcp"

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
  echo -e "\t$ltblue 1)$white IA Proxy"
  echo -e "\t$ltblue 2)$white RootDNS"
  echo -e "\t$ltblue 3)$white CA Server"
  echo -e "\t$ltblue 4)$white RTS"
  echo -e "\t$ltblue 5)$white Web Services"
  echo -e "\t$ltblue 6)$white Traffic Gen"
  echo -e "\t$ltblue 7)$white Web Traffic Host"
  echo -e "\t$ltblue q)$white Exit script"
  echo -ne "\n\t$ltblue Enter a Selection: $default"
  read answer
  case $answer in 
	  1) srv="IA Proxy"; opt=1; needdocker=n;;
	  2) srv="RootDNS"; opt=2; needdocker=n;;
	  3) srv="CA Server"; opt=3; needdocker=n;;
	  4) srv="NRTS"; opt=4; needdocker=y;;
	  5) srv="Web Services"; opt=5; needdocker=y;;
	  6) srv="Traffic Gen"; opt=6; needdocker=y;;
	  7) srv="Web Traffic Host"; opt=7; needdocker=y;;
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
	# Set up wget to use real internet proxy
        if grep ^use_proxy /etc/wgetrc; then
           sed -i '/^user_proxy/d' /etc wgetrc
        fi
        echo "use_proxy=yes" >> /etc/wgetrc	
        if grep ^http_proxy /etc/wgetrc; then
           sed -i '/^http_proxy/d' /etc/wgetrc
        fi
        echo "http_proxy=$Proxy" >> /etc/wgetrc
        if grep ^https_proxy /etc/wgetrc; then
          sed -i '/^https_proxy/d' /etc/wgetrc
        fi
        echo "https_proxy=$Proxy" >> /etc/wgetrc
	# Set up Apt to use real internet proxy
	echo "Acquire::http::Proxy \"$Proxy\";" > /etc/apt/apt.conf.d/proxy.conf
	echo "Acquire::https::Proxy \"$Proxy\";" >> /etc/apt/apt.conf.d/proxy.conf
fi

echo -e "$green Changings some environment settings $default"
sleep 2
echo "colo industry" > /root/.vimrc
echo 'LS_COLORS=$LSCOLORS:"di=96:"; export LS_COLORS' >> /root/.bashrc
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
mkdir /etc/update-motd.d/originals
mv /etc/update-motd.d/* /etc/update-motd.d/originals 2</dev/null

echo "#!/bin/bash" > /etc/update-motd.d/00-header
echo "echo 'Welcome to the'" >> /etc/update-motd.d/00-header
echo "figlet $servername" >> /etc/update-motd.d/00-header
clear
echo -e "$green Removing unncessary applications $default"
sleep 2
apt --purge remove -y cloud-* unattended-upgrades open-iscsi multipath-tools snapd nplan netplan.io
apt autoremove -y
rm -fr /root/snap
clear
echo -e "$green Disabling unnecssary services $default"
systemctl stop systemd-resolve.service systemd-timesyncd.service
systemctl disable system-resolve.service systemd-timesyncd.service
systemctl mask system-resolve.service systemd-timesyncd.service
rm /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
clear
echo -e "$green Installing needed applications $default"
sleep 2
apt install -y ifupdown net-tools curl make figlet ipcalc traceroute dos2unix
if [[ $needdocker == "y" ]]; then
  apt install -y ca-certificates gnupg
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
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
  if greo -q "^export https_proxy" /etc/default/docker; then
    sed -i '/export https_proxy/d' /etc/default/docker
  fi
  echo "export http_proxy=\"$Proxy\"" >> /etc/default/docker
  echo "export https_proxy=\"$Proxy\"" >> /etc/default/docker
  systemctl daemon-reload
  systemctl restart docker
fi
clear
gw=
case $opt in
  1) echo -e "$green Setting interfaces for the IA Proxy $default"
     nic1=$iapnic1; nic2=$iapnic2;;
  2) echo -e "$green Setting interfaces for the RootDNS $default"
     nic1=$rootdnsnic1; nic2=$rootdnsnic2; gw=$rootdnsgw;;
  3) echo -e "$green Setting interfaces for the CA Server $default"
     nic1=$canic1; nic2=$canic2; gw=$cagw;;
  4) echo -e "$green Setting interfaces for the RTS $default"
     nic1=$rtsnic1; nic2=$rtsnic2; gw=$rtsgw;;
  5) echo -e "$green Setting interfaces for the Web Services Server $default"
     nic1=$webnic1; nic2=$webnic2;;
  6) echo -e "$green Setting interfaces for the Traffic Gen Server $default"
     nic1=trafnic1; nic2=trafnic2;;
  7) echo -e "$green Setting interfaces for the Web Traffic Host Server $default"
     nic1=$webhostnic1; nic2=$webhostnic2;;
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
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher.service systemd-networkd-wait-online
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher.service systemd-networkd-wait-online
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher.service systemd-networkd-wait-online
systemctl unmask networking
systemctl enable networking
service networking stop
ip addr flush $anic
ip addr flush $gnic
service networking start
case $opt in 
  1) clear; echo -e "$green Installing $svr Specific Applications $default";
     
     apt install -y squid
     mv /etc/squid/squid.conf /etc/squid/squidmanual.txt 
     grep -v "^#" /etc/squid/squidmanual.txt | grep -v "^$" > /etc/squid/squid.conf
     sed -i '/^acl localnet/d' /etc/squid/squid.conf
     echo -e "acl localnet src 172.30.0.0/21\n$(cat /etc/squid/squid.conf)" > /etc/squid/squid.conf
     sed -i 's/http_access allow localhost/http_access allow localnet/g' /etc/squid/squid.conf
     service squid restart;;
  2) clear; echo -e "$green Installing $svr Specific Applications $default";
     apt update
     apt install -y bind9 bind9utils bind9-doc
     chmod 775 /etc/bind
     mkdir -p /etc/bind/RANGE
     mkdir -p /etc/bind/OPFOR
     mkdir -p /etc/bind/TRAFFIC
     cp -r rootdns/blackhole /etc/bind
     cp -r rootdsn/scripts /root/
     cp rootdns/db.* /etc/bind/RANGE
     cp rootdns/named.conf.* /etc/bind
     sed -i '/^OPTIONS/d' /etc/default/named
     echo "OPTIONS=\"-u bind -4\"" >> /etc/default/named
     echo "include \"/etc/bind/named.conf.OPFOR\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/named.conf.RANGE\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/named.conf.TRAFFIC\";" >> /etc/bind/named.conf
     echo "include \"/etc/bind/rndc.key\";" >> /etc/bind/named.conf
     service bind9 restart;;
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
     sed -i "s/CADOMAINNAME/$CA/g" /root/scripts/*.sh;;
  4) clear; echo -e "$green Installing $srv Specific Applications $default"
     cp -r rts/scripts /root
     cp -r rts/backbonerouters /root
     cp -r rts/Profiles /root
     export TOKEN=$(curl -s https://download.cobaltstrike.com/download -d "dlkey=${csl}" | grep 'href="/downloads/' | cut -d '/' -f3) 
     cd /root/
     sed -i "s/^intname=.*/intname=\"$gnic\"/g" /root/scripts/buildredteam.sh
     sed -i "s/^CAserver=.*/CAServer=\"$caip\"/g" /root/scripts/buildredteam.sh
     sed -i "s/^CAcert=.*/CAcert=\"int.$CA.crt.pem\"/g" /root/scripts/buildredteam.sh
     wget https://download.cobaltstrike.com/downloads/${TOKEN}/latest46/cobaltstrike-dist.tgz
     tar -zxf cobaltstrike-dist.tgz
     mv cobaltstrike cobaltstrike-local
     sed -i "s/^java/java -Dhttp.proxyHost=$ProxyIP -Dhttp.proxyPort=$ProxyPort -Dhttps.proxyHost=$ProxyIP -Dhttps.proxyPort=$ProxyPort/g" /root/cobaltstrike-local/update
     echo ${csl} | /root/cobaltstrike-local/update
     export http_proxy=$Proxy
     export https_proxy=$Proxy
     apt install -y mutt python3-pip golang
     cd /root
     git clone https://github.com/FortyNorthSecurity/C2concealer
     cd C2concealer
     ./install.sh
     cd /root
     git clone https://github.com/Tylous/SourcePoint
     cd /root/SourcePoint
     go build SourcePoint.go
     docker pull nginx
     docker pull haproxy
     docker pull httpd
     echo "FROM ubuntu" > /root/Dockerfile
     echo "ENV http_proxy $Proxy" >> /root/Dockerfile
     echo "ENV https_proxy $Proxy" >> /root/Dockerfile
     echo "USER root" >> /root/Dockerfile
     echo "RUN apt update && apt install --no-install-recommends -y openjdk-11-jdk && \ " >> /root/Dockerfile
     echo "    apt clean && rm -rf /var/local/apt/lists/* /tmp/* /var/tmp/*" >> /root/Dockerfile
     echo "RUN update-java-alternatives -s java-1.11.0-openjdk-amd64" >> /root/Dockerfile
     docker build -t cobaltstrike /root
     apt install -y postfix;;
esac
