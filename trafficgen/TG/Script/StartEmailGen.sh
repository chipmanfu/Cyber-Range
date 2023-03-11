#!/bin/bash
# Written by Chip McElvain
# External email traffic generator

# Set static variables.
senders="/content/Senders/senders.txt"
recps="/sendto/sendto.txt"
content="/content/Content/EmailContent.csv"
attmdir="/content/RandomFiles"
conffile="/etc/postfix/main.cf"

# Set some Defaults in case no arguments passed to the script.
timeint=60;jitter=50;maxto=4;maxattach=2;fqdn=

# Get passed arguments to adjust settings and get FQDN of email server to emulate.
while true; do
  case "$1" in
    -t|--timeint)
	    timeint="$2"
	    shift 2;;
    -j|--jitter)
	    jitter="$2"
	    shift 2;;
    -m|--maxto)
	    maxto="$2"
	    shift 2;;
    -a|--maxattach)
	    maxattach="$2"
	    shift 2;;
    -d|--domain)
	    fqdn="$2"
	    shift 2;;
    *) break;;
  esac
done

# Check if a domain was passed, if not exit.
if [ -z "$fqdn" ];
then 
	echo "Error, you must provide a FQDN using arg -d to use this"
	exit 0
fi

### Set up Postfix to emulate the domain selected and to blackhole all incoming emails.
# First, kill postfix if it's running
service postfix stop
# Edit the /etc/postfix/main.cf file, by removing the follow settings if they exist and adding 
# the ones we want back in.
sed -i '/^myorigin/d' $conffile
sed -i '/^myhostname/d' $conffile
sed -i '/^smtpd_banner/d' $conffile
sed -i '/^mydestination/d' $conffile
sed -i '/^virtual_alias_maps/d' $conffile
echo "myhostname=$fqdn" >> $conffile
echo "myorigin=/etc/mailname" >> $conffile
echo "smtpd_banner= \$myhostname Microsoft ESMTP Mail" >> $conffile
echo "mydestination= \$myhostname,localhost" >> $conffile
echo "virtual_alias_maps=hash:/etc/postfix/virtual_alias" >> $conffile

# Next, change the values in a few files
echo $fqdn > /etc/mailname
echo "mailer-daemon: postmaster" > /etc/aliases
echo "blackhole: /dev/null" >> /etc/aliases
echo "@$fqdn  blackhole@localhost" > /etc/postfix/virtual_alias
# Next, create postmap db's
postmap /etc/postfix/virtual_alias
newaliases
# Next, start posffix
service postfix start

# initiate log file
logfile="/content/TrafficLog/log_$fqdn"
datestart=`date "+%b-%d %H:%M"`
echo "$fqdn Email Traffic Generator started at $datestart" > $logfile
#### Next start the email traffic generator.
count=1
# Start inifinate loop of traffic Gen goodness
while :
do
  # Clear out attachment variable  
  muttattach=""
  # get list of email addresses to send to 
  numto=$(shuf -i 1-$maxto -n 1)
  sendtos=`shuf -n $numto $recps`
  sendlist=$( echo $sendtos | tr ' ' ';' )
  # Get email subject and body content 
  econtent=`shuf -n 1 $content`
  subject=$( echo "$econtent" | cut -d, -f1 )
  echo "$econtent" | cut -d, -f2 > body.txt
  # Get attachements to send if any
  attnum=$(shuf -i 0-$maxattach -n 1)
  if [ $attnum -gt 0 ];then 
    while IFS= read -r file;
    do
      muttattach="${muttattach} -a $file"
    done <<< `ls -d $attmdir/* | shuf -n $attnum`
  fi
  # Pick a email Sender
  sendfrom=`shuf -n 1 $senders`
  senderemail="$sendfrom@$fqdn"
  realname=$( echo $sendfrom | sed 's/\./ /' )  
  echo 'set edit_headers=yes' > /root/.muttrc
  echo 'set copy=no' >> /root/.muttrc
  echo 'set from = "'$senderemail'"' >> /root/.muttrc
  echo 'set realname = "'$realname'"' >> /root/.muttrc
  # send it!
  echo "" | mutt -s "$subject" -i body.txt $muttattach -- $sendlist
  #echo "mutt -s \"$subject\" -i body.txt $muttattach -- $sendlist"
  # log it!   
  datein=`date "+%b-%d %H:%M"`
  echo "email $count sent at $datein to $sendlist" >> $logfile
  let "count++"
  # Create time internal with jitter.  Sleep for that time before sending another email.
  lowrange=$(($timeint * $jitter / 100))
  sleep $(shuf -i $lowrange-$timeint -n 1)
done
