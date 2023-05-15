;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.poshmark.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.poshmark.com.
@	IN	MX	10	poshmark.com.
@	IN	A		13.249.85.118
mail	IN	A		13.249.85.118
www	IN	A		13.249.85.118
ns1	IN	A		198.41.0.4
