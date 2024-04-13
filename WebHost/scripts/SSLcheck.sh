#/bin/bash
# create log file if it doesn't exist
restart=0
ssl_log="/root/scripts/SSL_renewal.log"
caserver="180.1.1.50"
if [ ! -e $ssl_log ]; then
  touch $ssl_log
fi

today=`date +'%Y%m%d'` 
cd /etc/ssl/certs
declare -A month_map
month_map=( ["Jan"]="01" ["Feb"]="02" ["Mar"]="03" ["Apr"]="04" ["May"]="05" ["Jun"]="06" ["Jul"]="07" ["Aug"]="08" ["Sep"]="09" ["Oct"]="10" ["Nov"]="11" ["Dec"]="12" )
for x in `ls | grep .crt$`; do
  cexp=`openssl x509 -in $x -text -nout | grep -e "Not After" | awk {'print$7","$4","$5'}`
  cyear=`echo $cexp | cut -d, -f1`
  cmonth=`echo $cexp | cut -d, -f2`
  cday=`echo $cexp | cut -d, -f3`
  cmon=${month_map[$cmonth]}
  expiredate=$cyear$cmon$cday
  if [ $today -ge $expiredate ]; then
    echo "$x expired on $expiredate renewed on $today" >> $ssl_log
    # remove old cert.
    rm /etc/ssl/certs/$x
    # pull domain name from the cert name
    domain=`echo $x | rev | cut -d.  -f2- | rev`
    # remove index of previous SSL cert.
    ssh -v $caserver "sed -i \"/$domain$/d\" /root/ca/intermediate/index.txt"
    # Generate new cert using old key and CSR
    ssh -v $caserver "openssl ca -config /root/ca/intermediate/openssl_intermediate.cnf -extensions server_cert -days 825 -notext -md sha512 -in /root/ca/intermediate/csr/$domain.csr -out /root/ca/intermediate/certs/$domain.crt -passin pass:password -batch" 
    # Copy new cert to server
    scp $caserver:/root/ca/intermediate/certs/$domain.crt /etc/ssl/certs
    restart=1
  fi
done
if [ $restart == 1 ]; then
  service apache2 restart
fi

