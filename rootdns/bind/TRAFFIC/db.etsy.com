;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.etsy.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.etsy.com.
@	IN	MX	10	etsy.com.
@	IN	A		23.78.8.22
mail	IN	A		23.78.8.22
www	IN	A		23.78.8.22
ns1	IN	A		198.41.0.4
