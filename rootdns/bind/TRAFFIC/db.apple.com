;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.apple.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.apple.com.
@	IN	MX	10	apple.com.
@	IN	A		23.32.228.219
mail	IN	A		23.32.228.219
www	IN	A		23.32.228.219
ns1	IN	A		198.41.0.4
