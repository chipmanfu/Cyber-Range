;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.lonelyplanet.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.lonelyplanet.com.
@	IN	MX	10	lonelyplanet.com.
@	IN	A		13.249.85.5
mail	IN	A		13.249.85.5
www	IN	A		13.249.85.5
ns1	IN	A		198.41.0.4
