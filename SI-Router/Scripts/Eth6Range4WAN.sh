#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth6 address 6.6.6.1/29
set interfaces ethernet eth6 duplex auto
set interfaces ethernet eth6 speed auto 
commit
exit
