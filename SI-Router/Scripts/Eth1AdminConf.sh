#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth1 address 172.30.7.254/24
set interfaces ethernet eth1 duplex auto
set interfaces ethernet eth1 speed auto 

commit
save
exit