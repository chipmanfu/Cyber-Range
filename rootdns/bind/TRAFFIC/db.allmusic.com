;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.allmusic.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.allmusic.com.
@	IN	MX	10	allmusic.com.
@	IN	A		130.211.21.62
mail	IN	A		130.211.21.62
www	IN	A		130.211.21.62
ns1	IN	A		198.41.0.4
