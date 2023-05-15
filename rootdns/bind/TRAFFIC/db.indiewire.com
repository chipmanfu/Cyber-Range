;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.indiewire.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.indiewire.com.
@	IN	MX	10	indiewire.com.
@	IN	A		192.0.66.2
mail	IN	A		192.0.66.2
www	IN	A		192.0.66.2
ns1	IN	A		198.41.0.4
