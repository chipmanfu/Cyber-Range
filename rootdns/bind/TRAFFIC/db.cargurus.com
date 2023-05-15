;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.cargurus.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.cargurus.com.
@	IN	MX	10	cargurus.com.
@	IN	A		151.101.194.55
mail	IN	A		151.101.194.55
www	IN	A		151.101.194.55
ns1	IN	A		198.41.0.4
