;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.cvs.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.cvs.com.
@	IN	MX	10	cvs.com.
@	IN	A		23.219.48.199
mail	IN	A		23.219.48.199
www	IN	A		23.219.48.199
ns1	IN	A		198.41.0.4
