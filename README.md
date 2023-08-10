# CyberRange
The CyberRange is a project to create a simulated internet environment for Cyber training and exercises.  This environment has some built in features to help automate things for cyber threat emulation by handling things like IP assignment, DNS registration, Signed SSL cert generation for threat infrastructure systems like redirectors, Cobalt Strike teamservers, payload hosting and phishing attacks.  Additional consideration and features have been added to generate benign network traffic to improve realism.  

# The CyberRange Network Diagram
![CyberRange](https://github.com/chipmanfu/Cyber-Range/assets/50666533/c808bf4b-a025-42f0-af41-cf4eee4255b1)

This Github project provides the CyberRange systems shown above in the green box.  The blue box would be the target domains (aka blue space) environments that the end user would need to build and attach to the CyberRange envirnoment.  Once, you've installed the CyberRange, there will be a Bookstack website running on the Web-Services VM that contains all of the documentation regarding the CyberRange along with instructions on how to connect a target domain to this environment.

# CyberRange Key Features
- Geo-IP based Public IP routing - The SI-Router is configured to route around 1650 public IP subnets that represent Geo-locations around the world.
- Global DNS Registration - The RootDNS VM will emulate the real world Root DNS servers (A-root through M-root) as well as Googles Recurvise DNS server at 8.8.8.8.  This handles DNS for the environment and comes with scripts to allow users to register new DNS as well as some automation built in to OPFOR infastructure builds that can provide randomized DNS.
- Simulated Trusted Certificate Authority - The CA-Server VM will simulated a trusted CA.  This system also has scripts for user generated SSL certs that can be used for Web server authentication and/or SSL certs for signing binaries.  This system is also intergrated into the OPFOR infastructure automation and will create SSL certs for OPFOR Domains for any HTTPS C2, as well as provide a code-signing cert that will integrate into Cobalt Strikes teamserver.
- OPFOR Infastructure Automation - Then NRTS server is a customized Ubuntu server that can create various OPFOR infrastructure systems in docker contains.  Using a script called "buildredteam.sh", a user can quickly build out redirectors, payload host, Cobalt Strike Teamservers, and/or set up a phishing attack.  The script will automate IP assignments, DNS registration, and Obtaining CA signed SSL certs if required, then build out the service and configure this service and start it within a docker container.  Each NRTS you build can support running multiple OPFOR infastructure systems
- Simulated Internet File sharing service - The web-services VM runs an Owncloud instance in a docker container to simulate real world file hosting site like dropbox.  Owncloud supports WebDAV, and various APIs that enables OPFOR to utilized this for file exfil and/or payload hosting.
- Simulated Pastebin - The web-services VM additionally runs a dockerized hastebin instance.  This can be used by OPFOR to host code snipnets that can be called via https or http link.
- CyberRange Documenation - The web-services VM also hosts a dockerized bookstack instance that contains all of the CyberRange documenation.
- Real World NTP server emulation - The web-services VM hosts an NTP server that gets its time source from the IA-Proxy which in turn gets its time source from the real internet.  The RootDNS server will resolve real world NTP server domains such as time.windows.com, *.ntp.org, *.nist.gov, to this server to ensure your target domain systems are synced to real world time.
- 175 Hosted websites - The Traffic-WebHost VM runs an apache webserver that hosts 175 scrapped websites that can be used for traffic generation.  These sites are be build with SSL Certs that have been signed by the CA-Server to enable trusted SSL Certs for all of these sites.
- External SMTP Traffic Generator - The Traffic-EmailGen can generate emails and send these to your target domain users.
- Real World Internet Access - The CyberRange environment will build an internet access web proxy.  This allows enables access to the real internet for all of the CyberRange.

.
See the wiki for how to install.  
Once it's installed, there is a bookstack instance within the environment at www.redbook.com that contains detailed overviews and how to guides for using the environment.

