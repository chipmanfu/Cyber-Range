;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.indeed.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.indeed.com.
@	IN	MX	10	indeed.com.
@	IN	A		162.159.130.67
mail	IN	A		162.159.130.67
www	IN	A		162.159.130.67
ns1	IN	A		198.41.0.4
