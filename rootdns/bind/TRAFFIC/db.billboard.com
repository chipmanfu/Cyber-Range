;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.billboard.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.billboard.com.
@	IN	MX	10	billboard.com.
@	IN	A		192.0.66.69
mail	IN	A		192.0.66.69
www	IN	A		192.0.66.69
ns1	IN	A		198.41.0.4
