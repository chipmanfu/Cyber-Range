;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.rottentomatoes.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.rottentomatoes.com.
@	IN	MX	10	rottentomatoes.com.
@	IN	A		23.8.79.116
mail	IN	A		23.8.79.116
www	IN	A		23.8.79.116
ns1	IN	A		198.41.0.4
