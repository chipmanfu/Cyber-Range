;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.scribd.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.scribd.com.
@	IN	MX	10	scribd.com.
@	IN	A		151.101.194.152
mail	IN	A		151.101.194.152
www	IN	A		151.101.194.152
ns1	IN	A		198.41.0.4
