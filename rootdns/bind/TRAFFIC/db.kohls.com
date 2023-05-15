;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.kohls.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.kohls.com.
@	IN	MX	10	kohls.com.
@	IN	A		23.220.144.152
mail	IN	A		23.220.144.152
www	IN	A		23.220.144.152
ns1	IN	A		198.41.0.4
