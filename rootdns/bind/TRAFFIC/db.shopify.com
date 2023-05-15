;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.shopify.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.shopify.com.
@	IN	MX	10	shopify.com.
@	IN	A		185.146.173.20
mail	IN	A		185.146.173.20
www	IN	A		185.146.173.20
ns1	IN	A		198.41.0.4
