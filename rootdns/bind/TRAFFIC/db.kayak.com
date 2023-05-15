;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.kayak.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.kayak.com.
@	IN	MX	10	kayak.com.
@	IN	A		151.101.193.29
mail	IN	A		151.101.193.29
www	IN	A		151.101.193.29
ns1	IN	A		198.41.0.4
