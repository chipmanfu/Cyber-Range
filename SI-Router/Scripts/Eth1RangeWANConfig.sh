#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
# example for setting up the routing for a blue space.  
set interfaces ethernet eth3 address 1.1.1.1/29
commit
save
exit
