;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.ign.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.ign.com.
@	IN	MX	10	ign.com.
@	IN	A		151.101.193.135
mail	IN	A		151.101.193.135
www	IN	A		151.101.193.135
ns1	IN	A		198.41.0.4
