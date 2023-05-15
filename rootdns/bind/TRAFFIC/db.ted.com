;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.ted.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.ted.com.
@	IN	MX	10	ted.com.
@	IN	A		151.101.194.133
mail	IN	A		151.101.194.133
www	IN	A		151.101.194.133
ns1	IN	A		198.41.0.4
