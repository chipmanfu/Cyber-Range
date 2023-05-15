;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.shazam.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.shazam.com.
@	IN	MX	10	shazam.com.
@	IN	A		151.101.193.80
mail	IN	A		151.101.193.80
www	IN	A		151.101.193.80
ns1	IN	A		198.41.0.4
