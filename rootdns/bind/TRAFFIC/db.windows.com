; Windows NTP server -points to CyberRange NTP server on the webservices VM
$TTL	86400
@	IN	SOA	@	ns1.windows.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.windows.com.
@	IN	A		180.1.1.140
time	IN	A		180.1.1.140
ns1	IN	A		198.41.0.4
