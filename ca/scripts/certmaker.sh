#!/bin/bash
domain=;C=;ST=;L=;O=;CN=;random=;quiet=
while true; do
  case "$1" in
   -h|--help)
       echo -e "\nREQUIRED Flags"
       echo -e "\t-d or --domain FQDN,  ex. -d www.example.com"
       echo -e "\t-r or --random, this will randomize Country, City, State, and organization info"
       echo -e "\t-q or --quiet, will built the certs without showing settings and asking for confirmation"
       echo -e "OPTIONAL Flags - random values will be used if not set"
       echo -e "\t-C or --country 2LetterAbbrv, ex. -C US"
       echo -e "\t-ST or --state  State, ex -ST 'New York' NOTE: single quotes need if spaces"
       echo -e "\t-L or --locality, ex -L 'New York City'"
       echo -e "\t-O or --organization, ex -O 'example LTD'"
       echo -e "\t-CN or --commonname, ex -CN 'www.example.com'"
       echo -e "\t-A or --alias, ex -A 'example-server'"
       echo -e "\t-DNS1 or --SAN1  Subject Alt Name 1"
       echo -e "\t-DNS2 or --SAN2  Subject Alt Name 2"
       echo -e "\t-DNS3 or --SAN3  Subject Alt Name 3"
       echo -e "\t-DNS4 or --SAN4  Subject Alt Name 4"
       exit 0;;
   -q|--quiet)
       quiet="yes"
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
  echo "Exitting.. Domain flag must be set, use -h to see usage"
  exit 0
fi
if [[ $random == "yes" ]]; then
  C="US"
  citystate=`shuf -n 1 /root/scripts/UScitystate.txt`
  ST=`echo $citystate | cut -d, -f2`
   L=`echo $citystate | cut -d, -f1`
echo "got here"
  companytype=`shuf -n 1 /root/scripts/companytype.txt`
  TLD=`echo $domain | awk -F. '{print $(NF-1)}'`
   O="$TLD $companytype"
   alias=$TLD
   CN=$domain
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
    addalias=""
  fi
fi
if [[ $quiet == "" ]]; then
  echo "Certificate will be created with the following settings:"
  echo "                 domain: $domain"
  echo "              C(county): $C"
  echo "              ST(State): $ST"
  echo "            L(Locality): $L"
  echo "        O(Organization): $O"
  echo "        CN(Common Name): $CN"  
  if [[ $alias != "" ]]; then echo "               A(alias): $alias"; fi
  if [[ $DNS1 != "" ]]; then echo "             DNS1(SAN1): $DNS1"; fi
  if [[ $DNS2 != "" ]]; then echo "             DNS2(SAN2): $DNS2"; fi
  if [[ $DNS3 != "" ]]; then echo "             DNS3(SAN3): $DNS3"; fi
  if [[ $DNS4 != "" ]]; then echo "             DNS4{SAN4): $DNS4"; fi
  echo ""
  echo " Press <enter> to continue, or any key to cancel"
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
openssl req -out /root/ca/intermediate/csr/$domain.csr -newkey rsa:2048 -nodes -keyout /root/ca/intermediate/private/$domain.key -config /tmp/san.cnf
#openssl req -out /root/ca/intermediate/csr/$domain.csr.pem -newkey rsa:2048 -nodes -keyout /root/ca/intermediate/private/$domain.key.pem -subj "/C=$C/ST=$ST/L=$L/O=$O/CN=$CN"

openssl ca -config /root/ca/intermediate/openssl_intermediate.cnf -extensions server_cert -days 825 -notext -md sha512 -in /root/ca/intermediate/csr/$domain.csr -out /root/ca/intermediate/certs/$domain.crt -passin pass:CAPASSWORD -batch

openssl pkcs12 -inkey /root/ca/intermediate/private/$domain.key -in /root/ca/intermediate/certs/$domain.crt -export -chain -CAfile /root/ca/intermediate/certs/chain.trustme.crt.pem -out /root/ca/intermediate/certs/$domain.p12 -passout pass:CAPASSWORD $addalias

cp /root/ca/intermediate/private/$domain.key /var/www/html
cp /root/ca/intermediate/certs/$domain.crt /var/www/html
cp /root/ca/intermediate/certs/$domain.p12 /var/www/html
if [[ $quiet == "" ]]; then
  echo "New Certs created, scp them to the system you will use them on" 
  echo "scp /var/www/html/$domain.key <yourSystemIP>:/root/"  
  echo "scp /var/www/html/$domain.crt <yourSystemIP>:/root/"
  echo "scp /var/www/html/$domain.p12 <yourSystemIP>:/root/"
fi
