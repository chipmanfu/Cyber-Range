;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.gofundme.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.gofundme.com.
@	IN	MX	10	gofundme.com.
@	IN	A		13.249.85.35
mail	IN	A		13.249.85.35
www	IN	A		13.249.85.35
ns1	IN	A		198.41.0.4
