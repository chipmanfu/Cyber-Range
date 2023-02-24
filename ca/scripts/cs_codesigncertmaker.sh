#!/bin/bash
domain=
while true; do
  case "$1" in
   -h|--help)
       echo -e "\nREQUIRED Flags"
       echo -e "\t-d or --domain FQDN,  ex. -d www.example.com"
       exit 0;;
   -d|--domain)
       domain="$2"
       shift 2;;
      *) shift 2
        break;;
   esac
done
if [[ $domain == "" ]]; then
  echo "Exitting.. Domain flag must be set, use -h to see usage"
  exit 0
fi

echo "Code Signing Certificate will be created with the following settings:"
echo "                 domain: $domain"
echo ""
echo " Press <enter> to continue, or any key to cancel"
read ans
if [[ $ans != "" ]]; then 
  exit
fi 
cat > /tmp/cs.cnf <<- EOM
[ req ]
default_bits		= 4096
encrypt_key		= yes
default_md		= sha256
utf8			= yes
string_mask		= utf8only
prompt			= yes 
distinguished_name	= codesign_dn
req_extensions		= codesign_reqext
[ codesign_dn ]
commonName		= $DN
commonName_max		= 64
[ codesign_reqext ]
keyUsage		= critical,digitalSignature
extendedKeyUsage	= critical,codeSigning
subjectKeyIdentifier	= hash
EOM

openssl req -out /root/ca/intermediate/csr/cs.$domain.csr -newkey rsa:4096 -nodes -keyout /root/ca/intermediate/private/cs.$domain.key -config /tmp/cs.cnf

openssl ca -config /root/ca/intermediate/openssl_intermediate.cnf -extensions server_cert -days 825 -notext -md sha512 -in /root/ca/intermediate/csr/cs.$domain.csr -out /root/ca/intermediate/certs/cs.$domain.crt -passin pass:CAPASSWORD -batch

openssl pkcs12 -inkey /root/ca/intermediate/private/cs.$domain.key -in /root/ca/intermediate/certs/cs.$domain.crt -export -chain -CAfile /root/ca/intermediate/certs/chain.trustme.crt.pem -out /root/ca/intermediate/certs/cs.$domain.p12 -passout pass:CAPASSWORD

cp /root/ca/intermediate/certs/cs.$domain.p12 /var/www/html

echo "New Certs created, scp them to the system you will use them on" 
echo "scp /var/www/html/cs.$domain.p12 <yourSystemIP>:/root/"

