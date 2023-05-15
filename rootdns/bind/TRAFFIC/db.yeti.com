;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.yeti.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.yeti.com.
@	IN	MX	10	yeti.com.
@	IN	A		204.2.48.200
mail	IN	A		204.2.48.200
www	IN	A		204.2.48.200
ns1	IN	A		198.41.0.4
