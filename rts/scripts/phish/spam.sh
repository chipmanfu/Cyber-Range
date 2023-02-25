#!/bin/bash
# Example spaming script.

# set .muttrc file
echo 'set edit_headers=yes' > /root/.muttrc 
echo 'set from = "toteslegit@domain.com"' >> /root/.muttrc
echo 'set realname = "Toteslegit Admin"' >> /root/.muttrc

# NOTE: you need to make an email body message and save it as body.txt in the root folder
# NOTE: if you had an attachment then add that to the /root/phish directory.
while read p
do
  echo "" | mutt -s "Subject goes here" -i /root/scripts/phish/body.txt -a /root/scripts/phish/attachment.exe -- $p
done</root/scripts/phish/emaillist.txt


