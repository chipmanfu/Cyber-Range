;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.reddit.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.reddit.com.
@	IN	MX	10	reddit.com.
@	IN	A		151.101.193.140
mail	IN	A		151.101.193.140
www	IN	A		151.101.193.140
ns1	IN	A		198.41.0.4
