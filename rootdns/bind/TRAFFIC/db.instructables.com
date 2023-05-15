;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.instructables.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.instructables.com.
@	IN	MX	10	instructables.com.
@	IN	A		151.101.193.105
mail	IN	A		151.101.193.105
www	IN	A		151.101.193.105
ns1	IN	A		198.41.0.4
