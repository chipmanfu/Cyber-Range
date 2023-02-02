#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth0 address 172.30.7.254/24
set interfaces ethernet eth0 duplex auto
set interfaces ethernet eth0 speed auto 

commit
save
exit
