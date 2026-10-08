#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure
# The follow sets up routing for the rootDNS server so it can mimic all root DNS servers as well as googles recursive DNS server.
# 8.8.8.8         (Google's Recursive DNS Server)
set interfaces ethernet eth2 address 8.8.8.1/24
# 198.41.0.4      (A.root-servers.net)
set interfaces ethernet eth2 address 198.41.0.1/24
# 170.247.170.2   (B.root-servers.net)
set interfaces ethernet eth2 address 170.247.170.1/24
# 192.33.4.12     (C.root-servers.net)
set interfaces ethernet eth2 address 192.33.4.1/24
# 199.7.91.13     (D.root-servers.net)
set interfaces ethernet eth2 address 199.7.91.1/24
# 192.203.230.10  (E.root-servers.net)
set interfaces ethernet eth2 address 192.203.230.1/24
# 192.5.5.241     (F.root-servers.net)
set interfaces ethernet eth2 address 192.5.5.1/24
# 192.112.36.4    (G.root-servers.net)
set interfaces ethernet eth2 address 192.112.36.1/24
# 198.97.190.53   (H.root-servers.net)
set interfaces ethernet eth2 address 198.97.190.1/24
# 192.36.148.17   (I.root-servers.net)
set interfaces ethernet eth2 address 192.36.148.1/24
# 192.58.128.30   (J.root-servers.net)
set interfaces ethernet eth2 address 192.58.128.1/24
# 193.0.14.129    (K.root-servers.net)
set interfaces ethernet eth2 address 193.0.14.1/24
# 199.7.83.42     (L.root-servers.net)
set interfaces ethernet eth2 address 199.7.83.1/24
# 202.12.27.33    (M.root-servers.net)
set interfaces ethernet eth2 address 202.12.27.1/24

# The following sets up routing for the Traffic-emailGen server
#  67.23.44.96  (salesforce.net)
set interfaces ethernet eth2 address 67.23.44.1/24
#70.32.91.153   (linkedln.com)
set interfaces ethernet eth2 address 70.32.91.1/24
#72.32.4.26     (msn.com)
set interfaces ethernet eth2 address 72.32.4.1/24
#92.107.127.12  (gmail.com)
set interfaces ethernet eth2 address 92.107.127.1/24
#188.65.120.83  (facebook.com)
set interfaces ethernet eth2 address 188.65.120.1/24

# The following sets up routing for additional servers like CA servers, webservices.
# Used by WebServices VM - for CA server, redbook documentation, and faking the microsoft online test websites.
set interfaces ethernet eth2 address 180.1.1.1/24














commit
save
exit
