;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.ndtv.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.ndtv.com.
@	IN	MX	10	ndtv.com.
@	IN	A		23.11.225.25
mail	IN	A		23.11.225.25
www	IN	A		23.11.225.25
ns1	IN	A		198.41.0.4
