;Traffic-WebHost
$TTL	86400
@	IN	SOA	@	ns1.denofgeek.com. 42 3H 15M 1W 1D
@	IN	NS		ns1.denofgeek.com.
@	IN	MX	10	denofgeek.com.
@	IN	A		192.0.66.88
mail	IN	A		192.0.66.88
www	IN	A		192.0.66.88
ns1	IN	A		198.41.0.4
