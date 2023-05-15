;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.imdb.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.imdb.com.
@	IN	MX	10	imdb.com.
@	IN	A		13.249.89.64
mail	IN	A		13.249.89.64
www	IN	A		13.249.89.64
ns1	IN	A		198.41.0.4
