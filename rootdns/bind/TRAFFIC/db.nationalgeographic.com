;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.nationalgeographic.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.nationalgeographic.com.
@	IN	MX	10	nationalgeographic.com.
@	IN	A		13.249.85.105
mail	IN	A		13.249.85.105
www	IN	A		13.249.85.105
ns1	IN	A		198.41.0.4
