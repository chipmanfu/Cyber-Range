#!/bin/bash
domain=;C=;ST=;L=;O=;CN=;random=;quiet=;codesign="yes"
white="\e[1;37m"
ltblue="\e[1;36m"
ltgray="\e[0;37m"
dkgray="\e[1;30m"
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
default="\e[0m"

while true; do
  case "$1" in
   -h|--help)
       clear
       echo -e "\n$ltblue The script will generate the following certs."
       echo -e "\t$white - Signed Server certs in crt, pem and P12 formats (yourdomain.crt, yourdomain.pem, yourdomain.p12)"
       echo -e "\t$white - Signed Code-Signing cert in P12 format naming convention (cs.yourdomain.p12)"
       echo -e "\n$ltblue REQUIRED Flags"
       echo -e "\t$white -d or --domain FQDN $ltgray  ex. -d www.example.com"
       echo -e "\t$white -r or --random $ltgray this will randomize Country, City, State, and organization info (required if optional flags not set)"
       echo -e "$ltblue OPTIONAL Flags - random values will be used if not set"
       echo -e "\t$white -q or --quiet $ltgray will built the certs without showing settings and asking for confirmation"
       echo -e "\t$white -NoCS or --NoCodeSigning $ltgray this will not create the codesigning certs"
       echo -e "\t$white -C or --country 2LetterAbbrv $ltgray ex. -C US"
       echo -e "\t$white -ST or --state  State $ltgray ex -ST 'New York' NOTE: single quotes need if spaces"
       echo -e "\t$white -L or --locality $ltgray ex -L 'New York City'"
       echo -e "\t$white -O or --organization $ltgray ex -O 'example LTD'"
       echo -e "\t$white -CN or --commonname $ltgray ex -CN 'www.example.com'"
       echo -e "\t$white -A or --alias $ltgray ex -A 'example-server'"
       echo -e "\t$white -DNS1 or --SAN1  $ltgray Subject Alt Name 1, ex docs.example.com"
       echo -e "\t$white -DNS2 or --SAN2  $ltgray Subject Alt Name 2, ex cdn.example.com"
       echo -e "\t$white -DNS3 or --SAN3  $ltgray Subject Alt Name 3, ex mail.example.com"
       echo -e "\t$white -DNS4 or --SAN4  $ltgray Subject Alt Name 4, ex files.example.com $default"
       exit 0;;
   -q|--quiet)
       quiet="yes"
       shift 1;;
   -NoCS|--NoCodeSigning)
       codesign="no"
       shift 1;;
   -r|--random) 
       random="yes"
       shift 1;;         
   -d|--domain)
       domain="$2"
       shift 2;;
   -C|--country)
       C="$2"
       shift 2;;
   -ST|--state)
       ST="$2"
       shift 2;;
   -L|--locality)
        L="$2"
	shift 2;;
   -O|--organization)
        O="$2"
	shift 2;;
   -CN|--commonname)
        CN="$2"
	shift 2;; 
   -DNS1|--SAN1)
	DNS1="$2"
	shift 2;;
   -DNS2|--SAN2)
	DNS2="$2"
	shift 2;;
   -DNS3|--SAN3)
	DNS3="$2"
	shift 2;;
   -DNS4|--SAN4)
	DNS4="$2"
	shift 2;;
   -A|--alias)
	alias="$2"
	shift 2;;
      *) shift 2
        break;;
   esac
done
if [[ $domain == "" ]]; then
  echo -e "$red Exitting.. $yellow Domain flag must be set, use -h to see usage $default"
  exit 0
fi
if [[ $random == "yes" ]]; then
  C="US"
  citystate=`shuf -n 1 /root/scripts/UScitystate.txt`
  ST=`echo $citystate | cut -d, -f2`
  L=`echo $citystate | cut -d, -f1`
  companytype=`shuf -n 1 /root/scripts/companytype.txt`
  TLD=`echo $domain | awk -F. '{print $(NF-1)"."$(NF)}'`
  TLD2=`echo $domain | awk -F. '{print $(NF-1)}'`
  O="$TLD2 $companytype"
  alias=$TLD
  addalias="-name $TLD"
  CN=$TLD
  DNS1="www.$TLD"
  DNS2=$TLD
