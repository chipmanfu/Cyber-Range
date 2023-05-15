;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.discogs.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.discogs.com.
@	IN	MX	10	discogs.com.
@	IN	A		104.18.28.109
mail	IN	A		104.18.28.109
www	IN	A		104.18.28.109
ns1	IN	A		198.41.0.4
