;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.goodreads.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.goodreads.com.
@	IN	MX	10	goodreads.com.
@	IN	A		54.239.26.220
mail	IN	A		54.239.26.220
www	IN	A		54.239.26.220
ns1	IN	A		198.41.0.4
