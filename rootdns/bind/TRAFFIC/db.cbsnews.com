;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.cbsnews.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.cbsnews.com.
@	IN	MX	10	cbsnews.com.
@	IN	A		146.75.77.188
mail	IN	A		146.75.77.188
www	IN	A		146.75.77.188
ns1	IN	A		198.41.0.4
