;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.forbes.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.forbes.com.
@	IN	MX	10	forbes.com.
@	IN	A		151.101.193.55
mail	IN	A		151.101.193.55
www	IN	A		151.101.193.55
ns1	IN	A		198.41.0.4
