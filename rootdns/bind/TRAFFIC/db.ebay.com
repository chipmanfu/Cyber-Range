;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.ebay.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.ebay.com.
@	IN	MX	10	ebay.com.
@	IN	A		23.11.225.24
mail	IN	A		23.11.225.24
www	IN	A		23.11.225.24
ns1	IN	A		198.41.0.4
