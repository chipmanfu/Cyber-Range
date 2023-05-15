;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.hopkinsmedicine.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.hopkinsmedicine.com.
@	IN	MX	10	hopkinsmedicine.com.
@	IN	A		128.220.192.230
mail	IN	A		128.220.192.230
www	IN	A		128.220.192.230
ns1	IN	A		198.41.0.4
