;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.spacex.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.spacex.com.
@	IN	MX	10	spacex.com.
@	IN	A		151.101.194.134
mail	IN	A		151.101.194.134
www	IN	A		151.101.194.134
ns1	IN	A		198.41.0.4
