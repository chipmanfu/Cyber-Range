;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.addthis.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.addthis.com.
@	IN	MX	10	addthis.com.
@	IN	A		23.11.224.121
mail	IN	A		23.11.224.121
www	IN	A		23.11.224.121
ns1	IN	A		198.41.0.4
