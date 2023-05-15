;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.stackoverflow.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.stackoverflow.com.
@	IN	MX	10	stackoverflow.com.
@	IN	A		151.101.65.69
mail	IN	A		151.101.65.69
www	IN	A		151.101.65.69
ns1	IN	A		198.41.0.4
