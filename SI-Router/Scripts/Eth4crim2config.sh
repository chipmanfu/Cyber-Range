#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth4 address 9.9.10.49/29
set interfaces ethernet eth4 duplex auto
set interfaces ethernet eth4 speed auto 
commit
exit
