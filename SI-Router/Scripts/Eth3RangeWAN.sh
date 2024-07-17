#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth3 address 1.1.1.1/29
commit
save
exit
