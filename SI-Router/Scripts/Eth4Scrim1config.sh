#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth4 address 8.21.10.17/29
set interfaces ethernet eth4 duplex auto
set interfaces ethernet eth4 speed auto 
commit
exit
