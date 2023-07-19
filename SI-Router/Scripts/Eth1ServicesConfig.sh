#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth1 address 8.8.8.1/24
set interfaces ethernet eth1 address 180.1.1.1/24
set interfaces ethernet eth1 address 192.5.5.1/24
set interfaces ethernet eth1 address 192.33.4.1/24
set interfaces ethernet eth1 address 192.36.148.1/24
set interfaces ethernet eth1 address 192.58.128.1/24
set interfaces ethernet eth1 address 192.112.36.1/24
set interfaces ethernet eth1 address 192.203.230.1/24
set interfaces ethernet eth1 address 193.0.14.1/24
set interfaces ethernet eth1 address 198.41.0.1/24
set interfaces ethernet eth1 address 198.97.190.1/24
set interfaces ethernet eth1 address 199.7.83.1/24
set interfaces ethernet eth1 address 199.7.91.1/24
set interfaces ethernet eth1 address 199.9.14.1/24
set interfaces ethernet eth1 address 202.12.27.1/24

commit
save
exit
