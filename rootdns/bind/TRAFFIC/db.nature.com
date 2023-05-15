;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.nature.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.nature.com.
@	IN	MX	10	nature.com.
@	IN	A		151.101.192.95
mail	IN	A		151.101.192.95
www	IN	A		151.101.192.95
ns1	IN	A		198.41.0.4
