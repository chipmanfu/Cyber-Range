;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.espn.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.espn.com.
@	IN	MX	10	espn.com.
@	IN	A		13.249.85.103
mail	IN	A		13.249.85.103
www	IN	A		13.249.85.103
ns1	IN	A		198.41.0.4
