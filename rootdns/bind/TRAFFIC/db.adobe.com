;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.adobe.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.adobe.com.
@	IN	MX	10	adobe.com.
@	IN	A		23.48.99.84
mail	IN	A		23.48.99.84
www	IN	A		23.48.99.84
ns1	IN	A		198.41.0.4
