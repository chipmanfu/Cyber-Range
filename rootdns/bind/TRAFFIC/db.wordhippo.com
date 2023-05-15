;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.wordhippo.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.wordhippo.com.
@	IN	MX	10	wordhippo.com.
@	IN	A		173.231.200.231
mail	IN	A		173.231.200.231
www	IN	A		173.231.200.231
ns1	IN	A		198.41.0.4
