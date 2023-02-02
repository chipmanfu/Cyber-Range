#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth7 address 7.7.7.1/29
set interfaces ethernet eth7 duplex auto
set interfaces ethernet eth7 speed auto 
commit
exit
