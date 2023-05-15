;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.redbull.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.redbull.com.
@	IN	MX	10	redbull.com.
@	IN	A		23.11.225.74
mail	IN	A		23.11.225.74
www	IN	A		23.11.225.74
ns1	IN	A		198.41.0.4
