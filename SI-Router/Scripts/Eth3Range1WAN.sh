#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth3 address 1.1.1.1/29
set interfaces ethernet eth3 duplex auto
set interfaces ethernet eth3 speed auto 
commit
exit
