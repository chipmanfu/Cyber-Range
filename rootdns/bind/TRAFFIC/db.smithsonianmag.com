;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.smithsonianmag.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.smithsonianmag.com.
@	IN	MX	10	smithsonianmag.com.
@	IN	A		104.22.6.9
mail	IN	A		104.22.6.9
www	IN	A		104.22.6.9
ns1	IN	A		198.41.0.4
