;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.camelbak.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.camelbak.com.
@	IN	MX	10	camelbak.com.
@	IN	A		104.17.6.17
mail	IN	A		104.17.6.17
www	IN	A		104.17.6.17
ns1	IN	A		198.41.0.4
