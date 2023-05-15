;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.superpages.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.superpages.com.
@	IN	MX	10	superpages.com.
@	IN	A		151.138.150.150
mail	IN	A		151.138.150.150
www	IN	A		151.138.150.150
ns1	IN	A		198.41.0.4
