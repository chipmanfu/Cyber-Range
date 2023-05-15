;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.abebooks.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.abebooks.com.
@	IN	MX	10	abebooks.com.
@	IN	A		13.249.85.69
mail	IN	A		13.249.85.69
www	IN	A		13.249.85.69
ns1	IN	A		198.41.0.4
