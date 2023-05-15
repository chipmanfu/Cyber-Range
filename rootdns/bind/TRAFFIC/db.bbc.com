;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.bbc.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.bbc.com.
@	IN	MX	10	bbc.com.
@	IN	A		151.101.192.81
mail	IN	A		151.101.192.81
www	IN	A		151.101.192.81
ns1	IN	A		198.41.0.4
