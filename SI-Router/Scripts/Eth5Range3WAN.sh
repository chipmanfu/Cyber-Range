#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
set interfaces ethernet eth5 address 3.3.3.1/29
set interfaces ethernet eth5 duplex auto
set interfaces ethernet eth5 speed auto 
commit
exit