else 
  if [[ $C != "" ]]; then
    if [[ ${#C} != 2 ]] || [[ "$C" =~ [^a-zA-Z] ]]; then
      echo "Exitting.. Country flag must be 2 Letter Abbr"
      exit 0
    fi
  else
    C=NY
  fi
  if [[ $ST == "" ]]; then
    ST="New York"
  fi
  if [[ $CN == "" ]]; then
    CN=$domain
  fi
  if [[ $alias != "" ]]; then
    addalias="-name \"$alias\" "
  else
    TLD=`echo $domain | awk -F. '{print $(NF-1)"."$(NF)}'`
    addalias="-name \"$TLD\" "
  fi
fi
months_ago=$(shuf -i 6-18 -n 1)
curyr=$(date +%Y)
curmon=$(date +%m)
curday=$(date +%d)
tmpyr=$(date -d "$curyr-$curmon-01 $months_ago months ago" +%Y)
tmpmon=$(date -d "$curyr-$curmon-01 $months_ago months ago" +%m)
if [[ $quiet == "" ]]; then
  clear
  echo -e "$green Certificate will be created with the following settings:"
  echo -e "$ltblue modified creation date: $tmpyr-$tmpmon-$curday"
  echo -e "$ltblue                 domain: $white $domain "
  echo -e "$ltblue              C(county): $white $C"
  echo -e "$ltblue              ST(State): $white $ST"
  echo -e "$ltblue            L(Locality): $white $L"
  echo -e "$ltblue        O(Organization): $white $O"
  if [[ $codesign == "yes" ]]; then
    echo -e "$ltblue        CN(Common Name): $white $CN  $ltblue and using $white $O $ltblue for the code-signing cert"  
  else
    echo -e "$ltblue        CN(Common Name): $white $CN"  
  fi 
  if [[ $alias != "" ]]; then echo -e "$ltblue               A(alias): $white $alias"; fi
  if [[ $DNS1 != "" ]]; then echo -e "$ltblue             DNS1(SAN1): $white $DNS1"; fi
  if [[ $DNS2 != "" ]]; then echo -e "$ltblue             DNS2(SAN2): $white $DNS2"; fi
  if [[ $DNS3 != "" ]]; then echo -e "$ltblue             DNS3(SAN3): $white $DNS3"; fi
  if [[ $DNS4 != "" ]]; then echo -e "$ltblue             DNS4{SAN4): $white $DNS4"; fi
  echo -e "\n$ltblue Press$green <enter>$ltblue to continue, or any key to cancel $default"
  read ans
  if [[ $ans != "" ]]; then 
    exit
  fi 
fi
echo "[ req ]" > /tmp/san.cnf
echo "default_bits	= 2048" >> /tmp/san.cnf
echo "prompt		= no" >> /tmp/san.cnf
echo "distinguished_name = req_distinguished_name" >> /tmp/san.cnf
if [[ $DNS1 != "" ]]; then
  echo "req_extensions 	= req_ext" >> /tmp/san.cnf
fi
echo "[ req_distinguished_name ]" >> /tmp/san.cnf
echo "countryName		= $C" >> /tmp/san.cnf
echo "stateOrProvinceName	= $ST" >> /tmp/san.cnf
echo "localityName		= $L" >> /tmp/san.cnf
echo "organizationName		= $O" >> /tmp/san.cnf
echo "commonName		= $CN" >> /tmp/san.cnf
if [[ $DNS1 != "" ]]; then
  echo "[ req_ext ]" >> /tmp/san.cnf
  echo "subjectAltName = @alt_names" >> /tmp/san.cnf
  echo "[alt_names]" >> /tmp/san.cnf
  echo "DNS.1	= $DNS1" >> /tmp/san.cnf
  if [[ $DNS2 != "" ]]; then
    echo "DNS.2	= $DNS2" >> /tmp/san.cnf
  fi
  if [[ $DNS3 != "" ]]; then
    echo "DNS.3	= $DNS3" >> /tmp/san.cnf
  fi
  if [[ $DNS4 != "" ]]; then
    echo "DNS.4 = $DNS4" >> /tmp/san.cnf
  fi
fi
date -s "$tmpyr-$tmpmon-$curday"
openssl req -out /root/ca/intermediate/csr/$domain.csr -newkey rsa:2048 -nodes -keyout /root/ca/intermediate/private/$domain.key -config /tmp/san.cnf
openssl ca -config /root/ca/intermediate/openssl_intermediate.cnf -extensions server_cert -days 825 -notext -md sha512 -in /root/ca/intermediate/csr/$domain.csr -out /root/ca/intermediate/certs/$domain.crt -passin pass:password -batch
openssl pkcs12 -inkey /root/ca/intermediate/private/$domain.key -in /root/ca/intermediate/certs/$domain.crt -export -chain -CAfile /root/ca/intermediate/certs/chain.globalcert.com.crt.pem -out /root/ca/intermediate/certs/$domain.p12 -passout pass:password $addalias

if [[ $codesign == "yes" ]]; then
  # Create config file for Code Signing Cert
  cat > /tmp/cs.cnf <<- EOM
[ req ]
default_bits		= 3072 
encrypt_key		= yes
default_md		= sha256
utf8			= yes
string_mask		= utf8only
prompt			= no
distinguished_name	= codesign_dn
req_extensions		= codesign_reqext
[ codesign_dn ]
countryName		= $C
stateOrProvinceName	= $ST
localityName		= $L
organizationName	= $CN
commonName		= $O
[ codesign_reqext ]
keyUsage		= critical,digitalSignature
extendedKeyUsage	= critical,codeSigning
subjectKeyIdentifier	= hash
EOM
  openssl req -out /root/ca/intermediate/csr/cs.$domain.csr -newkey rsa:2048 -nodes -keyout /root/ca/intermediate/private/cs.$domain.key -config /tmp/cs.cnf
  openssl ca -config /root/ca/intermediate/openssl_intermediate.cnf -days 825 -notext -md sha512 -in /root/ca/intermediate/csr/cs.$domain.csr -out /root/ca/intermediate/certs/cs.$domain.crt -passin pass:password -batch
  openssl pkcs12 -inkey /root/ca/intermediate/private/cs.$domain.key -in /root/ca/intermediate/certs/cs.$domain.crt -export -chain -CAfile /root/ca/intermediate/certs/chain.globalcert.com.crt.pem -out /root/ca/intermediate/certs/cs.$domain.p12 -passout pass:password $addalias
ntpdate pool.ntp.org
cp /root/ca/intermediate/certs/cs.$domain.p12 /var/www/html
fi
cp /root/ca/intermediate/private/$domain.key /var/www/html
cp /root/ca/intermediate/certs/$domain.crt /var/www/html
cp /root/ca/intermediate/certs/$domain.p12 /var/www/html
cp /root/ca/intermediate/certs/cs.$domain.p12 /var/www/html
cat /var/www/html/$domain.key /var/www/html/$domain.crt > /var/www/html/$domain.pem
if [[ $quiet == "" ]]; then
  echo -e "$green New Certs created, scp them to the system you will use them on" 
  echo -e "\t$white scp /var/www/html/$domain.key <yourSystemIP>:/root/"  
  echo -e "\t$white scp /var/www/html/$domain.crt <yourSystemIP>:/root/"
  echo -e "\t$white scp /var/www/html/$domain.p12 <yourSystemIP>:/root/"
  echo -e "\t$white scp /var/www/html/$domain.pem <yourSystemIP>:/root/$default"
  if [[ $codesign == "yes" ]]; then
    echo -e "$green Code Signing Cert for signing binaries for $domain is at"
    echo -e "\t$white scp /var/www/html/cs.$domain.p12 <yourSystemIP>:/root/$default"
  fi
fi
